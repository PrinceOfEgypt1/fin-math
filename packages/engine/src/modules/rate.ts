import { d } from "../util/round";
export const monthlyToAnnual = (im: string | number) =>
  d(1).add(d(im)).pow(12).minus(1);
export const annualToMonthly = (ia: string | number) =>
  d(1).add(d(ia)).pow(d(1).div(12)).minus(1);
