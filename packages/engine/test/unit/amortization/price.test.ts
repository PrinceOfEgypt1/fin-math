import { describe, it, expect } from "vitest";
import {
  calculatePMT,
  generatePriceSchedule,
} from "../../../src/amortization/price";
import { Decimal } from "decimal.js";

describe("PRICE Amortization System", () => {
  describe("calculatePMT", () => {
    it("should calculate PMT for 12 months", () => {
      const result = calculatePMT({
        pv: new Decimal("10000"),
        annualRate: new Decimal("0.12"),
        n: 12,
      });

      expect(result.toNumber()).toBeCloseTo(888.49, 2);
    });

    it("should calculate PMT for 24 months", () => {
      const result = calculatePMT({
        pv: new Decimal("50000"),
        annualRate: new Decimal("0.15"),
        n: 24,
      });

      expect(result.toNumber()).toBeCloseTo(2424.33, 2);
    });

    it("should calculate PMT for 36 months", () => {
      const result = calculatePMT({
        pv: new Decimal("100000"),
        annualRate: new Decimal("0.10"),
        n: 36,
      });

      expect(result.toNumber()).toBeCloseTo(3226.72, 2);
    });
  });

  describe("generatePriceSchedule", () => {
    it("should generate complete schedule for 12 months", () => {
      const result = generatePriceSchedule({
        pv: new Decimal("10000"),
        annualRate: new Decimal("0.12"),
        n: 12,
      });

      expect(result.schedule.length).toBe(12);
      expect(result.pmt.toNumber()).toBeCloseTo(888.49, 2);

      const first = result.schedule[0];
      expect(first).toBeDefined();
      expect(first!.period).toBe(1);
      expect(first!.interest.toNumber()).toBeCloseTo(100.0, 2);
      expect(first!.amortization.toNumber()).toBeCloseTo(788.49, 2);

      const last = result.schedule[11];
      expect(last).toBeDefined();
      expect(last!.period).toBe(12);
      expect(last!.balance.toNumber()).toBeLessThanOrEqual(0.01);
    });

    it("should maintain decreasing balance", () => {
      const result = generatePriceSchedule({
        pv: new Decimal("10000"),
        annualRate: new Decimal("0.12"),
        n: 12,
      });

      for (let i = 0; i < result.schedule.length - 1; i++) {
        const current = result.schedule[i];
        const next = result.schedule[i + 1];
        expect(current).toBeDefined();
        expect(next).toBeDefined();
        expect(current!.balance.toNumber()).toBeGreaterThan(
          next!.balance.toNumber(),
        );
      }
    });
  });
});
