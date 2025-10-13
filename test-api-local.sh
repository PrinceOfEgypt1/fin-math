#!/usr/bin/env bash
set -Eeuo pipefail
have(){ command -v "$1" >/dev/null 2>&1; }
json(){ if have jq; then jq -r '.'; else cat; fi; }

if ! curl -s http://localhost:3001/health >/dev/null 2>&1; then
  pnpm -C "$(git rev-parse --show-toplevel 2>/dev/null || pwd)/packages/api" dev >/tmp/finmath-api.log 2>&1 &
  sleep 5
fi

echo "Health:"; curl -s http://localhost:3001/health | json
echo "POST /api/price:"; curl -s -X POST http://localhost:3001/api/price -H "Content-Type: application/json" -d '{"pv":10000,"rate":0.025,"n":12}' | json
