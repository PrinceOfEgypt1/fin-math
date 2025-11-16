import { describe, it, expect } from "vitest";
import { daysBetween, yearFraction } from "../../../src/day-count/conventions";
import { Decimal } from "decimal.js";

describe("Day Count Conventions", () => {
  describe("30/360", () => {
    it("should calculate days for full month (Jan to Feb)", () => {
      const start = new Date("2025-01-01");
      const end = new Date("2025-02-01");
      expect(daysBetween(start, end, "30/360")).toBe(30);
    });

    it("should calculate days for partial month", () => {
      const start = new Date("2025-01-15");
      const end = new Date("2025-02-15");
      expect(daysBetween(start, end, "30/360")).toBe(30);
    });

    it("should handle day 31 adjustments", () => {
      const start = new Date("2025-01-31");
      const end = new Date("2025-03-31");
      expect(daysBetween(start, end, "30/360")).toBe(60);
    });

    it("should calculate year fraction", () => {
      const start = new Date("2025-01-01");
      const end = new Date("2025-07-01");
      const yf = yearFraction(start, end, "30/360");
      expect(yf.toNumber()).toBeCloseTo(0.4932, 4); // 180/365
    });
  });

  describe("ACT/365", () => {
    it("should calculate actual days for January (31 days)", () => {
      const start = new Date("2025-01-01");
      const end = new Date("2025-02-01");
      expect(daysBetween(start, end, "ACT/365")).toBe(31);
    });

    it("should calculate actual days for February (28 days)", () => {
      const start = new Date("2025-02-01");
      const end = new Date("2025-03-01");
      expect(daysBetween(start, end, "ACT/365")).toBe(28);
    });

    it("should calculate year fraction", () => {
      const start = new Date("2025-01-01");
      const end = new Date("2025-07-01");
      const yf = yearFraction(start, end, "ACT/365");
      expect(yf.toNumber()).toBeCloseTo(0.4959, 4); // 181/365
    });
  });

  describe("ACT/360", () => {
    it("should use actual days with 360 divisor", () => {
      const start = new Date("2025-01-01");
      const end = new Date("2025-02-01");
      expect(daysBetween(start, end, "ACT/360")).toBe(31);

      const yf = yearFraction(start, end, "ACT/360");
      expect(yf.toNumber()).toBeCloseTo(0.0861, 4); // 31/360
    });
  });
});
