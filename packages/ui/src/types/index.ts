/**
 * Tipos TypeScript do FinMath UI
 */

export type AmortizationSystem = "PRICE" | "SAC";
export type DayCountConvention = "30/360" | "ACT/365" | "ACT/360";

export interface AmortizationScheduleRow {
  period: number;
  dueDate: Date;
  payment: number;
  interest: number;
  amortization: number;
  balance: number;
}
