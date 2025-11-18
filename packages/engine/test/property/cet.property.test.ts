import { describe, it, expect } from "vitest";
import { Decimal } from "decimal.js";
import fc from "fast-check";
import { calculateCET } from "../../src/modules/cet/index";

describe("CET - Testes de Propriedade", () => {
  it("CET sempre >= taxa nominal quando há custos adicionais", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 5000, max: 100000 }),
        fc.float({
          min: Math.fround(0.005),
          max: Math.fround(0.1),
          noNaN: true,
        }),
        fc.integer({ min: 6, max: 60 }),
        fc.integer({ min: 100, max: 5000 }),
        (valor, taxa, prazo, tarifa) => {
          const resultado = calculateCET({
            valorPrincipal: new Decimal(valor),
            taxaNominal: new Decimal(taxa),
            prazo,
            tarifaCadastro: new Decimal(tarifa),
            incluirIOF: false,
          });

          expect(resultado.cetMensal.toNumber()).toBeGreaterThan(taxa);
        },
      ),
      { numRuns: 50 },
    );
  });

  it("CET = taxa nominal quando não há custos adicionais", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 10000, max: 50000 }),
        fc.float({
          min: Math.fround(0.01),
          max: Math.fround(0.05),
          noNaN: true,
        }),
        fc.integer({ min: 12, max: 36 }),
        (valor, taxa, prazo) => {
          const resultado = calculateCET({
            valorPrincipal: new Decimal(valor),
            taxaNominal: new Decimal(taxa),
            prazo,
            incluirIOF: false,
          });

          const diff = Math.abs(resultado.cetMensal.toNumber() - taxa);
          expect(diff).toBeLessThan(0.001);
        },
      ),
      { numRuns: 30 },
    );
  });

  it("Valor líquido sempre <= valor principal", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 10000, max: 100000 }),
        fc.float({
          min: Math.fround(0.01),
          max: Math.fround(0.08),
          noNaN: true,
        }),
        fc.integer({ min: 6, max: 48 }),
        fc.boolean(),
        fc.integer({ min: 0, max: 3000 }),
        fc.integer({ min: 0, max: 2000 }),
        (valor, taxa, prazo, iof, tarifa1, tarifa2) => {
          const resultado = calculateCET({
            valorPrincipal: new Decimal(valor),
            taxaNominal: new Decimal(taxa),
            prazo,
            tarifaCadastro: new Decimal(tarifa1),
            tarifaAvaliacao: new Decimal(tarifa2),
            incluirIOF: iof,
          });

          expect(resultado.valorLiquidoLiberado.toNumber()).toBeLessThanOrEqual(
            valor,
          );
          expect(resultado.valorLiquidoLiberado.toNumber()).toBeGreaterThan(0);
        },
      ),
      { numRuns: 50 },
    );
  });

  it("Algoritmo converge em menos de 100 iterações", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 5000, max: 100000 }),
        fc.float({
          min: Math.fround(0.005),
          max: Math.fround(0.1),
          noNaN: true,
        }),
        fc.integer({ min: 6, max: 60 }),
        (valor, taxa, prazo) => {
          const resultado = calculateCET({
            valorPrincipal: new Decimal(valor),
            taxaNominal: new Decimal(taxa),
            prazo,
            incluirIOF: true,
          });

          expect(resultado.convergiu).toBe(true);
          expect(resultado.iteracoes).toBeLessThan(100);
          expect(resultado.iteracoes).toBeLessThan(50);
        },
      ),
      { numRuns: 40 },
    );
  });

  it("CET anual é consistente com CET mensal", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 10000, max: 50000 }),
        fc.float({
          min: Math.fround(0.01),
          max: Math.fround(0.05),
          noNaN: true,
        }),
        fc.integer({ min: 12, max: 36 }),
        (valor, taxa, prazo) => {
          const resultado = calculateCET({
            valorPrincipal: new Decimal(valor),
            taxaNominal: new Decimal(taxa),
            prazo,
            incluirIOF: false,
          });

          const cetAnualCalculado = new Decimal(1)
            .plus(resultado.cetMensal)
            .pow(12)
            .minus(1);

          const diff = resultado.cetAnual
            .minus(cetAnualCalculado)
            .abs()
            .toNumber();

          expect(diff).toBeLessThan(0.000001);
        },
      ),
      { numRuns: 30 },
    );
  });

  it("IOF aumenta o CET", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 10000, max: 50000 }),
        fc.float({
          min: Math.fround(0.01),
          max: Math.fround(0.05),
          noNaN: true,
        }),
        fc.integer({ min: 12, max: 36 }),
        (valor, taxa, prazo) => {
          const semIOF = calculateCET({
            valorPrincipal: new Decimal(valor),
            taxaNominal: new Decimal(taxa),
            prazo,
            incluirIOF: false,
          });

          const comIOF = calculateCET({
            valorPrincipal: new Decimal(valor),
            taxaNominal: new Decimal(taxa),
            prazo,
            incluirIOF: true,
          });

          expect(comIOF.cetMensal.toNumber()).toBeGreaterThan(
            semIOF.cetMensal.toNumber(),
          );
          expect(comIOF.iofTotal.toNumber()).toBeGreaterThan(0);
        },
      ),
      { numRuns: 30 },
    );
  });

  it("Custo total sempre > valor principal", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 10000, max: 50000 }),
        fc.float({
          min: Math.fround(0.01),
          max: Math.fround(0.08),
          noNaN: true,
        }),
        fc.integer({ min: 12, max: 48 }),
        (valor, taxa, prazo) => {
          const resultado = calculateCET({
            valorPrincipal: new Decimal(valor),
            taxaNominal: new Decimal(taxa),
            prazo,
            incluirIOF: false,
          });

          expect(resultado.custoTotal.toNumber()).toBeGreaterThan(valor);
        },
      ),
      { numRuns: 30 },
    );
  });
});
