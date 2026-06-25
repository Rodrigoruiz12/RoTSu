#!/usr/bin/env bash
# =============================================================================
# publish-ci-metrics.sh - Publica métricas del pipeline CI/CD a Pushgateway
# -----------------------------------------------------------------------------
# Permite que el dashboard Grafana (IE3) visualice:
#   - Tiempo de despliegue (rot_su_deploy_duration_seconds)
#   - Cobertura de pruebas (rotsu_test_coverage_percent{type=...})
#   - Resultado del pipeline (rotsu_pipeline_result{status=...})
#   - Errores registrados en el último run (rotsu_pipeline_errors_total)
#
# Uso:
#   publish-ci-metrics.sh --pushgateway-url=http://pushgateway:9091 \
#                         --deploy-duration=120 \
#                         --coverage-lines=98 \
#                         --coverage-branches=91 \
#                         --coverage-functions=80 \
#                         --pipeline-status=success \
#                         --errors=0
# =============================================================================
set -euo pipefail

# Valores por defecto
PUSHGATEWAY_URL="${PUSHGATEWAY_URL:-http://localhost:9091}"
DEPLOY_DURATION="${DEPLOY_DURATION:-0}"
COVERAGE_LINES="${COVERAGE_LINES:-0}"
COVERAGE_BRANCHES="${COVERAGE_BRANCHES:-0}"
COVERAGE_FUNCTIONS="${COVERAGE_FUNCTIONS:-0}"
COVERAGE_STATEMENTS="${COVERAGE_STATEMENTS:-0}"
PIPELINE_STATUS="${PIPELINE_STATUS:-unknown}"
ERRORS="${ERRORS:-0}"
JOB_NAME="rotsu-ci"
INSTANCE="${INSTANCE:-github-actions}"

# Parsear argumentos
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pushgateway-url=*) PUSHGATEWAY_URL="${1#*=}"; shift ;;
    --deploy-duration=*) DEPLOY_DURATION="${1#*=}"; shift ;;
    --coverage-lines=*) COVERAGE_LINES="${1#*=}"; shift ;;
    --coverage-branches=*) COVERAGE_BRANCHES="${1#*=}"; shift ;;
    --coverage-functions=*) COVERAGE_FUNCTIONS="${1#*=}"; shift ;;
    --coverage-statements=*) COVERAGE_STATEMENTS="${1#*=}"; shift ;;
    --pipeline-status=*) PIPELINE_STATUS="${1#*=}"; shift ;;
    --errors=*) ERRORS="${1#*=}"; shift ;;
    --job=*) JOB_NAME="${1#*=}"; shift ;;
    --instance=*) INSTANCE="${1#*=}"; shift ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "Argumento desconocido: $1" >&2; exit 1 ;;
  esac
done

# Construir payload de métricas
METRICS=$(cat <<EOF
# TYPE rotsu_deploy_duration_seconds gauge
rotsu_deploy_duration_seconds ${DEPLOY_DURATION}
# TYPE rotsu_test_coverage_percent gauge
rotsu_test_coverage_percent{type="lines"} ${COVERAGE_LINES}
rotsu_test_coverage_percent{type="branches"} ${COVERAGE_BRANCHES}
rotsu_test_coverage_percent{type="functions"} ${COVERAGE_FUNCTIONS}
rotsu_test_coverage_percent{type="statements"} ${COVERAGE_STATEMENTS}
# TYPE rotsu_pipeline_result gauge
rotsu_pipeline_result{status="${PIPELINE_STATUS}"} 1
# TYPE rotsu_pipeline_errors_total counter
rotsu_pipeline_errors_total ${ERRORS}
EOF
)

# Publicar a Pushgateway
URL="${PUSHGATEWAY_URL}/metrics/job/${JOB_NAME}/instance/${INSTANCE}"

echo "Publicando métricas CI a: ${URL}"
echo "${METRICS}" | curl --data-binary @- -X POST "${URL}" -fsS \
  -H "Content-Type: text/plain; version=0.0.4; charset=utf-8"

echo ""
echo "Métricas publicadas:"
echo "${METRICS}"
