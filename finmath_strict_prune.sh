#!/usr/bin/env bash
# finmath_strict_prune.sh
# Poda segura: remove apenas arquivos que o Fênix NÃO precisa.
# DRY-RUN por padrão. Use --apply para executar.
# Salvaguardas:
#  - Mantém núcleo do Fênix (.fenix/checks, policy, prompts, scripts, limits.yaml, rag, adapters)
#  - Mantém .github/workflows sempre
#  - NÃO remove testes E2E/A11y se houver referências nos workflows (auto-detecção)
#  - Flags: --keep-tests | --keep-artifacts | --keep-archives

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${ROOT:-}" ]] || { echo "❌ Execute dentro de um repositório Git."; exit 1; }
cd "$ROOT"

APPLY=false
KEEP_TESTS=false        # por padrão tentamos remover, mas auto-detecta e protege
KEEP_ARTIFACTS=false    # por padrão remove .fenix/artifacts
KEEP_ARCHIVES=false     # por padrão remove docs/archive

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=true ;;
    --keep-tests) KEEP_TESTS=true ;;
    --keep-artifacts) KEEP_ARTIFACTS=true ;;
    --keep-archives) KEEP_ARCHIVES=true ;;
    -h|--help)
      cat <<USAGE
Uso: $0 [--apply] [--keep-tests] [--keep-artifacts] [--keep-archives]
  --apply          Aplica as deleções (por padrão é DRY-RUN).
  --keep-tests     Força manter testes E2E/A11y mesmo sem referência em workflows.
  --keep-artifacts Mantém .fenix/artifacts.
  --keep-archives  Mantém docs/archive.
USAGE
      exit 0
      ;;
  esac
  shift
done

# Preferir ripgrep se existir
if command -v rg >/dev/null 2>&1; then
  GREP="rg -n --hidden --no-messages"
else
  GREP="grep -RIn --exclude-dir=.git"
fi

# Auto-detecção: workflows referenciam testes E2E/A11y?
if $GREP -e "test:e2e" -e "test:a11y" -e "playwright" .github/workflows >/dev/null 2>&1; then
  KEEP_TESTS=true
fi

# Utilitário: checar se um caminho é referenciado em workflows
is_referenced_in_workflows() {
  local p="$1"
  # testa nome do arquivo e caminho relativo
  local base
  base="$(basename "$p")"
  $GREP -F -- "$p" .github/workflows >/dev/null 2>&1 && return 0
  $GREP -F -- "$base" .github/workflows >/dev/null 2>&1 && return 0
  return 1
}

echo "📦 Repo : $(basename "$ROOT")"
echo "🔧 Modo : $($APPLY && echo APPLY || echo DRY-RUN)"
echo "🧩 Fênix: manter núcleo; artefatos: $($KEEP_ARTIFACTS && echo 'MANTER' || echo 'REMOVER')"
echo "📚 Arquivo de histórico (docs/archive): $($KEEP_ARCHIVES && echo 'MANTER' || echo 'REMOVER')"
echo "🧪 Testes E2E/A11y: $($KEEP_TESTS && echo 'MANTER' || echo 'REMOVER se não referenciados')"
echo

# Conjuntos de remoção seguros (apenas o que o Fênix não requer)
mapfile -t CANDIDATE_PATTERNS < <(cat <<'PATTERNS'
# Artefatos gerados/diagnósticos
.fenix/artifacts/**
_snapshot_reports/**
apps/demo/**
packages/engine/*.tgz
packages/ui/pnpm-lock.yaml

# Arquivo/Componentes soltos e legados na raiz (não dentro de packages/ui)
globals.css
tailwind.config.js
Button_A11y.tsx
Input_A11y.tsx
SkipLink.tsx

# Scripts operacionais de sprint/força-merge (desde que não referenciados por workflows)
force_merge_and_finish.sh
sprint4_inicio.sh
sprint4_part1_a11y.sh
sprint4_part2_e2e.sh
sprint4_part3_a11y_audit.sh
sprint4_finalizacao.sh
scripts/95_pos_merge_github.sh

# Ferramentas de patch/inspect (desde que não referenciadas)
tools/scripts/inspect_price.js
tools/scripts/patch_price_gf.js
PATTERNS
)

# docs/archive é opcional
$KEEP_ARCHIVES || CANDIDATE_PATTERNS+=("docs/archive/**")

# Testes E2E/A11y (só entram como candidatos se NÃO KEEP_TESTS)
if ! $KEEP_TESTS; then
  CANDIDATE_PATTERNS+=(
    "tests/e2e/**"
    "tests/a11y/**"
    "playwright.config.ts"
  )
fi

# Lista de arquivos versionados + não rastreados para avaliar
# (apenas arquivos, não diretórios)
collect_files() {
  git ls-files -z \
  | xargs -0 -I{} printf "%s\n" "{}"
  git ls-files --others --exclude-standard -z \
  | xargs -0 -I{} printf "%s\n" "{}"
}
mapfile -t ALL_FILES < <(collect_files)

# Função glob simples usando 'bash extglob'
shopt -s globstar nullglob extglob

should_remove() {
  local f="$1"

  # Nunca remover workflows e núcleo do Fênix
  [[ "$f" == .github/workflows/* ]] && return 1
  [[ "$f" == .fenix/checks/* ]] && return 1
  [[ "$f" == .fenix/policy/* ]] && return 1
  [[ "$f" == .fenix/prompts/* ]] && return 1
  [[ "$f" == .fenix/scripts/* ]] && return 1
  [[ "$f" == .fenix/rag/* ]] && return 1
  [[ "$f" == .fenix/adapters/* ]] && return 1
  [[ "$f" == .fenix/limits.yaml ]] && return 1

  # Proteção: se arquivo/pasta for referenciado por workflow, não remover
  if is_referenced_in_workflows "$f"; then
    return 1
  fi

  # Aplica padrões candidatos
  for pat in "${CANDIDATE_PATTERNS[@]}"; do
    # converte ** para glob real do bash
    if [[ "$pat" == */** ]]; then
      # mata prefixo até /**
      local dir="${pat%%/**}"
      if [[ -d "$dir" ]]; then
        # checa se f está dentro de dir e corresponde ao restante (aceita tudo)
        [[ "$f" == $dir/* ]] && echo "$f" >/dev/null && return 0
      fi
    else
      [[ "$f" == $pat ]] && return 0
    fi
  done

  return 1
}

TO_REMOVE=()
for f in "${ALL_FILES[@]}"; do
  # só considera arquivos existentes no workspace
  [[ -e "$f" ]] || continue

  # Se testes estão marcados para remoção, proteja novamente se workflow referir
  if [[ "$f" == tests/* || "$f" == "playwright.config.ts" ]]; then
    if $KEEP_TESTS; then
      continue
    else
      # segunda proteção: se workflow referir, não remove
      is_referenced_in_workflows "$f" && continue
    fi
  fi

  if should_remove "$f"; then
    TO_REMOVE+=("$f")
  fi
done

COUNT="${#TO_REMOVE[@]}"
if ! $APPLY; then
  echo "🧹 Serão removidos ($COUNT):"
  for p in "${TO_REMOVE[@]}"; do
    echo "  - $p"
  done
  echo
  echo "🔎 DRY-RUN: nada foi apagado."
  echo "   Para executar: $0 --apply"
  exit 0
fi

# APPLY
echo "🗑️  Removendo $COUNT itens…"
# Apaga apenas do diretório de trabalho; se estiver versionado, o git verá como remoção
for p in "${TO_REMOVE[@]}"; do
  rm -rf -- "$p" || true
done

echo "✅ Remoção concluída."
echo "💡 Próximos passos:"
echo "   git add -A && git commit -m \"chore(repo): prune arquivos não essenciais (Fênix-safe)\""
