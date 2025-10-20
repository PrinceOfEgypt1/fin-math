import { describe, it, expect } from "vitest";
import { Decimal } from "decimal.js";
import { calculateIOF } from "../../../src/modules/cet/iof";
import type { CetInput } from "../../../src/modules/cet/types";

describe("calculateIOF", () => {
  it("deve calcular IOF para prazo de 12 meses", () => {
    const input: CetInput = {
      valorPrincipal: new Decimal(10000),
      taxaNominal: new Decimal(0.02),
      prazo: 12,
      incluirIOF: true,
    };

    const resultado = calculateIOF(input);

    // IOF Fixo: 10000 * 0.38% = 38.00
    expect(resultado.fixo.toNumber()).toBeCloseTo(38, 2);

    // IOF Diário: 10000 * 0.0082% * 360 dias = 29.52
    expect(resultado.diario.toNumber()).toBeCloseTo(29.52, 2);

    // Total: 38 + 29.52 = 67.52
    expect(resultado.total.toNumber()).toBeCloseTo(67.52, 2);
  });

  it("deve calcular IOF para prazo de 24 meses", () => {
    const input: CetInput = {
      valorPrincipal: new Decimal(10000),
      taxaNominal: new Decimal(0.02),
      prazo: 24,
      incluirIOF: true,
    };

    const resultado = calculateIOF(input);

    // IOF Fixo: sempre 38.00
    expect(resultado.fixo.toNumber()).toBeCloseTo(38, 2);

    // IOF Diário: limitado a 365 dias
    // 10000 * 0.0082% * 365 = 29.93
    expect(resultado.diario.toNumber()).toBeCloseTo(29.93, 2);

    // Total
    expect(resultado.total.toNumber()).toBeCloseTo(67.93, 2);
  });

  it("deve limitar IOF diário a 365 dias (prazo longo)", () => {
    const input: CetInput = {
      valorPrincipal: new Decimal(10000),
      taxaNominal: new Decimal(0.02),
      prazo: 36, // 1080 dias, mas limitado a 365
      incluirIOF: true,
    };

    const resultado = calculateIOF(input);

    // IOF Diário deve ser calculado sobre no máximo 365 dias
    // CORREÇÃO: usar 0.0000082 (não 0.000082)
    const iofDiarioEsperado = new Decimal(10000).mul(0.0000082).mul(365);
    expect(resultado.diario.toNumber()).toBeCloseTo(
      iofDiarioEsperado.toNumber(),
      2,
    );
  });

  it("deve calcular IOF para valor principal alto", () => {
    const input: CetInput = {
      valorPrincipal: new Decimal(100000),
      taxaNominal: new Decimal(0.015),
      prazo: 12,
      incluirIOF: true,
    };

    const resultado = calculateIOF(input);

    // IOF Fixo: 100000 * 0.38% = 380.00
    expect(resultado.fixo.toNumber()).toBeCloseTo(380, 2);

    // IOF Diário: 100000 * 0.0082% * 360 = 295.20
    expect(resultado.diario.toNumber()).toBeCloseTo(295.2, 2);

    // Total: 675.20
    expect(resultado.total.toNumber()).toBeCloseTo(675.2, 2);
  });

  it("deve calcular IOF para prazo curto (6 meses)", () => {
    const input: CetInput = {
      valorPrincipal: new Decimal(5000),
      taxaNominal: new Decimal(0.025),
      prazo: 6,
      incluirIOF: true,
    };

    const resultado = calculateIOF(input);

    // IOF Fixo: 5000 * 0.38% = 19.00
    expect(resultado.fixo.toNumber()).toBeCloseTo(19, 2);

    // IOF Diário: 5000 * 0.0082% * 180 = 7.38
    expect(resultado.diario.toNumber()).toBeCloseTo(7.38, 2);

    // Total: 26.38
    expect(resultado.total.toNumber()).toBeCloseTo(26.38, 2);
  });

  it("deve retornar valores Decimal precisos", () => {
    const input: CetInput = {
      valorPrincipal: new Decimal(10000),
      taxaNominal: new Decimal(0.02),
      prazo: 12,
      incluirIOF: true,
    };

    const resultado = calculateIOF(input);

    // Verificar que são instâncias de Decimal
    expect(resultado.fixo).toBeInstanceOf(Decimal);
    expect(resultado.diario).toBeInstanceOf(Decimal);
    expect(resultado.total).toBeInstanceOf(Decimal);

    // Verificar que total = fixo + diario
    expect(resultado.total.equals(resultado.fixo.plus(resultado.diario))).toBe(
      true,
    );
  });
});
