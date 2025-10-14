import { d } from "../util/round.js";
export function npv(r: number | string, cfs: Array<string | number>) {
  const R = d(r);
  return cfs.reduce((s, cf, t) => s.plus(d(cf).div(d(1).add(R).pow(t))), d(0));
}
export function irrBisection(cfs: Array<string | number>, lo = 0, hi = 1) {
  let fLo = npv(lo, cfs),
    fHi = npv(hi, cfs);
  let tries = 0;
  while (fLo.mul(fHi).gt(0) && hi < 10 && tries < 30) {
    hi *= 1.5;
    fHi = npv(hi, cfs);
    tries++;
  }
  if (fLo.mul(fHi).gt(0)) return null;
  for (let k = 0; k < 120; k++) {
    const mid = (lo + hi) / 2,
      fMid = npv(mid, cfs);
    if (fMid.abs().lt(1e-12)) return mid;
    if (fLo.mul(fMid).lt(0)) {
      hi = mid;
      fHi = fMid;
    } else {
      lo = mid;
      fLo = fMid;
    }
  }
  return (lo + hi) / 2;
}
