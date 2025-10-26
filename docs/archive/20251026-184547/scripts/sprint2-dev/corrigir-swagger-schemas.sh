#!/bin/bash
# corrigir-swagger-schemas.sh
# Adiciona schemas OpenAPI aos controllers

cd ~/workspace/fin-math/packages/api

echo "🔧 CORRIGINDO SCHEMAS DO SWAGGER"
echo "================================"

# 1. Verificar se schemas existem
echo "📝 Verificando schemas..."
mkdir -p src/schemas

# 2. Criar/Atualizar price.schema.ts
cat > src/schemas/price.schema.ts << 'PRICE_SCHEMA'
// packages/api/src/schemas/price.schema.ts
import { z } from "zod";

export const PriceRequestSchema = z.object({
  pv: z.number().positive().describe("Valor presente (principal)"),
  rate: z.number().positive().describe("Taxa de juros por período"),
  n: z.number().int().positive().describe("Número de períodos"),
});

export type PriceRequest = z.infer<typeof PriceRequestSchema>;

export const PriceResponseSchema = z.object({
  schedule: z.array(z.object({
    k: z.number(),
    pmt: z.number(),
    interest: z.number(),
    amort: z.number(),
    balance: z.number(),
  })),
  snapshotId: z.string().uuid().optional(),
});
PRICE_SCHEMA
echo "✅ price.schema.ts criado"

# 3. Criar/Atualizar sac.schema.ts
cat > src/schemas/sac.schema.ts << 'SAC_SCHEMA'
// packages/api/src/schemas/sac.schema.ts
import { z } from "zod";

export const SacRequestSchema = z.object({
  pv: z.number().positive().describe("Valor presente (principal)"),
  rate: z.number().positive().describe("Taxa de juros por período"),
  n: z.number().int().positive().describe("Número de períodos"),
});

export type SacRequest = z.infer<typeof SacRequestSchema>;
SAC_SCHEMA
echo "✅ sac.schema.ts criado"

# 4. Criar/Atualizar cet.schema.ts
cat > src/schemas/cet.schema.ts << 'CET_SCHEMA'
// packages/api/src/schemas/cet.schema.ts
import { z } from "zod";

export const CetBasicRequestSchema = z.object({
  pv: z.number().positive().describe("Valor financiado"),
  rate: z.number().positive().describe("Taxa de juros mensal"),
  n: z.number().int().positive().describe("Número de parcelas"),
  iof: z.number().nonnegative().optional().describe("IOF (opcional)"),
  tac: z.number().nonnegative().optional().describe("TAC (opcional)"),
});

export type CetBasicRequest = z.infer<typeof CetBasicRequestSchema>;
CET_SCHEMA
echo "✅ cet.schema.ts criado"

# 5. Atualizar server.ts com configuração OpenAPI melhorada
cat > src/server.ts << 'SERVER_TS'
// packages/api/src/server.ts
import Fastify, { FastifyInstance } from "fastify";
import cors from "@fastify/cors";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";
import { priceRoutes } from "./routes/price.routes";
import { sacRoutes } from "./routes/sac.routes";
import { cetRoutes } from "./routes/cet.routes";
import { snapshotRoutes } from "./routes/snapshot.routes";
import { validatorRoutes } from "./routes/validator.routes";

export async function build(): Promise<FastifyInstance> {
  const fastify = Fastify({
    logger: {
      level: process.env.LOG_LEVEL || "info",
    },
  });

  // CORS
  await fastify.register(cors, {
    origin: true,
  });

  // Swagger com configuração detalhada
  await fastify.register(swagger, {
    openapi: {
      info: {
        title: "FinMath API",
        description: "API de Matemática Financeira - Sprint 2",
        version: "0.2.0",
      },
      servers: [
        {
          url: "http://localhost:3001",
          description: "Servidor de desenvolvimento",
        },
      ],
      components: {
        schemas: {
          PriceRequest: {
            type: "object",
            required: ["pv", "rate", "n"],
            properties: {
              pv: {
                type: "number",
                description: "Valor presente (principal)",
                example: 100000,
              },
              rate: {
                type: "number",
                description: "Taxa de juros por período (decimal)",
                example: 0.01,
              },
              n: {
                type: "integer",
                description: "Número de períodos",
                example: 12,
              },
            },
          },
          SacRequest: {
            type: "object",
            required: ["pv", "rate", "n"],
            properties: {
              pv: {
                type: "number",
                description: "Valor presente (principal)",
                example: 100000,
              },
              rate: {
                type: "number",
                description: "Taxa de juros por período (decimal)",
                example: 0.01,
              },
              n: {
                type: "integer",
                description: "Número de períodos",
                example: 12,
              },
            },
          },
          CetBasicRequest: {
            type: "object",
            required: ["pv", "rate", "n"],
            properties: {
              pv: {
                type: "number",
                description: "Valor financiado",
                example: 100000,
              },
              rate: {
                type: "number",
                description: "Taxa de juros mensal (decimal)",
                example: 0.01,
              },
              n: {
                type: "integer",
                description: "Número de parcelas",
                example: 12,
              },
              iof: {
                type: "number",
                description: "IOF (opcional)",
                example: 150,
              },
              tac: {
                type: "number",
                description: "TAC (opcional)",
                example: 50,
              },
            },
          },
        },
      },
    },
  });

  await fastify.register(swaggerUi, {
    routePrefix: "/api-docs",
    uiConfig: {
      docExpansion: "list",
      deepLinking: true,
      defaultModelsExpandDepth: 3,
      defaultModelExpandDepth: 3,
    },
    staticCSP: true,
  });

  // Rotas
  await fastify.register(priceRoutes, { prefix: "/api" });
  await fastify.register(sacRoutes, { prefix: "/api" });
  await fastify.register(cetRoutes, { prefix: "/api" });
  await fastify.register(snapshotRoutes, { prefix: "/api" });
  await fastify.register(validatorRoutes, { prefix: "/api" });

  return fastify;
}
SERVER_TS
echo "✅ server.ts atualizado"

# 6. Atualizar routes para incluir schema OpenAPI
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
        $ref: "#/components/schemas/PriceRequest",
      },
      response: {
        200: {
          description: "Cronograma Price calculado com sucesso",
          type: "object",
        },
      },
    },
    handler: postPrice,
  });
}
PRICE_ROUTES
echo "✅ price.routes.ts atualizado"

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
        $ref: "#/components/schemas/SacRequest",
      },
      response: {
        200: {
          description: "Cronograma SAC calculado com sucesso",
          type: "object",
        },
      },
    },
    handler: postSac,
  });
}
SAC_ROUTES
echo "✅ sac.routes.ts atualizado"

cat > src/routes/cet.routes.ts << 'CET_ROUTES'
// packages/api/src/routes/cet.routes.ts
import { FastifyInstance } from "fastify";
import { postCetBasic } from "../controllers/cet.controller";

export async function cetRoutes(fastify: FastifyInstance) {
  fastify.post("/cet/basic", {
    schema: {
      description: "Calcula CET básico (com tarifas t0)",
      tags: ["CET"],
      body: {
        $ref: "#/components/schemas/CetBasicRequest",
      },
      response: {
        200: {
          description: "CET calculado com sucesso",
          type: "object",
        },
      },
    },
    handler: postCetBasic,
  });
}
CET_ROUTES
echo "✅ cet.routes.ts atualizado"

# 7. Rebuild
echo ""
echo "🔨 Rebuilding..."
pnpm build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ ✅ ✅ SWAGGER CORRIGIDO COM SUCESSO! ✅ ✅ ✅"
    echo ""
    echo "🎯 Próximos passos:"
    echo "  1. Reiniciar servidor: pnpm dev"
    echo "  2. Recarregar Swagger: http://localhost:3001/api-docs"
    echo "  3. Agora os campos de Request Body devem aparecer!"
else
    echo "❌ Build falhou"
    exit 1
fi
