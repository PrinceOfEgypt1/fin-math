import { d, round2 } from "../util/round.js";

/**
 * Calcula o pagamento (PMT) de uma série uniforme
 *
 * @param pv - Valor presente
 * @param i - Taxa de juros por período
 * @param n - Número de períodos
 * @param due - Se true, pagamento antecipado (no início); se false, postecipado (no final)
 * @returns Valor do pagamento periódico
 *
 * Fórmula (postecipada): PMT = PV × [i × (1+i)^n] / [(1+i)^n - 1]
 * Fórmula (antecipada): PMT_due = PMT_post / (1+i)
 */
export function pmt(
  pv: string | number,
  i: string | number,
  n: number,
  due = false,
) {
  const I = d(i);
  const PV = d(pv);

  // Caso especial: taxa zero
  if (I.isZero()) return round2(PV.div(n));

  // ✅ CORREÇÃO: Fórmula correta do PMT
  // PMT = PV × [i × (1+i)^n] / [(1+i)^n - 1]
  const factor = I.plus(1).pow(n);
  const numerator = I.times(factor);
  const denominator = factor.minus(1);

  let p = PV.times(numerator).div(denominator);

  // Se pagamento antecipado, dividir por (1+i)
  if (due) {
    p = p.div(I.plus(1));
  }

  return round2(p);
}
