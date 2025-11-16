import { Decimal } from "decimal.js";

/**
 * Day count conventions supported
 */
export type DayCountConvention = "30/360" | "ACT/365" | "ACT/360";

/**
 * Calculate days between two dates using specified convention
 *
 * @param startDate - Start date (inclusive)
 * @param endDate - End date (exclusive)
 * @param convention - Day count convention to use
 * @returns Number of days according to convention
 *
 * @example
 * daysBetween(new Date('2025-01-01'), new Date('2025-02-01'), '30/360') // 30
 * daysBetween(new Date('2025-01-01'), new Date('2025-02-01'), 'ACT/365') // 31
 */
export function daysBetween(
  startDate: Date,
  endDate: Date,
  convention: DayCountConvention,
): number {
  if (convention === "30/360") {
    return days30_360(startDate, endDate);
  }

  // ACT/365 and ACT/360 use actual days
  return actualDays(startDate, endDate);
}

/**
 * Calculate year fraction between two dates
 *
 * @param startDate - Start date (inclusive)
 * @param endDate - End date (exclusive)
 * @param convention - Day count convention to use
 * @returns Year fraction as Decimal
 *
 * @example
 * yearFraction(new Date('2025-01-01'), new Date('2025-07-01'), 'ACT/365')
 * // Returns ~0.4959 (181 days / 365)
 */
export function yearFraction(
  startDate: Date,
  endDate: Date,
  convention: DayCountConvention,
): Decimal {
  const days = daysBetween(startDate, endDate, convention);

  const divisor = convention === "ACT/360" ? 360 : 365;

  return new Decimal(days).div(divisor);
}

/**
 * Calculate actual days between dates (calendar days)
 */
function actualDays(startDate: Date, endDate: Date): number {
  const start = new Date(startDate);
  const end = new Date(endDate);

  // Remove time component
  start.setHours(0, 0, 0, 0);
  end.setHours(0, 0, 0, 0);

  const diffMs = end.getTime() - start.getTime();
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

  return diffDays;
}

/**
 * Calculate days using 30/360 convention
 * Each month is considered to have 30 days
 */
function days30_360(startDate: Date, endDate: Date): number {
  let y1 = startDate.getFullYear();
  let m1 = startDate.getMonth() + 1;
  let d1 = startDate.getDate();

  let y2 = endDate.getFullYear();
  let m2 = endDate.getMonth() + 1;
  let d2 = endDate.getDate();

  // Adjust day 31 to day 30
  if (d1 === 31) d1 = 30;
  if (d2 === 31 && d1 >= 30) d2 = 30;

  return 360 * (y2 - y1) + 30 * (m2 - m1) + (d2 - d1);
}
