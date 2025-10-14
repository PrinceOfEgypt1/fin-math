import { PriceRequest } from "../schemas/price.schema.js";
import { generatePriceSchedule } from "@finmath/engine";
import { Decimal } from "decimal.js";
import { randomUUID } from "node:crypto";

export async function calculatePrice(req: PriceRequest) {
  const calculationId = randomUUID();
  const motorVersion = "0.4.0";

  // Usar engine com Decimal.js
  const result = generatePriceSchedule({
    pv: new Decimal(req.pv),
    annualRate: new Decimal(req.annualRate),
    n: req.n,
  });

  // Converter para formato esperado pela API
  const schedule = result.schedule.map((row) => ({
    k: row.period,
    pmt: row.pmt.toNumber(),
    interest: row.interest.toNumber(),
    amort: row.amortization.toNumber(),
    balance: row.balance.toNumber(),
  }));

  return {
    calculationId,
    motorVersion,
    result: {
      pmt: result.pmt.toNumber(),
      schedule,
    },
  };
}
