#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh - Setup inicial de infraestructura AWS via Terraform
# -----------------------------------------------------------------------------
# Automatiza el primer despliegue de:
#   - VPC + Subnet + IGW
#   - EC2 t3.small Spot con Kubernetes (kubeadm) preinstalado
#   - ECR repository
#   - IAM user para GitHub Actions
#   - Descarga del kubeconfig
#
# Prerequisitos:
#   - AWS CLI configurado (aws configure)
#   - Terraform >= 1.7 instalado
#   - Permisos para crear VPC, EC2, ECR, IAM en la cuenta
#
# Uso:
#   bash scripts/bootstrap.sh
# =============================================================================
set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_ok()    { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
log_warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
log_fail()  { printf "${RED}[FAIL]${NC} %s\n" "$1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TERRAFORM_DIR="${REPO_ROOT}/terraform"

# -----------------------------------------------------------------------------
# Verificar prerequisitos
# -----------------------------------------------------------------------------
check_prereqs() {
  log_info "Verificando prerequisitos..."

  if ! command -v aws >/dev/null 2>&1; then
    log_fail "AWS CLI no instalado. Instalar: https://aws.amazon.com/cli/"
    exit 1
  fi

  if ! command -v terraform >/dev/null 2>&1; then
    log_fail "Terraform no instalado. Instalar: https://developer.hashicorp.com/terraform/install"
    exit 1
  fi

  if ! aws sts get-caller-identity >/dev/null 2>&1; then
    log_fail "AWS CLI no autenticado. Ejecutar: aws configure"
    exit 1
  fi

  TF_VERSION=$(terraform version -json 2>/dev/null | jq -r '.terraform_version' 2>/dev/null || terraform version | head -1 | awk '{print $2}' | sed 's/v//')
  if ! printf '%s\n%s\n' "1.7.0" "$TF_VERSION" | sort -V -C; then
    log_fail "Terraform >= 1.7.0 requerido. Versión actual: $TF_VERSION"
    exit 1
  fi

  log_ok "Prerequisitos OK (AWS: $(aws sts get-caller-identity --query Arn --output text))"
}

# -----------------------------------------------------------------------------
# Configurar terraform.tfvars si no existe
# -----------------------------------------------------------------------------
setup_tfvars() {
  if [ -f "${TERRAFORM_DIR}/terraform.tfvars" ]; then
    log_info "terraform.tfvars ya existe, no se sobrescribe"
    return 0
  fi

  log_info "Creando terraform.tfvars desde el ejemplo..."

  read -rp "AWS Region [us-east-1]: " AWS_REGION
  AWS_REGION="${AWS_REGION:-us-east-1}"

  cat > "${TERRAFORM_DIR}/terraform.tfvars" <<EOF
aws_region         = "${AWS_REGION}"
project_name       = "rotsu"
environment        = "dev"
instance_type      = "t3.small"
use_spot           = true
spot_max_price     = "0.020"
ecr_repository_name = "rotsu/frontend"
github_actions_iam_name = "rotsu-github-actions"
# SSH deshabilitado por defecto. Para habilitar acceso SSH de debug,
# descomentar y pegar tu llave publica. Se recomienda usar SSM en su lugar.
enable_ssh_access  = false
# ssh_public_key    = ""
# allowed_ssh_cidr  = "0.0.0.0/0"
ssm_kubeconfig_name = "/rotsu/k8s/kubeconfig"
enable_remote_backend = false
EOF

  log_ok "terraform.tfvars creado en ${TERRAFORM_DIR}/"
}

# -----------------------------------------------------------------------------
# Terraform init + plan + apply
# -----------------------------------------------------------------------------
run_terraform() {
  log_info "Inicializando Terraform..."
  (cd "${TERRAFORM_DIR}" && terraform init -backend=false -input=false)

  log_info "Validando configuración..."
  (cd "${TERRAFORM_DIR}" && terraform validate)

  log_info "Generando plan (esto puede tardar)..."
  (cd "${TERRAFORM_DIR}" && terraform plan -out=tfplan -input=false)

  echo ""
  log_warn "Revisa el plan arriba. Se va a aplicar en 10 segundos."
  log_warn "Presiona Ctrl+C para abortar."
  sleep 10

  log_info "Aplicando infraestructura (puede tardar 10-15 min)..."
  log_info "kubeadm inicializa el cluster Kubernetes single-node; el kubeconfig se sube a SSM Parameter Store via SSM send-command."
  (cd "${TERRAFORM_DIR}" && terraform apply -input=false tfplan)
  rm -f "${TERRAFORM_DIR}/tfplan"

  log_ok "Infraestructura AWS provisionada y kubeconfig subido a SSM Parameter Store"
}

# -----------------------------------------------------------------------------
# Mostrar outputs importantes
# -----------------------------------------------------------------------------
show_outputs() {
  log_info "Outputs importantes:"

  (cd "${TERRAFORM_DIR}" && terraform output -json > /tmp/tf-outputs.json)

  K8S_IP=$(jq -r '.k8s_public_ip.value' /tmp/tf-outputs.json)
  ECR_URL=$(jq -r '.ecr_repository_url.value' /tmp/tf-outputs.json)
  APP_URL=$(jq -r '.app_url.value' /tmp/tf-outputs.json)
  GRAFANA_URL=$(jq -r '.grafana_url.value' /tmp/tf-outputs.json)
  PUSHGATEWAY_URL=$(jq -r '.pushgateway_url.value' /tmp/tf-outputs.json)

  cat <<EOF

  ${GREEN}=== URLS DE ACCESO ===${NC}
  App:          ${APP_URL}
  Grafana:      ${GRAFANA_URL} (admin / rotsu-admin)
  Pushgateway:  ${PUSHGATEWAY_URL}

  ${GREEN}=== VARIABLES PARA GITHUB SECRETS ===${NC}
  AWS_ACCESS_KEY_ID:       $(jq -r '.github_actions_access_key_id.value' /tmp/tf-outputs.json)
  AWS_SECRET_ACCESS_KEY:   $(jq -r '.github_actions_secret_access_key.value' /tmp/tf-outputs.json)
  AWS_REGION:              $(grep aws_region "${TERRAFORM_DIR}/terraform.tfvars" | cut -d'"' -f2)

  ${GREEN}=== KUBECONFIG ===${NC}
  Descargado en: ${TERRAFORM_DIR}/kubeconfig.yaml
  Usar: export KUBECONFIG=${TERRAFORM_DIR}/kubeconfig.yaml

EOF

  log_info "Próximos pasos:"
  echo "  1. Configurar los 7 secrets en GitHub (ver TAREAS_PENDIENTES.md)"
  echo "  2. Push a develop o main para que el workflow corra"
  echo "  3. Verificar el dashboard en ${GRAFANA_URL}"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
  log_info "RoTSu Bootstrap - Setup inicial de infraestructura AWS"
  echo ""

  check_prereqs
  setup_tfvars
  run_terraform
  show_outputs

  log_ok "Bootstrap completado. Ver TAREAS_PENDIENTES.md para los siguientes pasos."
}

main "$@"
