#!/usr/bin/env bash
# finish_all.sh
# Faz o restante em um tiro só:
# - cria/ajusta PR da branch atual (se for de limpeza), ativa auto-merge (squash) e tenta merge imediato (--admin opcional)
# - sincroniza main
# - roda health check completo (fsck/gc, whitelist de .sh, MDs ativas, OpenAPI, Fênix dry-run)
# - confirma árvore de .sh e .md ativas
#
# Uso:
#   bash finish_all.sh
#   ADMIN=1 bash finish_all.sh        # tenta merge imediato com --admin (se política permitir)
#   BRANCH_CLEAN=chore/clean-sh-XXXX bash finish_all.sh   # especifica uma branch de limpeza, se você não estiver nela
#
set -euo pipefail
IFS=$'\n\t'

say()  { printf "%b\n" "$*"; }
die()  { say "❌ $*"; exit 1; }
ok()   { say "✅ $*"; }
warn() { say "⚠️  $*"; }

# 0) Pré-checagens simples
command -v git >/dev/null || die "git não encontrado"
command -v gh  >/dev/null || warn "gh (GitHub CLI) não encontrado — PR automático será pulado"
command -v node >/dev/null || warn "node não encontrado — pulará openapi_check.cjs"
test -f package.json -a -d .git || die "não parece a raiz do repo"
export LC_ALL=${LC_ALL:-C.UTF-8}
export LANG=${LANG:-C.UTF-8}

# 1) Descobrir branch alvo de PR (a de limpeza)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
BRANCH_CLEAN="${BRANCH_CLEAN:-$CURRENT_BRANCH}"

# Heurística: tratamos como branch de limpeza se começar com "chore/clean-sh-"
if [[ ! "$BRANCH_CLEAN" =~ ^chore/clean-sh- ]]; then
  warn "Branch atual não parece ser a de limpeza: '$BRANCH_CLEAN'. Vou pular criação/merge de PR."
  DO_PR=0
else
  DO_PR=1
fi

# 2) PR: criar (se não existir), ligar auto-merge (squash) e opcionalmente forçar admin merge
if [[ $DO_PR -eq 1 && $(command -v gh >/dev/null; echo $?) -eq 0 ]]; then
  say "🪄 PR: garantindo PR para '$BRANCH_CLEAN' → base 'main' (squash)"
  # Ver se já existe PR desta branch
  if ! PR_JSON=$(gh pr view "$BRANCH_CLEAN" --json number,mergeStateStatus,headRefName,baseRefName --jq '{n:.number,s:.mergeStateStatus}' 2>/dev/null); then
    # criar PR
    gh pr create -B main -H "$BRANCH_CLEAN" \
      -t "Limpeza de scripts .sh (Fênix apenas)" \
      -b "Arquiva scripts legados em docs/archive; mantém whitelist do Fênix." >/dev/null
    PR_JSON=$(gh pr view "$BRANCH_CLEAN" --json number,mergeStateStatus --jq '{n:.number,s:.mergeStateStatus}')
    ok "PR criado para $BRANCH_CLEAN"
  else
    ok "PR já existe para $BRANCH_CLEAN"
  fi

  PR_NUMBER=$(jq -r '.n' <<<"$PR_JSON" 2>/dev/null || echo "")
  test -n "${PR_NUMBER:-}" || die "não consegui obter número do PR"

  say "🔁 Ativando auto-merge (squash) no PR #$PR_NUMBER"
  gh pr merge "$PR_NUMBER" --auto --squash || warn "auto-merge configurado, mas pode depender de checks/políticas"

  if [[ "${ADMIN:-0}" == "1" ]]; then
    say "🛡️  Tentando merge imediato com --admin (se permitido pela política)"
    gh pr merge "$PR_NUMBER" --admin --squash || warn "merge admin não disponível agora (política ou checks pendentes)"
  fi
else
  warn "Pulando etapa de PR (sem gh ou branch não é de limpeza)."
fi

# 3) Sincronizar main local
say "🌳 Sincronizando 'main'"
git fetch origin main -q
git switch main -q
git pull --ff-only -q || warn "pull --ff-only não aplicado (sem mudanças ou merge pendente)."

# 4) Health check completo (blindado)
say "🩺 Health check: git fsck/gc, submódulos, whitelist de .sh, MDs e Fênix/OpenAPI"

# 4.1 Git fsck/gc
git fsck --full >/dev/null && ok "git fsck ok"
git reflog expire --expire-unreachable=now --all >/dev/null || true
git gc --prune=now --aggressive >/dev/null && ok "git gc ok"

# 4.2 Submódulos órfãos
if test -f .gitmodules; then
  warn "Existe .gitmodules — verifique necessidade de submódulos"
else
  ok "sem .gitmodules"
fi

if git ls-files -s | awk '$1==160000{found=1} END{exit !found}'; then
  die "há gitlinks de submódulo no índice (não esperado)."
else
  ok "sem gitlinks (submódulos)"
fi

# 4.3 Whitelist de .sh (fora de docs/archive e .husky)
ALLOWED_SH=(
  ".fenix/scripts/fenix-dry-run.sh"
  ".fenix/scripts/fenix-report.sh"
  "scripts/95_pos_merge_github.sh"
  ".fenix/scripts/clean_fenix_sh.sh"   # caso você tenha movido o seu limpador pra .fenix
  "clean_fenix_sh.sh"                   # caso ainda esteja na raiz
)

say "🧹 Conferindo scripts ativos (.sh) fora de docs/archive/.husky"
mapfile -t SH_ACTIVE < <(git ls-files '*.sh' ':!:docs/archive/**' ':!:.husky/**' | sort || true)
BAD=()
for f in "${SH_ACTIVE[@]:-}"; do
  okd=0
  for a in "${ALLOWED_SH[@]}"; do [[ "$f" == "$a" ]] && okd=1; done
  if [[ $okd -eq 1 ]]; then
    printf "   • OK: %s\n" "$f"
  else
    BAD+=("$f")
  fi
done
if ((${#BAD[@]:-0} > 0)); then
  say "❌ Encontrados .sh não permitidos:"
  printf "   - %s\n" "${BAD[@]}"
  exit 1
else
  ok "apenas .sh permitidos permanecem ativos"
fi

# 4.4 MDs ativas (informativo; esperado: poucos MDs)
say "📄 MDs ativas (fora de docs/archive/) — informativo"
mapfile -t MDS < <(git ls-files '*.md' ':!:docs/archive/**' | sort || true)
if ((${#MDS[@]:-0} > 0)); then
  for m in "${MDS[@]}"; do printf "   • %s\n" "$m"; done
else
  say "   • nenhuma"
fi

# 4.5 OpenAPI (se possível)
if [[ -f ".fenix/checks/validators/openapi_check.cjs" ]]; then
  if node .fenix/checks/validators/openapi_check.cjs >/dev/null; then
    ok "OpenAPI ok"
  else
    die "OpenAPI check falhou"
  fi
else
  warn "openapi_check.cjs não encontrado — pulando"
fi

# 4.6 Fênix dry-run (se existir)
if [[ -x ".fenix/scripts/fenix-dry-run.sh" ]]; then
  if bash .fenix/scripts/fenix-dry-run.sh >/dev/null; then
    ok "Fênix dry-run ok"
  else
    die "Fênix dry-run falhou"
  fi
else
  warn "Fênix dry-run não encontrado — pulando"
fi

# 5) Opcional: atualizar TREE.md rápido (sem node_modules, .git etc)
if command -v tree >/dev/null; then
  say "🌲 Atualizando TREE.md (nível 6)"
  tree -a -I 'node_modules|dist|.git|coverage|.turbo|pnpm-store|.pnpm-store|.cache' -L 6 > TREE.md || true
  git add TREE.md || true
  (git commit -m "chore(docs): atualiza TREE.md pós-limpeza" && git push) >/dev/null || true
else
  warn "tree não instalado — pulando TREE.md"
fi

say ""
ok "Tudo pronto!"
say "• Branch atual: $(git rev-parse --abbrev-ref HEAD)"
say "• Se o PR estiver em auto-merge, ele entra assim que os checks/políticas concluírem."
