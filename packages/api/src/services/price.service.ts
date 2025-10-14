import { PriceRequest } from "../schemas/price.schema";
import { randomUUID } from "node:crypto";

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
  const calculationId = randomUUID();
  const motorVersion = "0.4.0";

  const i = req.annualRate / 12;
  const pv = req.pv;
  const n = req.n;

  const pow = Math.pow(1 + i, n);
  const pmt = i === 0 ? pv / n : (pv * i * pow) / (pow - 1);

  let schedule: Row[] = [];
  let saldo = pv;

  for (let k = 1; k <= n; k++) {
    const interest = saldo * i;
    let amort = pmt - interest;
    let newSaldo = saldo - amort;

    if (k === n) {
      const residual = newSaldo;
      if (Math.abs(residual) > 0.005) {
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

  return {
    calculationId,
    motorVersion,
    result: {
      pmt: HALF_UP(pmt),
      schedule,
    },
  };
}
