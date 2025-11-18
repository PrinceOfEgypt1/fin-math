#!/bin/bash
# investigar-estado-atual.sh

echo "🔍 INVESTIGAÇÃO COMPLETA - FINMATH PROJECT"
echo "=========================================="
echo ""

echo "📊 1. MÓDULOS DO ENGINE"
echo "----------------------"
echo ""

echo "📄 CET.TS (crítico para Sprint 2):"
echo "-----------------------------------"
cat packages/engine/src/modules/cet.ts
echo ""
echo "Tamanho: $(wc -l < packages/engine/src/modules/cet.ts) linhas"
echo ""

echo "📄 AMORTIZATION.TS:"
echo "-------------------"
head -30 packages/engine/src/modules/amortization.ts
echo "... (truncado)"
echo ""

echo "📄 IRR.TS:"
echo "----------"
cat packages/engine/src/modules/irr.ts
echo ""

echo "🧪 2. TESTES UNITÁRIOS"
echo "---------------------"
echo ""
echo "Estrutura:"
ls -lah packages/engine/test/unit/
echo ""

echo "🏆 3. GOLDEN FILES"
echo "-----------------"
echo ""
echo "📁 Onda 1:"
ls -lah packages/engine/test/golden/onda1/ | head -15
echo ""
echo "📁 Onda 2:"
ls -lah packages/engine/test/golden/onda2/ | head -15
echo ""

echo "🌐 4. API - ESTRUTURA"
echo "--------------------"
echo ""
echo "📂 Routes:"
ls -lah packages/api/src/routes/
echo ""
echo "📂 Controllers:"
ls -lah packages/api/src/controllers/ 2>/dev/null || echo "   ❌ Não encontrado"
echo ""
echo "📂 Schemas:"
ls -lah packages/api/src/schemas/ 2>/dev/null || echo "   ❌ Não encontrado"
echo ""
echo "📂 Services:"
ls -lah packages/api/src/services/ 2>/dev/null || echo "   ❌ Não encontrado"
echo ""

echo "🧪 5. RODAR TESTES"
echo "-----------------"
echo ""
echo "Executando testes do engine..."
cd packages/engine
pnpm test 2>&1 | tail -30
cd ../..
echo ""

echo "🏆 6. GOLDEN FILES TEST"
echo "----------------------"
echo ""
echo "Executando golden files test..."
cd packages/engine
pnpm test:golden 2>&1 | tail -30
cd ../..
echo ""

echo "=========================================="
echo "✅ INVESTIGAÇÃO COMPLETA"
