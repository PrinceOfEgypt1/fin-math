/**
 * Day Count Module
 * Implements day count conventions and pro-rata interest calculations
 */

export { daysBetween, yearFraction } from "./conventions.js";
export type { DayCountConvention } from "./conventions.js";
export { calculateProRataInterest } from "./pro-rata.js";
export type { ProRataInput, ProRataResult } from "./pro-rata.js";
