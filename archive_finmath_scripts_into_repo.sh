#!/usr/bin/env bash
set -euo pipefail

# ======================================================
#  Arquiva scripts legados DENTRO do repositório:
#  docs/archive/legacy-scripts-<TS>/...
#  Uso:
#    DRY_RUN=1 ./archive_finmath_scripts_into_repo.sh  # só lista
#           ./archive_finmath_scripts_into_repo.sh      # executa
# ======================================================

TS="$(date +%Y%m%d-%H%M%S)"
BRANCH="chore/archive-scripts-${TS}"
ARCHIVE_ROOT="docs/archive/legacy-scripts-${TS}"
DRY_RUN="${DRY_RUN:-0}"   # DRY_RUN=1 para simular

say() { echo -e "$@"; }
cmd() { say "  $*"; [[ "$DRY_RUN" == "1" ]] || eval "$*"; }

# --- 0) Pré-checagens
git rev-parse --is-inside-work-tree >/dev/null
if ! git diff --quiet || ! git diff --cached --quiet; then
  say "⚠️  Working tree tem mudanças. Faça commit/stash antes."
  exit 1
fi

say "▶ Arquivo interno de scripts — TS=${TS}  DRY_RUN=${DRY_RUN}"

# --- 1) Criar branch
cmd git switch -c "${BRANCH}"

# --- 2) Selecionar candidatos (scripts legados)
#     - .sh na raiz
#     - tudo sob scripts/ e tools/scripts/
#     - .sh “perdidos” em packages/ui, apps, etc.
#     - scripts clássicos da raiz (teste-geral*.sh, validate-*, UPDATE-SPRINTS.sh etc.)
mapfile -t CAND < <(git ls-tree -r --name-only HEAD | \
  grep -E '^([^/]+\.sh|scripts/|tools/scripts/|apps/[^/]+\.sh|packages/ui/[^/]+\.sh)$' || true)

EXTRAS=(
  "UPDATE-SPRINTS.sh"
  "validate-sprint4.sh"
  "teste-geral-completo.sh"
  "teste-geral-completo-v2.sh"
  "teste-geral-final.sh"
  "teste-geral-final-v2.sh"
  "scripts/sprint2-dev"
  "tools/scripts"
)
for p in "${EXTRAS[@]}"; do
  if git ls-files --error-unmatch "$p" >/dev/null 2>&1; then
    CAND+=("$p")
  fi
done

# Desduplicar
TMP="$(mktemp)"; printf "%s\n" "${CAND[@]}" | sort -u > "$TMP"; mapfile -t CAND < "$TMP"; rm -f "$TMP"

# --- 3) Itens temporários (não arquivar; vamos remover)
#     Mantemos apenas scripts no archive; snapshots/logs saem.
TRASH=(
  "_snapshot_reports"
  "snapshot-amostra.txt"
  "snapshot_00.part" "snapshot_01.part" "snapshot_02.part"
  "snapshot_03.part" "snapshot_04.part" "snapshot_05.part" "snapshot_06.part"
)

say "🧭 Scripts a arquivar (${#CAND[@]}):"
for p in "${CAND[@]}"; do say "  - $p"; done

say "🧹 Artefatos temporários a remover (${#TRASH[@]}):"
for t in "${TRASH[@]}"; do
  if git ls-files --error-unmatch "$t" >/dev/null 2>&1; then
    say "  - $t"
  fi
done

if [[ "$DRY_RUN" == "1" ]]; then
  say "🔎 DRY-RUN ativo — nada será alterado."
  exit 0
fi

# --- 4) Criar raiz do archive
cmd mkdir -p "${ARCHIVE_ROOT}"

# --- 5) Mover scripts para docs/archive preservando estrutura
move_preserving_path() {
  local src="$1"
  local dest="${ARCHIVE_ROOT}/${src}"
  local dest_dir
  dest_dir="$(dirname "$dest")"
  cmd mkdir -p "$dest_dir"
  cmd git mv "$src" "$dest"
}

# mover diretórios inteiros “scripts/” e “tools/scripts/” primeiro (se ainda existem)
for d in "scripts" "tools/scripts" "scripts/sprint2-dev"; do
  if git ls-files --error-unmatch "$d" >/dev/null 2>&1; then
    # mover diretório inteiro para archive mantendo nome/estrutura
    dest="${ARCHIVE_ROOT}/${d%/}"
    cmd mkdir -p "$(dirname "$dest")"
    cmd git mv "$d" "$dest"
    # e retirar possíveis entradas já incluídas nos CAND
    CAND=("${CAND[@]/$d}")
  fi
done

# mover arquivos restantes (ex.: *.sh na raiz, packages/ui/*.sh, apps/*.sh, etc.)
for f in "${CAND[@]}"; do
  [[ -z "$f" ]] && continue
  if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
    move_preserving_path "$f"
  fi
done

# --- 6) Remover artefatos temporários
for t in "${TRASH[@]}"; do
  if git ls-files --error-unmatch "$t" >/dev/null 2>&1; then
    # se diretório:
    if [[ -d "$t" ]]; then cmd git rm -r "$t"; else cmd git rm -f "$t"; fi
  fi
done

# --- 7) Reforçar .gitignore (sem bloquear docs/archive)
IGNORES=$'\n# --- block legacy local scripts (exceto docs/archive) ---\n/*.sh\n/tools/scripts/\n/scripts/\n/_snapshot_reports/\n/snapshot_*.part\n*.Zone.Identifier\n'
cmd "printf \"%s\" \"${IGNORES}\" >> .gitignore"

# --- 8) Política clara
cmd mkdir -p docs
cat > docs/SCRIPTS_POLICY.md <<'MD'
# Política de Scripts Locais (FinMath)

**Não usamos scripts locais em produção.**
- Toda automação roda no **CI (GitHub Actions)**, orquestrada pelo **Fênix** (branch protegida + checks).
- Alterações **devem** passar por **Pull Request** com **auto-merge (squash)** e checagens verdes.
- Scripts legados foram **arquivados** em `docs/archive/` apenas para referência histórica. **Não execute**.

**Como trabalhar:**
1. Crie uma branch da sprint (ex.: `sprint-N`) ou da HU (`feat/hNN-...`).
2. Abra PR para `main`.
3. Aguarde checks do Fênix (lint, typecheck, testes, build, OpenAPI).
4. Faça merge (squash) quando tudo estiver verde.

Dúvidas? Veja `README.md` e `docs/SPRINTS.md`.
MD

# --- 9) Commit
cmd git add .gitignore docs/SCRIPTS_POLICY.md "${ARCHIVE_ROOT}"
cmd git commit -m "chore: arquiva scripts locais em ${ARCHIVE_ROOT}, remove temporários e reforça política sem scripts locais"

# --- 10) PR (auto-merge) — opcional
if command -v gh >/dev/null 2>&1; then
  cmd git push -u origin "${BRANCH}"
  cmd gh pr create --base main --head "${BRANCH}" \
    -t "chore: arquivar scripts locais + política sem scripts (CI-first)" \
    -b "Move scripts legados para ${ARCHIVE_ROOT}, remove artefatos temporários e reforça .gitignore. **Não execute** scripts arquivados; fluxo é 100% via PR + Fênix."
  # auto-merge (squash) assim que checks passarem
  cmd "gh pr merge --auto --squash || true"
  say "✅ PR aberto. Deixe o Fênix validar e efetivar o merge."
else
  say "ℹ️  gh CLI não encontrado. Faça push e abra PR manualmente."
fi

say "🎉 Concluído."
