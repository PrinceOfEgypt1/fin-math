// packages/api/src/routes/irr.routes.ts
import type { FastifyInstance, FastifyPluginOptions } from "fastify";
import { z } from "zod";
import { irr as irrModule } from "finmath-engine";

function solveIRRWithBisection(
  cashFlows: number[],
  opts?: { tol?: number; maxIter?: number },
) {
  const tol = opts?.tol ?? 1e-6;
  const maxIter = opts?.maxIter ?? 200;

  let low = -0.9999;
  let high = 1.0;
  const npvAt = (r: number) => irrModule.npv(r, cashFlows).toNumber();

  let fLow = npvAt(low);
  let fHigh = npvAt(high);

  let expandCount = 0;
  while (fLow * fHigh > 0 && expandCount < 12) {
    high *= 2;
    fHigh = npvAt(high);
    expandCount++;
    if (fLow * fHigh <= 0) break;
    low = Math.max(-0.9999, low - 0.5);
    fLow = npvAt(low);
  }

  if (fLow * fHigh > 0) {
    return {
      converged: false,
      iterations: 0,
      irr: null as number | null,
      method: "bisection" as const,
    };
  }

  let iterations = 0;
  let mid = 0;
  for (; iterations < maxIter; iterations++) {
    mid = (low + high) / 2;
    const fMid = npvAt(mid);

    if (Math.abs(fMid) < tol || Math.abs(high - low) < tol) {
      return {
        converged: true,
        iterations,
        irr: mid,
        method: "bisection" as const,
      };
    }

    if (fLow * fMid <= 0) {
      high = mid;
      fHigh = fMid;
    } else {
      low = mid;
      fLow = fMid;
    }
  }

  return {
    converged: false,
    iterations,
    irr: mid,
    method: "bisection" as const,
  };
}

export async function irrRoutes(
  app: FastifyInstance,
  _opts: FastifyPluginOptions,
) {
  app.post("/irr", async (request, reply) => {
    const schema = z.object({
      cashFlows: z.array(z.number()).min(2),
      initialGuess: z.number().optional().default(0.1), // não é usado na bissecção, mantém por compat
      maxIterations: z.number().optional().default(200),
      tolerance: z.number().optional().default(1e-6),
    });

    try {
      const body = schema.parse(request.body);

      const result = solveIRRWithBisection(body.cashFlows, {
        tol: body.tolerance,
        maxIter: body.maxIterations,
      });

      const npvValue =
        result.irr != null ? irrModule.npv(result.irr, body.cashFlows) : null;

      return reply.status(200).send({
        success: true,
        data: {
          irr: result.irr,
          iterations: result.iterations,
          method: result.method,
          converged: result.converged,
          npv: npvValue ? npvValue.toNumber() : null,
        },
      });
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      return reply.status(400).send({ success: false, error: message });
    }
  });
}

export default irrRoutes;
