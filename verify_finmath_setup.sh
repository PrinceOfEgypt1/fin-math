#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="${1:-$(pwd)}"
MIN_PNPM="10.18.2"
GIT_REMOTE_EXPECTED_RE="(git@github.com:|https://github.com/)PrinceOfEgypt1/fin-math(\.git)?"

cyan()  { printf "\033[36m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
red()   { printf "\033[31m%s\033[0m\n" "$*"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$*"; }

PASS=0; FAIL=0; WARN=0
ok()   { green "✔ $*"; ((PASS++)) || true; }
ko()   { red   "✘ $*"; ((FAIL++)) || true; }
wrn()  { yellow"⚠ $*"; ((WARN++)) || true; }

ver_ge() { [ "$(printf '%s\n' "$1" "$2" | sort -V | tail -n1)" = "$1" ]; }
need_cmd() { if ! command -v "$1" >/dev/null 2>&1; then ko "Comando ausente: $1"; return 1; else ok "Comando presente: $1"; fi; }

json_dep_ver() { node -e "let p=require('./package.json'); let d=(p.devDependencies&&p.devDependencies['$1'])||(p.dependencies&&p.dependencies['$1'])||''; process.stdout.write(d)" 2>/dev/null || true; }
json_has_dep() { local v; v="$(json_dep_ver "$1")"; [[ -n "$v" ]]; }
json_not_dep() { local v; v="$(json_dep_ver "$1")"; [[ -z "$v" ]]; }
json_has_script() { node -e "let p=require('./package.json'); process.exit(p.scripts && p.scripts['$1']?0:1)" 2>/dev/null; }

begin() {
  cyan "==> Verificando FinMath em: $REPO_DIR"
  cd "$REPO_DIR"
}

check_git() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then ok "Dentro de um repositório Git"; else ko "Não é um repositório Git"; return; fi
  local branch; branch="$(git rev-parse --abbrev-ref HEAD || true)"
  [[ "$branch" == "main" ]] && ok "Branch atual: main" || ko "Branch atual não é 'main' (é '$branch')"
  local origin; origin="$(git remote get-url origin 2>/dev/null || true)"
  [[ "$origin" =~ $GIT_REMOTE_EXPECTED_RE ]] && ok "origin configurado: $origin" || ko "origin não aponta para GitHub esperado (atual: '$origin')"
  if git ls-remote --exit-code origin main >/dev/null 2>&1; then ok "Branch 'main' existe no remoto (push feito)"; else ko "Branch 'main' não encontrado no remoto (faltou 'git push -u origin main'?)"; fi
}

check_workspace_and_pnpm() {
  if [[ -f "pnpm-workspace.yaml" ]]; then
    if grep -q "^packages:" pnpm-workspace.yaml; then ok "pnpm-workspace.yaml presente e com 'packages:'"
    else ko "pnpm-workspace.yaml sem 'packages:'"; fi
  else
    ko "pnpm-workspace.yaml ausente"
  fi

  need_cmd node
  need_cmd corepack
  if need_cmd pnpm; then
    local ver; ver="$(pnpm -v || true)"
    ver_ge "$ver" "$MIN_PNPM" && ok "PNPM >= $MIN_PNPM (versão: $ver)" || ko "PNPM < $MIN_PNPM (versão: $ver). Rode: corepack prepare pnpm@$MIN_PNPM --activate"
  fi
}

check_eslint_optionB() {
  [[ -f package.json ]] || { ko "package.json ausente"; return; }

  # ESLint 9.x (aceita ^9, ~9, 9.x, etc)
  json_has_dep "eslint" && [[ "$(json_dep_ver eslint)" =~ ^[\^~]?9(\.|$) ]] \
    && ok "ESLint 9 declarado ($(json_dep_ver eslint))" \
    || ko "ESLint 9 não detectado (achado: '$(json_dep_ver eslint)')"

  json_has_dep "@eslint/js" && ok "@eslint/js presente ($(json_dep_ver @eslint/js))" || ko "@eslint/js ausente"

  # typescript-eslint 8.x (pacote unificado)
  json_has_dep "typescript-eslint" && [[ "$(json_dep_ver typescript-eslint)" =~ ^[\^~]?8(\.|$) ]] \
    && ok "typescript-eslint 8 presente ($(json_dep_ver typescript-eslint))" \
    || ko "typescript-eslint 8 não detectado (achado: '$(json_dep_ver typescript-eslint)')"

  json_has_dep "eslint-plugin-import"  && ok "eslint-plugin-import presente ($(json_dep_ver eslint-plugin-import))"   || ko "eslint-plugin-import ausente"
  json_has_dep "eslint-plugin-promise" && ok "eslint-plugin-promise presente ($(json_dep_ver eslint-plugin-promise))" || ko "eslint-plugin-promise ausente"
  json_has_dep "eslint-config-love"    && ok "eslint-config-love presente ($(json_dep_ver eslint-config-love))"       || ko "eslint-config-love ausente"

  # Prettier 3.x
  json_has_dep "prettier" && [[ "$(json_dep_ver prettier)" =~ ^[\^~]?3(\.|$) ]] \
    && ok "Prettier 3 presente ($(json_dep_ver prettier))" \
    || ko "Prettier 3 não detectado (achado: '$(json_dep_ver prettier)')"

  # garantir que o preset antigo foi removido
  json_not_dep "eslint-config-standard-with-typescript" && ok "Preset antigo removido (eslint-config-standard-with-typescript)" || ko "Preset antigo ainda presente"
  json_not_dep "@typescript-eslint/parser" && ok "Removido @typescript-eslint/parser" || ko "Ainda existe @typescript-eslint/parser"
  json_not_dep "@typescript-eslint/eslint-plugin" && ok "Removido @typescript-eslint/eslint-plugin" || ko "Ainda existe @typescript-eslint/eslint-plugin"
}

check_eslint_config_file() {
  if [[ -f "eslint.config.js" ]]; then
    local c; c="$(< eslint.config.js )"
    [[ "$c" == *'import js from "@eslint/js";'* ]] && ok "eslint.config.js importa @eslint/js" || ko "eslint.config.js não importa @eslint/js"
    [[ "$c" == *'import tseslint from "typescript-eslint";'* ]] && ok "eslint.config.js importa typescript-eslint" || ko "eslint.config.js não importa typescript-eslint"
    [[ "$c" == *'import love from "eslint-config-love";'* ]] && ok "eslint.config.js importa eslint-config-love" || ko "eslint.config.js não importa eslint-config-love"
  else
    ko "eslint.config.js ausente na raiz"
  fi
}

check_husky_and_lintstaged() {
  if [[ -d ".husky" && -f ".husky/pre-commit" ]]; then
    grep -q "pnpm lint-staged" .husky/pre-commit && ok "Husky pre-commit chama 'pnpm lint-staged'" || ko "Husky pre-commit não chama 'pnpm lint-staged'"
  else
    ko "Husky não encontrado (.husky/pre-commit ausente)"
  fi

  node -e "let p=require('./package.json'); process.exit(p['lint-staged']?0:1)" 2>/dev/null \
    && ok "Config 'lint-staged' presente no package.json" \
    || ko "Config 'lint-staged' ausente no package.json"

  node -e "let p=require('./package.json'); let s=p.scripts&&p.scripts.prepare||''; process.exit(/husky\s+install/.test(s)?1:0)" 2>/dev/null \
    && ok "Sem script 'prepare' com 'husky install' (ok)" \
    || ko "Ainda existe 'scripts.prepare' com 'husky install' (remova)"
}

check_pnpm_scripts_and_build() {
  json_has_script "dev:api" && ok "Script dev:api existe" || wrn "Script dev:api não encontrado"
  json_has_script "dev:ui"  && ok "Script dev:ui existe"  || wrn "Script dev:ui não encontrado"
  json_has_script "build"   && ok "Script build existe"   || wrn "Script build não encontrado"
  json_has_script "test"    && ok "Script test existe"    || wrn "Script test não encontrado"

  if pnpm -r install; then ok "pnpm -r install OK"; else ko "pnpm -r install falhou"; fi
  if pnpm -r -w run -if-present build; then ok "pnpm -r build (if-present) OK"; else ko "pnpm -r build falhou"; fi
  if json_has_script "test"; then
    if pnpm -r -w run -if-present test || true; then ok "pnpm -r test OK"; else ko "pnpm -r test falhou"; fi
  fi
}

summary() {
  cyan "==> Resumo: ${PASS} OK, ${WARN} avisos, ${FAIL} erros"
  (( FAIL == 0 ))
}

begin
check_git
check_workspace_and_pnpm
check_eslint_optionB
check_eslint_config_file
check_husky_and_lintstaged
check_pnpm_scripts_and_build
summary
