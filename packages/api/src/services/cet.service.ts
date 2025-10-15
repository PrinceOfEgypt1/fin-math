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
