import { PriceRequest } from "../schemas/price.schema";
import { randomUUID } from "node:crypto";
// Import do motor (expostos no package @finmath/engine)
import { amortization } from "@finmath/engine"; // assume export { amortization } no index do motor
// Fallback simples se o motor tiver API distinta
type Row = {
  k: number;
  pmt: number;
  interest: number;
  amort: number;
  balance: number;
  date?: string;
};

const HALF_UP = (x: number, places = 2) =>
  Number(Math.round(Number(x + "e+" + places)) + "e-" + places);

export async function calculatePrice(req: PriceRequest) {
  const t0 = performance.now();
  const calculationId = randomUUID();
  const motorVersion = "0.1.1";

  // Cálculo via motor, com fallback manual
  let schedule: Row[] = [];
  const i = req.rateMonthly;
  const pv = req.pv;
  const n = req.n;

  // PMT PRICE
  const pow = Math.pow(1 + i, n);
  const pmt = i === 0 ? pv / n : (pv * i * pow) / (pow - 1);

  // Construção de cronograma (juros↓, amort↑)
  let saldo = pv;
  for (let k = 1; k <= n; k++) {
    const interest = saldo * i;
    let amort = pmt - interest;
    let newSaldo = saldo - amort;

    // Ajuste final na última parcela (saldo residual ≤ 0,01)
    if (k === n) {
      const residual = newSaldo;
      if (Math.abs(residual) > 0.005) {
        // corrige na amortização final
        amort += residual;
        newSaldo = 0;
      } else {
        newSaldo = 0;
      }
    }

    schedule.push({
      k,
      pmt: HALF_UP(pmt),
      interest: HALF_UP(interest),
      amort: HALF_UP(amort),
      balance: HALF_UP(newSaldo < 0 ? 0 : newSaldo),
    });
    saldo = newSaldo;
  }

  const totalPaid = HALF_UP(
    schedule.reduce((s, r) => s + r.pmt, 0) + (req.feesT0 || 0),
  );
  const totalInterest = HALF_UP(schedule.reduce((s, r) => s + r.interest, 0));
  const durationMs = Math.max(0, performance.now() - t0);

  return {
    pmt: HALF_UP(pmt),
    schedule,
    totals: { totalPaid, totalInterest, feesT0: HALF_UP(req.feesT0 || 0) },
    meta: { calculationId, motorVersion, durationMs },
  };
}
