#!/usr/bin/env bash
# clean_fenix_sh.sh — arquiva scripts *.sh não essenciais ao Fênix
# Uso:
#   DRY_RUN=1 ./clean_fenix_sh.sh   # (padrão) só simula
#   DRY_RUN=0 ./clean_fenix_sh.sh   # executa (git mv, commit, push)

set -Eeuo pipefail
IFS=$'\n\t'

# --------- Configurações ---------
: "${DRY_RUN:=1}"

# Whitelist dos scripts .sh que DEVEM permanecer ativos no repositório
# (ajuste se necessário)
declare -a KEEP_LIST=(
  "56_verify_fenix_local.sh"
  "47_force_merge_with_protection_roundtrip.sh"
  "scripts/95_pos_merge_github.sh"
  ".fenix/scripts/fenix-dry-run.sh"
  ".fenix/scripts/fenix-report.sh"
  ".fenix/scripts/health_check.sh"
)

# Pastas que nunca vamos arquivar (permanecem intocadas)
declare -a NEVER_ARCHIVE_PREFIXES=(
  ".husky/"          # hooks
)

# --------- Guardas & ambiente ---------
# 1) Verifica se é raiz de repo
if [[ ! -d .git || ! -f package.json ]]; then
  echo "❌ Não parece a raiz do repositório (precisa de .git e package.json)." >&2
  exit 1
fi

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# 2) Garante que não estamos em 'main' para evitar mexer direto na branch protegida
current_branch="$(git rev-parse --abbrev-ref HEAD)"
ts="$(date +%Y%m%d-%H%M%S)"
target_branch="chore/clean-sh-${ts}"
if [[ "$current_branch" == "main" ]]; then
  echo "ℹ️  Criando branch de trabalho: $target_branch"
  git switch -c "$target_branch" >/dev/null
else
  echo "ℹ️  Usando branch atual: $current_branch"
fi

# 3) Diretório de arquivamento (sempre relativo ao repo)
ARCHIVE_DIR="docs/archive/${ts}"
mkdir -p -- "$ARCHIVE_DIR"

# --------- Helpers ---------
path_in_keep_list() {
  local p="$1"
  for k in "${KEEP_LIST[@]}"; do
    [[ "$p" == "$k" ]] && return 0
  done
  return 1
}

path_is_never_archive() {
  local p="$1"
  for pref in "${NEVER_ARCHIVE_PREFIXES[@]}"; do
    [[ "$p" == "$pref"* ]] && return 0
  done
  return 1
}

# --------- Seleção de candidatos ---------
# • Pega apenas arquivos .sh rastreados
# • Ignora tudo que já está em docs/archive/**
# • Mantém a possibilidade de preservar .fenix/* pela whitelist (não excluímos .fenix do scan)
mapfile -d '' SH_FILES < <(git ls-files -z -- '*.sh' ':!:docs/archive/**')

to_archive=()
kept=()

for f in "${SH_FILES[@]}"; do
  # 1) Nunca arquivar pastas proibidas
  if path_is_never_archive "$f"; then
    kept+=("$f")
    continue
  fi
  # 2) Manter whitelist do Fênix
  if path_in_keep_list "$f"; then
    kept+=("$f")
    continue
  fi
  # 3) Caso contrário, vai para o archive
  to_archive+=("$f")
done

echo "==> 🧾 Resumo de seleção"
echo "   • Mantidos (whitelist + never-archive): ${#kept[@]}"
for k in "${kept[@]}"; do echo "     - $k"; done
echo "   • A arquivar: ${#to_archive[@]}"
for a in "${to_archive[@]}"; do echo "     - $a"; done

# --------- Execução ---------
if (( DRY_RUN )); then
  echo "🔎 DRY_RUN=1 — nada será modificado. Para aplicar, rode: DRY_RUN=0 $0"
  exit 0
fi

# Move com git mv preservando estrutura
moved_count=0
for s in "${to_archive[@]}"; do
  dest="${ARCHIVE_DIR}/${s}"
  mkdir -p -- "$(dirname "$dest")"
  git mv -- "$s" "$dest"
  echo "↪ arquivado: $s → $dest"
  ((moved_count++)) || true
done

if (( moved_count == 0 )); then
  echo "✅ Nada a arquivar. Sem alterações."
  exit 0
fi

# Commit
git add -A
git commit -m "chore(scripts): arquiva scripts *.sh legados em ${ARCHIVE_DIR} (mantém Fênix core)" || true

# Push
git push -u origin "$(git rev-parse --abbrev-ref HEAD)"

echo
echo "✅ Limpeza aplicada."
echo "   - Branch: $(git rev-parse --abbrev-ref HEAD)"
echo "   - Arquivo(s) movidos: ${moved_count}"
echo "   - Archive dir: ${ARCHIVE_DIR}"
echo
echo "👉 Se quiser abrir PR automaticamente (opcional), rode:"
echo "   gh pr create -B main -H $(git rev-parse --abbrev-ref HEAD) \\"
echo "      -t \"Limpeza de scripts .sh (Fênix apenas)\" \\"
echo "      -b \"Arquiva scripts legados em ${ARCHIVE_DIR}; mantém whitelist do Fênix.\""
echo
echo "🔎 Pós-checagem sugerida:"
echo "   git ls-files '*.sh' ':!:docs/archive/**' | sed 's/^/SH ativo: /'"
