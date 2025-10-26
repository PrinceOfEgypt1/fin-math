// packages/api/src/controllers/irr.controller.ts
import { Request, Response } from "express";
import { irr } from "finmath-engine";
import Decimal from "decimal.js";
import { z } from "zod";

const IRRRequestSchema = z.object({
  cashFlows: z.array(z.number()).min(2),
  initialGuess: z.number().optional().default(0.1),
  maxIterations: z.number().optional().default(100),
  tolerance: z.number().optional().default(0.0001),
});

export async function calculateIRREndpoint(req: Request, res: Response) {
  try {
    const validated = IRRRequestSchema.parse(req.body);

    const result = irr.solveIRR({
      cashFlows: validated.cashFlows.map((v) => new Decimal(v)),
      initialGuess: new Decimal(validated.initialGuess),
      maxIterations: validated.maxIterations,
      tolerance: new Decimal(validated.tolerance),
    });

    const npvValue =
      result.irr != null
        ? irr.npv({
            rate: result.irr,
            cashFlows: validated.cashFlows.map((v) => new Decimal(v)),
          })
        : null;

    return res.status(200).json({
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
    return res.status(400).json({ success: false, error: message });
  }
}
