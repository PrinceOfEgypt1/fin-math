#!/usr/bin/env bash
set -euo pipefail

# Uso:
#   .fenix/scripts/fenix-dry-run.sh --scope all|changed --plan <arquivo>
SCOPE="changed"
PLAN=".fenix/artifacts/plan.md"
ENFORCE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope) SCOPE="$2"; shift 2;;
    --plan) PLAN="$2"; shift 2;;
    --enforce) ENFORCE=1; shift;;
    *) shift;;
  esac
done

mkdir -p "$(dirname "$PLAN")"
echo "# Plano (dry-run)" > "$PLAN"
echo "- scope: $SCOPE" >> "$PLAN"
echo "- enforce: $ENFORCE" >> "$PLAN"

if [[ -f .fenix/checks/fenix-checks.config.json ]]; then
  echo -e "\n## Checks mapeados" >> "$PLAN"
  jq -r '.checks | to_entries[] | "- " + .key + ": " + .value' .fenix/checks/fenix-checks.config.json >> "$PLAN"
else
  echo "⚠️  Config .fenix/checks/fenix-checks.config.json não encontrada" >> "$PLAN"
fi

echo "Fênix (dry-run) finalizado: $PLAN"
