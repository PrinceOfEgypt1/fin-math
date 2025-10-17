#!/bin/bash
set -euo pipefail

echo "🚀 IMPLEMENTANDO H12 - CET API"
echo "=============================="
echo ""

# 1. Criar Schema
echo "📝 1. Criando cet.schema.ts..."
cat > packages/api/src/schemas/cet.schema.ts << 'SCHEMA'
import { z } from "zod";

export const CETBasicRequestSchema = z.object({
  pv: z.number().positive("Valor presente deve ser positivo"),
  pmt: z.number().positive("Valor da parcela deve ser positivo"),
  n: z.number().int().positive().max(480, "Número de parcelas deve ser <= 480"),
  feesT0: z.array(z.number().nonnegative()).default([]),
  baseAnnual: z.number().int().positive().default(12),
});

export type CETBasicRequest = z.infer<typeof CETBasicRequestSchema>;

export const CETBasicResponseSchema = z.object({
  irrMonthly: z.number(),
  cetAnnual: z.number(),
  valorLiquido: z.number(),
  totalFees: z.number(),
  cashflows: z.array(z.number()),
  meta: z.object({
    motorVersion: z.string(),
    calculationId: z.string(),
    timestamp: z.string(),
  }),
});

export type CETBasicResponse = z.infer<typeof CETBasicResponseSchema>;
SCHEMA
echo "   ✅ cet.schema.ts criado"

# 2. Criar Service
echo ""
echo "📝 2. Criando cet.service.ts..."
cat > packages/api/src/services/cet.service.ts << 'SERVICE'
import { cetBasic } from "@finmath/engine";
import type { CETBasicRequest, CETBasicResponse } from "../schemas/cet.schema";

export class CETService {
  calculateBasic(params: CETBasicRequest): CETBasicResponse {
    const { pv, pmt, n, feesT0, baseAnnual } = params;
    const result = cetBasic(pv, pmt, n, feesT0, baseAnnual);
    const totalFees = feesT0.reduce((sum, fee) => sum + fee, 0);
    const valorLiquido = pv - totalFees;

    return {
      irrMonthly: result.irrMonthly,
      cetAnnual: result.cetAnnual,
      valorLiquido,
      totalFees,
      cashflows: result.cashflows,
      meta: {
        motorVersion: "0.4.0",
        calculationId: crypto.randomUUID(),
        timestamp: new Date().toISOString(),
      },
    };
  }
}

export const cetService = new CETService();
SERVICE
echo "   ✅ cet.service.ts criado"

# 3. Criar Controller
echo ""
echo "📝 3. Criando cet.controller.ts..."
cat > packages/api/src/controllers/cet.controller.ts << 'CONTROLLER'
import type { FastifyRequest, FastifyReply } from "fastify";
import { cetService } from "../services/cet.service";
import type { CETBasicRequest } from "../schemas/cet.schema";

export class CETController {
  async calculateBasic(
    request: FastifyRequest<{ Body: CETBasicRequest }>,
    reply: FastifyReply
  ) {
    try {
      const result = cetService.calculateBasic(request.body);
      return reply.status(200).send(result);
    } catch (error) {
      request.log.error(error, "Erro ao calcular CET básico");
      return reply.status(500).send({
        error: "Internal Server Error",
        message: error instanceof Error ? error.message : "Erro desconhecido",
      });
    }
  }
}

export const cetController = new CETController();
CONTROLLER
echo "   ✅ cet.controller.ts criado"

# 4. Criar Routes
echo ""
echo "📝 4. Criando cet.routes.ts..."
cat > packages/api/src/routes/cet.routes.ts << 'ROUTES'
import type { FastifyInstance } from "fastify";
import { cetController } from "../controllers/cet.controller";
import { CETBasicRequestSchema } from "../schemas/cet.schema";

export async function cetRoutes(app: FastifyInstance) {
  app.post(
    "/cet/basic",
    {
      schema: {
        description: "Calcula CET Básico (tarifas t=0)",
        tags: ["CET"],
        body: CETBasicRequestSchema,
      },
    },
    cetController.calculateBasic.bind(cetController)
  );
}
ROUTES
echo "   ✅ cet.routes.ts criado"

# 5. Atualizar server.ts
echo ""
echo "📝 5. Atualizando server.ts..."

# Backup
cp packages/api/src/server.ts packages/api/src/server.ts.bak

# Adicionar import
if ! grep -q "cetRoutes" packages/api/src/server.ts; then
  sed -i '/import { sacRoutes } from/a import { cetRoutes } from "./routes/cet.routes";' packages/api/src/server.ts
  echo "   ✅ Import adicionado"
else
  echo "   ⚠️  Import já existe"
fi

# Adicionar registro
if ! grep -q "cetRoutes" packages/api/src/server.ts | grep -q "register"; then
  sed -i '/await fastify.register(sacRoutes/a \  await fastify.register(cetRoutes, { prefix: "/api" });' packages/api/src/server.ts
  echo "   ✅ Registro adicionado"
else
  echo "   ⚠️  Registro já existe"
fi

# 6. Verificar
echo ""
echo "🔍 6. Verificando implementação..."
echo ""

if [ -f "packages/api/src/schemas/cet.schema.ts" ]; then
  echo "   ✅ Schema existe"
else
  echo "   ❌ Schema NÃO existe"
fi

if [ -f "packages/api/src/services/cet.service.ts" ]; then
  echo "   ✅ Service existe"
else
  echo "   ❌ Service NÃO existe"
fi

if [ -f "packages/api/src/controllers/cet.controller.ts" ]; then
  echo "   ✅ Controller existe"
else
  echo "   ❌ Controller NÃO existe"
fi

if [ -f "packages/api/src/routes/cet.routes.ts" ]; then
  echo "   ✅ Routes existe"
else
  echo "   ❌ Routes NÃO existe"
fi

if grep -q "cetRoutes" packages/api/src/server.ts; then
  echo "   ✅ Registrado no server.ts"
else
  echo "   ❌ NÃO registrado no server.ts"
fi

# 7. Build
echo ""
echo "🏗️  7. Buildando API..."
cd packages/api
pnpm build
cd ../..

echo ""
echo "=============================="
echo "✅ H12 - CET API IMPLEMENTADA!"
echo "=============================="
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo "   1. Testar: pnpm -F @finmath/api dev"
echo "   2. curl -X POST http://localhost:3001/api/cet/basic \\"
echo "        -H 'Content-Type: application/json' \\"
echo "        -d '{\"pv\":10000,\"pmt\":946.56,\"n\":12,\"feesT0\":[50,30]}'"
echo "   3. Commitar: git add . && git commit -m 'feat(H12): Implementa API CET básico'"
echo ""
