import { describe, it, expect } from "vitest";
import { Decimal } from "decimal.js";
import { calculateCET } from "../../../src/modules/cet/index";

describe("calculateCET - Integração", () => {
  it("deve calcular CET sem tarifas e sem IOF", () => {
    const resultado = calculateCET({
      valorPrincipal: new Decimal(10000),
      taxaNominal: new Decimal(0.02),
      prazo: 12,
      incluirIOF: false,
    });

    expect(resultado.cetMensal.toNumber()).toBeCloseTo(0.02, 3);
    expect(resultado.convergiu).toBe(true);
    expect(resultado.valorLiquidoLiberado.toNumber()).toBe(10000);
  });

  it("deve calcular CET com IOF", () => {
    const resultado = calculateCET({
      valorPrincipal: new Decimal(10000),
      taxaNominal: new Decimal(0.02),
      prazo: 12,
      incluirIOF: true,
    });

    expect(resultado.cetMensal.toNumber()).toBeGreaterThan(0.02);
    expect(resultado.convergiu).toBe(true);
    expect(resultado.iofTotal.toNumber()).toBeGreaterThan(0);
    expect(resultado.valorLiquidoLiberado.toNumber()).toBeLessThan(10000);
  });

  it("deve calcular CET com tarifa de cadastro", () => {
    const resultado = calculateCET({
      valorPrincipal: new Decimal(10000),
      taxaNominal: new Decimal(0.02),
      prazo: 12,
      tarifaCadastro: new Decimal(500),
      incluirIOF: false,
    });

    expect(resultado.cetMensal.toNumber()).toBeGreaterThan(0.02);
    expect(resultado.valorLiquidoLiberado.toNumber()).toBe(9500);
  });

  it("deve calcular CET com múltiplas tarifas e IOF", () => {
    const resultado = calculateCET({
      valorPrincipal: new Decimal(50000),
      taxaNominal: new Decimal(0.015),
      prazo: 24,
      tarifaCadastro: new Decimal(800),
      tarifaAvaliacao: new Decimal(1200),
      incluirIOF: true,
    });

    expect(resultado.convergiu).toBe(true);
    expect(resultado.cetMensal.toNumber()).toBeGreaterThan(0.015);

    const tarifasTotal = 800 + 1200;
    expect(resultado.valorLiquidoLiberado.toNumber()).toBeLessThan(
      50000 - tarifasTotal,
    );
  });

  it("deve calcular CET com seguro fixo", () => {
    const resultado = calculateCET({
      valorPrincipal: new Decimal(10000),
      taxaNominal: new Decimal(0.02),
      prazo: 12,
      seguro: {
        tipo: "fixo",
        valor: new Decimal(50),
      },
      incluirIOF: false,
    });

    expect(resultado.convergiu).toBe(true);
    expect(resultado.cetMensal.toNumber()).toBeGreaterThan(0.02);
    expect(resultado.custoTotal.toNumber()).toBeGreaterThan(12 * 946.56);
  });

  it("deve calcular CET anual corretamente", () => {
    const resultado = calculateCET({
      valorPrincipal: new Decimal(10000),
      taxaNominal: new Decimal(0.02),
      prazo: 12,
      incluirIOF: false,
    });

    const cetAnualEsperado = new Decimal(1)
      .plus(resultado.cetMensal)
      .pow(12)
      .minus(1);

    expect(resultado.cetAnual.toNumber()).toBeCloseTo(
      cetAnualEsperado.toNumber(),
      6,
    );
  });

  it("deve convergir mesmo com taxa muito baixa", () => {
    // CORRIGIDO: Mesmo com taxa muito baixa, o algoritmo pode convergir
    // O teste anterior esperava erro, mas o Newton-Raphson é robusto
    const resultado = calculateCET({
      valorPrincipal: new Decimal(10000),
      taxaNominal: new Decimal(0.001), // taxa muito baixa mas válida
      prazo: 12,
      incluirIOF: false,
    });

    // Deve convergir, apenas com mais iterações
    expect(resultado.convergiu).toBe(true);
    expect(resultado.cetMensal.toNumber()).toBeGreaterThan(0);
  });

  it("deve ter número razoável de iterações", () => {
    const resultado = calculateCET({
      valorPrincipal: new Decimal(25000),
      taxaNominal: new Decimal(0.025),
      prazo: 36,
      tarifaCadastro: new Decimal(600),
      incluirIOF: true,
    });

    expect(resultado.iteracoes).toBeLessThan(50);
  });
});
