import { describe, it, expect } from "vitest";
import { calculateProRataInterest } from "../../../src/day-count/pro-rata";
import { Decimal } from "decimal.js";

describe("Pro-Rata Interest", () => {
  it("should calculate pro-rata interest for 1 month (ACT/365)", () => {
    const result = calculateProRataInterest({
      principal: new Decimal("100000"),
      annualRate: new Decimal("0.12"),
      startDate: new Date("2025-01-01"),
      endDate: new Date("2025-02-01"),
      convention: "ACT/365",
    });

    expect(result.interest.toNumber()).toBeCloseTo(1019.18, 2);
    expect(result.days).toBe(31);
    expect(result.convention).toBe("ACT/365");
  });

  it("should calculate pro-rata interest for 1 month (30/360)", () => {
    const result = calculateProRataInterest({
      principal: new Decimal("100000"),
      annualRate: new Decimal("0.12"),
      startDate: new Date("2025-01-01"),
      endDate: new Date("2025-02-01"),
      convention: "30/360",
    });

    expect(result.interest.toNumber()).toBeCloseTo(986.3, 2);
    expect(result.days).toBe(31);
    expect(result.convention).toBe("30/360");
  });

  it("should calculate pro-rata interest for 6 months", () => {
    const result = calculateProRataInterest({
      principal: new Decimal("50000"),
      annualRate: new Decimal("0.10"),
      startDate: new Date("2025-01-01"),
      endDate: new Date("2025-07-01"),
      convention: "ACT/365",
    });

    expect(result.interest.toNumber()).toBeCloseTo(2479.45, 2);
    expect(result.days).toBe(181);
  });
});
