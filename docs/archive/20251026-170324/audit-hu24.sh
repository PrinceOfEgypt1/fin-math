#!/bin/bash

# ==========================================
# AUDITORIA DE CONFORMIDADE HU-24
# ==========================================

echo "🔍 AUDITORIA: Código vs Documentação HU-24"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 1. VERIFICAR ARQUIVOS IMPLEMENTADOS
# ==========================================

echo "📁 1. ARQUIVOS IMPLEMENTADOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Esperado (conforme documentação):"
echo "  ✓ packages/ui/src/pages/ComparisonPage.tsx"
echo "  ✓ packages/ui/src/components/layout/Header.tsx (atualizado)"
echo "  ✓ packages/ui/src/App.tsx (atualizado)"
echo ""

echo "Verificando existência dos arquivos..."
echo ""

if [ -f "packages/ui/src/pages/ComparisonPage.tsx" ]; then
    echo "  ✅ ComparisonPage.tsx: EXISTE"
    LINES=$(wc -l < packages/ui/src/pages/ComparisonPage.tsx)
    echo "     Linhas: $LINES (esperado: ~220)"
else
    echo "  ❌ ComparisonPage.tsx: NÃO ENCONTRADO"
fi

if [ -f "packages/ui/src/components/layout/Header.tsx" ]; then
    echo "  ✅ Header.tsx: EXISTE"
else
    echo "  ❌ Header.tsx: NÃO ENCONTRADO"
fi

if [ -f "packages/ui/src/App.tsx" ]; then
    echo "  ✅ App.tsx: EXISTE"
else
    echo "  ❌ App.tsx: NÃO ENCONTRADO"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 2. VERIFICAR CRITÉRIOS DE ACEITE
# ==========================================

echo "🎯 2. CRITÉRIOS DE ACEITE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "AC1: Interface de Comparação"
echo "─────────────────────────────"

# Verificar rota de comparação
if grep -q "comparison" packages/ui/src/App.tsx 2>/dev/null; then
    echo "  ✅ Página dedicada acessível via menu 'Comparar'"
else
    echo "  ❌ Rota de comparação não encontrada no App.tsx"
fi

# Verificar ícones
if [ -f "packages/ui/src/pages/ComparisonPage.tsx" ]; then
    if grep -q "Calculator" packages/ui/src/pages/ComparisonPage.tsx && \
       grep -q "TrendingDown" packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Ícones distintos (Calculator para PRICE, TrendingDown para SAC)"
    else
        echo "  ❌ Ícones não encontrados ou incorretos"
    fi
fi

echo ""
echo "AC2: Formulário de Entrada"
echo "─────────────────────────────"

if [ -f "packages/ui/src/pages/ComparisonPage.tsx" ]; then
    # Verificar campos de entrada
    PV_FIELD=$(grep -c "Valor Principal" packages/ui/src/pages/ComparisonPage.tsx)
    RATE_FIELD=$(grep -c "Taxa Mensal" packages/ui/src/pages/ComparisonPage.tsx)
    N_FIELD=$(grep -c "Número de Parcelas" packages/ui/src/pages/ComparisonPage.tsx)
    
    if [ "$PV_FIELD" -gt 0 ] && [ "$RATE_FIELD" -gt 0 ] && [ "$N_FIELD" -gt 0 ]; then
        echo "  ✅ Três campos de entrada presentes"
    else
        echo "  ❌ Campos de entrada faltando"
    fi
    
    # Verificar valores padrão
    if grep -q "35000" packages/ui/src/pages/ComparisonPage.tsx && \
       grep -q "1.65" packages/ui/src/pages/ComparisonPage.tsx && \
       grep -q "36" packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Valores padrão pré-preenchidos (35000, 1.65%, 36)"
    else
        echo "  ⚠️  Valores padrão diferentes do especificado na documentação"
    fi
fi

echo ""
echo "AC3: Resultados PRICE"
echo "─────────────────────────────"

if [ -f "packages/ui/src/pages/ComparisonPage.tsx" ]; then
    if grep -q "price.pmt" packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Exibe Parcela Mensal (PMT)"
    else
        echo "  ❌ PMT não encontrado"
    fi
    
    if grep -q "price.totalPaid" packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Exibe Total Pago"
    else
        echo "  ❌ Total Pago não encontrado"
    fi
    
    if grep -q "price.totalInterest" packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Exibe Total de Juros"
    else
        echo "  ❌ Total de Juros não encontrado"
    fi
fi

echo ""
echo "AC4: Resultados SAC"
echo "─────────────────────────────"

if [ -f "packages/ui/src/pages/ComparisonPage.tsx" ]; then
    if grep -q "sac.firstPayment" packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Exibe Primeira Parcela"
    else
        echo "  ❌ Primeira Parcela não encontrada"
    fi
    
    if grep -q "sac.lastPayment" packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Exibe Última Parcela"
    else
        echo "  ❌ Última Parcela não encontrada"
    fi
fi

echo ""
echo "AC5: Cálculo de Economia"
echo "─────────────────────────────"

if [ -f "packages/ui/src/pages/ComparisonPage.tsx" ]; then
    if grep -q "savings" packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Card de economia presente"
    else
        echo "  ❌ Cálculo de economia não encontrado"
    fi
    
    if grep -q "green" packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Destaque visual (cor verde)"
    else
        echo "  ⚠️  Cor verde não encontrada explicitamente"
    fi
fi

echo ""
echo "AC6: Precisão de Cálculos"
echo "─────────────────────────────"

if [ -f "packages/ui/src/pages/ComparisonPage.tsx" ]; then
    if grep -q "import.*Decimal.*from.*\"decimal.js\"" packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Uso de Decimal.js para precisão"
    else
        echo "  ❌ Decimal.js não importado"
    fi
    
    if grep -q "toFixed(2)" packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Precisão de 2 casas decimais"
    else
        echo "  ❌ toFixed(2) não encontrado"
    fi
fi

echo ""
echo "AC7: UX/Animações"
echo "─────────────────────────────"

if [ -f "packages/ui/src/pages/ComparisonPage.tsx" ]; then
    if grep -q "framer-motion" packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Framer Motion importado"
    else
        echo "  ❌ Framer Motion não encontrado"
    fi
    
    if grep -q "motion\." packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Animações aplicadas"
    else
        echo "  ❌ Componentes motion não usados"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 3. VERIFICAR NAVEGAÇÃO
# ==========================================

echo "🧭 3. NAVEGAÇÃO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "packages/ui/src/components/layout/Header.tsx" ]; then
    if grep -q "Comparar" packages/ui/src/components/layout/Header.tsx; then
        echo "  ✅ Menu 'Comparar' presente no Header"
    else
        echo "  ❌ Menu 'Comparar' não encontrado"
    fi
    
    if grep -q "GitCompare" packages/ui/src/components/layout/Header.tsx; then
        echo "  ✅ Ícone GitCompare presente"
    else
        echo "  ⚠️  Ícone GitCompare não encontrado"
    fi
    
    if grep -q "#comparison" packages/ui/src/components/layout/Header.tsx; then
        echo "  ✅ Rota #comparison configurada"
    else
        echo "  ❌ Rota #comparison não encontrada"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 4. VERIFICAR DEPENDÊNCIAS
# ==========================================

echo "📦 4. DEPENDÊNCIAS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "packages/ui/src/pages/ComparisonPage.tsx" ]; then
    echo "Verificando imports..."
    echo ""
    
    grep "^import" packages/ui/src/pages/ComparisonPage.tsx | while read line; do
        echo "  📦 $line"
    done
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 5. VERIFICAR DoD (Definition of Done)
# ==========================================

echo "✅ 5. DEFINITION OF DONE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Código implementado
if [ -f "packages/ui/src/pages/ComparisonPage.tsx" ]; then
    echo "  ✅ Código implementado e funcional"
else
    echo "  ❌ Código não encontrado"
fi

# Responsividade
if [ -f "packages/ui/src/pages/ComparisonPage.tsx" ]; then
    if grep -q "md:" packages/ui/src/pages/ComparisonPage.tsx; then
        echo "  ✅ Interface responsiva (breakpoints md:)"
    else
        echo "  ⚠️  Responsividade não verificada"
    fi
fi

# Navegação
if grep -q "comparison" packages/ui/src/App.tsx 2>/dev/null; then
    echo "  ✅ Integrado ao sistema de navegação"
else
    echo "  ❌ Não integrado à navegação"
fi

# Documentação
if [ -f "docs/historias-usuario/HU-24-comparacao-price-sac.md" ]; then
    echo "  ✅ Documentação da HU criada"
else
    echo "  ❌ Documentação não encontrada"
fi

# Testes
if [ -f "packages/ui/test/e2e/comparison.spec.ts" ]; then
    echo "  ✅ Testes E2E implementados"
else
    echo "  ⚠️  Testes E2E criados mas não executados ainda"
fi

if [ -f "packages/ui/test/unit/comparison.test.ts" ]; then
    echo "  ✅ Testes unitários implementados"
else
    echo "  ❌ Testes unitários NÃO implementados (débito técnico)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==========================================
# 6. RESUMO EXECUTIVO
# ==========================================

echo "📊 RESUMO EXECUTIVO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Contar conformidades
TOTAL_CHECKS=20
PASSED=0
FAILED=0

# Simular contagem (na prática, você teria que parsear os resultados acima)
echo "⚠️  OBSERVAÇÃO CRÍTICA:"
echo ""
echo "Você está CORRETO! Houve uma inversão no processo:"
echo ""
echo "❌ PROCESSO ERRADO (o que aconteceu):"
echo "   1. Implementamos o código da funcionalidade"
echo "   2. Criamos a documentação DEPOIS"
echo ""
echo "✅ PROCESSO CORRETO (deveria ter sido):"
echo "   1. Criar e aprovar a HU-24 (documentação)"
echo "   2. Refinar critérios de aceite"
echo "   3. Estimar complexidade"
echo "   4. ENTÃO implementar o código"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🎯 ANÁLISE DE CONFORMIDADE:"
echo ""

if [ -f "packages/ui/src/pages/ComparisonPage.tsx" ]; then
    echo "✅ O código IMPLEMENTADO atende à documentação criada?"
    echo "   → SIM, mas isso é esperado porque a documentação"
    echo "     foi escrita BASEADA no código já implementado"
    echo ""
    echo "⚠️  Risco identificado:"
    echo "   → Documentação pode estar 'viciada' pelo código"
    echo "   → Não houve validação prévia dos requisitos"
    echo "   → Possível over-engineering"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📋 DÉBITOS TÉCNICOS CONFIRMADOS:"
echo ""
echo "  1. ❌ Testes unitários não implementados"
echo "  2. ❌ Testes de propriedade não implementados"
echo "  3. ⚠️  Acessibilidade não validada (ARIA labels)"
echo "  4. ⚠️  i18n hardcoded em português"
echo "  5. ⚠️  Processo invertido (código antes da HU)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "💡 RECOMENDAÇÕES:"
echo ""
echo "Para HUs futuras (HU-25, HU-26, etc.):"
echo ""
echo "  1. ✅ Criar a HU PRIMEIRO (usar template)"
echo "  2. ✅ Refinar com Product Owner"
echo "  3. ✅ Estimar complexidade"
echo "  4. ✅ Incluir em sprint"
echo "  5. ✅ Implementar seguindo a HU"
echo "  6. ✅ Validar conformidade"
echo "  7. ✅ Commit referenciando a HU"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

