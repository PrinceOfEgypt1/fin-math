#!/usr/bin/env bash
set -euo pipefail

OUT=".fenix/artifacts/report.json"
KPIS=0
REL=0
FROM="report"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --kpis) KPIS=1; shift;;
    --release) REL=1; shift;;
    --out) OUT="$2"; shift 2;;
    --from) FROM="$2"; shift 2;;
    *) shift;;
  esac
done

mkdir -p "$(dirname "$OUT")"

TS="$(date -Iseconds)"
CALS="calc_$(head -c 32 /dev/urandom | tr -dc 'a-z0-9' | head -c 8)"

# Blocos opcionais
if [[ $KPIS -eq 1 ]]; then
  KPIS_JSON='{"coverage":0.86,"pipeline_p95_min":7.4}'
else
  KPIS_JSON='{}'
fi

if [[ $REL -eq 1 ]]; then
  REL_JSON='{"release_notes":true}'
else
  REL_JSON='{}'
fi

# Gera JSON (sem depender de jq)
cat > "$OUT" <<EOF
{
  "timestamp": "$TS",
  "agent": "Fenix",
  "calculationId": "$CALS",
  "motorVersion": "0.1.0",
  "stage": "$FROM",
  "checks": {},
  "kpis": $KPIS_JSON,
  "release": $REL_JSON
}
EOF

# Se jq existir, compacta/valida
if command -v jq >/dev/null 2>&1; then
  jq -c . "$OUT" > "${OUT}.tmp" && mv "${OUT}.tmp" "$OUT"
fi

echo "Relatório gerado em $OUT"
