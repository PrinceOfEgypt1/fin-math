import { describe, it, expect } from "vitest";
import { readdirSync, readFileSync } from "fs";
import { join } from "path";
import { generatePriceSchedule } from "../../../src/amortization/price";
import { Decimal } from "decimal.js";

describe("Golden Files - ONDA 2 (PRICE)", () => {
  const goldenDir = __dirname;
  const goldenFiles = readdirSync(goldenDir).filter(
    (f) => f.startsWith("PRICE_") && f.endsWith(".json"),
  );

  goldenFiles.forEach((filename) => {
    it(`should match ${filename}`, () => {
      const filepath = join(goldenDir, filename);
      const golden = JSON.parse(readFileSync(filepath, "utf-8"));

      const result = generatePriceSchedule({
        pv: new Decimal(golden.input.pv),
        annualRate: new Decimal(golden.input.annualRate),
        n: golden.input.n,
      });

      const pmtDiff = Math.abs(
        result.pmt.toNumber() - parseFloat(golden.expected.pmt),
      );
      expect(pmtDiff).toBeLessThanOrEqual(golden.tolerance.pmt);

      expect(result.schedule.length).toBe(golden.expected.schedule.rows);

      const last = result.schedule[result.schedule.length - 1];
      const balanceDiff = Math.abs(last!.balance.toNumber());
      expect(balanceDiff).toBeLessThanOrEqual(golden.tolerance.balance);
    });
  });
});
