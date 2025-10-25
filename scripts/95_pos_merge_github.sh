#!/usr/bin/env bash
set -euo pipefail

echo "⬇️  Sync main"
git switch main >/dev/null 2>&1 || true
git fetch origin
git reset --hard origin/main

echo
echo "🧹 Clean merged local branches"
git fetch -p origin
git branch --merged main | grep -vE '^\*|main$' | xargs -r git branch -d || true

echo
echo "🧹 (opcional) apagar remotas antigas"
# git push origin --delete sprint-2 || true
# git push origin --delete feat/h15-irr-tir-com-brent || true

echo
echo "🧪 Fênix smoke local"
./56_verify_fenix_local.sh || true

echo
echo "📌 HEAD em: $(git rev-parse --short HEAD)"
git --no-pager log --oneline -n 5
echo "✅ pós-merge ok."
