#!/bin/bash
# teste-completo-sprint2-v2.sh
# Versão robusta - continua mesmo com erros

echo "🧪 ======================================"
echo "   TESTE COMPLETO - SPRINT 2 v2"
echo "========================================"
echo ""

SUCCESS=0
FAILED=0

# ============================================
# 1. AMBIENTE
# ============================================
echo "📦 1/6 - AMBIENTE"
echo "----------------"

echo -n "🔍 Node.js... "
if command -v node &> /dev/null; then
    echo "✅ PASS ($(node --version))"
    ((SUCCESS++))
else
    echo "❌ FAIL"
    ((FAILED++))
fi

echo -n "🔍 pnpm... "
if command -v pnpm &> /dev/null; then
    echo "✅ PASS (v$(pnpm --version))"
    ((SUCCESS++))
else
    echo "❌ FAIL"
    ((FAILED++))
fi

echo -n "🔍 Git... "
if [ -d ".git" ]; then
    echo "✅ PASS ($(git branch --show-current))"
    ((SUCCESS++))
else
    echo "❌ FAIL"
    ((FAILED++))
fi

echo ""

# ============================================
# 2. BUILD
# ============================================
echo "🔨 2/6 - BUILD"
echo "--------------"

echo -n "🔍 Build Engine... "
cd packages/engine
if pnpm build > /tmp/build-engine.log 2>&1; then
    echo "✅ PASS"
    ((SUCCESS++))
else
    echo "❌ FAIL"
    ((FAILED++))
fi
cd ../..

echo -n "🔍 Build API... "
cd packages/api
if pnpm build > /tmp/build-api.log 2>&1; then
    echo "✅ PASS"
    ((SUCCESS++))
else
    echo "❌ FAIL (ver /tmp/build-api.log)"
    ((FAILED++))
fi
cd ../..

echo ""

# ============================================
# 3. TESTES
# ============================================
echo "🧪 3/6 - TESTES"
echo "---------------"

echo -n "🔍 Testes API... "
cd packages/api
if pnpm test > /tmp/test-api.log 2>&1; then
    PASSED=$(grep -oP '\d+(?= passed)' /tmp/test-api.log | head -1)
    echo "✅ PASS ($PASSED testes)"
    ((SUCCESS++))
else
    echo "❌ FAIL (ver /tmp/test-api.log)"
    ((FAILED++))
fi
cd ../..

echo ""

# ============================================
# 4. API RODANDO
# ============================================
echo "🚀 4/6 - API RODANDO"
echo "--------------------"

cd packages/api
echo "   Iniciando servidor (aguarde 5s)..."
pnpm dev > /tmp/server.log 2>&1 &
SERVER_PID=$!
sleep 5
cd ../..

echo -n "🔍 Servidor... "
if ps -p $SERVER_PID > /dev/null 2>&1; then
    echo "✅ PASS (PID: $SERVER_PID)"
    ((SUCCESS++))
else
    echo "❌ FAIL"
    ((FAILED++))
    cat /tmp/server.log | tail -20
fi

echo -n "🔍 Swagger UI... "
if curl -s http://localhost:3001/api-docs > /dev/null 2>&1; then
    echo "✅ PASS"
    ((SUCCESS++))
else
    echo "❌ FAIL"
    ((FAILED++))
fi

echo -n "🔍 POST /api/price... "
RESPONSE=$(curl -s -X POST http://localhost:3001/api/price \
  -H "Content-Type: application/json" \
  -d '{"pv":100000,"rate":0.12,"n":12}' 2>/dev/null)

if echo "$RESPONSE" | grep -q "snapshotId"; then
    SNAPSHOT_ID=$(echo "$RESPONSE" | grep -o '"snapshotId":"[^"]*"' | cut -d'"' -f4)
    echo "✅ PASS (snapshot: ${SNAPSHOT_ID:0:8}...)"
    ((SUCCESS++))
else
    echo "❌ FAIL"
    ((FAILED++))
fi

echo -n "🔍 GET /api/snapshot/:id... "
if [ -n "$SNAPSHOT_ID" ]; then
    SNAP_RESP=$(curl -s http://localhost:3001/api/snapshot/$SNAPSHOT_ID 2>/dev/null)
    if echo "$SNAP_RESP" | grep -q "hash"; then
        echo "✅ PASS"
        ((SUCCESS++))
    else
        echo "❌ FAIL"
        ((FAILED++))
    fi
else
    echo "⏭️  SKIP (sem snapshot)"
fi

echo -n "🔍 POST /api/cet/basic... "
CET=$(curl -s -X POST http://localhost:3001/api/cet/basic \
  -H "Content-Type: application/json" \
  -d '{"pv":100000,"rate":0.12,"n":12,"iof":150,"tac":50}' 2>/dev/null)

if echo "$CET" | grep -q "cet"; then
    echo "✅ PASS"
    ((SUCCESS++))
else
    echo "❌ FAIL"
    ((FAILED++))
fi

echo -n "🔍 POST /api/validate/schedule... "
VAL=$(curl -s -X POST http://localhost:3001/api/validate/schedule \
  -H "Content-Type: application/json" \
  -d '{"input":{"pv":100000,"rate":0.12,"n":1,"system":"price"},"expected":[{"k":1,"pmt":112000,"interest":1000,"amort":111000,"balance":0}],"actual":[{"k":1,"pmt":112000,"interest":1000,"amort":111000,"balance":0}]}' 2>/dev/null)

if echo "$VAL" | grep -q '"valid":true'; then
    echo "✅ PASS"
    ((SUCCESS++))
else
    echo "❌ FAIL"
    ((FAILED++))
fi

echo -n "🔍 POST /api/sac (501)... "
HTTP=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:3001/api/sac \
  -H "Content-Type: application/json" \
  -d '{"pv":100000,"rate":0.12,"n":12}' 2>/dev/null)

if [ "$HTTP" = "501" ]; then
    echo "✅ PASS"
    ((SUCCESS++))
else
    echo "❌ FAIL (HTTP: $HTTP)"
    ((FAILED++))
fi

kill $SERVER_PID 2>/dev/null
sleep 2

echo ""

# ============================================
# 5. ESTRUTURA
# ============================================
echo "📁 5/6 - ESTRUTURA"
echo "------------------"

echo -n "🔍 H21 files... "
H21=0
[ -f "packages/api/src/controllers/snapshot.controller.ts" ] && ((H21++))
[ -f "packages/api/src/services/snapshot.service.ts" ] && ((H21++))
[ -f "packages/api/src/schemas/snapshot.schema.ts" ] && ((H21++))
[ -f "packages/api/src/routes/snapshot.routes.ts" ] && ((H21++))

if [ $H21 -eq 4 ]; then
    echo "✅ PASS (4/4)"
    ((SUCCESS++))
else
    echo "❌ FAIL ($H21/4)"
    ((FAILED++))
fi

echo -n "🔍 H22 files... "
H22=0
[ -f "packages/api/src/controllers/validator.controller.ts" ] && ((H22++))
[ -f "packages/api/src/services/validator.service.ts" ] && ((H22++))
[ -f "packages/api/src/schemas/validator.schema.ts" ] && ((H22++))
[ -f "packages/api/src/routes/validator.routes.ts" ] && ((H22++))

if [ $H22 -eq 4 ]; then
    echo "✅ PASS (4/4)"
    ((SUCCESS++))
else
    echo "❌ FAIL ($H22/4)"
    ((FAILED++))
fi

echo -n "🔍 Scripts organizados... "
if [ -d "scripts/sprint2-dev" ]; then
    COUNT=$(ls scripts/sprint2-dev/*.sh 2>/dev/null | wc -l)
    echo "✅ PASS ($COUNT scripts)"
    ((SUCCESS++))
else
    echo "❌ FAIL"
    ((FAILED++))
fi

echo -n "🔍 Raiz limpa... "
ROOT=$(ls *.sh 2>/dev/null | wc -l)
if [ "$ROOT" -eq 0 ]; then
    echo "✅ PASS"
    ((SUCCESS++))
else
    echo "❌ FAIL ($ROOT scripts na raiz)"
    ((FAILED++))
fi

echo ""

# ============================================
# 6. GIT
# ============================================
echo "🔧 6/6 - GIT"
echo "------------"

echo -n "🔍 Working tree... "
if [ -z "$(git status --porcelain)" ]; then
    echo "✅ PASS (clean)"
    ((SUCCESS++))
else
    echo "❌ FAIL (dirty)"
    ((FAILED++))
fi

echo -n "🔍 Commits Sprint 2... "
COMMITS=$(git log --oneline --grep="H21\|H22\|sprint" main 2>/dev/null | wc -l)
if [ $COMMITS -ge 3 ]; then
    echo "✅ PASS ($COMMITS commits)"
    ((SUCCESS++))
else
    echo "❌ FAIL ($COMMITS commits)"
    ((FAILED++))
fi

echo ""

# ============================================
# RESULTADO
# ============================================
echo "========================================"
echo "📊 RESULTADO FINAL"
echo "========================================"
echo ""

TOTAL=$((SUCCESS + FAILED))
PERC=$((SUCCESS * 100 / TOTAL))

echo "✅ Sucesso: $SUCCESS/$TOTAL ($PERC%)"
echo "❌ Falhas:  $FAILED/$TOTAL"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 PERFEITO! Todos os testes passaram!"
    exit 0
elif [ $PERC -ge 80 ]; then
    echo "⚠️  APROVADO ($PERC%) - Pequenas falhas"
    exit 0
else
    echo "❌ REPROVADO ($PERC%)"
    exit 1
fi
