import { Decimal } from "decimal.js";
import type { CetInput } from "./types";

/**
 * Constrói o fluxo de caixa completo do financiamento
 *
 * O fluxo de caixa representa todos os pagamentos mensais que o tomador fará.
 * Inclui:
 * - Parcela mensal (PMT calculada pelo método PRICE)
 * - Seguro (se houver)
 *
 * @param input - Parâmetros do financiamento
 * @returns Array de Decimals representando cada pagamento mensal
 *
 * @example
 * ```typescript
 * const fluxo = buildCashFlow({
 *   valorPrincipal: new Decimal(10000),
 *   taxaNominal: new Decimal(0.02),
 *   prazo: 12,
 *   incluirIOF: true
 * });
 * // [946.56, 946.56, 946.56, ...] (12 valores)
 * ```
 */
export function buildCashFlow(input: CetInput): Decimal[] {
  const { valorPrincipal, taxaNominal, prazo, seguro } = input;

  // Calcular PMT usando fórmula PRICE (parcela fixa)
  // PMT = PV × [i × (1+i)^n] / [(1+i)^n - 1]
  const i = taxaNominal;
  const n = prazo;

  const numerator = i.mul(new Decimal(1).plus(i).pow(n));
  const denominator = new Decimal(1).plus(i).pow(n).minus(1);
  const pmt = valorPrincipal.mul(numerator).div(denominator);

  // Calcular valor mensal do seguro (se houver)
  let seguroMensal = new Decimal(0);
  if (seguro) {
    if (seguro.tipo === "fixo") {
      // Seguro fixo mensal
      seguroMensal = seguro.valor;
    } else {
      // Seguro percentual: divide o total pelo prazo
      seguroMensal = valorPrincipal.mul(seguro.valor).div(prazo);
    }
  }

  // Parcela mensal total = PMT + seguro
  const parcelaMensal = pmt.plus(seguroMensal);

  // Criar array com todas as parcelas (todas iguais no método PRICE)
  return Array(prazo).fill(parcelaMensal);
}
