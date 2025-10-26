// packages/api/src/controllers/irr.controller.ts
import { Request, Response } from "express";
import { irr as irrModule } from "finmath-engine"; // expõe npv(r, cfs)
import Decimal from "decimal.js";
import { z } from "zod";

const IRRRequestSchema = z.object({
  cashFlows: z.array(z.number()).min(2),
  initialGuess: z.number().optional().default(0.1),
  maxIterations: z.number().optional().default(200),
  tolerance: z.number().optional().default(1e-6),
});

// Solver simples por bissecção utilizando NPV do engine
function solveIRRWithBisection(
  cashFlows: number[],
  opts?: { tol?: number; maxIter?: number },
) {
  const tol = opts?.tol ?? 1e-6;
  const maxIter = opts?.maxIter ?? 200;

  let low = -0.9999; // limite inferior (evita divisão por zero no (1+r)^t)
  let high = 1.0; // começa em 100% a.m.
  const npvAt = (r: number) => irrModule.npv(r, cashFlows).toNumber();

  let fLow = npvAt(low);
  let fHigh = npvAt(high);

  // Garante mudança de sinal expandindo o intervalo
  let expandCount = 0;
  while (fLow * fHigh > 0 && expandCount < 12) {
    // expande pra cima
    high *= 2; // 100% -> 200% -> 400% ... (até 4096% máx.)
    fHigh = npvAt(high);
    expandCount++;
    if (fLow * fHigh <= 0) break;
    // expande pra baixo (limitado a -0.9999)
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

export async function calculateIRREndpoint(req: Request, res: Response) {
  try {
    const validated = IRRRequestSchema.parse(req.body);

    // resolve IRR com bissecção, usando o NPV do engine (assinatura: npv(r, cfs))
    const result = solveIRRWithBisection(validated.cashFlows, {
      tol: validated.tolerance,
      maxIter: validated.maxIterations,
    });

    const npvValue =
      result.irr != null
        ? irrModule.npv(result.irr, validated.cashFlows)
        : null;

    return res.status(200).json({
      success: true,
      data: {
        irr: result.irr,
        iterations: result.iterations,
        method: result.method,
        converged: result.converged,
        npv: npvValue ? new Decimal(npvValue).toNumber() : null,
      },
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    return res.status(400).json({ success: false, error: message });
  }
}
