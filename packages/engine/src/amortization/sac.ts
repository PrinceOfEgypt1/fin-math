// packages/engine/src/amortization/sac.ts
import { Decimal } from "decimal.js";
import { round2 } from "../util/round.js";

export interface SacInput {
  pv: Decimal;
  annualRate: Decimal;
  n: number;
}

export interface SacScheduleRow {
  period: number;
  pmt: Decimal;
  interest: Decimal;
  amortization: Decimal;
  balance: Decimal;
}

export interface SacResult {
  amortConst: Decimal;
  schedule: SacScheduleRow[];
}

export function generateSacSchedule(input: SacInput): SacResult {
  const { pv, annualRate, n } = input;
  const monthlyRate = annualRate.div(12);
  const amortConst = round2(pv.div(n));
  const schedule: SacScheduleRow[] = [];
  let balance = pv;

  for (let k = 1; k <= n; k++) {
    const interest = round2(balance.mul(monthlyRate));
    let amortization: Decimal;
    if (k === n) {
      amortization = round2(balance);
    } else {
      amortization = amortConst;
    }
    const pmt = round2(interest.add(amortization));
    const newBalance = round2(balance.sub(amortization));
    schedule.push({
      period: k,
      pmt,
      interest,
      amortization,
      balance: newBalance,
    });
    balance = newBalance;
  }

  return { amortConst, schedule };
}
