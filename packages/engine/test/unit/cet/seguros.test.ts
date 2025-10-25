import { describe, it, expect } from "vitest";
import Decimal from "decimal.js";
import { calculateSeguro } from "../../../src/modules/cet/seguros";

describe("Seguros", () => {
  it("deve calcular seguro fixo", () => {
    const result = calculateSeguro(
      { tipo: "fixo", valor: new Decimal(12.9) },
      new Decimal(10000),
      new Decimal(9000),
    );

    expect(result.toNumber()).toBe(12.9);
  });

  it("deve calcular seguro percentual sobre PV", () => {
    const result = calculateSeguro(
      { tipo: "percentualPV", valor: new Decimal(0.01) }, // 1%
      new Decimal(10000),
      new Decimal(9000),
    );

    expect(result.toNumber()).toBe(100);
  });

  it("deve calcular seguro percentual sobre saldo", () => {
    const result = calculateSeguro(
      { tipo: "percentualSaldo", valor: new Decimal(0.01) }, // 1%
      new Decimal(10000),
      new Decimal(9000),
    );

    expect(result.toNumber()).toBe(90);
  });
});
