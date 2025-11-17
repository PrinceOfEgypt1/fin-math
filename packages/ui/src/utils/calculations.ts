import Decimal from "decimal.js";

/**
 * Utilitários de cálculo financeiro
 *
 * Estas funções implementam os algoritmos básicos de amortização
 * compatíveis com o @finmath/engine
 */

export interface PriceResult {
  parcela: Decimal;
  totalPago: Decimal;
  totalJuros: Decimal;
  cronograma: Array<{
    periodo: number;
    saldoInicial: Decimal;
    juros: Decimal;
    amortizacao: Decimal;
    parcela: Decimal;
    saldoFinal: Decimal;
  }>;
}

export interface SacResult {
  parcelaInicial: Decimal;
  parcelaFinal: Decimal;
  totalPago: Decimal;
  totalJuros: Decimal;
  cronograma: Array<{
    periodo: number;
    saldoInicial: Decimal;
    juros: Decimal;
    amortizacao: Decimal;
    parcela: Decimal;
    saldoFinal: Decimal;
  }>;
}

/**
 * Calcula a prestação pelo sistema PRICE (PMT)
 * Fórmula: PMT = PV * [i * (1+i)^n] / [(1+i)^n - 1]
 */
export function calculatePMT(pv: Decimal, rate: Decimal, n: number): Decimal {
  if (rate.equals(0)) {
    return pv.div(n);
  }

  const onePlusRate = new Decimal(1).plus(rate);
  const numerator = rate.times(onePlusRate.pow(n));
  const denominator = onePlusRate.pow(n).minus(1);

  return pv.times(numerator.div(denominator));
}

/**
 * Gera cronograma completo do sistema PRICE
 */
export function generatePriceSchedule(
  pv: Decimal,
  rate: Decimal,
  n: number,
): PriceResult {
  const pmt = calculatePMT(pv, rate, n);
  const cronograma = [];
  let saldoAtual = pv;
  let totalJuros = new Decimal(0);

  for (let i = 1; i <= n; i++) {
    const juros = saldoAtual.times(rate);
    const amortizacao = pmt.minus(juros);
    const saldoFinal = saldoAtual.minus(amortizacao);

    cronograma.push({
      periodo: i,
      saldoInicial: saldoAtual,
      juros,
      amortizacao,
      parcela: pmt,
      saldoFinal: saldoFinal.lessThan(0.01) ? new Decimal(0) : saldoFinal,
    });

    totalJuros = totalJuros.plus(juros);
    saldoAtual = saldoFinal;
  }

  return {
    parcela: pmt,
    totalPago: pmt.times(n),
    totalJuros,
    cronograma,
  };
}

/**
 * Gera cronograma completo do sistema SAC
 */
export function generateSacSchedule(
  pv: Decimal,
  rate: Decimal,
  n: number,
): SacResult {
  const amortizacaoConstante = pv.div(n);
  const cronograma = [];
  let saldoAtual = pv;
  let totalJuros = new Decimal(0);
  let totalPago = new Decimal(0);

  for (let i = 1; i <= n; i++) {
    const juros = saldoAtual.times(rate);
    const parcela = amortizacaoConstante.plus(juros);
    const saldoFinal = saldoAtual.minus(amortizacaoConstante);

    cronograma.push({
      periodo: i,
      saldoInicial: saldoAtual,
      juros,
      amortizacao: amortizacaoConstante,
      parcela,
      saldoFinal: saldoFinal.lessThan(0.01) ? new Decimal(0) : saldoFinal,
    });

    totalJuros = totalJuros.plus(juros);
    totalPago = totalPago.plus(parcela);
    saldoAtual = saldoFinal;
  }

  return {
    parcelaInicial: cronograma[0].parcela,
    parcelaFinal: cronograma[cronograma.length - 1].parcela,
    totalPago,
    totalJuros,
    cronograma,
  };
}

/**
 * Formata valor Decimal para exibição em Reais
 */
export function formatCurrency(value: Decimal): string {
  return value.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ".");
}

/**
 * Formata taxa percentual para exibição
 */
export function formatPercentage(value: Decimal): string {
  return value.times(100).toFixed(2);
}
