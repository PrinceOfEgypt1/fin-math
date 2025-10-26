#!/bin/bash
# corrigir-erros-build.sh
# Limpa duplicações e corrige erros de TypeScript

set -e

echo "🔧 CORRIGINDO ERROS DE BUILD"
echo "============================="
echo ""

cd ~/workspace/fin-math

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ========================================
# 1. RESTAURAR BACKUPS (Estado limpo)
# ========================================
echo "📦 1/3 Restaurando backups originais..."

FILES=(
    "packages/api/src/server.ts"
    "packages/api/src/controllers/price.controller.ts"
    "packages/api/src/controllers/sac.controller.ts"
    "packages/api/src/controllers/cet.controller.ts"
)

for file in "${FILES[@]}"; do
    if [ -f "${file}.backup-h21h22" ]; then
        cp "${file}.backup-h21h22" "$file"
        echo -e "${GREEN}✅ Restaurado: $file${NC}"
    else
        echo -e "${YELLOW}⚠️  Backup não encontrado: $file${NC}"
    fi
done

echo ""

# ========================================
# 2. APLICAR MODIFICAÇÕES CORRETAMENTE (Uma vez só)
# ========================================
echo "🔧 2/3 Aplicando modificações corretamente..."
echo ""

# 2.1 MODIFICAR server.ts
echo "  📝 Modificando server.ts..."
SERVER_FILE="packages/api/src/server.ts"

# Encontrar a linha com imports de routes
LINE_NUM=$(grep -n "import.*routes.*from.*\/routes" "$SERVER_FILE" | tail -1 | cut -d: -f1)

if [ ! -z "$LINE_NUM" ]; then
    # Adicionar imports APÓS a última linha de import de routes
    sed -i "${LINE_NUM}a import { snapshotRoutes } from \"./routes/snapshot.routes\";\nimport { validatorRoutes } from \"./routes/validator.routes\";" "$SERVER_FILE"
fi

# Encontrar a linha com register de routes
REG_LINE=$(grep -n "await.*register.*Routes.*prefix" "$SERVER_FILE" | tail -1 | cut -d: -f1)

if [ ! -z "$REG_LINE" ]; then
    # Adicionar registros APÓS o último register
    sed -i "${REG_LINE}a \ \ await fastify.register(snapshotRoutes, { prefix: \"/api\" });\n\ \ await fastify.register(validatorRoutes, { prefix: \"/api\" });" "$SERVER_FILE"
fi

echo -e "${GREEN}  ✅ server.ts modificado${NC}"

# 2.2 MODIFICAR price.controller.ts
echo "  📝 Modificando price.controller.ts..."
PRICE_FILE="packages/api/src/controllers/price.controller.ts"

# Adicionar import após primeira linha de imports
sed -i '1a import { snapshotService } from "../services/snapshot.service";' "$PRICE_FILE"

# Encontrar e substituir o return
sed -i '/return reply.send(result);/{
N
s/return reply.send(result);/const snapshotId = snapshotService.create("price", parsed.data, result);\n    return reply.send({ ...result, _meta: { snapshotId, snapshotUrl: `\/api\/snapshot\/${snapshotId}` } });/
}' "$PRICE_FILE"

echo -e "${GREEN}  ✅ price.controller.ts modificado${NC}"

# 2.3 MODIFICAR sac.controller.ts
echo "  📝 Modificando sac.controller.ts..."
SAC_FILE="packages/api/src/controllers/sac.controller.ts"

sed -i '1a import { snapshotService } from "../services/snapshot.service";' "$SAC_FILE"

sed -i '/return reply.send(result);/{
N
s/return reply.send(result);/const snapshotId = snapshotService.create("sac", parsed.data, result);\n    return reply.send({ ...result, _meta: { snapshotId, snapshotUrl: `\/api\/snapshot\/${snapshotId}` } });/
}' "$SAC_FILE"

echo -e "${GREEN}  ✅ sac.controller.ts modificado${NC}"

# 2.4 MODIFICAR cet.controller.ts
echo "  📝 Modificando cet.controller.ts..."
CET_FILE="packages/api/src/controllers/cet.controller.ts"

if [ -f "$CET_FILE" ]; then
    sed -i '1a import { snapshotService } from "../services/snapshot.service";' "$CET_FILE"
    
    sed -i '/return reply.send(result);/{
N
s/return reply.send(result);/const snapshotId = snapshotService.create("cet", parsed.data, result);\n    return reply.send({ ...result, _meta: { snapshotId, snapshotUrl: `\/api\/snapshot\/${snapshotId}` } });/
}' "$CET_FILE"
    
    echo -e "${GREEN}  ✅ cet.controller.ts modificado${NC}"
fi

echo ""

# ========================================
# 3. CORRIGIR validator.service.ts (TypeScript strict)
# ========================================
echo "🔧 3/3 Corrigindo validator.service.ts..."

VALIDATOR_FILE="packages/api/src/services/validator.service.ts"

# Substituir a função compareSchedules com verificação de undefined
cat > /tmp/validator_fix.txt << 'EOF'
  private compareSchedules(expected: ScheduleRow[], received: ScheduleRow[]): any[] {
    const diffs: any[] = [];
    const columns = ["pmt", "interest", "amort", "balance"] as const;
    const minLength = Math.min(expected.length, received.length);

    for (let i = 0; i < minLength; i++) {
      const exp = expected[i];
      const rec = received[i];
      
      // Verificação de undefined
      if (!exp || !rec || exp.k !== rec.k) continue;

      columns.forEach(col => {
        const expectedVal = exp[col];
        const receivedVal = rec[col];
        const delta = Math.abs(expectedVal - receivedVal);
        const deltaPercent = expectedVal !== 0 ? (delta / Math.abs(expectedVal)) * 100 : 0;
        const withinTolerance = delta <= this.toleranceAbsolute;

        if (delta > 0) {
          diffs.push({ row: exp.k, column: col, expected: expectedVal, received: receivedVal, delta, deltaPercent, withinTolerance });
        }
      });
    }
    return diffs;
  }
EOF

# Substituir a função no arquivo
sed -i '/private compareSchedules/,/^  }$/c\'"$(cat /tmp/validator_fix.txt)" "$VALIDATOR_FILE"

echo -e "${GREEN}✅ validator.service.ts corrigido${NC}"
echo ""

# ========================================
# 4. VALIDAR MODIFICAÇÕES
# ========================================
echo "🔍 VALIDANDO CORREÇÕES..."
echo ""

errors=0

# Verificar imports únicos
for file in "${FILES[@]}"; do
    IMPORT_COUNT=$(grep -c "snapshotService" "$file" 2>/dev/null || echo "0")
    if [ "$IMPORT_COUNT" -eq 1 ] || [ "$IMPORT_COUNT" -eq 0 ]; then
        echo -e "${GREEN}✅ $file: Import único${NC}"
    else
        echo -e "${RED}❌ $file: $IMPORT_COUNT imports (deveria ser 1)${NC}"
        ((errors++))
    fi
done

echo ""

if [ $errors -eq 0 ]; then
    echo -e "${GREEN}🎉 CORREÇÕES APLICADAS COM SUCESSO!${NC}"
    echo ""
    echo "🚀 Próximo passo:"
    echo "   cd packages/api && pnpm build"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Ainda há erros. Verifique manualmente.${NC}"
    exit 1
fi
