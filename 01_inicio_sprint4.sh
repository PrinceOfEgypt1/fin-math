#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="${REPO_DIR:-$HOME/workspace/fin-math}"
BRANCH_NAME="${BRANCH_NAME:-sprint-4}"

echo "🚀 =========================================="
echo "🚀 INICIANDO SPRINT 4 - BACKEND"
echo "🚀 =========================================="
echo ""

cd "$REPO_DIR"

echo "📂 PASSO 1: Sincronizando com GitHub..."
git fetch origin main || true

# Garante que estamos em main (sem tentar deletar branches em uso)
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD || echo main)"
if [[ "$CURRENT_BRANCH" != "main" ]]; then
  git switch main || git checkout main
fi

# Atualiza main
git pull --ff-only origin main || true

# Cria ou troca para a branch da sprint de maneira idempotente
if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
  echo "ℹ️  Branch '$BRANCH_NAME' já existe."
  if [[ "$(git rev-parse --abbrev-ref HEAD)" != "$BRANCH_NAME" ]]; then
    git switch "$BRANCH_NAME" || git checkout "$BRANCH_NAME"
    echo "✅ Alterado para a branch '$BRANCH_NAME'."
  else
    echo "✅ Já estamos na branch '$BRANCH_NAME'."
  fi
else
  git switch -c "$BRANCH_NAME" || git checkout -b "$BRANCH_NAME"
  echo "✅ Branch '$BRANCH_NAME' criada."
fi

echo ""
echo "🧹 PASSO 2: Limpando backups físicos..."
# Remove arquivos comuns de backup; não falha se não houver
find . \( -name '*.bak' -o -name '*~' -o -name '*.backup' -o -name '*.save' -o -name 'package.tmp' \) -print -delete || true
echo "✅ Backups físicos removidos (se existiam)."

echo ""
echo "🔍 PASSO 3: Validação inicial (leve)..."
# Evita falhar se não houver scripts específicos
if command -v pnpm >/dev/null 2>&1; then
  echo "   • pnpm detectado. (Validações completas serão feitas ao final da sprint.)"
else
  echo "   • pnpm não encontrado; instale para rodar testes locais."
fi

echo "✅ Ambiente pronto para a Sprint 4."
