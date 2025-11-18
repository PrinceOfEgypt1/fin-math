import Decimal from "decimal.js";
Decimal.set({ precision: 40, rounding: Decimal.ROUND_HALF_UP });
export const d = (v: number | string) => new Decimal(v);
export const round2 = (x: Decimal | number | string) =>
  new Decimal(x).toDecimalPlaces(2, Decimal.ROUND_HALF_UP);
