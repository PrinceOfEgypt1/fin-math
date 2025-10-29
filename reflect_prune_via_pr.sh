#!/usr/bin/env bash
# reflect_prune_via_pr.sh
# Reflete deleções/modificações atuais criando um branch e um PR para main (respeitando branch protection).

set -euo pipefail

# 0) Pré-requisitos
command -v git >/dev/null || { echo "❌ git não encontrado"; exit 1; }
command -v gh  >/dev/null || { echo "❌ GitHub CLI (gh) não encontrado"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "❌ Não é um repositório Git"; exit 1; }
git remote get-url origin >/dev/null 2>&1 || { echo "❌ Remoto 'origin' não configurado"; exit 1; }

# 1) Garantir main limpa e atualizada
git switch main
git pull --ff-only
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "❌ Há mudanças pendentes em 'main'. Faça stash/commit antes."; exit 1;
fi

# 2) Criar branch de trabalho
TS="$(date +%Y%m%d-%H%M%S)"
BR="prune-${TS}"
git switch -c "$BR"

# (Opcional) Ignorar artefatos de teste se existirem
if [ -d "playwright-report" ] || [ -d "test-results" ]; then
  { echo; echo "playwright-report/"; echo "test-results/"; } >> .gitignore || true
fi

# 3) Indexar tudo (inclui deleções)
git add -A

# 4) Abortar se não houver mudanças
if git diff --cached --quiet; then
  echo "ℹ️ Nada a commitar. O repositório já reflete o prune."; exit 0;
fi

# 5) Métricas e commit
DEL_STAGED="$(git diff --cached --name-only --diff-filter=D | wc -l | tr -d ' ')"
ADD_STAGED="$(git diff --cached --name-only --diff-filter=A | wc -l | tr -d ' ')"
MOD_STAGED="$(git diff --cached --name-only --diff-filter=M | wc -l | tr -d ' ')"
COMMIT_MSG="chore(repo): refletir prune — ${DEL_STAGED:-0} deleções, ${ADD_STAGED:-0} adições, ${MOD_STAGED:-0} modificações"
git commit -m "$COMMIT_MSG"
git push -u origin "$BR"

# 6) Criar PR (tentando auto-merge por squash; se a política permitir ele será aplicado)
TITLE="refletir prune (${TS}) — ${DEL_STAGED}D/${ADD_STAGED}A/${MOD_STAGED}M"
BODY="$(cat <<'EOF'
Reflete a limpeza de arquivos (prune) no repositório.

**Resumo**
- Deleções: ${DEL_STAGED}
- Adições:  ${ADD_STAGED}
- Modificações: ${MOD_STAGED}

_Gerado pelo script `reflect_prune_via_pr.sh`._
EOF
)"
PR_URL="$(gh pr create --base main --title "$TITLE" --body "$BODY")" || {
  echo "❌ Falha ao criar PR via gh."; exit 1;
}

# 7) Tentar habilitar auto-merge (squash). Ignora erro se não permitido.
gh pr merge --squash --auto "$PR_URL" 2>/dev/null || true

echo "✅ PR criado: $PR_URL"
echo "📝 $COMMIT_MSG"
