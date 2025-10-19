/**
 * Testes Unitários: CET Básico (VALORES CORRIGIDOS)
 * Sprint 4 - H15 (Parte 3)
 */

import { describe, it, expect } from "vitest";
import { Decimal } from "decimal.js";
import { calculateCETBasic, formatCET } from "../../../src/cet/basic";

describe("CET Básico (Sprint 4)", () => {
  describe("calculateCETBasic - Casos típicos", () => {
    it("deve calcular CET para Price 12x com tarifa t0", () => {
      // Caso: PV=10000, 12x de 946.56, tarifa=85
      // VALORES REAIS (não hardcoded):
      // - PMT 946.56 produz IRR ~2.16% (não 2.5%)
      // - Com tarifa, CET ~29% a.a.
      const result = calculateCETBasic({
        pv: new Decimal("10000"),
        schedule: Array(12).fill(new Decimal("946.56")),
        feesT0: [new Decimal("85")],
        baseAnnual: 12,
      });

      expect(result.irrResult.converged).toBe(true);
      expect(result.irrMonthly).toBeDefined();

      // IRR mensal deve estar entre 2% e 2.3%
      const irrPct = result.irrMonthly.mul(100).toNumber();
      expect(irrPct).toBeGreaterThan(2.0);
      expect(irrPct).toBeLessThan(2.3);

      // CET anual entre 27% e 32%
      const cetPct = result.cetAnnual.mul(100).toNumber();
      expect(cetPct).toBeGreaterThan(27);
      expect(cetPct).toBeLessThan(32);

      // Breakdown
      expect(result.breakdown.pv.toNumber()).toBe(10000);
      expect(result.breakdown.totalFeesT0.toNumber()).toBe(85);
      expect(result.breakdown.netInflow.toNumber()).toBe(9915);

      // Cashflows
      expect(result.cashflows.length).toBe(13); // CF0 + 12 parcelas
      expect(result.cashflows[0]!.toNumber()).toBe(9915);
      expect(result.cashflows[1]!.toNumber()).toBe(-946.56);

      console.log(`✓ CET anual: ${formatCET(result.cetAnnual)}`);
      console.log(`✓ IRR mensal: ${formatCET(result.irrMonthly)}`);
    });

    it("deve calcular CET para Price 24x", () => {
      // Caso: PV=5000, 24x de 250, tarifa=50
      const result = calculateCETBasic({
        pv: new Decimal("5000"),
        schedule: Array(24).fill(new Decimal("250")),
        feesT0: [new Decimal("50")],
        baseAnnual: 12,
      });

      expect(result.irrResult.converged).toBe(true);
      expect(result.irrMonthly.greaterThan(0)).toBe(true);
      expect(result.cetAnnual.greaterThan(0)).toBe(true);

      // CET deve ser positivo e razoável (< 50%)
      const cetPct = result.cetAnnual.mul(100).toNumber();
      expect(cetPct).toBeGreaterThan(0);
      expect(cetPct).toBeLessThan(50);

      console.log(`✓ CET 24x: ${formatCET(result.cetAnnual)}`);
    });

    it("deve calcular CET sem tarifas (equivale à taxa nominal)", () => {
      // Sem tarifas: CET = taxa implícita do cronograma
      const result = calculateCETBasic({
        pv: new Decimal("10000"),
        schedule: Array(12).fill(new Decimal("946.56")),
        feesT0: [], // SEM tarifas
        baseAnnual: 12,
      });

      expect(result.irrResult.converged).toBe(true);
      expect(result.breakdown.totalFeesT0.toNumber()).toBe(0);
      expect(result.breakdown.netInflow.toNumber()).toBe(10000);

      // IRR deve estar entre 2% e 2.3% (taxa implícita do PMT)
      const irrPct = result.irrMonthly.mul(100).toNumber();
      expect(irrPct).toBeGreaterThan(2.0);
      expect(irrPct).toBeLessThan(2.3);

      console.log(`✓ IRR sem tarifas: ${formatCET(result.irrMonthly)}`);
    });

    it("deve calcular CET com múltiplas tarifas t0", () => {
      const result = calculateCETBasic({
        pv: new Decimal("10000"),
        schedule: Array(12).fill(new Decimal("946.56")),
        feesT0: [
          new Decimal("50"), // Cadastro
          new Decimal("35"), // Análise
          new Decimal("20"), // Registro
        ], // Total: 105
        baseAnnual: 12,
      });

      expect(result.breakdown.totalFeesT0.toNumber()).toBe(105);
      expect(result.breakdown.netInflow.toNumber()).toBe(9895);

      // CET com mais tarifas deve ser maior que com tarifa=85
      const cetPct = result.cetAnnual.mul(100).toNumber();
      expect(cetPct).toBeGreaterThan(27); // Referência: caso com tarifa=85 dá ~29%
      expect(cetPct).toBeLessThan(35);

      console.log(`✓ CET múltiplas tarifas: ${formatCET(result.cetAnnual)}`);
    });

    it("deve mostrar que tarifas aumentam o CET", () => {
      // Comparar mesmo cronograma com e sem tarifas
      const semTarifa = calculateCETBasic({
        pv: new Decimal("10000"),
        schedule: Array(12).fill(new Decimal("946.56")),
        feesT0: [],
        baseAnnual: 12,
      });

      const comTarifa = calculateCETBasic({
        pv: new Decimal("10000"),
        schedule: Array(12).fill(new Decimal("946.56")),
        feesT0: [new Decimal("85")],
        baseAnnual: 12,
      });

      // CET com tarifa deve ser maior
      expect(comTarifa.cetAnnual.greaterThan(semTarifa.cetAnnual)).toBe(true);

      const diff = comTarifa.cetAnnual.minus(semTarifa.cetAnnual).mul(100);
      console.log(`✓ Impacto da tarifa: +${diff.toFixed(2)}pp no CET`);
    });
  });

  describe("calculateCETBasic - Conversão anual", () => {
    it("deve usar base anual customizada", () => {
      const result12 = calculateCETBasic({
        pv: new Decimal("10000"),
        schedule: Array(12).fill(new Decimal("946.56")),
        feesT0: [new Decimal("85")],
        baseAnnual: 12,
      });

      const result365 = calculateCETBasic({
        pv: new Decimal("10000"),
        schedule: Array(12).fill(new Decimal("946.56")),
        feesT0: [new Decimal("85")],
        baseAnnual: 365,
      });

      // IRR mensal deve ser igual (independente da base)
      expect(result12.irrMonthly.toNumber()).toBeCloseTo(
        result365.irrMonthly.toNumber(),
        8,
      );

      // CET anual deve ser diferente (base 365 >> base 12)
      expect(result365.cetAnnual.greaterThan(result12.cetAnnual)).toBe(true);

      console.log(`✓ CET (base 12): ${formatCET(result12.cetAnnual)}`);
      console.log(`✓ CET (base 365): ${formatCET(result365.cetAnnual)}`);
    });
  });

  describe("calculateCETBasic - Validações", () => {
    it("deve rejeitar PV não positivo", () => {
      expect(() =>
        calculateCETBasic({
          pv: new Decimal("0"),
          schedule: [new Decimal("100")],
          feesT0: [],
        }),
      ).toThrow("PV must be positive");
    });

    it("deve rejeitar schedule vazio", () => {
      expect(() =>
        calculateCETBasic({
          pv: new Decimal("1000"),
          schedule: [],
          feesT0: [],
        }),
      ).toThrow("Schedule cannot be empty");
    });

    it("deve rejeitar tarifas >= PV", () => {
      expect(() =>
        calculateCETBasic({
          pv: new Decimal("1000"),
          schedule: [new Decimal("100")],
          feesT0: [new Decimal("1000")], // Tarifa = PV
        }),
      ).toThrow("Net inflow must be positive");
    });

    it("deve rejeitar baseAnnual não positivo", () => {
      expect(() =>
        calculateCETBasic({
          pv: new Decimal("1000"),
          schedule: [new Decimal("100")],
          feesT0: [],
          baseAnnual: 0,
        }),
      ).toThrow("baseAnnual must be positive");
    });
  });

  describe("formatCET", () => {
    it("deve formatar CET como porcentagem", () => {
      const cet = new Decimal("0.3367");
      expect(formatCET(cet)).toBe("33.67%");
      expect(formatCET(cet, 4)).toBe("33.6700%");
    });
  });
});
