import { describe, it, expect } from "vitest";
import { Decimal } from "decimal.js";
import {
  calculateNPV,
  hasSignChange,
  countSignChanges,
} from "../../../src/irr/npv";

// PMT para anuidade postecipada: PMT = PV * [r(1+r)^n]/[(1+r)^n - 1]
function pmtAnnuityPostec(PV: Decimal, r: Decimal, n: number): Decimal {
  if (r.eq(0)) {
    return PV.div(n);
  }
  const one = new Decimal(1);
  const pow = one.plus(r).pow(n);
  return PV.mul(r).mul(pow).div(pow.minus(1));
}

describe("NPV - Net Present Value", () => {
  describe("calculateNPV", () => {
    it("calcula NPV corretamente para fluxo simples", () => {
      // Fluxo: [1000, -500, -600], r = 10%
      // NPV ≈ 49.59
      const cash = [new Decimal(1000), new Decimal(-500), new Decimal(-600)];
      const r = new Decimal(0.1);
      const npv = calculateNPV(r, cash);
      expect(npv.toNumber()).toBeCloseTo(49.59, 2);
    });

    it("NPV ≈ 0 quando r é a IRR do fluxo (empréstimo CF0>0, saídas negativas)", () => {
      const PV = new Decimal(10000);
      const irr = new Decimal(0.025); // 2.5% a.m.
      const n = 12;
      const pmt = pmtAnnuityPostec(PV, irr, n); // ≈ 974.87
      const cash = [PV, ...Array.from({ length: n }, () => pmt.neg())];
      const npv = calculateNPV(irr, cash);
      expect(Math.abs(npv.toNumber())).toBeLessThan(1e-2); // 1 centavo
    });

    it("para fluxo de empréstimo: se r < IRR => NPV < 0", () => {
      const PV = new Decimal(10000);
      const irr = new Decimal(0.025);
      const n = 12;
      const pmt = pmtAnnuityPostec(PV, irr, n);
      const cash = [PV, ...Array.from({ length: n }, () => pmt.neg())];

      const rLower = new Decimal(0.02); // menor que IRR
      const npvLower = calculateNPV(rLower, cash);
      expect(npvLower.isNegative()).toBe(true);
    });

    it("para fluxo de empréstimo: se r > IRR => NPV > 0", () => {
      const PV = new Decimal(10000);
      const irr = new Decimal(0.025);
      const n = 12;
      const pmt = pmtAnnuityPostec(PV, irr, n);
      const cash = [PV, ...Array.from({ length: n }, () => pmt.neg())];

      const rHigher = new Decimal(0.03); // maior que IRR
      const npvHigher = calculateNPV(rHigher, cash);
      expect(npvHigher.isPositive()).toBe(true);
    });

    it("lança erro para array vazio", () => {
      expect(() => calculateNPV(new Decimal(0.1), [])).toThrow(
        "Cashflows array cannot be empty",
      );
    });

    it("trata taxa zero (NPV = soma dos fluxos)", () => {
      const cash = [new Decimal(1000), new Decimal(-500), new Decimal(-600)];
      const r = new Decimal(0);
      const npv = calculateNPV(r, cash);
      expect(npv.toNumber()).toBeCloseTo(-100, 10);
    });

    it("lança erro quando rate <= -1 (evita divisão por zero)", () => {
      const cash = [new Decimal(100), new Decimal(-100)];
      expect(() => calculateNPV(new Decimal(-1), cash)).toThrow();
      expect(() => calculateNPV(new Decimal(-1.5), cash)).toThrow();
    });
  });

  describe("hasSignChange / countSignChanges (ignorando zeros)", () => {
    it("detecta mudança (+ → -) ignorando zeros", () => {
      const cash = [
        new Decimal(0),
        new Decimal(100),
        new Decimal(0),
        new Decimal(-10),
      ];
      expect(hasSignChange(cash)).toBe(true);
    });

    it("detecta mudança (- → +)", () => {
      const cash = [new Decimal(-1000), new Decimal(0), new Decimal(500)];
      expect(hasSignChange(cash)).toBe(true);
    });

    it("false quando todos positivos ou todos negativos (zeros ignorados)", () => {
      expect(
        hasSignChange([new Decimal(0), new Decimal(1), new Decimal(2)]),
      ).toBe(false);
      expect(
        hasSignChange([new Decimal(-1), new Decimal(0), new Decimal(-2)]),
      ).toBe(false);
    });

    it("contagem de mudanças (zeros ignorados)", () => {
      const cash = [
        new Decimal(1000), // +
        new Decimal(0),
        new Decimal(-500), // - (1)
        new Decimal(200), // + (2)
        new Decimal(0),
        new Decimal(-100), // - (3)
      ];
      expect(countSignChanges(cash)).toBe(3);
    });
  });
});
