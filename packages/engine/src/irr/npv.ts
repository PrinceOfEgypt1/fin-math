/**
 * NPV (Net Present Value / Valor Presente Líquido)
 * NPV(r, CF) = Σ(CF[k] / (1 + r)^k) para k = 0..n
 *
 * Observação sobre sinais:
 * - Em fluxo de EMPRÉSTIMO modelado como CF0 > 0 (entrada) e CFk<0 (saídas),
 *   o NPV tende a AUMENTAR quando a taxa (r) aumenta.
 *   Logo:
 *     • se r < IRR  => NPV < 0
 *     • se r = IRR  => NPV ≈ 0
 *     • se r > IRR  => NPV > 0
 */

import { Decimal } from "decimal.js";

export function calculateNPV(rate: Decimal, cashflows: Decimal[]): Decimal {
  if (cashflows.length === 0) {
    throw new Error("Cashflows array cannot be empty");
  }
  // Evita divisão por zero: (1 + r)^k com r <= -1 é inválido
  if (rate.lte(-1)) {
    throw new Error("Rate must be greater than -1");
  }

  const one = new Decimal(1);
  const onePlusRate = one.plus(rate);
  let npv = new Decimal(0);

  for (let k = 0; k < cashflows.length; k++) {
    const discount = onePlusRate.pow(k);
    const pv = cashflows[k]!.div(discount);
    npv = npv.plus(pv);
  }
  return npv;
}

/**
 * Detecta mudança de sinal ignorando zeros.
 */
export function hasSignChange(cashflows: Decimal[]): boolean {
  if (cashflows.length < 2) return false;

  let prevSign: number | null = null;
  for (let i = 0; i < cashflows.length; i++) {
    const cf = cashflows[i];
    if (cf!.isZero()) continue;
    const sign = cf!.isPositive() ? 1 : -1;
    if (prevSign === null) {
      prevSign = sign;
      continue;
    }
    if (sign !== prevSign) return true;
    prevSign = sign;
  }
  return false;
}

/**
 * Conta mudanças de sinal ignorando zeros.
 */
export function countSignChanges(cashflows: Decimal[]): number {
  if (cashflows.length < 2) return 0;

  let prevSign: number | null = null;
  let changes = 0;

  for (let i = 0; i < cashflows.length; i++) {
    const cf = cashflows[i];
    if (cf!.isZero()) continue;
    const sign = cf!.isPositive() ? 1 : -1;
    if (prevSign === null) {
      prevSign = sign;
      continue;
    }
    if (sign !== prevSign) {
      changes += 1;
      prevSign = sign;
    }
  }
  return changes;
}
