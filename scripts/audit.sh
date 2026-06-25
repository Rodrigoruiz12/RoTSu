#!/usr/bin/env bash
# =============================================================================
# audit.sh - Script de auditoría automatizada de cumplimiento (IE5/IE6)
# -----------------------------------------------------------------------------
# Ejecuta validaciones de seguridad, calidad y cumplimiento normativo.
# Retorna exit 1 ante cualquier hallazgo crítico (interrumpe el pipeline).
# Retorna exit 0 si todas las validaciones son aceptables.
#
# Validaciones:
#   1. Dockerfile con hadolint (linter de Dockerfiles)
#   2. npm audit (vulnerabilidades de dependencias, severity high+)
#   3. license-checker (licencias no permitidas)
#   4. Detección de secretos en el repositorio (patrones comunes)
#   5. Verificación de .gitignore (cobertura de archivos sensibles)
# =============================================================================
set -euo pipefail

# Configuración
SEVERITY_THRESHOLD="high"
ALLOWED_LICENSES="MIT;ISC;Apache-2.0;BSD-2-Clause;BSD-3-Clause;0BSD;CC0-1.0;Unlicense;Python-2.0;MPL-2.0"
CRITICAL_FINDINGS=0
WARNINGS=0

# Colores para output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_ok()      { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
log_warn()    { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
log_fail()    { printf "${RED}[FAIL]${NC} %s\n" "$1"; }

# -----------------------------------------------------------------------------
# 1. Lint del Dockerfile con hadolint
# -----------------------------------------------------------------------------
audit_dockerfile() {
  log_info "Auditoría 1/5: Dockerfile (hadolint)"
  if ! command -v hadolint >/dev/null 2>&1; then
    log_warn "hadolint no instalado, se omite validación del Dockerfile"
    WARNINGS=$((WARNINGS + 1))
    return 0
  fi

  if hadolint Dockerfile --failure-threshold error; then
    log_ok "Dockerfile pasa validación hadolint"
  else
    log_fail "Dockerfile contiene errores críticos según hadolint"
    CRITICAL_FINDINGS=$((CRITICAL_FINDINGS + 1))
  fi
}

# -----------------------------------------------------------------------------
# 2. npm audit - vulnerabilidades de dependencias
# -----------------------------------------------------------------------------
audit_dependencies() {
  log_info "Auditoría 2/5: Dependencias npm (audit, severity >= ${SEVERITY_THRESHOLD})"

  if [ ! -f package.json ]; then
    log_fail "No se encontró package.json"
    CRITICAL_FINDINGS=$((CRITICAL_FINDINGS + 1))
    return 0
  fi

  # npm audit requiere un lockfile. Si no existe (entorno pnpm), se genera uno temporal.
  if [ ! -f package-lock.json ]; then
    log_info "Generando package-lock.json temporal para auditoría..."
    if ! npm install --package-lock-only --no-audit --no-fund >/dev/null 2>&1; then
      log_warn "No se pudo generar package-lock.json, se omite auditoría de dependencias"
      WARNINGS=$((WARNINGS + 1))
      return 0
    fi
  fi

  # npm audit devuelve exit code != 0 si hay vulnerabilidades del umbral indicado
  set +e
  npm audit --audit-level="${SEVERITY_THRESHOLD}" --omit=dev > /tmp/audit-output.txt 2>&1
  local audit_exit=$?
  set -e

  if [ ${audit_exit} -eq 0 ]; then
    log_ok "Sin vulnerabilidades de severidad >= ${SEVERITY_THRESHOLD}"
  else
    log_fail "Vulnerabilidades detectadas (severity >= ${SEVERITY_THRESHOLD}):"
    cat /tmp/audit-output.txt
    CRITICAL_FINDINGS=$((CRITICAL_FINDINGS + 1))
  fi
}

# -----------------------------------------------------------------------------
# 3. Verificación de licencias de dependencias
# -----------------------------------------------------------------------------
audit_licenses() {
  log_info "Auditoría 3/5: Licencias de dependencias"

  if ! command -v license-checker >/dev/null 2>&1; then
    if ! npx --yes license-checker --version >/dev/null 2>&1; then
      log_warn "license-checker no disponible, se omite validación de licencias"
      WARNINGS=$((WARNINGS + 1))
      return 0
    fi
    LC_CMD="npx --yes license-checker"
  else
    LC_CMD="license-checker"
  fi

  local tmp_licenses
  tmp_licenses=$(mktemp)
  ${LC_CMD} --summary --csv > "${tmp_licenses}" 2>/dev/null || true

  if [ ! -s "${tmp_licenses}" ]; then
    log_warn "No se pudo generar reporte de licencias"
    WARNINGS=$((WARNINGS + 1))
    rm -f "${tmp_licenses}"
    return 0
  fi

  log_info "Licencias detectadas:"
  cat "${tmp_licenses}"

  # Verificar licencias no permitidas (copyleft fuerte)
  local forbidden="GPL-2.0;GPL-3.0;AGPL-3.0;LGPL-2.1;LGPL-3.0;CC-BY-NC;CC-BY-SA-4.0"
  local found_forbidden=0
  IFS=';' read -ra FORBIDDEN_ARRAY <<< "${forbidden}"
  for lic in "${FORBIDDEN_ARRAY[@]}"; do
    if grep -qi "${lic}" "${tmp_licenses}"; then
      log_fail "Licencia no permitida detectada: ${lic}"
      found_forbidden=1
    fi
  done

  if [ ${found_forbidden} -eq 0 ]; then
    log_ok "No se detectaron licencias copyleft restrictivas"
  else
    CRITICAL_FINDINGS=$((CRITICAL_FINDINGS + 1))
  fi

  rm -f "${tmp_licenses}"
}

# -----------------------------------------------------------------------------
# 4. Detección de secretos en el repositorio
# -----------------------------------------------------------------------------
audit_secrets() {
  log_info "Auditoría 4/5: Detección de secretos en el código"

  local secret_patterns=(
    "AKIA[0-9A-Z]{16}"
    "aws_secret_access_key\s*=\s*[A-Za-z0-9/+=]{40}"
    "sk-[A-Za-z0-9]{20,}"
    "gh[pousr]_[A-Za-z0-9]{36}"
    "-----BEGIN [A-Z]+ PRIVATE KEY-----"
    "password\s*=\s*[\"'][^\"']{8,}[\"']"
    "api[_-]?key\s*=\s*[\"'][^\"']{16,}[\"']"
  )

  local found_secrets=0
  local search_paths=("src" "k8s" "terraform" "scripts" ".github")

  for pattern in "${secret_patterns[@]}"; do
    for path in "${search_paths[@]}"; do
      if [ -d "${path}" ]; then
        # Excluir directorios generados (.terraform, node_modules, coverage)
        if grep -rEn --exclude-dir=".terraform" --exclude-dir="node_modules" --exclude-dir="coverage" \
            "${pattern}" "${path}" 2>/dev/null | \
            grep -v -E "(placeholder|example|REPLACE|<your|YOUR_|\$\{)"; then
          log_fail "Posible secreto detectado (patrón: ${pattern})"
          found_secrets=1
        fi
      fi
    done
  done

  if [ ${found_secrets} -eq 0 ]; then
    log_ok "No se detectaron secretos expuestos en el código"
  else
    CRITICAL_FINDINGS=$((CRITICAL_FINDINGS + 1))
  fi
}

# -----------------------------------------------------------------------------
# 5. Verificación de .gitignore
# -----------------------------------------------------------------------------
audit_gitignore() {
  log_info "Auditoría 5/5: Cobertura de .gitignore"

  if [ ! -f .gitignore ]; then
    log_fail "No se encontró .gitignore"
    CRITICAL_FINDINGS=$((CRITICAL_FINDINGS + 1))
    return 0
  fi

  local required_entries=("node_modules" ".env" "dist" "coverage" "*.tfstate" ".terraform/")
  local missing=0
  for entry in "${required_entries[@]}"; do
    if ! grep -q "^${entry}" .gitignore; then
      log_warn "Entrada faltante en .gitignore: ${entry}"
      missing=$((missing + 1))
    fi
  done

  # tfvars no debe estar trackeado (puede contener secrets)
  if grep -q "\.tfvars$" .gitignore; then
    log_ok "*.tfvars correctamente ignorado"
  else
    log_warn "*.tfvars no está en .gitignore (recomendado para evitar secretos)"
    missing=$((missing + 1))
  fi

  if [ ${missing} -eq 0 ]; then
    log_ok ".gitignore cubre todos los patrones sensibles requeridos"
  else
    WARNINGS=$((WARNINGS + missing))
  fi
}

# -----------------------------------------------------------------------------
# Resumen final
# -----------------------------------------------------------------------------
summary() {
  echo ""
  echo "=========================================="
  echo "  RESUMEN DE AUDITORÍA"
  echo "=========================================="
  printf "  Hallazgos críticos: %s\n" "${CRITICAL_FINDINGS}"
  printf "  Advertencias:       %s\n" "${WARNINGS}"
  echo "=========================================="

  if [ ${CRITICAL_FINDINGS} -gt 0 ]; then
    log_fail "AUDITORÍA REPROBADA - ${CRITICAL_FINDINGS} hallazgo(s) crítico(s)"
    log_fail "El pipeline se detiene para proteger el entorno productivo (IE6)"
    exit 1
  fi

  if [ ${WARNINGS} -gt 0 ]; then
    log_warn "AUDITORÍA APROBADA CON OBSERVACIONES - ${WARNINGS} advertencia(s)"
  else
    log_ok "AUDITORÍA APROBADA - cumplimiento normativo verificado"
  fi
  exit 0
}

# -----------------------------------------------------------------------------
# Ejecución principal
# -----------------------------------------------------------------------------
main() {
  log_info "Iniciando auditoría automatizada de cumplimiento - $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""

  audit_dockerfile
  audit_dependencies
  audit_licenses
  audit_secrets
  audit_gitignore

  summary
}

main "$@"
