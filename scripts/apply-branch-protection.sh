#!/usr/bin/env bash
# =============================================================================
# apply-branch-protection.sh - Aplica políticas de protección de rama (IE5/IE6)
# -----------------------------------------------------------------------------
# Usa la API REST de GitHub para proteger las ramas main y develop,
# exigiendo que los checks obligatorios pasen antes de cualquier merge.
#
# Requisitos:
#   - gh CLI autenticado con scope 'repo' (o 'admin:repo_hook' para orgs)
#   - El repositorio debe existir en GitHub
#
# Uso:
#   GH_REPO=Tavotsu/RoTSu bash scripts/apply-branch-protection.sh
# =============================================================================
set -euo pipefail

REPO="${GH_REPO:-${GITHUB_REPOSITORY:-}}"
BRANCHES="${BRANCHES:-main develop}"

if [ -z "${REPO}" ]; then
  echo "ERROR: Define GH_REPO=owner/name o ejecuta desde GitHub Actions" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh CLI no está instalado" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/branch-protection.json"

if [ ! -f "${CONFIG_FILE}" ]; then
  echo "ERROR: No se encuentra ${CONFIG_FILE}" >&2
  exit 1
fi

for branch in ${BRANCHES}; do
  echo "Aplicando protección a rama '${branch}' de ${REPO}..."
  if gh api -X PUT \
    "repos/${REPO}/branches/${branch}/protection" \
    --input "${CONFIG_FILE}" \
    -H "Accept: application/vnd.github+json"; then
    echo "✓ Rama '${branch}' protegida correctamente"
  else
    echo "✗ Falló la protección de la rama '${branch}'" >&2
    exit 1
  fi
done

echo ""
echo "Protección de ramas aplicada exitosamente (IE5/IE6)."
echo "Checks obligatorios antes de merge:"
jq -r '.required_status_checks.contexts[]' "${CONFIG_FILE}" | sed 's/^/  - /'
