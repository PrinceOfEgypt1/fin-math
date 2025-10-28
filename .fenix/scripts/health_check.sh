#!/usr/bin/env bash
# health_check.sh — verificação pós-limpeza
set -Eeuo pipefail

echo "📍 Repo: $(pwd)"
test -d .git && test -f package.json || { echo "❌ Não parece a raiz do repo"; exit 1; }

# 1) Git sanity
echo "==> 🧭 Git status (limpeza de working tree)"
git status --porcelain=v1

echo "==> 🔗 Submódulos órfãos?"
test -f .gitmodules && cat .gitmodules || echo "(sem .gitmodules)"
git ls-files -s | awk '$1==160000{print "submodule:",$0}' || true

echo "==> 🔍 Objetos/refs quebrados?"
git fsck --no-reflogs --full

echo "==> ↕️ Divergência vs. origin/main (se branch existir)"
git fetch --quiet origin || true
if git rev-parse --verify origin/main >/dev/null 2>&1; then
  git --no-pager diff --stat --color=never origin/main... || true
fi

# 2) Arquivos & políticas
echo "==> 🧹 Procura scripts .sh fora das whitelists"
KEEP_SH_REGEX='^(56_verify_fenix_local\.sh|47_force_merge_with_protection_roundtrip\.sh|scripts/95_pos_merge_github\.sh|\.fenix/scripts/fenix-dry-run\.sh|\.fenix/scripts/fenix-report\.sh)$'
mapfile -d '' SHS < <(git ls-files -z -- '*.sh' ':!:docs/archive/**' ':!:.fenix/**' ':!:.husky/**')
LEFTOVER=0
for s in "${SHS[@]:-}"; do
  if [[ ! "$s" =~ $KEEP_SH_REGEX ]]; then
    echo "  ⚠️  Script ainda ativo fora do archive: $s"
    LEFTOVER=1
  fi
done
[[ $LEFTOVER -eq 0 ]] && echo "  ✅ OK: nenhum .sh fora do archive/whitelist"

echo "==> 📄 Revisão de documentação ativa (fora de docs/archive/)"
mapfile -d '' MDS < <(git ls-files -z -- '*.md' ':!:docs/archive/**')
if ((${#MDS[@]:-0} > 0)); then
  printf "  📚 MD ativos (%d):\n" "${#MDS[@]}"; printf "    - %s\n" "${MDS[@]}"
else
  echo "  ✅ OK: sem MD ativos (somente em archive/)"
fi

# 3) Fênix (idempotente)
if [[ -x ./56_verify_fenix_local.sh ]]; then
  echo "==> 🧪 Fênix smoke local"
  ./56_verify_fenix_local.sh || { echo "❌ Fênix smoke falhou"; exit 1; }
else
  echo "  ℹ️  Sem 56_verify_fenix_local.sh — pulando"
fi

# 4) Lint, tipos, testes, build (workspaces)
echo "==> 🧩 Instalação rápida (se necessário)"
command -v pnpm >/dev/null || { echo "❌ pnpm não encontrado"; exit 1; }
pnpm install --frozen-lockfile

echo "==> ✨ Lint"
pnpm -w run -r lint

echo "==> 🧠 Typecheck"
pnpm -w run -r typecheck

echo "==> 🧪 Tests (unit/property/integration/golden)"
pnpm -w --filter @finmath/engine run test
pnpm -w --filter @finmath/engine run test:property
pnpm -w --filter @finmath/engine run test:golden
pnpm -w --filter @finmath/api    run test:integration

echo "==> 🏗️ Build de pacotes"
pnpm -w --filter @finmath/engine run build
pnpm -w --filter @finmath/api    run build
pnpm -w --filter @finmath/ui     run build

# 5) OpenAPI
echo "==> 📜 OpenAPI validator (se disponível)"
if [[ -f .fenix/checks/validators/openapi_check.cjs ]]; then
  node .fenix/checks/validators/openapi_check.cjs
else
  echo "  ℹ️  Validador OpenAPI não encontrado — pulando"
fi

# 6) Árvore resumida (sanidade visual)
echo "==> 🌳 Árvore resumida (nível 3, sem node_modules/git/dist)"
command -v tree >/dev/null || { sudo apt-get update -y && sudo apt-get install -y tree; }
tree -a -I 'node_modules|dist|.git|coverage|.turbo|pnpm-store|.pnpm-store|.cache' -L 3 | sed 's/^/  /'

echo "✅ Health check concluído."
