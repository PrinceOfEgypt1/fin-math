import { Decimal } from "decimal.js";
import { round2 } from "../util/round.js";

/**
 * Input for PRICE calculation
 */
export interface PriceInput {
  pv: Decimal;
  annualRate: Decimal;
  n: number;
}

/**
 * Row in PRICE schedule
 */
export interface PriceScheduleRow {
  period: number;
  pmt: Decimal;
  interest: Decimal;
  amortization: Decimal;
  balance: Decimal;
}

/**
 * Result of PRICE calculation
 */
export interface PriceResult {
  pmt: Decimal;
  schedule: PriceScheduleRow[];
}

/**
 * Calculate PMT (fixed payment) for PRICE system
 *
 * Formula: PMT = PV * [i * (1+i)^n] / [(1+i)^n - 1]
 */
export function calculatePMT(input: PriceInput): Decimal {
  const { pv, annualRate, n } = input;

  const i = annualRate.div(12);
  const onePlusI = new Decimal(1).add(i);
  const power = onePlusI.pow(n);

  const numerator = i.mul(power);
  const denominator = power.sub(1);

  const pmt = pv.mul(numerator).div(denominator);

  return round2(pmt);
}

/**
 * Generate complete PRICE amortization schedule
 */
export function generatePriceSchedule(input: PriceInput): PriceResult {
  const { pv, annualRate, n } = input;

  const pmt = calculatePMT(input);
  const monthlyRate = annualRate.div(12);

  const schedule: PriceScheduleRow[] = [];
  let balance = pv;

  for (let period = 1; period <= n; period++) {
    const interest = round2(balance.mul(monthlyRate));
    let amortization = round2(pmt.sub(interest));

    if (period === n) {
      amortization = round2(balance);
    }

    const newBalance = round2(balance.sub(amortization));

    schedule.push({
      period,
      pmt,
      interest,
      amortization,
      balance: newBalance,
    });

    balance = newBalance;
  }

  return {
    pmt,
    schedule,
  };
}
