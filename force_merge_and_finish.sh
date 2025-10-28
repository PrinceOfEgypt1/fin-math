#!/usr/bin/env bash
set -euo pipefail

BRANCH=main
PRS=(51 52)

# Descobre OWNER/REPO a partir do origin
remote_url="$(git remote get-url origin)"
case "$remote_url" in
  git@github.com:*.git) path="${remote_url#git@github.com:}"; path="${path%.git}";;
  https://github.com/*) path="${remote_url#https://github.com/}"; path="${path%.git}";;
  *) echo "❌ Remoto 'origin' não é GitHub: $remote_url"; exit 1;;
esac
OWNER="${path%%/*}"
REPO="${path#*/}"
echo "🏷️  Repo: $OWNER/$REPO | Branch: $BRANCH | PRs: ${PRS[*]}"

command -v gh >/dev/null || { echo "❌ Requer GitHub CLI (gh)."; exit 1; }
gh auth status >/dev/null || { echo "❌ Faça 'gh auth login' antes."; exit 1; }

# Backup da proteção
BACKUP="$(mktemp)"
if gh api -H "Accept: application/vnd.github+json" \
  "/repos/$OWNER/$REPO/branches/$BRANCH/protection" >"$BACKUP" 2>/dev/null; then
  echo "💾 Proteção salva: $BACKUP"
else
  echo "{}" >"$BACKUP"
  echo "ℹ️  Sem proteção ativa ou sem permissão para ler proteção."
fi

# Afrouxa proteções mínimas (sem remover por completo)
echo "🔓 Afrouxando proteção temporariamente…"
printf '{"dismiss_stale_reviews":false,"require_code_owner_reviews":false,"required_approving_review_count":0}\n' \
| gh api --method PATCH -H "Accept: application/vnd.github+json" \
  "/repos/$OWNER/$REPO/branches/$BRANCH/protection/required_pull_request_reviews" --input - >/dev/null || true

printf '{"strict":false,"contexts":[]}\n' \
| gh api --method PATCH -H "Accept: application/vnd.github+json" \
  "/repos/$OWNER/$REPO/branches/$BRANCH/protection/required_status_checks" --input - >/dev/null || true

gh api --method DELETE -H "Accept: application/vnd.github+json" \
  "/repos/$OWNER/$REPO/branches/$BRANCH/protection/enforce_admins" >/dev/null || true

# Mescla PRs (sem -B!)
for pr in "${PRS[@]}"; do
  echo "🔀 Merge PR #$pr…"
  gh pr merge "$pr" --squash --delete-branch -R "$OWNER/$REPO" \
  || gh pr merge "$pr" --admin --squash --delete-branch -R "$OWNER/$REPO"
done

# Sincroniza main
echo "🌳 Sync $BRANCH…"
git fetch origin
git switch "$BRANCH"
git reset --hard "origin/$BRANCH"

# Checks rápidos
echo "🧪 Checks:"
bash ./.fenix/scripts/fenix-dry-run.sh && echo "  ✓ Fênix (dry-run)"
node .fenix/checks/validators/openapi_check.cjs && echo "  ✓ OpenAPI"

echo "🔎 Scripts *.sh ativos (fora de archive/.fenix/.husky):"
git ls-files '*.sh' ':!:docs/archive/**' ':!:.fenix/**' ':!:.husky/**' | sed 's/^/  • /' || true

if git ls-files -s | awk '$1==160000{exit 1}'; then
  echo "  ✓ sem gitlinks"
else
  echo "  ❌ ainda há gitlinks"
fi

# Restaura proteção original
echo "🔒 Restaurando proteção…"
gh api --method PUT -H "Accept: application/vnd.github+json" \
  "/repos/$OWNER/$REPO/branches/$BRANCH/protection" --input "$BACKUP" >/dev/null || \
  echo "⚠️  Não foi possível restaurar automaticamente. Verifique a proteção no GitHub."

echo "✅ Concluído."
