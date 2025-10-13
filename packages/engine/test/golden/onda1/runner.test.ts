import { describe, it, expect } from "vitest";
import { readdirSync, readFileSync } from "fs";
import { join } from "path";
import { calculateProRataInterest } from "../../../src/day-count/pro-rata";
import { Decimal } from "decimal.js";

describe("Golden Files - ONDA 1 (Day Count)", () => {
  const goldenDir = __dirname;
  const goldenFiles = readdirSync(goldenDir).filter(
    (f) => f.startsWith("DAYCOUNT_") && f.endsWith(".json"),
  );

  goldenFiles.forEach((filename) => {
    it(`should match ${filename}`, () => {
      const filepath = join(goldenDir, filename);
      const golden = JSON.parse(readFileSync(filepath, "utf-8"));

      const result = calculateProRataInterest({
        principal: new Decimal(golden.input.principal),
        annualRate: new Decimal(golden.input.annualRate),
        startDate: new Date(golden.input.startDate),
        endDate: new Date(golden.input.endDate),
        convention: golden.input.convention,
      });

      // Validate interest
      const interestDiff = Math.abs(
        result.interest.toNumber() - parseFloat(golden.expected.interest),
      );
      expect(interestDiff).toBeLessThanOrEqual(golden.tolerance.interest);

      // Validate other fields
      expect(result.days).toBe(golden.expected.days);
      expect(result.convention).toBe(golden.expected.convention);

      // Year fraction should match (with tolerance)
      const yfDiff = Math.abs(
        result.yearFraction.toNumber() -
          parseFloat(golden.expected.yearFraction),
      );
      expect(yfDiff).toBeLessThanOrEqual(0.0001);
    });
  });
});
