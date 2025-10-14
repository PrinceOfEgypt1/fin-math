import { SacRequest } from "../schemas/sac.schema";
import { randomUUID } from "node:crypto";
const HALF_UP = (x: number, places = 2) =>
  Number(Math.round(Number(x + "e+" + places)) + "e-" + places);

type Row = {
  k: number;
  pmt: number;
  interest: number;
  amort: number;
  balance: number;
};

export async function calculateSac(req: SacRequest) {
  const t0 = performance.now();
  const calculationId = randomUUID();
  const motorVersion = "0.1.1";

  const i = req.rateMonthly;
  const pv = req.pv;
  const n = req.n;

  const amortConst = pv / n;
  let saldo = pv;
  const schedule: Row[] = [];
  for (let k = 1; k <= n; k++) {
    const interest = saldo * i;
    let pmt = amortConst + interest;
    let amort = amortConst;
    let newSaldo = saldo - amort;

    if (k === n) {
      if (Math.abs(newSaldo) > 0.005) {
        amort += newSaldo;
        pmt = amort + interest;
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

  const totals = {
    totalPaid: HALF_UP(
      schedule.reduce((s, r) => s + r.pmt, 0) + (req.feesT0 || 0),
    ),
    totalInterest: HALF_UP(schedule.reduce((s, r) => s + r.interest, 0)),
    feesT0: HALF_UP(req.feesT0 || 0),
  };

  return {
    schedule,
    totals,
    meta: {
      calculationId,
      motorVersion,
      durationMs: Math.max(0, performance.now() - t0),
    },
  };
}
