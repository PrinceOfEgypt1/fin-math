#!/bin/bash
# reset-e-corrigir-tudo.sh
# RESET COMPLETO e correção definitiva

set -e

cd ~/workspace/fin-math/packages/api

echo "🔄 RESET COMPLETO E CORREÇÃO DEFINITIVA"
echo "======================================="

# 1. LIMPAR tudo que foi criado errado
echo "🧹 Limpando arquivos problemáticos..."
rm -f src/services/price.service.ts
rm -f src/services/sac.service.ts
rm -f src/services/cet.service.ts

# 2. RECRIAR schemas corretos (baseado no que a API espera)
echo "📝 Criando schemas corretos..."

cat > src/schemas/price.schema.ts << 'PRICE_SCHEMA'
// packages/api/src/schemas/price.schema.ts
import { z } from "zod";

export const PriceRequestSchema = z.object({
  pv: z.number().positive(),
  rate: z.number().positive(),
  n: z.number().int().positive(),
});

export type PriceRequest = z.infer<typeof PriceRequestSchema>;
PRICE_SCHEMA

cat > src/schemas/sac.schema.ts << 'SAC_SCHEMA'
// packages/api/src/schemas/sac.schema.ts
import { z } from "zod";

export const SacRequestSchema = z.object({
  pv: z.number().positive(),
  rate: z.number().positive(),
  n: z.number().int().positive(),
});

export type SacRequest = z.infer<typeof SacRequestSchema>;
SAC_SCHEMA

cat > src/schemas/cet.schema.ts << 'CET_SCHEMA'
// packages/api/src/schemas/cet.schema.ts
import { z } from "zod";

export const CetBasicRequestSchema = z.object({
  pv: z.number().positive(),
  rate: z.number().positive(),
  n: z.number().int().positive(),
  iof: z.number().nonnegative().optional(),
  tac: z.number().nonnegative().optional(),
});

export type CetBasicRequest = z.infer<typeof CetBasicRequestSchema>;
CET_SCHEMA

# 3. RECRIAR controllers corretos (SEM services)
echo "📝 Criando controllers corretos..."

cat > src/controllers/price.controller.ts << 'PRICE_CTRL'
// packages/api/src/controllers/price.controller.ts
import { FastifyRequest, FastifyReply } from "fastify";
import { PriceRequestSchema } from "../schemas/price.schema";
import { calculatePrice } from "@finmath/engine";
import { snapshotService } from "../services/snapshot.service";

export async function postPrice(
  request: FastifyRequest,
  reply: FastifyReply
) {
  try {
    const body = PriceRequestSchema.parse(request.body);
    
    // Calcular usando o motor
    const result = calculatePrice(body.pv, body.rate, body.n);
    
    // Criar snapshot
    const snapshot = snapshotService.create(body, result, "/api/price");
    
    return reply.status(200).send({
      schedule: result.schedule,
      snapshotId: snapshot.id,
    });
  } catch (error: any) {
    return reply.status(400).send({
      error: {
        code: "VALIDATION_ERROR",
        message: "Validation failed",
        details: error.errors || [{ message: error.message }],
      },
    });
  }
}
PRICE_CTRL

cat > src/controllers/sac.controller.ts << 'SAC_CTRL'
// packages/api/src/controllers/sac.controller.ts
import { FastifyRequest, FastifyReply } from "fastify";
import { SacRequestSchema } from "../schemas/sac.schema";
import { calculateSAC } from "@finmath/engine";
import { snapshotService } from "../services/snapshot.service";

export async function postSac(
  request: FastifyRequest,
  reply: FastifyReply
) {
  try {
    const body = SacRequestSchema.parse(request.body);
    
    // Calcular usando o motor
    const result = calculateSAC(body.pv, body.rate, body.n);
    
    // Criar snapshot
    const snapshot = snapshotService.create(body, result, "/api/sac");
    
    return reply.status(200).send({
      schedule: result.schedule,
      snapshotId: snapshot.id,
    });
  } catch (error: any) {
    return reply.status(400).send({
      error: {
        code: "VALIDATION_ERROR",
        message: "Validation failed",
        details: error.errors || [{ message: error.message }],
      },
    });
  }
}
SAC_CTRL

cat > src/controllers/cet.controller.ts << 'CET_CTRL'
// packages/api/src/controllers/cet.controller.ts
import { FastifyRequest, FastifyReply } from "fastify";
import { CetBasicRequestSchema } from "../schemas/cet.schema";
import { calculateCET } from "@finmath/engine";
import { snapshotService } from "../services/snapshot.service";

export async function postCetBasic(
  request: FastifyRequest,
  reply: FastifyReply
) {
  try {
    const body = CetBasicRequestSchema.parse(request.body);
    
    // Calcular usando o motor
    const result = calculateCET({
      pv: body.pv,
      rate: body.rate,
      n: body.n,
      iof: body.iof || 0,
      tac: body.tac || 0,
    });
    
    // Criar snapshot
    const snapshot = snapshotService.create(body, result, "/api/cet/basic");
    
    return reply.status(200).send({
      cet: result.cet,
      schedule: result.schedule,
      snapshotId: snapshot.id,
    });
  } catch (error: any) {
    return reply.status(400).send({
      error: {
        code: "VALIDATION_ERROR",
        message: "Validation failed",
        details: error.errors || [{ message: error.message }],
      },
    });
  }
}
CET_CTRL

# 4. RECRIAR routes com schema OpenAPI
echo "📝 Criando routes com OpenAPI..."

cat > src/routes/price.routes.ts << 'PRICE_ROUTES'
// packages/api/src/routes/price.routes.ts
import { FastifyInstance } from "fastify";
import { postPrice } from "../controllers/price.controller";

export async function priceRoutes(fastify: FastifyInstance) {
  fastify.post("/price", {
    schema: {
      description: "Calcula cronograma Price (PMT constante)",
      tags: ["Amortização"],
      body: {
        type: "object",
        required: ["pv", "rate", "n"],
        properties: {
          pv: { type: "number", description: "Valor presente", example: 100000 },
          rate: { type: "number", description: "Taxa de juros", example: 0.01 },
          n: { type: "integer", description: "Número de períodos", example: 12 },
        },
      },
      response: {
        200: {
          description: "Cronograma calculado",
          type: "object",
          properties: {
            schedule: { type: "array" },
            snapshotId: { type: "string" },
          },
        },
      },
    },
    handler: postPrice,
  });
}
PRICE_ROUTES

cat > src/routes/sac.routes.ts << 'SAC_ROUTES'
// packages/api/src/routes/sac.routes.ts
import { FastifyInstance } from "fastify";
import { postSac } from "../controllers/sac.controller";

export async function sacRoutes(fastify: FastifyInstance) {
  fastify.post("/sac", {
    schema: {
      description: "Calcula cronograma SAC (amortização constante)",
      tags: ["Amortização"],
      body: {
        type: "object",
        required: ["pv", "rate", "n"],
        properties: {
          pv: { type: "number", description: "Valor presente", example: 100000 },
          rate: { type: "number", description: "Taxa de juros", example: 0.01 },
          n: { type: "integer", description: "Número de períodos", example: 12 },
        },
      },
      response: {
        200: {
          description: "Cronograma calculado",
          type: "object",
          properties: {
            schedule: { type: "array" },
            snapshotId: { type: "string" },
          },
        },
      },
    },
    handler: postSac,
  });
}
SAC_ROUTES

cat > src/routes/cet.routes.ts << 'CET_ROUTES'
// packages/api/src/routes/cet.routes.ts
import { FastifyInstance } from "fastify";
import { postCetBasic } from "../controllers/cet.controller";

export async function cetRoutes(fastify: FastifyInstance) {
  fastify.post("/cet/basic", {
    schema: {
      description: "Calcula CET básico",
      tags: ["CET"],
      body: {
        type: "object",
        required: ["pv", "rate", "n"],
        properties: {
          pv: { type: "number", description: "Valor financiado", example: 100000 },
          rate: { type: "number", description: "Taxa mensal", example: 0.01 },
          n: { type: "integer", description: "Número de parcelas", example: 12 },
          iof: { type: "number", description: "IOF (opcional)", example: 150 },
          tac: { type: "number", description: "TAC (opcional)", example: 50 },
        },
      },
      response: {
        200: {
          description: "CET calculado",
          type: "object",
          properties: {
            cet: { type: "number" },
            schedule: { type: "array" },
            snapshotId: { type: "string" },
          },
        },
      },
    },
    handler: postCetBasic,
  });
}
CET_ROUTES

# 5. BUILD
echo ""
echo "🔨 Building..."
pnpm build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ ✅ ✅ BUILD COM SUCESSO! ✅ ✅ ✅"
    echo ""
    echo "🎯 Próximos passos:"
    echo "  1. Reiniciar servidor: cd packages/api && pnpm dev"
    echo "  2. Testar: curl -X POST http://localhost:3001/api/price -H 'Content-Type: application/json' -d '{\"pv\":100000,\"rate\":0.01,\"n\":12}'"
    echo "  3. Swagger: http://localhost:3001/api-docs"
else
    echo ""
    echo "❌ Build falhou"
    exit 1
fi
