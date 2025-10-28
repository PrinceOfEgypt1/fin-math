#!/bin/bash
# teste-completo-sprint2.sh
# Bateria completa de testes para validar Sprint 2

set -e

echo "🧪 ======================================"
echo "   TESTE COMPLETO - SPRINT 2"
echo "========================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SUCCESS=0
FAILED=0

test_step() {
    local test_name="$1"
    echo -n "🔍 $test_name... "
}

test_pass() {
    echo -e "${GREEN}✅ PASS${NC}"
    ((SUCCESS++))
}

test_fail() {
    local error="$1"
    echo -e "${RED}❌ FAIL${NC}"
    echo "   Erro: $error"
    ((FAILED++))
}

# ============================================
# 1. TESTES DE AMBIENTE
# ============================================
echo "📦 1/6 - VERIFICANDO AMBIENTE"
echo "----------------------------"

test_step "Node.js instalado"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✅ PASS${NC} ($NODE_VERSION)"
    ((SUCCESS++))
else
    test_fail "Node.js não encontrado"
fi

test_step "pnpm instalado"
if command -v pnpm &> /dev/null; then
    PNPM_VERSION=$(pnpm --version)
    echo -e "${GREEN}✅ PASS${NC} (v$PNPM_VERSION)"
    ((SUCCESS++))
else
    test_fail "pnpm não encontrado"
fi

test_step "Git configurado"
if [ -d ".git" ]; then
    CURRENT_BRANCH=$(git branch --show-current)
    echo -e "${GREEN}✅ PASS${NC} (branch: $CURRENT_BRANCH)"
    ((SUCCESS++))
else
    test_fail "Não é um repositório git"
fi

echo ""

# ============================================
# 2. TESTES DE BUILD
# ============================================
echo "🔨 2/6 - TESTES DE BUILD"
echo "------------------------"

test_step "Build do Engine"
cd packages/engine
if pnpm build > /dev/null 2>&1; then
    test_pass
else
    test_fail "Build do engine falhou"
fi
cd ../..

test_step "Build da API"
cd packages/api
if pnpm build > /dev/null 2>&1; then
    test_pass
else
    test_fail "Build da API falhou"
fi
cd ../..

echo ""

# ============================================
# 3. TESTES UNITÁRIOS E INTEGRAÇÃO
# ============================================
echo "🧪 3/6 - TESTES UNITÁRIOS"
echo "-------------------------"

test_step "Testes da API"
cd packages/api
TEST_OUTPUT=$(pnpm test 2>&1)
if echo "$TEST_OUTPUT" | grep -q "Test Files.*passed"; then
    TESTS_PASSED=$(echo "$TEST_OUTPUT" | grep -oP '\d+(?= passed)' | head -1)
    echo -e "${GREEN}✅ PASS${NC} ($TESTS_PASSED testes passando)"
    ((SUCCESS++))
else
    test_fail "Alguns testes falharam"
fi
cd ../..

echo ""

# ============================================
# 4. TESTES DA API EM EXECUÇÃO
# ============================================
echo "🚀 4/6 - TESTES DE API (SERVIDOR RODANDO)"
echo "------------------------------------------"

# Iniciar servidor em background
cd packages/api
echo "   Iniciando servidor..."
pnpm dev > /tmp/finmath-server.log 2>&1 &
SERVER_PID=$!
cd ../..

# Aguardar servidor iniciar
sleep 5

test_step "Servidor iniciou"
if ps -p $SERVER_PID > /dev/null; then
    test_pass
else
    test_fail "Servidor não iniciou"
    kill $SERVER_PID 2>/dev/null || true
    exit 1
fi

test_step "Swagger UI acessível"
if curl -s http://localhost:3001/api-docs > /dev/null; then
    test_pass
else
    test_fail "Swagger UI não responde"
fi

test_step "POST /api/price"
PRICE_RESPONSE=$(curl -s -X POST http://localhost:3001/api/price \
  -H "Content-Type: application/json" \
  -d '{"pv":100000,"rate":0.12,"n":12}')

if echo "$PRICE_RESPONSE" | grep -q "snapshotId"; then
    SNAPSHOT_ID=$(echo "$PRICE_RESPONSE" | grep -o '"snapshotId":"[^"]*"' | cut -d'"' -f4)
    echo -e "${GREEN}✅ PASS${NC} (snapshotId: ${SNAPSHOT_ID:0:8}...)"
    ((SUCCESS++))
else
    test_fail "Resposta não contém snapshotId"
fi

test_step "GET /api/snapshot/:id"
if [ -n "$SNAPSHOT_ID" ]; then
    SNAPSHOT_RESPONSE=$(curl -s http://localhost:3001/api/snapshot/$SNAPSHOT_ID)
    if echo "$SNAPSHOT_RESPONSE" | grep -q "hash"; then
        test_pass
    else
        test_fail "Snapshot não encontrado"
    fi
else
    test_fail "Sem snapshotId para testar"
fi

test_step "POST /api/cet/basic"
CET_RESPONSE=$(curl -s -X POST http://localhost:3001/api/cet/basic \
  -H "Content-Type: application/json" \
  -d '{"pv":100000,"rate":0.12,"n":12,"iof":150,"tac":50}')

if echo "$CET_RESPONSE" | grep -q "cet"; then
    test_pass
else
    test_fail "CET não calculado"
fi

test_step "POST /api/validate/schedule"
VALIDATE_RESPONSE=$(curl -s -X POST http://localhost:3001/api/validate/schedule \
  -H "Content-Type: application/json" \
  -d '{
    "input":{"pv":100000,"rate":0.12,"n":3,"system":"price"},
    "expected":[
      {"k":1,"pmt":40211.48,"interest":1000,"amort":39211.48,"balance":60788.52}
    ],
    "actual":[
      {"k":1,"pmt":40211.48,"interest":1000,"amort":39211.48,"balance":60788.52}
    ]
  }')

if echo "$VALIDATE_RESPONSE" | grep -q '"valid":true'; then
    test_pass
else
    test_fail "Validação não funcionou"
fi

test_step "POST /api/sac (deve retornar 501)"
SAC_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST http://localhost:3001/api/sac \
  -H "Content-Type: application/json" \
  -d '{"pv":100000,"rate":0.12,"n":12}')

HTTP_CODE=$(echo "$SAC_RESPONSE" | tail -n1)
if [ "$HTTP_CODE" = "501" ]; then
    test_pass
else
    test_fail "Esperado 501, recebeu $HTTP_CODE"
fi

# Parar servidor
echo ""
echo "   Parando servidor..."
kill $SERVER_PID 2>/dev/null || true
sleep 2

echo ""

# ============================================
# 5. TESTES DE ESTRUTURA
# ============================================
echo "📁 5/6 - ESTRUTURA DO PROJETO"
echo "-----------------------------"

test_step "Arquivo package.json existe"
if [ -f "package.json" ]; then
    test_pass
else
    test_fail "package.json não encontrado"
fi

test_step "Diretório packages/api existe"
if [ -d "packages/api" ]; then
    test_pass
else
    test_fail "packages/api não encontrado"
fi

test_step "Diretório packages/engine existe"
if [ -d "packages/engine" ]; then
    test_pass
else
    test_fail "packages/engine não encontrado"
fi

test_step "Scripts organizados em scripts/sprint2-dev"
if [ -d "scripts/sprint2-dev" ]; then
    SCRIPT_COUNT=$(ls scripts/sprint2-dev/*.sh 2>/dev/null | wc -l)
    echo -e "${GREEN}✅ PASS${NC} ($SCRIPT_COUNT scripts)"
    ((SUCCESS++))
else
    test_fail "scripts/sprint2-dev não encontrado"
fi

test_step "Sem scripts na raiz"
ROOT_SCRIPTS=$(ls *.sh 2>/dev/null | wc -l)
if [ "$ROOT_SCRIPTS" -eq 0 ]; then
    test_pass
else
    test_fail "$ROOT_SCRIPTS scripts encontrados na raiz"
fi

test_step "Arquivos H21 criados"
H21_FILES=0
[ -f "packages/api/src/controllers/snapshot.controller.ts" ] && ((H21_FILES++))
[ -f "packages/api/src/services/snapshot.service.ts" ] && ((H21_FILES++))
[ -f "packages/api/src/schemas/snapshot.schema.ts" ] && ((H21_FILES++))
[ -f "packages/api/src/routes/snapshot.routes.ts" ] && ((H21_FILES++))

if [ $H21_FILES -eq 4 ]; then
    test_pass
else
    test_fail "Apenas $H21_FILES/4 arquivos H21 encontrados"
fi

test_step "Arquivos H22 criados"
H22_FILES=0
[ -f "packages/api/src/controllers/validator.controller.ts" ] && ((H22_FILES++))
[ -f "packages/api/src/services/validator.service.ts" ] && ((H22_FILES++))
[ -f "packages/api/src/schemas/validator.schema.ts" ] && ((H22_FILES++))
[ -f "packages/api/src/routes/validator.routes.ts" ] && ((H22_FILES++))

if [ $H22_FILES -eq 4 ]; then
    test_pass
else
    test_fail "Apenas $H22_FILES/4 arquivos H22 encontrados"
fi

echo ""

# ============================================
# 6. TESTES DE GIT
# ============================================
echo "🔧 6/6 - ESTADO DO GIT"
echo "----------------------"

test_step "Working tree limpo"
if [ -z "$(git status --porcelain)" ]; then
    test_pass
else
    test_fail "Há mudanças não commitadas"
fi

test_step "Branch main existe"
if git show-ref --verify --quiet refs/heads/main; then
    test_pass
else
    test_fail "Branch main não existe"
fi

test_step "Branch sprint-2 existe"
if git show-ref --verify --quiet refs/heads/sprint-2; then
    test_pass
else
    test_fail "Branch sprint-2 não existe"
fi

test_step "Commits da Sprint 2 na main"
SPRINT2_COMMITS=$(git log --oneline --grep="H21\|H22\|sprint-2" main | wc -l)
if [ $SPRINT2_COMMITS -ge 3 ]; then
    echo -e "${GREEN}✅ PASS${NC} ($SPRINT2_COMMITS commits)"
    ((SUCCESS++))
else
    test_fail "Esperado >= 3 commits, encontrado $SPRINT2_COMMITS"
fi

echo ""

# ============================================
# RESULTADO FINAL
# ============================================
echo "========================================"
echo "📊 RESULTADO FINAL"
echo "========================================"
echo ""
echo -e "✅ Testes passaram: ${GREEN}$SUCCESS${NC}"
echo -e "❌ Testes falharam: ${RED}$FAILED${NC}"
echo ""

TOTAL=$((SUCCESS + FAILED))
PERCENTAGE=$((SUCCESS * 100 / TOTAL))

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 SUCESSO TOTAL! Todos os testes passaram!${NC}"
    echo ""
    echo "✅ Sprint 2 está 100% funcional e pronta para produção!"
    exit 0
elif [ $PERCENTAGE -ge 80 ]; then
    echo -e "${YELLOW}⚠️  APROVADO COM RESSALVAS ($PERCENTAGE%)${NC}"
    echo ""
    echo "A maioria dos testes passou, mas há algumas falhas."
    exit 1
else
    echo -e "${RED}❌ FALHOU - Muitos testes falharam ($PERCENTAGE%)${NC}"
    echo ""
    echo "Revise os erros acima e corrija antes de continuar."
    exit 2
fi
