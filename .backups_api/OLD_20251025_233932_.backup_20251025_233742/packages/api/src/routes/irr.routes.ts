// packages/api/src/routes/irr.routes.ts
import type { FastifyInstance, FastifyPluginOptions } from "fastify";
import { z } from "zod";
import Decimal from "decimal.js";
import { irr } from "finmath-engine";

export async function irrRoutes(
  app: FastifyInstance,
  _opts: FastifyPluginOptions,
) {
  app.post("/irr", async (request, reply) => {
    const schema = z.object({
      cashFlows: z.array(z.number()).min(2),
      initialGuess: z.number().optional().default(0.1),
      maxIterations: z.number().optional().default(100),
      tolerance: z.number().optional().default(0.0001),
    });

    try {
      const body = schema.parse(request.body);

      const result = irr.solveIRR({
        cashFlows: body.cashFlows.map((v) => new Decimal(v)),
        initialGuess: new Decimal(body.initialGuess),
        maxIterations: body.maxIterations,
        tolerance: new Decimal(body.tolerance),
      });

      const npvValue =
        result.irr != null
          ? irr.npv({
              rate: result.irr,
              cashFlows: body.cashFlows.map((v) => new Decimal(v)),
            })
          : null;

      return reply.status(200).send({
        success: true,
        data: {
          irr: result.irr?.toNumber() ?? null,
          iterations: result.iterations,
          method: result.method,
          converged: result.converged,
          npv: npvValue?.toNumber() ?? null,
        },
      });
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      return reply.status(400).send({ success: false, error: message });
    }
  });
}

export default irrRoutes;
