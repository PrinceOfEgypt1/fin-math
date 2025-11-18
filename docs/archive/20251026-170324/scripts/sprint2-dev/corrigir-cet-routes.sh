#!/bin/bash
set -euo pipefail

echo "🔧 CORRIGINDO CET ROUTES - Schema Validation"
echo "============================================"
echo ""

echo "1️⃣ Verificando padrão de outros endpoints..."
echo ""

echo "📄 price.routes.ts (primeiras 30 linhas):"
head -30 packages/api/src/routes/price.routes.ts
echo ""

echo "📄 sac.routes.ts (primeiras 30 linhas):"
head -30 packages/api/src/routes/sac.routes.ts
echo ""

echo "2️⃣ Criando versão corrigida de cet.routes.ts..."
echo ""

# Backup
cp packages/api/src/routes/cet.routes.ts packages/api/src/routes/cet.routes.ts.backup

# Criar versão corrigida
cat > packages/api/src/routes/cet.routes.ts << 'ROUTES'
import type { FastifyInstance } from "fastify";
import { cetController } from "../controllers/cet.controller";
import { CETBasicRequestSchema } from "../schemas/cet.schema";

/**
 * Rotas de CET (Custo Efetivo Total)
 */
export async function cetRoutes(app: FastifyInstance) {
  /**
   * POST /api/cet/basic
   * 
   * Calcula CET Básico de um empréstimo.
   * 
   * CET Básico considera apenas tarifas aplicadas em t=0 (momento da concessão).
   * Não inclui IOF, seguros ou custos recorrentes.
   */
  app.post(
    "/cet/basic",
    {
      schema: {
        description: "Calcula CET Básico (tarifas t=0)",
        tags: ["CET"],
        body: {
          type: "object",
          required: ["pv", "pmt", "n"],
          properties: {
            pv: { type: "number", minimum: 0 },
            pmt: { type: "number", minimum: 0 },
            n: { type: "integer", minimum: 1, maximum: 480 },
            feesT0: {
              type: "array",
              items: { type: "number", minimum: 0 },
              default: []
            },
            baseAnnual: { type: "integer", minimum: 1, default: 12 }
          }
        },
        response: {
          200: {
            type: "object",
            properties: {
              irrMonthly: { type: "number" },
              cetAnnual: { type: "number" },
              valorLiquido: { type: "number" },
              totalFees: { type: "number" },
              cashflows: { type: "array", items: { type: "number" } },
              meta: {
                type: "object",
                properties: {
                  motorVersion: { type: "string" },
                  calculationId: { type: "string" },
                  timestamp: { type: "string" }
                }
              }
            }
          }
        }
      },
      preValidation: async (request, reply) => {
        try {
          // Validar com Zod
          request.body = CETBasicRequestSchema.parse(request.body);
        } catch (error: any) {
          reply.status(400).send({
            error: "Bad Request",
            message: error.errors?.[0]?.message || "Invalid request body"
          });
        }
      }
    },
    cetController.calculateBasic.bind(cetController)
  );
}
ROUTES

echo "   ✅ cet.routes.ts corrigido"
echo ""

echo "3️⃣ Rebuilding API..."
echo ""
cd packages/api
pnpm build
cd ../..

echo ""
echo "============================================"
echo "✅ CORREÇÃO APLICADA!"
echo "============================================"
echo ""
echo "🚀 Teste agora:"
echo "   pnpm -F @finmath/api dev"
echo ""
