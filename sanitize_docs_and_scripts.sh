#!/usr/bin/env bash
set -euo pipefail

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  FinMath — Sanitização de Documentação e Scripts (com arquivamento)  ║
# ╚══════════════════════════════════════════════════════════════════════╝
#
# O que faz:
# 1) Cria branch de trabalho
# 2) Gera inventário "antes"
# 3) Move docs/snapshots/scripts legados para docs/archive/<timestamp>/
# 4) Remove arquivos temporários/lixo
# 5) Mantém apenas documentação essencial + .fenix + scripts/95_pos_merge_github.sh
# 6) Gera inventário "depois", comita e abre PR (auto-merge squash)
#
# Uso:
#   DRY_RUN=1 ./sanitize_docs_and_scripts.sh   # simulação (não altera nada)
#   ./sanitize_docs_and_scripts.sh             # aplica de verdade
#
# Pré-requisitos: git, gh (GitHub CLI) autenticado, pnpm opcional.
# Política: não toca em código-fonte, apenas docs/scripts e artefatos.

DRY_RUN="${DRY_RUN:-0}"
TS="$(date +%Y%m%d-%H%M%S)"
BR="chore/docs-sanitize-${TS}"
ARCHIVE_DIR="docs/archive/${TS}"
ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || true)"

[[ -n "${ROOT_DIR}" ]] || { echo "❌ Não estou dentro de um repositório Git."; exit 1; }
cd "$ROOT_DIR"

echo "▶ FinMath — Sanitização (TS=$TS)  DRY_RUN=${DRY_RUN}"

# ────────────────────────────────────────────────────────────────────────
# 0) Guardrails e branch
# ────────────────────────────────────────────────────────────────────────
git fetch -q origin || true

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$CURRENT_BRANCH" == "HEAD" ]]; then
  echo "ℹ️  Em detached HEAD; vou criar branch mesmo assim."
fi

if [[ "$DRY_RUN" != "1" ]]; then
  # garante que estamos no último main remoto
  (git switch main >/dev/null 2>&1 || true)
  git fetch origin -q
  git reset --hard origin/main
  git switch -c "$BR"
else
  echo "  git switch -c ${BR}"
fi

# ────────────────────────────────────────────────────────────────────────
# 1) Inventário "antes"
# ────────────────────────────────────────────────────────────────────────
mkdir -p ".fenix/artifacts"
INV_BEFORE=".fenix/artifacts/sanitize_before_${TS}.txt"
INV_AFTER=".fenix/artifacts/sanitize_after_${TS}.txt"

tree_cmd="tree -a -I 'node_modules|dist|.git|coverage|.turbo|pnpm-store|.pnpm-store|.cache' -L 6"
if command -v tree >/dev/null 2>&1; then
  if [[ "$DRY_RUN" != "1" ]]; then
    eval "$tree_cmd" > "$INV_BEFORE" || true
  else
    echo "  INVENTÁRIO (antes) → $INV_BEFORE"
  fi
else
  echo "⚠️  'tree' não encontrado; inventário textual simples será usado."
  if [[ "$DRY_RUN" != "1" ]]; then
    git ls-files > "$INV_BEFORE"
  else
    echo "  git ls-files > $INV_BEFORE"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# 2) Listas de ação
# ────────────────────────────────────────────────────────────────────────

# 2.1) Scripts legados/desnecessários → arquivar
SCRIPTS_TO_ARCHIVE=(
  "UPDATE-SPRINTS.sh"
  "apply_finmath_patches_v4.sh"
  "audit-hu24.sh"
  "audit-project-complete.sh"
  "configurar-status-field-v2.sh"
  "configurar-status-field-v3.sh"
  "configurar-status-field.sh"
  "converter-para-board.sh"
  "copiar_arquivos.sh"
  "criar-board-view.sh"
  "criar-project-board.sh"
  "diagnose-lint.sh"
  "export_debug.sh"
  "fin-math.sh"
  "fix-eslint-config.sh"
  "fix-package-name.sh"
  "fix-validation-routes.sh"
  "fix-workspace.sh"
  "fix_single_file.sh"
  "fix_typescript_errors.sh"
  "install_dependencies.sh"
  "rollback_finmath_patches.sh"
  "validate_errors.sh"
  "validate-sprint4.sh"
  "teste-geral-completo-v2.sh"
  "teste-geral-completo.sh"
  "teste-geral-final-v2.sh"
  "teste-geral-final.sh"
  "tools/scripts"
  "scripts/sprint2-dev"
  "packages/ui/create-components.sh"
  "packages/ui/fix-errors.sh"
  "packages/ui/setup-parte1.sh"
  "packages/ui/setup-parte2.sh"
  "packages/ui/setup-parte3.sh"
)

# 2.2) Documentação redundante/antiga → arquivar
DOCS_TO_ARCHIVE=(
  "README.md.old"
  "CHANGELOG.md.old"
  "CHECKLIST_FINAL_SPRINT3.md"
  "SPRINT3_RESUMO_EXECUTIVO.md"
  "TREE.md"
  "VALIDATION-REPORT-FINAL.md"
  "docs/SPRINT4B-SUMMARY.md"
  "docs/sprint-planning/sprint5-checklist.md"
  "docs/h15-irr-tir-com-brent.md"
  "docs/sprint2/validate-docs.sh"
)

# 2.3) Diretórios de fontes não versionadas (DOCX etc) → arquivar
DIRS_TO_ARCHIVE=(
  "docs/source-docs"
  "_snapshot_reports"
  "docs/api"                # documentação gerada; manteremos o openapi.yaml como fonte da verdade
)

# 2.4) Artefatos/snapshots/lixo para REMOVER (sem arquivar)
TRASH_TO_REMOVE=(
  "snapshot-amostra.txt"
  "snapshot_00.part"
  "snapshot_01.part"
  "snapshot_02.part"
  "snapshot_03.part"
  "snapshot_04.part"
  "snapshot_05.part"
  "snapshot_06.part"
  "fin-math"                # duplicata de árvore (pasta solta)
)

# 2.5) O que vamos MANTER (referência, não usado pelo script; só pra clareza):
# - README.md
# - CHANGELOG.md
# - api/openapi.yaml
# - docs/ARCHITECTURE.md, docs/TESTING.md, docs/CONTRIBUTING.md
# - docs/adr/**
# - .fenix/**
# - scripts/95_pos_merge_github.sh
# - packages/** (código), apps/** (demo), tools/board-management/**
# - .github/** (CI, Guard), .husky/**
# - pnpm-lock.yaml, pnpm-workspace.yaml

# ────────────────────────────────────────────────────────────────────────
# Helpers
# ────────────────────────────────────────────────────────────────────────
move_to_archive() {
  local path="$1"
  local dest="${ARCHIVE_DIR}/$(dirname "$path")"
  if [[ -e "$path" ]]; then
    echo "  ↪ arquivar: $path → ${ARCHIVE_DIR}/"
    if [[ "$DRY_RUN" != "1" ]]; then
      mkdir -p "$dest"
      git mv "$path" "${ARCHIVE_DIR}/${path}" 2>/dev/null || {
        # caso git mv não funcione (dir empty), faça manual + git add
        mkdir -p "$(dirname "${ARCHIVE_DIR}/${path}")"
        mv "$path" "${ARCHIVE_DIR}/${path}"
        git add -A "${ARCHIVE_DIR}/${path}"
        git rm -r --cached "$path" 2>/dev/null || true
      }
    fi
  fi
}

remove_path() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "  ✖ remover: $path"
    if [[ "$DRY_RUN" != "1" ]]; then
      git rm -r -f "$path" || true
    fi
  fi
}

# ────────────────────────────────────────────────────────────────────────
# 3) Arquivar scripts/documentação/dirs
# ────────────────────────────────────────────────────────────────────────
echo "🗄️  Arquivando no repositório em: ${ARCHIVE_DIR}"
if [[ "$DRY_RUN" != "1" ]]; then
  mkdir -p "$ARCHIVE_DIR"
  # marcador com contexto
  cat > "${ARCHIVE_DIR}/README.md" <<EOF
# Arquivo — ${TS}

Este diretório contém scripts e documentação legada/gerada que foram movidos
durante a sanitização. Consulte o histórico do Git para recuperar qualquer item.

Motivações:
- Remover duplicidade, reduzir ruído e manter fonte de verdade única
- Evitar execução acidental de scripts que quebram o projeto
- Preservar histórico (sem zip externo)

EOF
  git add "${ARCHIVE_DIR}/README.md"
else
  echo "  mkdir -p ${ARCHIVE_DIR} && (README.md de contexto)"
fi

echo "▶ Scripts a arquivar:"
for s in "${SCRIPTS_TO_ARCHIVE[@]}"; do
  [[ -e "$s" ]] && echo "   - $s"
done

for s in "${SCRIPTS_TO_ARCHIVE[@]}"; do
  move_to_archive "$s"
done

echo "▶ Documentos a arquivar:"
for d in "${DOCS_TO_ARCHIVE[@]}"; do
  [[ -e "$d" ]] && echo "   - $d"
done

for d in "${DOCS_TO_ARCHIVE[@]}"; do
  move_to_archive "$d"
done

echo "▶ Diretórios a arquivar:"
for dir in "${DIRS_TO_ARCHIVE[@]}"; do
  [[ -e "$dir" ]] && echo "   - $dir"
done

for dir in "${DIRS_TO_ARCHIVE[@]}"; do
  move_to_archive "$dir"
done

# ────────────────────────────────────────────────────────────────────────
# 4) Remover lixo
# ────────────────────────────────────────────────────────────────────────
echo "🧹 Removendo artefatos temporários/lixo:"
for t in "${TRASH_TO_REMOVE[@]}"; do
  [[ -e "$t" ]] && echo "   - $t"
done

for t in "${TRASH_TO_REMOVE[@]}"; do
  remove_path "$t"
done

# ────────────────────────────────────────────────────────────────────────
# 5) Reforçar .gitignore (artefatos locais/SO)
# ────────────────────────────────────────────────────────────────────────
IGNORE_SNIPPET=$'\n# Sanitização: ignorar artefatos locais / SO\n*.Zone.Identifier\n.DS_Store\nThumbs.db\n'
if [[ "$DRY_RUN" != "1" ]]; then
  if ! grep -q "Sanitização: ignorar artefatos locais" .gitignore 2>/dev/null; then
    printf "%s" "$IGNORE_SNIPPET" >> .gitignore
    git add .gitignore
  fi
else
  echo "  (atualizaria .gitignore com ignoráveis de SO)"
fi

# ────────────────────────────────────────────────────────────────────────
# 6) Inventário "depois"
# ────────────────────────────────────────────────────────────────────────
if command -v tree >/dev/null 2>&1; then
  if [[ "$DRY_RUN" != "1" ]]; then
    eval "$tree_cmd" > "$INV_AFTER" || true
  else
    echo "  INVENTÁRIO (depois) → $INV_AFTER"
  fi
else
  if [[ "$DRY_RUN" != "1" ]]; then
    git ls-files > "$INV_AFTER"
  else
    echo "  git ls-files > $INV_AFTER"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# 7) Commit, PR e auto-merge
# ────────────────────────────────────────────────────────────────────────
if [[ "$DRY_RUN" == "1" ]]; then
  echo "🔎 DRY-RUN ativo — nada será comitado nem enviado."
  echo "   Quando estiver ok, rode sem DRY_RUN para aplicar."
  exit 0
fi

git add -A
if ! git diff --cached --quiet; then
  git commit -m "docs: sanitização e arquivamento de scripts/docs em ${ARCHIVE_DIR}"
else
  echo "ℹ️  Nenhuma alteração para commit."
fi

git push -u origin "$BR"

if command -v gh >/dev/null 2>&1; then
  PR_URL="$(gh pr create --base main --head "$BR" \
    -t "docs: sanitização de documentação e scripts (arquivado em ${ARCHIVE_DIR})" \
    -b "Este PR move/arquiva documentação e scripts legados para ${ARCHIVE_DIR}, remove artefatos temporários e mantém apenas documentação essencial. Inventários em:
- ${INV_BEFORE}
- ${INV_AFTER}
")"
  echo "🔗 PR: ${PR_URL}"
  # auto-merge (squash) + garantir carimbo do Fênix
  gh pr merge --auto --squash || true
  gh workflow run "Fenix Guard" --ref "$BR" || true
  gh pr checks --watch --interval 10 || true
else
  echo "ℹ️  gh (GitHub CLI) não disponível. Abra PR manual para ${BR} → main."
fi

echo "✅ Sanitização finalizada."
