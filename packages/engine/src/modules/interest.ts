import { d, round2 } from "../util/round.js";
export function fv(pv: string | number, i: string | number, n: number) {
  return round2(d(pv).mul(d(1).add(d(i)).pow(n)));
}
export function pv(fv: string | number, i: string | number, n: number) {
  return round2(d(fv).div(d(1).add(d(i)).pow(n)));
}
