/**
 * CET (Custo Efetivo Total) - Versão Básica
 * Sprint 4 - H15 (Parte 3)
 *
 * Escopo MVP: CET com tarifas t0 apenas (sem IOF/seguros)
 * Referência: Guia CET — Source of Truth v1.0
 */

import { Decimal } from "decimal.js";
import { solveIRR, convertToAnnual, IRRResult } from "../irr/brent";

/**
 * Entrada para cálculo de CET básico
 */
export interface CETBasicInput {
  /** Valor presente (crédito liberado) */
  pv: Decimal;

  /** Cronograma de parcelas (PMT) */
  schedule: Decimal[];

  /** Tarifas cobradas no tempo 0 */
  feesT0?: Decimal[];

  /** Base anual para conversão (padrão: 12 meses) */
  baseAnnual?: number;
}

/**
 * Resultado do cálculo de CET
 */
export interface CETResult {
  /** IRR mensal encontrado */
  irrMonthly: Decimal;

  /** CET anual equivalente */
  cetAnnual: Decimal;

  /** Fluxo de caixa usado no cálculo */
  cashflows: Decimal[];

  /** Breakdown dos componentes */
  breakdown: {
    /** Valor presente */
    pv: Decimal;

    /** Total de tarifas t0 */
    totalFeesT0: Decimal;

    /** Entrada líquida do cliente (t=0) */
    netInflow: Decimal;
  };

  /** Resultado detalhado do solver IRR */
  irrResult: IRRResult;
}

/**
 * Calcula CET básico usando solver de Brent
 *
 * Fórmula (Guia CET - SoT §4):
 * 1. CF[0] = +PV - tarifas_t0
 * 2. CF[k] = -PMT[k] (k=1..n)
 * 3. IRR_m = solveIRR(CF, tolerance=1e-8)
 * 4. CET_aa = (1 + IRR_m)^base - 1
 *
 * @param input - Parâmetros do cálculo
 * @returns Resultado com IRR mensal e CET anual
 *
 * @example
 * ```typescript
 * const result = calculateCETBasic({
 *   pv: new Decimal('10000'),
 *   schedule: [
 *     new Decimal('946.56'),  // PMT_1
 *     new Decimal('946.56'),  // PMT_2
 *     // ... 12 parcelas
 *   ],
 *   feesT0: [new Decimal('85')],  // Tarifa de cadastro
 *   baseAnnual: 12
 * });
 *
 * console.log(result.cetAnnual.toNumber()); // 0.3367 (33.67% a.a.)
 * ```
 */
export function calculateCETBasic(input: CETBasicInput): CETResult {
  const { pv, schedule, feesT0 = [], baseAnnual = 12 } = input;

  // Validações
  if (schedule.length === 0) {
    throw new Error("Schedule cannot be empty");
  }

  if (pv.lessThanOrEqualTo(0)) {
    throw new Error("PV must be positive");
  }

  if (baseAnnual <= 0) {
    throw new Error("baseAnnual must be positive");
  }

  // 1. Calcular entrada líquida do cliente (t=0)
  const totalFeesT0 = feesT0.reduce(
    (sum, fee) => sum.plus(fee),
    new Decimal(0),
  );

  const netInflow = pv.minus(totalFeesT0);

  if (netInflow.lessThanOrEqualTo(0)) {
    throw new Error("Net inflow must be positive (PV > fees)");
  }

  // 2. Montar fluxo de caixa
  const cashflows: Decimal[] = [
    netInflow, // CF[0]: +PV - tarifas_t0 (entrada do cliente)
    ...schedule.map((pmt) => pmt.neg()), // CF[k]: -PMT (saídas)
  ];

  // 3. Resolver IRR com Brent
  const irrResult = solveIRR(cashflows, {
    tolerance: new Decimal("1e-8"),
  });

  if (!irrResult.converged || !irrResult.irr) {
    throw new Error(
      `IRR did not converge. Diagnostics: ${JSON.stringify(irrResult.diagnostics)}`,
    );
  }

  const irrMonthly = irrResult.irr;

  // 4. Converter para CET anual
  const cetAnnual = convertToAnnual(irrMonthly, baseAnnual);

  return {
    irrMonthly,
    cetAnnual,
    cashflows,
    breakdown: {
      pv,
      totalFeesT0,
      netInflow,
    },
    irrResult,
  };
}

/**
 * Helper: converte CET para porcentagem formatada
 */
export function formatCET(cet: Decimal, decimals: number = 2): string {
  return `${cet.mul(100).toFixed(decimals)}%`;
}
