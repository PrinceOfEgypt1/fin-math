#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------
# FinMath — Ultra Slim Repo
# Compacta docs e remove scripts legados
# ---------------------------------------------

TS="$(date +%Y%m%d-%H%M%S)"
BR="chore/docs-ultraslim-$TS"
ARCHIVE_DIR="docs/archive/$TS"
DRY_RUN="${DRY_RUN:-0}"           # DRY_RUN=1 para só simular
DELETE_SCRIPTS="${DELETE_SCRIPTS:-0}" # DELETE_SCRIPTS=1 para excluir .sh (em vez de arquivar)
GH_AUTO="${GH_AUTO:-1}"           # GH_AUTO=0 para não abrir PR

echo "▶ Ultra Slim (TS=$TS)  DRY_RUN=$DRY_RUN  DELETE_SCRIPTS=$DELETE_SCRIPTS"

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "  $*"
  else
    eval "$@"
  fi
}

# 0) Pré-checagens básicas
test -d .git || { echo "❌ Rode na raiz do repo (onde há .git)"; exit 1; }
git update-index -q --refresh || true

# 1) Branch e inventário inicial
run "git switch -c '$BR'"
run "mkdir -p .fenix/artifacts"
run "git ls-files -z | xargs -0 -I{} echo {} > .fenix/artifacts/ultraslim_before_$TS.txt"

# 2) Diretório de archive + README de contexto
run "mkdir -p '$ARCHIVE_DIR'"
if [[ "$DRY_RUN" == "0" ]]; then
  cat > "$ARCHIVE_DIR/README.md" <<'EOF'
# Arquivo de Documentação/Script — Archive

Este diretório armazena **documentos e scripts legados** removidos na rotina de sanitização “ultra slim”.
Nada foi descartado sem registro: o histórico está aqui e no Git.

Critérios adotados:
- Manter somente: README.md, LICENSE, CHANGELOG.md, docs/README.md, docs/ARCHITECTURE.md, docs/TESTING.md, docs/CONTRIBUTING.md e api/openapi.yaml
- **Todos os .sh** fora de `.fenix/` e `.husky/` foram arquivados (ou deletados se a flag DELETE_SCRIPTS=1 foi usada)
- Toda documentação auxiliar (ADR, issues, sprints, DOCX, typedoc estático, etc.) veio para cá

Para recuperar algo, faça cherry-pick ou copie a partir deste diretório.
EOF
fi

# 3) Whitelist do que fica (ajuste se quiser)
KEEP_MD=(
  "README.md"
  "LICENSE"
  "CHANGELOG.md"
  "docs/README.md"
  "docs/ARCHITECTURE.md"
  "docs/TESTING.md"
  "docs/CONTRIBUTING.md"
)
# Sem ser .md, mantemos explicitamente:
KEEP_OTHER=(
  "api/openapi.yaml"
)

# 4) Arquivar toda doc .md fora da whitelist (em raiz e docs/)
echo "▶ Compactando documentação para $ARCHIVE_DIR (exceto whitelist)"
# Coleta todos .md (raiz e docs) que NÃO estejam na whitelist
mapfile -t MD_TO_ARCHIVE < <(
  git ls-files '*.md' 'docs/**/*.md' \
    | grep -v -E '^\.fenix/' \
    | while read -r f; do
        keep=0
        for k in "${KEEP_MD[@]}"; do
          [[ "$f" == "$k" ]] && keep=1 && break
        done
        [[ $keep -eq 0 ]] && echo "$f"
      done
)

for f in "${MD_TO_ARCHIVE[@]}"; do
  [[ -z "$f" ]] && continue
  echo "  ↪ arquivar doc: $f"
  run "mkdir -p '$ARCHIVE_DIR/$(dirname "$f")'"
  run "git mv '$f' '$ARCHIVE_DIR/$f'"
done

# 5) Arquivar conteúdo de docs/ que não é da whitelist (ex.: api/ estático, ADR, issues, sprints, docx…)
echo "▶ Arquivando conteúdo amplo de docs/ (exceto whitelist)"
mapfile -t DOCS_MISC < <(
  git ls-files docs \
    | grep -v -E '^docs/(README\.md|ARCHITECTURE\.md|TESTING\.md|CONTRIBUTING\.md)(|$)' \
    | grep -v -E '^docs/archive/' \
    | while read -r f; do
        # pular se já movido na etapa anterior
        if git status --porcelain=v1 | grep -q "R  $f -> $ARCHIVE_DIR/"; then
          continue
        fi
        echo "$f"
      done
)

for f in "${DOCS_MISC[@]}"; do
  [[ -z "$f" ]] && continue
  # Se já no destino, pula
  [[ "$f" == "$ARCHIVE_DIR"* ]] && continue
  echo "  ↪ arquivar docs: $f"
  dest="$ARCHIVE_DIR/$f"
  run "mkdir -p '$(dirname "$dest")'"
  run "git mv '$f' '$dest'"
done

# 6) Scripts .sh — arquivar (ou deletar) tudo, EXCETO o que é do Fênix
echo "▶ Processando scripts .sh (fora de .fenix/ e .husky/ e preservando Fênix essenciais)"

# whitelist de scripts que DEVEM ficar
KEEP_SH_REGEX='^(56_verify_fenix_local\.sh|47_force_merge_with_protection_roundtrip\.sh|scripts/95_pos_merge_github\.sh)$'

mapfile -t SH_TARGETS < <(
  git ls-files '*.sh' \
    | grep -v -E '^\.fenix/' \
    | grep -v -E '^\.husky/' \
    | grep -v -E "$KEEP_SH_REGEX"
)

for f in "${SH_TARGETS[@]}"; do
  [[ -z "$f" ]] && continue
  if [[ "$DELETE_SCRIPTS" == "1" ]]; then
    echo "  ✖ deletar script: $f"
    run "git rm -f '$f'"
  else
    echo "  ↪ arquivar script: $f"
    dest="$ARCHIVE_DIR/$f"
    run "mkdir -p '$(dirname "$dest")'"
    run "git mv '$f' '$dest'"
  fi
done

# mensagem de confirmação do que ficou
echo "▶ Preservados (Fênix): 56_verify_fenix_local.sh, 47_force_merge_with_protection_roundtrip.sh, scripts/95_pos_merge_github.sh e TUDO em .fenix/"


# 7) Garantir arquivos não-MD essenciais (whitelist)
echo "▶ Checando arquivos essenciais (não-MD)"
for f in "${KEEP_OTHER[@]}"; do
  if ! test -f "$f"; then
    echo "  ⚠ essencial ausente: $f"
  fi
done

# 8) Lixos temporários e artefatos
echo "▶ Limpando lixos temporários"
TRASH=(
  "snapshot-amostra.txt"
  "snapshot_00.part" "snapshot_01.part" "snapshot_02.part" "snapshot_03.part"
  "snapshot_04.part" "snapshot_05.part" "snapshot_06.part"
)
for t in "${TRASH[@]}"; do
  if test -e "$t"; then
    echo "  ✖ remover: $t"
    if [[ "$DRY_RUN" == "1" ]]; then
      echo "  (simulado) git rm -f '$t'"
    else
      git rm -f "$t" || rm -f "$t" || true
    fi
  fi
done

# 9) .gitignore reforçado
echo "▶ Reforçando .gitignore"
ensure_gitignore() {
  local pattern="$1"
  if ! grep -qE "^${pattern//\./\\.}$" .gitignore 2>/dev/null; then
    if [[ "$DRY_RUN" == "1" ]]; then
      echo "  (simulado) echo '$pattern' >> .gitignore"
    else
      echo "$pattern" >> .gitignore
    fi
  fi
}
ensure_gitignore "snapshot_*.part"
ensure_gitignore "*.log"
ensure_gitignore "*.DS_Store"
ensure_gitignore "Thumbs.db"

# 10) Inventário final, commit
run "git ls-files -z | xargs -0 -I{} echo {} > .fenix/artifacts/ultraslim_after_$TS.txt"

MSG="chore(docs): ultra slim — arquiva docs/scripts legados em $ARCHIVE_DIR; limpa artefatos"
if [[ "$DRY_RUN" == "1" ]]; then
  echo "  (simulado) git add -A && git commit -m \"$MSG\""
else
  git add -A
  git commit -m "$MSG" || true
fi

# 11) Push + PR opcional
if [[ "$DRY_RUN" == "0" ]]; then
  run "git push -u origin '$BR'"
  if command -v gh >/dev/null && [[ "$GH_AUTO" == "1" ]]; then
    echo "▶ Abrindo PR com auto-merge (squash)…"
    run "gh pr create --base main --title 'chore(docs): ultra slim' --body 'Arquiva docs/scripts legados em $ARCHIVE_DIR; mantém docs mínimos e openapi; remove lixos temporários.'"
    run "gh pr merge --auto --squash || true"
    run "gh pr checks --watch --interval 10 || true"
  fi
fi

echo "✅ Ultra Slim finalizado."
