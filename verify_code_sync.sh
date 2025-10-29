#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
git fetch --all --quiet --tags

echo "📦 Repo : $(basename "$(pwd)")"
echo "🌿 Branch: $BRANCH"
echo

# Pathspecs para code+config
FILTERS=(
  '**/*.ts' '**/*.tsx' '**/*.js' '**/*.jsx' '**/*.mjs' '**/*.cjs'
  '**/*.json' '**/*.jsonc' '**/*.yaml' '**/*.yml'
  '**/*.html' '**/*.css' '**/*.sh'
  ':(exclude)node_modules' ':(exclude)**/dist' ':(exclude)**/coverage'
  ':(exclude)_snapshot_reports' ':(exclude).git' ':(exclude)**/*.md'
)

# Apenas globs (sem excludes) para ls-files --others
GLOBS_ONLY=(
  '**/*.ts' '**/*.tsx' '**/*.js' '**/*.jsx' '**/*.mjs' '**/*.cjs'
  '**/*.json' '**/*.jsonc' '**/*.yaml' '**/*.yml'
  '**/*.html' '**/*.css' '**/*.sh'
)

# Ahead/Behind: left=HEAD (ahead), right=origin/BRANCH (behind)
read AHEAD BEHIND < <(git rev-list --left-right --count HEAD...origin/"$BRANCH" | awk '{print $1" "$2}')
echo "🔁 Ahead/Behind vs origin/$BRANCH: $AHEAD/$BEHIND"
echo

# Mudanças locais não commitadas
echo "🧪 Mudanças locais não commitadas (code+config):"
if git status --porcelain=v1 -- "${FILTERS[@]}" | grep -q .; then
  git status --porcelain=v1 -- "${FILTERS[@]}"
else
  echo "(nenhuma)"
fi
echo

# Diferenças HEAD vs origin/BRANCH
echo "🧪 Diferenças HEAD vs origin/$BRANCH (code+config):"
if git diff --name-status origin/"$BRANCH"...HEAD -- "${FILTERS[@]}" | grep -q .; then
  git diff --name-status origin/"$BRANCH"...HEAD -- "${FILTERS[@]}"
else
  echo "(nenhuma)"
fi
echo

# Não rastreados
echo "🧪 Arquivos code+config NÃO rastreados:"
if git ls-files --others --exclude-standard -- "${GLOBS_ONLY[@]}" | grep -q .; then
  git ls-files --others --exclude-standard -- "${GLOBS_ONLY[@]}"
else
  echo "(nenhum)"
fi
echo

PEND=0
[[ "$AHEAD" != "0" || "$BEHIND" != "0" ]] && PEND=1
if git status --porcelain=v1 -- "${FILTERS[@]}" | grep -q .; then PEND=1; fi
if git ls-files --others --exclude-standard -- "${GLOBS_ONLY[@]}" | grep -q .; then PEND=1; fi

if [[ $PEND -eq 0 ]]; then
  echo "✅ VEREDITO: Código/Config SINCRONIZADOS com origin/$BRANCH."
  exit 0
else
  echo "❌ VEREDITO: Há pendências de publicação/sincronização em CÓDIGO/CONFIG."
  echo "   ➜ Use as seções acima para ver o que falta commitar/pushar/mergear."
  exit 1
fi
