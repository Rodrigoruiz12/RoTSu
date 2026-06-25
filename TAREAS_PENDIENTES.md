# Tareas Pendientes - RoTSu ev3.md

Este documento lista las tareas que el equipo debe completar manualmente para
activar completamente la infraestructura de observabilidad y cumplimiento.

Las tareas ya automatizadas en el código no aparecen aquí (CI/CD, Terraform,
manifiestos K8s, tests, audit script, etc.).

---

## ⚠️ IMPORTANTE: Flujo del Primer Deploy

El workflow CI/CD actual está optimizado para **deploys a partir del segundo
push a `main`**. El **primer deploy** debe hacerse **localmente** porque hay
dependencias circulares:

```
Primer deploy (local):
  - bash scripts/bootstrap.sh  →  terraform apply crea VPC, EC2, ECR, IAM
  - El equipo captura outputs (AWS_ACCESS_KEY_ID, etc.)
  - El equipo configura GitHub Secrets

Segundo deploy en adelante (CI/CD):
  - Push a main dispara el workflow
  - terraform-apply hace update (no create)
  - deploy-k8s despliega la app
```

Si el equipo intenta hacer push a `main` ANTES del bootstrap local, el job
`build-and-push` fallará porque ECR aún no existe.

---

## Tarea 1: Configurar Secrets en GitHub

Ir a: `Settings → Secrets and variables → Actions → New repository secret`

| Secret | Valor | Fuente |
|--------|-------|--------|
| `AWS_ACCESS_KEY_ID` | Access Key del IAM `rotsu-github-actions` | Output de `terraform apply`: `github_actions_access_key_id` |
| `AWS_SECRET_ACCESS_KEY` | Secret Access Key | Output de `terraform apply`: `github_actions_secret_access_key` |
| `AWS_REGION` | Región AWS (ej: `us-east-1`) | La misma que `terraform.tfvars` |
| `SONAR_TOKEN` | Token de SonarCloud | https://sonarcloud.io/account/security |
| `SNYK_TOKEN` | Token de Snyk | https://app.snyk.io/account |

> **Nota**: Ya no se requiere `SSH_PUBLIC_KEY` ni `K3S_TOKEN` - el proyecto usa **AWS SSM Session Manager** y **kubeadm** (la herramienta oficial de Kubernetes) en lugar de k3s.

**Tiempo estimado**: 5-10 min

---

## Tarea 2: Vincular SonarCloud

1. Crear cuenta en https://sonarcloud.io con la org de GitHub
2. Crear nuevo proyecto: `rotsu_frontend` (debe coincidir con `sonar.projectKey` en `sonar-project.properties`)
3. Vincular el repositorio `Tavotsu/RoTSu`
4. El token se genera en My Account → Security → Generate Token
5. Actualizar `sonar.organization` en `sonar-project.properties` con tu org de SonarCloud

**Tiempo estimado**: 5-10 min

---

## Tarea 3: Primer Despliegue de Infraestructura (BOOTSTRAP LOCAL)

> **Crítico**: este paso se hace UNA vez, en local, con AWS CLI configurado.
> Después de esto, el workflow CI/CD se encarga de todo.

```bash
# 1. Configurar AWS CLI con las credenciales de AWS Academy Learner Lab
aws configure
# AWS Access Key ID:     <la del laboratorio>
# AWS Secret Access Key: <la del laboratorio>
# Default region:        us-east-1 (o la que asigne AWS Academy)
# Default output:        json

# 2. Bootstrap (crea terraform.tfvars, valida, plan, apply)
bash scripts/bootstrap.sh
# Confirmar con "yes" cuando pregunte el plan
# Esperar 10-15 min mientras:
#   - Crea VPC, EC2, ECR, IAM
#   - La EC2 se inicializa (cloud-init: kubeadm, kubectl, flannel)
#   - Terraform sube el kubeconfig a SSM Parameter via SSM send-command

# 3. Capturar los outputs
cd terraform
terraform output -json > /tmp/outputs.json
cat /tmp/outputs.json | jq '.'

# IMPORTANTE: copiar estos valores para GitHub Secrets:
# - github_actions_access_key_id       → AWS_ACCESS_KEY_ID
# - github_actions_secret_access_key   → AWS_SECRET_ACCESS_KEY (sensitive)
# - ssm_session_command                → para debug si necesitas conectarte a la EC2

# 4. Verificar que el cluster K8s está operativo (via SSM)
INSTANCE_ID=$(terraform output -raw k8s_instance_id)
aws ssm start-session --target $INSTANCE_ID
# Dentro de la sesión: kubectl get nodes
# Salir: exit
```

**Costo estimado AWS Academy ($20)**: ~$0.10/día en Spot t3.small, alcanza para ~5 semanas.

**Tiempo estimado**: 15-20 min

---

## Tarea 4: Configurar Branch Protection (Recomendado, no bloqueante)

El JSON con la configuración (`scripts/branch-protection.json`) y el script
(`scripts/apply-branch-protection.sh`) ya están en el repo. Solo falta ejecutarlo
una vez con permisos de admin.

**Opción A - Vía script** (requiere `gh` autenticado):
```bash
gh auth login
GH_REPO=Tavotsu/RoTSu bash scripts/apply-branch-protection.sh
```

**Opción B - Vía UI de GitHub**:
1. Ir a `Settings → Branches → Add rule`
2. Branch name pattern: `main` (repetir para `develop`)
3. Activar:
   - ✅ Require a pull request before merging (1 aprobación)
   - ✅ Require status checks: `build-and-test`, `sonarcloud`, `snyk-security`, `audit-compliance`
   - ✅ Require linear history
   - ✅ Do not allow force pushes
   - ✅ Do not allow deletions
   - ✅ Include administrators

**Tiempo estimado**: 5-10 min

---

## Tarea 5: Reflexiones Individuales (Sección 12 del README)

Abrir `README.md` → Sección 12 "Conclusiones" → Cada integrante redacta su
reflexión personal sobre aprendizaje y contribución. **Sin apoyo de IA**
según reglamento de la evaluación.

---

## Tarea 6: Verificación Post-Despliegue

Tras el primer bootstrap, verificar que todo funciona:

```bash
# 1. Verificar cluster K8s
INSTANCE_ID=$(cd terraform && terraform output -raw k8s_instance_id)
aws ssm send-command \
  --instance-ids "$INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["sudo kubectl get nodes -o wide"]' \
  --output text --query 'Command.CommandId'
# Esperar 5s, luego:
aws ssm get-command-invocation \
  --command-id "<CMD_ID>" \
  --instance-id "$INSTANCE_ID" \
  --query 'StandardOutputContent' --output text

# 2. Desplegar la app + monitoring (en local, una vez)
cd terraform/k8s
terraform init
terraform apply
# Esperar 3-5 min para que Helm instale todo

# 3. Verificar acceso a la app y dashboards
K8S_IP=$(cd ../terraform && terraform output -raw k8s_public_ip)
echo "App:        http://$K8S_IP:30080"
echo "Grafana:    http://$K8S_IP:30100 (admin/rotsu-admin)"
echo "Pushgateway:http://$K8S_IP:9091"
curl -f http://$K8S_IP:30080   # App
curl -f http://$K8S_IP:30100   # Grafana

# 4. Verificar pods del monitoring (via SSM)
aws ssm send-command \
  --instance-ids "$INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["sudo kubectl -n monitoring get pods"]' \
  --output text --query 'Command.CommandId'
```

---

## Tarea 7: Forzar Falla del Pipeline (IE6)

Para demostrar que el pipeline se detiene ante una falla crítica:

1. **Falla por cobertura**: bajar el threshold en `vitest.config.ts` a 95% (con 98% actual) → el workflow falla en `build-and-test`
2. **Falla por Snyk**: añadir una dependencia con vulnerabilidad crítica conocida → `snyk-security` falla
3. **Falla por SonarCloud**: introducir un code smell severo → `sonarcloud` quality gate falla
4. **Falla por audit**: añadir un console.log con un "password" hardcoded → `audit-compliance` falla
5. **Falla por branch protection**: con los checks requeridos, intentar mergear un PR con uno de los checks fallando → el merge se rechaza

---

## Soporte

Cualquier duda consultar el README principal (secciones 9, 10 y 11) o abrir un
issue en el repositorio.
