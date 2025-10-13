#!/usr/bin/env bash
set -Eeuo pipefail
REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
BLUE='\033[0;34m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
log(){ printf "%b%s%b\n" "$BLUE" "$*" "$NC"; }
err(){ printf "%b%s%b\n" "$RED" "$*" "$NC"; }

BR=$(git -C "$REPO" branch --show-current)
[[ $BR =~ ^sprint- ]] || { err "Branch atual não é de sprint ($BR)"; exit 1; }
./validar-sprint.sh
git -C "$REPO" checkout main
git -C "$REPO" pull --rebase origin main || true
git -C "$REPO" merge "$BR" --no-ff -m "chore: merge Sprint 2 (H9 Price API)"
git -C "$REPO" push origin main
git -C "$REPO" tag -a v0.2.0 -m "Sprint 2 (H9)"; git -C "$REPO" push origin v0.2.0
git -C "$REPO" branch -d "$BR" || true
log "Finalizado 🎉"
