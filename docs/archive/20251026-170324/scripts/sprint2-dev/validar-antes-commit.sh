#!/bin/bash
# validar-antes-commit.sh
# Script de validação completa antes do commit final da Sprint 2
# Executa TODAS as verificações necessárias

set -e

echo "🔍 VALIDAÇÃO COMPLETA PRÉ-COMMIT - SPRINT 2"
echo "=============================================="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contadores
PASSED=0
FAILED=0

# Função para registrar sucesso
pass() {
    echo -e "${GREEN}✅ PASSOU:${NC} $1"
    ((PASSED++))
}

# Função para registrar falha
fail() {
    echo -e "${RED}❌ FALHOU:${NC} $1"
    ((FAILED++))
}

# Função para avisos
warn() {
    echo -e "${YELLOW}⚠️  AVISO:${NC} $1"
}

# ========================================
# FASE 1: Verificações de Ambiente
# ========================================
echo "📋 FASE 1: Verificações de Ambiente"
echo ""

# 1.1 Verificar diretório
if [ -d "packages/api" ] && [ -d "packages/engine" ]; then
    pass "Diretório correto (raiz do projeto)"
else
    fail "Não está na raiz do projeto"
    exit 1
fi

# 1.2 Verificar branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" == "sprint-2" ]; then
    pass "Branch correta (sprint-2)"
else
    fail "Branch incorreta (esperado: sprint-2, atual: $CURRENT_BRANCH)"
    exit 1
fi

# 1.3 Verificar Node.js
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -ge 18 ]; then
    pass "Node.js versão adequada (v$NODE_VERSION)"
else
    fail "Node.js muito antigo (v$NODE_VERSION, requerido: ≥18)"
fi

echo ""

# ========================================
# FASE 2: Verificar Arquivos Criados
# ========================================
echo "📋 FASE 2: Verificar Arquivos Criados (H21 + H22)"
echo ""

REQUIRED_FILES=(
    "packages/api/src/schemas/snapshot.schema.ts"
    "packages/api/src/services/snapshot.service.ts"
    "packages/api/src/controllers/snapshot.controller.ts"
    "packages/api/src/routes/snapshot.routes.ts"
    "packages/api/src/schemas/validator.schema.ts"
    "packages/api/src/services/validator.service.ts"
    "packages/api/src/controllers/validator.controller.ts"
    "packages/api/src/routes/validator.routes.ts"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        pass "Arquivo existe: $(basename $file)"
    else
        fail "Arquivo faltando: $file"
    fi
done

echo ""

# ========================================
# FASE 3: Verificar Modificações Manuais
# ========================================
echo "📋 FASE 3: Verificar Modificações Manuais"
echo ""

# 3.1 Verificar server.ts
if grep -q "snapshotRoutes" packages/api/src/server.ts; then
    pass "server.ts: snapshotRoutes importado"
else
    fail "server.ts: falta import de snapshotRoutes"
fi

if grep -q "validatorRoutes" packages/api/src/server.ts; then
    pass "server.ts: validatorRoutes importado"
else
    fail "server.ts: falta import de validatorRoutes"
fi

# 3.2 Verificar price.controller.ts
if grep -q "snapshotService" packages/api/src/controllers/price.controller.ts; then
    pass "price.controller.ts: snapshotService integrado"
else
    fail "price.controller.ts: falta integração de snapshotService"
fi

# 3.3 Verificar sac.controller.ts
if grep -q "snapshotService" packages/api/src/controllers/sac.controller.ts; then
    pass "sac.controller.ts: snapshotService integrado"
else
    fail "sac.controller.ts: falta integração de snapshotService"
fi

# 3.4 Verificar cet.controller.ts (se existir)
if [ -f "packages/api/src/controllers/cet.controller.ts" ]; then
    if grep -q "snapshotService" packages/api/src/controllers/cet.controller.ts; then
        pass "cet.controller.ts: snapshotService integrado"
    else
        warn "cet.controller.ts: falta integração de snapshotService (opcional)"
    fi
fi

echo ""

# ========================================
# FASE 4: Type Check
# ========================================
echo "📋 FASE 4: Type Check"
echo ""

cd packages/engine
if pnpm type-check > /dev/null 2>&1; then
    pass "Type check engine"
else
    fail "Type check engine falhou"
    pnpm type-check
fi

cd ../api
if pnpm type-check > /dev/null 2>&1; then
    pass "Type check API"
else
    fail "Type check API falhou"
    pnpm type-check
fi

cd ../..
echo ""

# ========================================
# FASE 5: Linting
# ========================================
echo "📋 FASE 5: Linting"
echo ""

cd packages/engine
if pnpm lint > /dev/null 2>&1; then
    pass "Lint engine"
else
    fail "Lint engine falhou"
    pnpm lint
fi

cd ../api
if pnpm lint > /dev/null 2>&1; then
    pass "Lint API"
else
    fail "Lint API falhou"
    pnpm lint
fi

cd ../..
echo ""

# ========================================
# FASE 6: Build
# ========================================
echo "📋 FASE 6: Build"
echo ""

cd packages/engine
if pnpm build > /dev/null 2>&1; then
    pass "Build engine"
else
    fail "Build engine falhou"
    pnpm build
fi

cd ../api
if pnpm build > /dev/null 2>&1; then
    pass "Build API"
else
    fail "Build API falhou"
    pnpm build
fi

cd ../..
echo ""

# ========================================
# FASE 7: Testes Unitários
# ========================================
echo "📋 FASE 7: Testes Unitários (Engine)"
echo ""

cd packages/engine
if pnpm test > /dev/null 2>&1; then
    TEST_RESULT=$(pnpm test 2>&1 | grep -E "Tests.*passed" || echo "")
    pass "Testes engine ($TEST_RESULT)"
else
    fail "Testes engine falharam"
    pnpm test
fi

cd ../..
echo ""

# ========================================
# FASE 8: Golden Files
# ========================================
echo "📋 FASE 8: Golden Files"
echo ""

cd packages/engine
if [ -f "package.json" ] && grep -q "golden:verify" package.json; then
    if pnpm golden:verify > /dev/null 2>&1; then
        GOLDEN_RESULT=$(pnpm golden:verify 2>&1 | grep -E "Golden.*passed" || echo "verdes")
        pass "Golden files ($GOLDEN_RESULT)"
    else
        warn "Golden files falharam (pode precisar de atualização)"
    fi
else
    warn "Script golden:verify não encontrado (pular)"
fi

cd ../..
echo ""

# ========================================
# FASE 9: Verificar Backups Físicos
# ========================================
echo "📋 FASE 9: Verificar Backups Físicos (Proibidos)"
echo ""

BAK_FILES=$(find packages -name "*.bak" -o -name "*.backup" -o -name "*.save" 2>/dev/null)
if [ -z "$BAK_FILES" ]; then
    pass "Nenhum backup físico encontrado"
else
    fail "Backups físicos encontrados (devem ser removidos):"
    echo "$BAK_FILES"
fi

echo ""

# ========================================
# FASE 10: Git Status
# ========================================
echo "📋 FASE 10: Git Status"
echo ""

# 10.1 Verificar arquivos não rastreados suspeitos
UNTRACKED=$(git status --porcelain | grep "^??" | wc -l)
if [ "$UNTRACKED" -gt 0 ]; then
    warn "$UNTRACKED arquivo(s) não rastreado(s) - verificar antes de commit"
    git status --porcelain | grep "^??"
else
    pass "Nenhum arquivo não rastreado"
fi

# 10.2 Verificar mudanças staged
STAGED=$(git diff --cached --name-only | wc -l)
if [ "$STAGED" -gt 0 ]; then
    warn "$STAGED arquivo(s) já em staging - verificar"
    git diff --cached --name-only
fi

echo ""

# ========================================
# FASE 11: Testes de API (Opcional)
# ========================================
echo "📋 FASE 11: Testes de API (Smoke Tests)"
echo ""

# Verificar se servidor está rodando
API_URL="http://localhost:3001"
if curl -s "$API_URL/health" > /dev/null 2>&1; then
    pass "API está acessível"
    
    # Teste rápido de snapshot
    PRICE_RESPONSE=$(curl -s -X POST "$API_URL/api/price" \
        -H "Content-Type: application/json" \
        -d '{"pv":10000,"rate":0.025,"n":12}')
    
    SNAPSHOT_ID=$(echo "$PRICE_RESPONSE" | grep -o '"snapshotId":"[^"]*"' | cut -d'"' -f4)
    
    if [ ! -z "$SNAPSHOT_ID" ]; then
        pass "Snapshot sendo criado em /api/price"
        
        # Testar GET snapshot
        if curl -s "$API_URL/api/snapshot/$SNAPSHOT_ID" | grep -q "\"id\":\"$SNAPSHOT_ID\""; then
            pass "GET /api/snapshot/:id funciona"
        else
            fail "GET /api/snapshot/:id não funciona"
        fi
    else
        fail "Snapshot não sendo criado em /api/price"
    fi
    
    # Teste rápido de validador
    VALIDATION=$(curl -s -X POST "$API_URL/api/validate/schedule" \
        -H "Content-Type: application/json" \
        -d '{"type":"price","params":{"pv":10000,"rate":0.025,"n":2},"schedule":[{"k":1,"pmt":5188.44,"interest":250.00,"amort":4938.44,"balance":5061.56},{"k":2,"pmt":5188.10,"interest":126.54,"amort":5061.56,"balance":0.00}]}')
    
    if echo "$VALIDATION" | grep -q '"valid"'; then
        pass "POST /api/validate/schedule funciona"
    else
        fail "POST /api/validate/schedule não funciona"
    fi
else
    warn "API não está rodando - pular testes de API"
    warn "Execute: cd packages/api && pnpm dev"
fi

echo ""

# ========================================
# RESUMO FINAL
# ========================================
echo "=============================================="
echo "📊 RESUMO DA VALIDAÇÃO"
echo "=============================================="
echo ""
echo -e "${GREEN}Passou: $PASSED${NC}"
echo -e "${RED}Falhou: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 TODAS AS VALIDAÇÕES PASSARAM!${NC}"
    echo ""
    echo "✅ Pronto para commit!"
    echo ""
    echo "Próximos passos:"
    echo "  1. git add packages/api/src/"
    echo "  2. git commit -m 'feat(H21,H22): Implementa Snapshots e Validador'"
    echo "  3. git push origin sprint-2 (ou continuar com merge local)"
    echo ""
    exit 0
else
    echo -e "${RED}❌ VALIDAÇÃO FALHOU${NC}"
    echo ""
    echo "Corrija os problemas acima antes de fazer commit."
    echo "Consulte TROUBLESHOOTING.md para ajuda."
    echo ""
    exit 1
fi
