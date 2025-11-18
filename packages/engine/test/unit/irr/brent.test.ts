/**
 * Testes Unitários: Solver de Brent (IRR) - VERSÃO FINAL CORRIGIDA
 */

import { describe, it, expect } from "vitest";
import { Decimal } from "decimal.js";
import { solveIRR, convertToAnnual } from "../../../src/irr/brent";

describe("IRR - Solver de Brent (Sprint 4)", () => {
  describe("solveIRR - Fluxos regulares", () => {
    it("deve convergir para fluxo monotônico típico (Price 12x)", () => {
      // PMT CORRETO para PV=10000, i=2.5% a.m., n=12
      // PMT = 10000 × [0.025 × 1.025^12] / [1.025^12 - 1] ≈ 974.81
      const cashflows = [
        new Decimal("10000"), // t=0: cliente recebe
        new Decimal("-974.81"), // t=1 a 12: cliente paga (PMT correto!)
        new Decimal("-974.81"),
        new Decimal("-974.81"),
        new Decimal("-974.81"),
        new Decimal("-974.81"),
        new Decimal("-974.81"),
        new Decimal("-974.81"),
        new Decimal("-974.81"),
        new Decimal("-974.81"),
        new Decimal("-974.81"),
        new Decimal("-974.81"),
        new Decimal("-974.81"),
      ];

      const result = solveIRR(cashflows);

      expect(result.converged).toBe(true);
      expect(result.irr).not.toBeNull();
      expect(result.method).toBe("brent");

      // IRR ≈ 2.5% (tolerância 0.1%)
      const expectedIRR = 0.025;
      const actualIRR = result.irr!.toNumber();
      const relativeError = Math.abs((actualIRR - expectedIRR) / expectedIRR);

      expect(relativeError).toBeLessThan(0.001);

      console.log(
        `✓ IRR encontrado: ${(actualIRR * 100).toFixed(4)}% (esperado: 2.5000%)`,
      );
      console.log(`✓ Erro relativo: ${(relativeError * 100).toFixed(6)}%`);
    });

    it("deve convergir para fluxo com taxa alta (> 10% a.m.)", () => {
      const cashflows = [
        new Decimal("10000"),
        ...Array(12).fill(new Decimal("-1500")),
      ];

      const result = solveIRR(cashflows);

      expect(result.converged).toBe(true);
      expect(result.irr).not.toBeNull();
      expect(result.irr!.toNumber()).toBeGreaterThan(0.1);
    });

    it("deve convergir para fluxo com taxa baixa (< 1% a.m.)", () => {
      const cashflows = [
        new Decimal("10000"),
        ...Array(12).fill(new Decimal("-850")),
      ];

      const result = solveIRR(cashflows);

      expect(result.converged).toBe(true);
      expect(result.irr).not.toBeNull();
      expect(result.irr!.toNumber()).toBeLessThan(0.01);
      expect(result.irr!.toNumber()).toBeGreaterThan(0);
    });

    it("deve convergir para fluxo Price 24x (CET completo)", () => {
      const cashflows = [
        new Decimal("10000"),
        ...Array(24).fill(new Decimal("-500")),
      ];

      const result = solveIRR(cashflows);

      expect(result.converged).toBe(true);
      expect(result.irr).not.toBeNull();
      expect(result.irr!.toNumber()).toBeGreaterThan(0);
    });
  });

  describe("solveIRR - Diagnósticos", () => {
    it("deve retornar noSignChange=true para fluxo sem troca de sinal", () => {
      const cashflows = [
        new Decimal("1000"),
        new Decimal("500"),
        new Decimal("600"),
      ];

      const result = solveIRR(cashflows);

      expect(result.converged).toBe(false);
      expect(result.irr).toBeNull();
      expect(result.diagnostics?.noSignChange).toBe(true);

      console.log("✓ Diagnóstico correto: sem mudança de sinal");
    });

    it("deve alertar sobre possíveis múltiplas raízes", () => {
      // Fluxo com 2 mudanças de sinal: + → - → +
      const cashflows = [
        new Decimal("1000"), // +
        new Decimal("-1500"), // - (mudança 1)
        new Decimal("600"), // + (mudança 2)
      ];

      const result = solveIRR(cashflows);

      // DEVE incluir multipleRoots=true INDEPENDENTE de convergência
      expect(result.diagnostics).toBeDefined();
      expect(result.diagnostics?.multipleRoots).toBe(true);

      console.log("✓ Alerta de múltiplas raízes emitido");
      console.log(`  Convergiu: ${result.converged}`);
      console.log(`  IRR: ${result.irr?.toNumber() ?? "null"}`);
      console.log(`  multipleRoots: ${result.diagnostics?.multipleRoots}`);
    });

    it("deve retornar noSignChange para fluxo todo negativo", () => {
      const cashflows = [
        new Decimal("-1000"),
        new Decimal("-500"),
        new Decimal("-300"),
      ];

      const result = solveIRR(cashflows);

      expect(result.converged).toBe(false);
      expect(result.irr).toBeNull();
      expect(result.diagnostics?.noSignChange).toBe(true);
    });
  });

  describe("solveIRR - Opções customizadas", () => {
    it("deve respeitar chute inicial (guess)", () => {
      const cashflows = [
        new Decimal("10000"),
        ...Array(12).fill(new Decimal("-974.81")),
      ];

      const result = solveIRR(cashflows, {
        guess: new Decimal("0.02"),
      });

      expect(result.converged).toBe(true);
      expect(result.irr).not.toBeNull();
    });

    it("deve usar intervalo customizado (range)", () => {
      const cashflows = [
        new Decimal("10000"),
        ...Array(12).fill(new Decimal("-974.81")),
      ];

      const result = solveIRR(cashflows, {
        range: {
          lo: new Decimal("0.01"),
          hi: new Decimal("0.05"),
        },
      });

      expect(result.converged).toBe(true);
      expect(result.irr).not.toBeNull();
    });

    it("deve usar bissecção quando forceBisection=true", () => {
      const cashflows = [
        new Decimal("10000"),
        ...Array(12).fill(new Decimal("-974.81")),
      ];

      const result = solveIRR(cashflows, {
        forceBisection: true,
      });

      expect(result.converged).toBe(true);
      expect(result.method).toBe("bisection");

      console.log("✓ Método bissecção usado conforme solicitado");
    });

    it("deve respeitar tolerância customizada", () => {
      const cashflows = [
        new Decimal("10000"),
        ...Array(12).fill(new Decimal("-974.81")),
      ];

      const result = solveIRR(cashflows, {
        tolerance: new Decimal("1e-10"),
      });

      expect(result.converged).toBe(true);
      expect(result.diagnostics?.finalNPV?.abs().toNumber()).toBeLessThan(1e-9);
    });
  });

  describe("convertToAnnual", () => {
    it("deve converter IRR mensal para anual (12 meses)", () => {
      const irrMonthly = new Decimal("0.025");
      const irrAnnual = convertToAnnual(irrMonthly, 12);

      expect(irrAnnual.toNumber()).toBeCloseTo(0.3449, 4);

      console.log(
        `✓ 2.5% a.m. = ${(irrAnnual.toNumber() * 100).toFixed(2)}% a.a.`,
      );
    });

    it("deve lidar com IRR zero", () => {
      const irrMonthly = new Decimal("0");
      const irrAnnual = convertToAnnual(irrMonthly, 12);

      expect(irrAnnual.toNumber()).toBe(0);
    });

    it("deve lidar com base anual diferente de 12", () => {
      const irrMonthly = new Decimal("0.01");
      const irrAnnual = convertToAnnual(irrMonthly, 6);

      expect(irrAnnual.toNumber()).toBeCloseTo(0.0615, 4);
    });
  });
});
