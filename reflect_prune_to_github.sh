#!/usr/bin/env bash
# reflect_prune_to_github.sh
# Reflete no GitHub o commit com as deleções já realizadas (412 arquivos).
# - Faz sanity checks
# - Faz push do branch atual para origin
# - Se não for "main", tenta abrir um PR automaticamente (se "gh" estiver disponível)

set -euo pipefail

# 1) Checagens básicas
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "❌ Não é um repositório Git."; exit 1; }
REMOTE_URL="$(git remote get-url origin 2>/dev/null || true)"
[[ -n "${REMOTE_URL}" ]] || { echo "❌ Remoto 'origin' não configurado."; exit 1; }

# 2) Estado e branch atual
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
AHEAD="$(git rev-list --left-right --count origin/${BRANCH}...HEAD 2>/dev/null | awk '{print $1}' || echo 0)"
DIRTY="$(git status --porcelain | wc -l | tr -d ' ')"

echo "📦 Repo   : $(basename "$(pwd)")"
echo "🌿 Branch : ${BRANCH}"
echo "🔗 Origin : ${REMOTE_URL}"

# 3) Garante que não há alterações não commitadas (evita push parcial)
if [[ "${DIRTY}" != "0" ]]; then
  echo "❌ Há alterações não commitadas. Faça commit antes."
  exit 1
fi

# 4) Busca remotos e valida branch remoto
git fetch origin --prune

# 5) Push do branch atual
echo "🚀 Enviando branch '${BRANCH}' para origin…"
git push -u origin "${BRANCH}"

# 6) Se branch não for main, tenta abrir PR automaticamente (opcional)
if [[ "${BRANCH}" != "main" ]]; then
  if command -v gh >/dev/null 2>&1; then
    echo "🧭 Criando Pull Request: main ← ${BRANCH}"
    gh pr create --fill --base main --head "${BRANCH}" || {
      echo "⚠️  Não consegui criar PR via gh. Abra manualmente no GitHub: compare main ← ${BRANCH}."
    }
  else
    echo "ℹ️  gh não encontrado. Abra o PR manualmente no GitHub (compare main ← ${BRANCH})."
  fi
else
  echo "✅ Branch 'main' atualizado no remoto."
fi

echo "✨ Pronto. As deleções já estão refletidas no repositório remoto."
