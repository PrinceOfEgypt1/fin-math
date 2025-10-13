import Decimal from "decimal.js";
import { randomUUID } from "crypto";
import { addMonths, format } from "date-fns";
import { createContextLogger } from "../../infrastructure/logger";
import {
  recordCalculationDuration,
  recordCalculationResult,
} from "../../infrastructure/metrics";
import type {
  PriceRequest,
  PriceResponse,
} from "../../presentation/validators/price.schema";

// PMT Price local (evita acoplamento direto ao pacote do motor neste protótipo)
function pmtPrice(pv: Decimal, i: Decimal, n: number): Decimal {
  if (n <= 0) return new Decimal(0);
  if (i.isZero()) return pv.div(n);
  const a = i.add(1).pow(n);
  return pv.mul(i.mul(a).div(a.sub(1)));
}

export interface IPriceService {
  calculate(params: PriceRequest): Promise<PriceResponse>;
}

export class PriceService implements IPriceService {
  private readonly motorVersion = "0.1.1";
  async calculate(params: PriceRequest): Promise<PriceResponse> {
    const t0 = Date.now();
    const calculationId = randomUUID();
    const log = createContextLogger({
      calculationId,
      motorVersion: this.motorVersion,
    });

    try {
      const pv = new Decimal(params.pv);
      const i = new Decimal(params.rate);
      const pmt = pmtPrice(pv, i, params.n);

      const schedule = [];
      let balance = pv;
      const base = new Date();
      for (let k = 1; k <= params.n; k++) {
        const interest = balance.mul(i);
        let amort = pmt.sub(interest);
        let payment = pmt;
        if (k === params.n) {
          amort = balance;
          payment = amort.add(interest);
        }
        balance = balance.sub(amort);
        schedule.push({
          period: k,
          date: addMonths(base, k),
          payment,
          interest,
          amortization: amort,
          balance: balance.abs().lt(0.01) ? new Decimal(0) : balance,
        });
      }

      const totalInterest = schedule.reduce(
        (s, r) => s.add(r.interest),
        new Decimal(0),
      );
      const totalFeesT0 = (params.feesT0 || []).reduce(
        (s, f) => s + f.value,
        0,
      );
      const totalPaid = pmt.mul(params.n).add(totalFeesT0);

      const duration = Date.now() - t0;
      recordCalculationDuration("price", duration);
      recordCalculationResult("price", true);
      log.info(
        {
          pmt: pmt.toFixed(2),
          totalInterest: totalInterest.toFixed(2),
          duration,
        },
        "OK",
      );

      return {
        pmt: pmt.toNumber(),
        totalInterest: totalInterest.toNumber(),
        totalPaid: totalPaid.toNumber(),
        schedule: schedule.map((p) => ({
          period: p.period,
          date: format(p.date, "yyyy-MM-dd"),
          payment: p.payment.toNumber(),
          interest: p.interest.toNumber(),
          amortization: p.amortization.toNumber(),
          balance: p.balance.toNumber(),
        })),
        meta: {
          calculationId,
          motorVersion: this.motorVersion,
          timestamp: new Date().toISOString(),
        },
      };
    } catch (err) {
      const duration = Date.now() - t0;
      recordCalculationDuration("price", duration);
      recordCalculationResult("price", false);
      throw err;
    }
  }
}
