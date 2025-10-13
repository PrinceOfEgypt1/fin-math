#!/usr/bin/env bash
set -Eeuo pipefail
BLUE='\033[0;34m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
log_i(){ echo -e "${BLUE}ℹ️  $1${NC}"; }
log_ok(){ echo -e "${GREEN}✅ $1${NC}"; }
log_e(){ echo -e "${RED}❌ $1${NC}"; }
REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

log_i "Typecheck engine"; pnpm -C "$REPO" -F @finmath/engine typecheck
log_i "Golden files";    pnpm -C "$REPO" -F @finmath/engine test:golden
if pnpm -C "$REPO/packages/api" run -s build >/dev/null 2>&1; then log_ok "API build OK"; else log_i "API build (opcional)"; fi
cnt=$(find "$REPO" \( -name "*bak*" -o -name "*backup*" -o -name "*.save" \) -type f | wc -l); [ "$cnt" -eq 0 ] || { log_e "Backups físicos encontrados ($cnt)"; exit 1; }
log_ok "Validação concluída"
