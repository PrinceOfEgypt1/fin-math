#!/bin/bash
# modificar-controllers.sh
# Automatiza as 4 modificações manuais necessárias

set -e

echo "🔧 MODIFICANDO AUTOMATICAMENTE OS 4 ARQUIVOS"
echo "=============================================="
echo ""

cd ~/workspace/fin-math

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ========================================
# FUNÇÃO: Verificar se arquivo existe
# ========================================
check_file() {
    if [ ! -f "$1" ]; then
        echo -e "${RED}❌ Arquivo não encontrado: $1${NC}"
        exit 1
    fi
}

# ========================================
# FUNÇÃO: Fazer backup
# ========================================
backup_file() {
    local file=$1
    if [ ! -f "${file}.backup-h21h22" ]; then
        cp "$file" "${file}.backup-h21h22"
        echo -e "${GREEN}✅ Backup criado: ${file}.backup-h21h22${NC}"
    else
        echo -e "${YELLOW}⚠️  Backup já existe: ${file}.backup-h21h22${NC}"
    fi
}

# ========================================
# FUNÇÃO: Verificar se modificação já existe
# ========================================
is_modified() {
    local file=$1
    local pattern=$2
    grep -q "$pattern" "$file" 2>/dev/null
}

# ========================================
# 1. MODIFICAR server.ts
# ========================================
echo "📝 1/4 Modificando server.ts..."

SERVER_FILE="packages/api/src/server.ts"
check_file "$SERVER_FILE"
backup_file "$SERVER_FILE"

# Verificar se já foi modificado
if is_modified "$SERVER_FILE" "snapshotRoutes"; then
    echo -e "${YELLOW}⚠️  server.ts já contém snapshotRoutes (pular)${NC}"
else
    # Adicionar imports após as outras importações de routes
    sed -i '/import.*routes.*from.*\/routes/a import { snapshotRoutes } from "./routes/snapshot.routes";\nimport { validatorRoutes } from "./routes/validator.routes";' "$SERVER_FILE"
    
    # Adicionar registros após os outros registros
    sed -i '/await.*register.*Routes.*prefix.*api/a \  await fastify.register(snapshotRoutes, { prefix: "/api" });\n  await fastify.register(validatorRoutes, { prefix: "/api" });' "$SERVER_FILE"
    
    echo -e "${GREEN}✅ server.ts modificado${NC}"
fi

echo ""

# ========================================
# 2. MODIFICAR price.controller.ts
# ========================================
echo "📝 2/4 Modificando price.controller.ts..."

PRICE_FILE="packages/api/src/controllers/price.controller.ts"
check_file "$PRICE_FILE"
backup_file "$PRICE_FILE"

if is_modified "$PRICE_FILE" "snapshotService"; then
    echo -e "${YELLOW}⚠️  price.controller.ts já contém snapshotService (pular)${NC}"
else
    # Adicionar import do snapshotService
    sed -i '/^import/a import { snapshotService } from "../services/snapshot.service";' "$PRICE_FILE"
    
    # Criar arquivo temporário com a modificação do return
    cat > /tmp/price_modification.txt << 'EOF'
    // Criar snapshot
    const snapshotId = snapshotService.create("price", parsed.data, result);

    // Retornar com metadata
    return reply.send({
      ...result,
      _meta: {
        snapshotId,
        snapshotUrl: `/api/snapshot/${snapshotId}`,
      },
    });
EOF

    # Substituir o return simples pelo return com snapshot
    sed -i '/return reply.send(result);/c\    \/\/ Criar snapshot\n    const snapshotId = snapshotService.create("price", parsed.data, result);\n\n    \/\/ Retornar com metadata\n    return reply.send({\n      ...result,\n      _meta: {\n        snapshotId,\n        snapshotUrl: \`\/api\/snapshot\/${snapshotId}\`,\n      },\n    });' "$PRICE_FILE"
    
    echo -e "${GREEN}✅ price.controller.ts modificado${NC}"
fi

echo ""

# ========================================
# 3. MODIFICAR sac.controller.ts
# ========================================
echo "📝 3/4 Modificando sac.controller.ts..."

SAC_FILE="packages/api/src/controllers/sac.controller.ts"
check_file "$SAC_FILE"
backup_file "$SAC_FILE"

if is_modified "$SAC_FILE" "snapshotService"; then
    echo -e "${YELLOW}⚠️  sac.controller.ts já contém snapshotService (pular)${NC}"
else
    # Adicionar import do snapshotService
    sed -i '/^import/a import { snapshotService } from "../services/snapshot.service";' "$SAC_FILE"
    
    # Substituir o return simples pelo return com snapshot (tipo: sac)
    sed -i '/return reply.send(result);/c\    \/\/ Criar snapshot\n    const snapshotId = snapshotService.create("sac", parsed.data, result);\n\n    \/\/ Retornar com metadata\n    return reply.send({\n      ...result,\n      _meta: {\n        snapshotId,\n        snapshotUrl: \`\/api\/snapshot\/${snapshotId}\`,\n      },\n    });' "$SAC_FILE"
    
    echo -e "${GREEN}✅ sac.controller.ts modificado${NC}"
fi

echo ""

# ========================================
# 4. MODIFICAR cet.controller.ts
# ========================================
echo "📝 4/4 Modificando cet.controller.ts..."

CET_FILE="packages/api/src/controllers/cet.controller.ts"

# CET pode não existir ainda, então tratamos diferente
if [ ! -f "$CET_FILE" ]; then
    echo -e "${YELLOW}⚠️  cet.controller.ts não encontrado (criar se necessário)${NC}"
else
    check_file "$CET_FILE"
    backup_file "$CET_FILE"

    if is_modified "$CET_FILE" "snapshotService"; then
        echo -e "${YELLOW}⚠️  cet.controller.ts já contém snapshotService (pular)${NC}"
    else
        # Adicionar import do snapshotService
        sed -i '/^import/a import { snapshotService } from "../services/snapshot.service";' "$CET_FILE"
        
        # Substituir o return simples pelo return com snapshot (tipo: cet)
        sed -i '/return reply.send(result);/c\    \/\/ Criar snapshot\n    const snapshotId = snapshotService.create("cet", parsed.data, result);\n\n    \/\/ Retornar com metadata\n    return reply.send({\n      ...result,\n      _meta: {\n        snapshotId,\n        snapshotUrl: \`\/api\/snapshot\/${snapshotId}\`,\n      },\n    });' "$CET_FILE"
        
        echo -e "${GREEN}✅ cet.controller.ts modificado${NC}"
    fi
fi

echo ""

# ========================================
# VALIDAÇÃO FINAL
# ========================================
echo "🔍 VALIDANDO MODIFICAÇÕES..."
echo ""

validation_ok=true

# Validar server.ts
if grep -q "snapshotRoutes" "$SERVER_FILE" && grep -q "validatorRoutes" "$SERVER_FILE"; then
    echo -e "${GREEN}✅ server.ts: Imports e registros OK${NC}"
else
    echo -e "${RED}❌ server.ts: Faltam imports ou registros${NC}"
    validation_ok=false
fi

# Validar price.controller.ts
if grep -q "snapshotService" "$PRICE_FILE" && grep -q "_meta" "$PRICE_FILE"; then
    echo -e "${GREEN}✅ price.controller.ts: Snapshot integrado${NC}"
else
    echo -e "${RED}❌ price.controller.ts: Falta integração de snapshot${NC}"
    validation_ok=false
fi

# Validar sac.controller.ts
if grep -q "snapshotService" "$SAC_FILE" && grep -q "_meta" "$SAC_FILE"; then
    echo -e "${GREEN}✅ sac.controller.ts: Snapshot integrado${NC}"
else
    echo -e "${RED}❌ sac.controller.ts: Falta integração de snapshot${NC}"
    validation_ok=false
fi

# Validar cet.controller.ts (se existir)
if [ -f "$CET_FILE" ]; then
    if grep -q "snapshotService" "$CET_FILE" && grep -q "_meta" "$CET_FILE"; then
        echo -e "${GREEN}✅ cet.controller.ts: Snapshot integrado${NC}"
    else
        echo -e "${RED}❌ cet.controller.ts: Falta integração de snapshot${NC}"
        validation_ok=false
    fi
fi

echo ""

# ========================================
# RESULTADO FINAL
# ========================================
if [ "$validation_ok" = true ]; then
    echo "=============================================="
    echo -e "${GREEN}🎉 MODIFICAÇÕES CONCLUÍDAS COM SUCESSO!${NC}"
    echo "=============================================="
    echo ""
    echo "📋 Arquivos modificados:"
    echo "   ✅ packages/api/src/server.ts"
    echo "   ✅ packages/api/src/controllers/price.controller.ts"
    echo "   ✅ packages/api/src/controllers/sac.controller.ts"
    if [ -f "$CET_FILE" ]; then
        echo "   ✅ packages/api/src/controllers/cet.controller.ts"
    fi
    echo ""
    echo "💾 Backups criados:"
    echo "   📄 *.backup-h21h22"
    echo ""
    echo "🚀 Próximos passos:"
    echo "   1. cd packages/api && pnpm build"
    echo "   2. pnpm dev (Terminal 1)"
    echo "   3. ./testar-h21-h22.sh (Terminal 2)"
    echo ""
    exit 0
else
    echo "=============================================="
    echo -e "${RED}❌ ALGUMAS MODIFICAÇÕES FALHARAM${NC}"
    echo "=============================================="
    echo ""
    echo "🔧 Solução:"
    echo "   1. Verifique os arquivos acima"
    echo "   2. Consulte os backups: *.backup-h21h22"
    echo "   3. Ou faça modificações manualmente"
    echo ""
    exit 1
fi
