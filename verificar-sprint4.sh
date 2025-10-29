#!/bin/bash
# Salve como: ~/workspace/fin-math/verificar-sprint4.sh
# Execute: bash verificar-sprint4.sh

cd ~/workspace/fin-math

echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║              VERIFICAÇÃO SPRINT 4 - FINMATH                              ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""

# ==============================================================================
# 1. ESTRUTURA GERAL DO PROJETO
# ==============================================================================
echo "📁 1. ESTRUTURA GERAL DO PROJETO"
echo "─────────────────────────────────────────────────────────────────────────"
tree -L 2 -I 'node_modules|dist|build|.git' . 2>/dev/null || find . -maxdepth 2 -type d | grep -v node_modules | grep -v .git
echo ""

# ==============================================================================
# 2. VERIFICAR ACESSIBILIDADE (PARTE COMPLETA - 60%)
# ==============================================================================
echo "✅ 2. ACESSIBILIDADE - ITENS COMPLETOS (60%)"
echo "─────────────────────────────────────────────────────────────────────────"

echo "2.1. Design System A11y"
if [ -d "docs/design-system" ]; then
    echo "   ✅ docs/design-system/ existe"
    ls -lh docs/design-system/
else
    echo "   ❌ docs/design-system/ NÃO encontrado"
fi
echo ""

echo "2.2. Tokens Semânticos (Tailwind)"
if [ -f "packages/ui/tailwind.config.js" ]; then
    echo "   ✅ tailwind.config.js existe"
    echo "   Buscando tokens semânticos (--surface, --text):"
    grep -E "(--surface|--text|--primary|--secondary)" packages/ui/tailwind.config.js | head -10
else
    echo "   ❌ tailwind.config.js NÃO encontrado"
fi
echo ""

echo "2.3. Foco Visível (CSS)"
if [ -f "packages/ui/src/styles.css" ] || [ -f "packages/ui/src/globals.css" ]; then
    echo "   ✅ Arquivo de estilos existe"
    echo "   Buscando :focus-visible:"
    grep -r "focus-visible" packages/ui/src/ --include="*.css" || echo "   ⚠️  :focus-visible não encontrado"
else
    echo "   ❌ Arquivo de estilos NÃO encontrado"
fi
echo ""

echo "2.4. Navegação por Teclado (Componentes)"
if [ -d "packages/ui/src/components" ]; then
    echo "   ✅ Diretório de componentes existe"
    echo "   Componentes principais:"
    ls packages/ui/src/components/*.tsx 2>/dev/null | wc -l
    ls packages/ui/src/components/*.tsx 2>/dev/null | head -10
else
    echo "   ❌ Diretório de componentes NÃO encontrado"
fi
echo ""

echo "2.5. ARIA Labels (ExplainPanel)"
if [ -f "packages/ui/src/components/ExplainPanel.tsx" ]; then
    echo "   ✅ ExplainPanel.tsx existe"
    echo "   Buscando aria- attributes:"
    grep -E "aria-" packages/ui/src/components/ExplainPanel.tsx | head -5 || echo "   ⚠️  ARIA attributes não encontrados"
else
    echo "   ❌ ExplainPanel.tsx NÃO encontrado"
fi
echo ""

# ==============================================================================
# 3. VERIFICAR E2E (PARTE PENDENTE - 0%)
# ==============================================================================
echo "❌ 3. TESTES E2E - ITENS PENDENTES (0%)"
echo "─────────────────────────────────────────────────────────────────────────"

echo "3.1. Configuração Playwright"
if [ -f "playwright.config.ts" ] || [ -f "packages/ui/playwright.config.ts" ]; then
    echo "   ✅ playwright.config.ts EXISTE"
    cat playwright.config.ts 2>/dev/null || cat packages/ui/playwright.config.ts 2>/dev/null
else
    echo "   ❌ playwright.config.ts NÃO encontrado"
fi
echo ""

echo "3.2. Diretório de Testes E2E"
if [ -d "test/e2e" ] || [ -d "tests/e2e" ] || [ -d "packages/ui/e2e" ]; then
    echo "   ✅ Diretório E2E EXISTE"
    echo "   Arquivos de teste:"
    find . -path "*/e2e/*.spec.ts" -o -path "*/e2e/*.spec.js" 2>/dev/null
else
    echo "   ❌ Diretório E2E NÃO encontrado"
    echo "   Criando estrutura sugerida:"
    echo "      test/e2e/price-flow.spec.ts"
    echo "      test/e2e/sac-flow.spec.ts"
    echo "      test/e2e/cet-flow.spec.ts"
    echo "      test/e2e/validator-flow.spec.ts"
    echo "      test/e2e/export-flow.spec.ts"
fi
echo ""

echo "3.3. Testes de Acessibilidade (axe-core)"
if [ -d "test/a11y" ] || [ -d "tests/a11y" ]; then
    echo "   ✅ Diretório A11y EXISTE"
    find . -path "*/a11y/*.spec.ts" -o -path "*/a11y/*.test.ts" 2>/dev/null
else
    echo "   ❌ Diretório A11y NÃO encontrado"
fi
echo ""

echo "3.4. Dependências Playwright"
echo "   Verificando package.json:"
if grep -q "playwright" package.json packages/ui/package.json 2>/dev/null; then
    echo "   ✅ Playwright está nas dependências"
    grep "playwright" package.json packages/ui/package.json 2>/dev/null
else
    echo "   ❌ Playwright NÃO encontrado no package.json"
fi
echo ""

echo "3.5. Dependências axe-core"
if grep -q "axe-core" package.json packages/ui/package.json 2>/dev/null; then
    echo "   ✅ axe-core está nas dependências"
    grep "axe-core" package.json packages/ui/package.json 2>/dev/null
else
    echo "   ❌ axe-core NÃO encontrado no package.json"
fi
echo ""

# ==============================================================================
# 4. VERIFICAR CI/CD
# ==============================================================================
echo "🔄 4. INTEGRAÇÃO CI/CD"
echo "─────────────────────────────────────────────────────────────────────────"

if [ -f ".github/workflows/ci.yml" ]; then
    echo "   ✅ CI workflow existe"
    echo "   Buscando jobs de E2E:"
    grep -A 10 "e2e" .github/workflows/ci.yml || echo "   ⚠️  Job E2E não encontrado no CI"
else
    echo "   ❌ .github/workflows/ci.yml NÃO encontrado"
fi
echo ""

# ==============================================================================
# 5. SCRIPTS NPM/PNPM
# ==============================================================================
echo "📦 5. SCRIPTS DE TESTE"
echo "─────────────────────────────────────────────────────────────────────────"

echo "   Scripts disponíveis:"
grep "\"test" package.json | head -10
echo ""

if grep -q "test:e2e" package.json packages/ui/package.json 2>/dev/null; then
    echo "   ✅ Script test:e2e EXISTE"
else
    echo "   ❌ Script test:e2e NÃO encontrado"
fi

if grep -q "test:a11y" package.json packages/ui/package.json 2>/dev/null; then
    echo "   ✅ Script test:a11y EXISTE"
else
    echo "   ❌ Script test:a11y NÃO encontrado"
fi
echo ""

# ==============================================================================
# 6. RESUMO FINAL
# ==============================================================================
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                           RESUMO FINAL                                   ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""

echo "📊 STATUS DA SPRINT 4 SEGUNDO O EXCEL:"
echo "   ✅ Acessibilidade (Design, Tokens, Foco, ARIA): 5/5 (100%)"
echo "   ❌ Testes E2E: 0/14 (0%)"
echo "   ⚠️  TOTAL: 5/19 (60%)"
echo ""

echo "🎯 PRÓXIMOS PASSOS PARA COMPLETAR 100%:"
echo "   1. Instalar Playwright: pnpm add -D @playwright/test"
echo "   2. Instalar axe-core: pnpm add -D @axe-core/playwright"
echo "   3. Criar playwright.config.ts"
echo "   4. Criar diretório test/e2e/"
echo "   5. Implementar 15 testes E2E"
echo "   6. Criar diretório test/a11y/"
echo "   7. Implementar testes de acessibilidade"
echo "   8. Adicionar E2E ao CI (.github/workflows/ci.yml)"
echo "   9. Gerar relatório de acessibilidade"
echo "  10. Executar testes cross-browser"
echo ""

echo "⏱️  ESTIMATIVA PARA CONCLUSÃO: 4-6 horas"
echo ""
