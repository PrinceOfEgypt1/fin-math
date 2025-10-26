import { Request, Response } from "express";
import { calculateIRR, calculateNPV } from "finmath-engine";
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

    const result = calculateIRR(
      validated.cashFlows.map((cf) => new Decimal(cf)),
      new Decimal(validated.initialGuess),
      validated.maxIterations,
      new Decimal(validated.tolerance),
    );

    res.json({
      success: true,
      data: {
        irr: result.irr.toNumber(),
        iterations: result.iterations,
        method: result.method,
        converged: result.converged,
        npv: result.npv?.toNumber(),
      },
    });
  } catch (error: unknown) {
    res.status(400).json({
      success: false,
      error: error.message,
    });
  }
}
