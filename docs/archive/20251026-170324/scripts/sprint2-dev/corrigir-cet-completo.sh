#!/bin/bash
set -euo pipefail

echo "🔧 CORRIGINDO CET - PADRÃO DO PROJETO"
echo "====================================="
echo ""

# 1. CORRIGIR CONTROLLER
echo "1️⃣ Corrigindo cet.controller.ts..."
cat > packages/api/src/controllers/cet.controller.ts << 'CONTROLLER'
import { FastifyRequest, FastifyReply } from "fastify";
import { CETBasicRequestSchema } from "../schemas/cet.schema";
import { cetService } from "../services/cet.service";

export async function postCETBasic(
  req: FastifyRequest,
  reply: FastifyReply
) {
  const parsed = CETBasicRequestSchema.safeParse(req.body);
  
  if (!parsed.success) {
    return reply.status(400).send({
      error: {
        code: "VALIDATION_ERROR",
        message: "Validation failed",
        details: parsed.error.errors.map((e) => ({
          path: e.path,
          message: e.message,
        })),
      },
    });
  }

  const result = cetService.calculateBasic(parsed.data);
  return reply.send(result);
}
CONTROLLER
echo "   ✅ Controller corrigido"

# 2. CORRIGIR ROUTES
echo ""
echo "2️⃣ Corrigindo cet.routes.ts..."
cat > packages/api/src/routes/cet.routes.ts << 'ROUTES'
import { FastifyInstance } from "fastify";
import { postCETBasic } from "../controllers/cet.controller";

export async function cetRoutes(app: FastifyInstance) {
  app.post("/cet/basic", postCETBasic);
}
ROUTES
echo "   ✅ Routes corrigido"

# 3. CORRIGIR SERVICE (remover async desnecessário)
echo ""
echo "3️⃣ Verificando service..."
if grep -q "async calculateBasic" packages/api/src/services/cet.service.ts; then
  echo "   ⚠️  Service tem async desnecessário"
  
  cat > packages/api/src/services/cet.service.ts << 'SERVICE'
import { cetBasic } from "@finmath/engine";
import type { CETBasicRequest, CETBasicResponse } from "../schemas/cet.schema";

/**
 * Serviço para cálculos de CET
 */
export class CETService {
  /**
   * Calcula CET Básico
   * 
   * @param params - Parâmetros do empréstimo
   * @returns Resultado com CET mensal, anual e detalhes
   */
  calculateBasic(params: CETBasicRequest): CETBasicResponse {
    const { pv, pmt, n, feesT0, baseAnnual } = params;

    // Chamar motor
    const result = cetBasic(pv, pmt, n, feesT0, baseAnnual);

    // Calcular valor líquido e total de tarifas
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
  echo "   ✅ Service corrigido"
else
  echo "   ✅ Service já está correto"
fi

# 4. REBUILD
echo ""
echo "4️⃣ Rebuilding API..."
cd packages/api
pnpm build

if [ $? -eq 0 ]; then
  echo ""
  echo "====================================="
  echo "✅ CORREÇÃO APLICADA COM SUCESSO!"
  echo "====================================="
  echo ""
  echo "🚀 TESTE AGORA:"
  echo "   Terminal 1: pnpm -F @finmath/api dev"
  echo ""
  echo "   Terminal 2:"
  echo "   curl -X POST http://localhost:3001/api/cet/basic \\"
  echo "     -H 'Content-Type: application/json' \\"
  echo "     -d '{\"pv\":10000,\"pmt\":946.56,\"n\":12,\"feesT0\":[50,30]}'"
  echo ""
else
  echo ""
  echo "❌ Build falhou - verificar erros acima"
  exit 1
fi

cd ../..
