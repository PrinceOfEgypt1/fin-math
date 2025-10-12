import { irrBisection } from "./irr";
export function cetBasic(
  pv: number | string,
  pmt: number | string,
  n: number,
  feesT0: Array<number | string> = [],
  baseAnnual = 12,
) {
  const fees = feesT0.reduce<number>(
    (s: number, v: number | string) => s + Number(v),
    0,
  );
  const cfs = [
    Number(pv) - Number(fees),
    ...Array.from({ length: n }, () => -Number(pmt)),
  ];
  const irr = irrBisection(cfs) ?? 0;
  const cetAnnual = Math.pow(1 + irr, baseAnnual) - 1;
  return { irrMonthly: irr, cetAnnual, cashflows: cfs };
}
