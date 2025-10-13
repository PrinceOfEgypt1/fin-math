/**
 * Day Count Module
 * Implements day count conventions and pro-rata interest calculations
 */

export { daysBetween, yearFraction } from "./conventions";
export type { DayCountConvention } from "./conventions";
export { calculateProRataInterest } from "./pro-rata";
export type { ProRataInput, ProRataResult } from "./pro-rata";
