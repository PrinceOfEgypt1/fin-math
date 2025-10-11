import { d, round2 } from "../util/round";
export function pmt(
  pv: string | number,
  i: string | number,
  n: number,
  due = false,
) {
  const I = d(i),
    PV = d(pv);
  if (I.isZero()) return round2(PV.div(n));
  const a = I.plus(1).pow(n).minus(1).div(I);
  let p = PV.div(a);
  if (due) p = p.div(I.plus(1));
  return round2(p);
}
