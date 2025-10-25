import Decimal from "decimal.js";

export interface SeguroConfig {
  tipo: "fixo" | "percentualPV" | "percentualSaldo";
  valor: Decimal;
}

/**
 * Calcula valor do seguro para uma parcela
 *
 * @param config - Configuração do seguro
 * @param pv - Valor presente (para percentualPV)
 * @param saldoDevedor - Saldo devedor (para percentualSaldo)
 * @returns Valor do seguro
 */
export function calculateSeguro(
  config: SeguroConfig,
  pv: Decimal,
  saldoDevedor: Decimal,
): Decimal {
  switch (config.tipo) {
    case "fixo":
      return config.valor;

    case "percentualPV":
      return pv.mul(config.valor);

    case "percentualSaldo":
      return saldoDevedor.mul(config.valor);

    default:
      throw new Error(`Tipo de seguro inválido: ${config.tipo}`);
  }
}

/**
 * Adiciona seguros ao cash flow de CET
 *
 * @param schedule - Cronograma de amortização
 * @param config - Configuração do seguro
 * @param pv - Valor presente
 * @returns Cash flows com seguros
 */
export function addSeguros(
  schedule: Array<{ periodo: number; saldo: Decimal }>,
  config: SeguroConfig | null,
  pv: Decimal,
): Decimal[] {
  if (!config) {
    return [];
  }

  return schedule.map((row) => calculateSeguro(config, pv, row.saldo));
}
