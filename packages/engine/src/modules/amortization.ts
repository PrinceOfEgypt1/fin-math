import { d, round2 } from "../util/round.js";
import { pmt as pmtSeries } from "./series.js";

export function price(pv: string | number, i: string | number, n: number) {
  const PMT = round2(pmtSeries(pv, i, n)).toNumber();
  let bal = d(pv);
  const rows: Array<{
    k: number;
    pmt: number;
    interest: number;
    amort: number;
    balance: number;
  }> = [];
  for (let k = 1; k <= n; k++) {
    const interest = round2(bal.mul(i)).toNumber();
    let amort = round2(PMT - interest).toNumber();
    if (k === n) amort = round2(bal).toNumber();
    const newBal = round2(bal.minus(amort)).toNumber();
    rows.push({ k, pmt: PMT, interest, amort, balance: newBal });
    bal = d(newBal);
  }
  const total = rows.reduce((s, r) => s + r.pmt, 0);
  const juros = total - d(pv).toNumber();
  return {
    pmt: PMT,
    rows,
    totalPaid: round2(total).toNumber(),
    totalInterest: round2(juros).toNumber(),
  };
}

export function sac(pv: string | number, i: string | number, n: number) {
  let bal = d(pv);
  const amortConst = round2(bal.div(n)).toNumber();
  const rows: Array<{
    k: number;
    pmt: number;
    interest: number;
    amort: number;
    balance: number;
  }> = [];
  for (let k = 1; k <= n; k++) {
    const interest = round2(bal.mul(i)).toNumber();
    let amort = k === n ? round2(bal).toNumber() : amortConst;
    const pmt = round2(interest + amort).toNumber();
    const newBal = round2(bal.minus(amort)).toNumber();
    rows.push({ k, pmt, interest, amort, balance: newBal });
    bal = d(newBal);
  }
  const total = rows.reduce((s, r) => s + r.pmt, 0);
  const juros = total - d(pv).toNumber();
  return {
    amortConst,
    rows,
    totalPaid: round2(total).toNumber(),
    totalInterest: round2(juros).toNumber(),
  };
}
