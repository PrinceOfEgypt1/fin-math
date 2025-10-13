import { Decimal } from "decimal.js";
import { round2 } from "../util/round";
import { yearFraction, type DayCountConvention } from "./conventions";

/**
 * Input for pro-rata interest calculation
 */
export interface ProRataInput {
  principal: Decimal;
  annualRate: Decimal;
  startDate: Date;
  endDate: Date;
  convention: DayCountConvention;
}

/**
 * Result of pro-rata interest calculation
 */
export interface ProRataResult {
  interest: Decimal;
  yearFraction: Decimal;
  days: number;
  convention: DayCountConvention;
}

/**
 * Calculate pro-rata interest for a period
 *
 * Formula: Interest = Principal × Annual_Rate × Year_Fraction
 *
 * @param input - Calculation input parameters
 * @returns Pro-rata interest result
 *
 * @example
 * calculateProRataInterest({
 *   principal: new Decimal('100000'),
 *   annualRate: new Decimal('0.12'),
 *   startDate: new Date('2025-01-01'),
 *   endDate: new Date('2025-02-01'),
 *   convention: 'ACT/365'
 * })
 * // Returns { interest: 1019.18, yearFraction: 0.0849..., days: 31 }
 */
export function calculateProRataInterest(input: ProRataInput): ProRataResult {
  const { principal, annualRate, startDate, endDate, convention } = input;

  // Calculate year fraction
  const yf = yearFraction(startDate, endDate, convention);

  // Calculate interest: P × r × t
  const interest = principal.mul(annualRate).mul(yf);

  // Calculate actual days for reference
  const diffMs = endDate.getTime() - startDate.getTime();
  const days = Math.floor(diffMs / (1000 * 60 * 60 * 24));

  return {
    interest: round2(interest),
    yearFraction: yf,
    days,
    convention,
  };
}
