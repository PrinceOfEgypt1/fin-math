import { Decimal } from "decimal.js";

/**
 * Entrada para cálculo de CET
 */
export interface CetInput {
  /** Valor principal do financiamento */
  valorPrincipal: Decimal;

  /** Taxa de juros nominal mensal (ex: 0.02 para 2% a.m.) */
  taxaNominal: Decimal;

  /** Prazo em meses */
  prazo: number;

  /** Tarifa de cadastro (TAC) opcional */
  tarifaCadastro?: Decimal;

  /** Tarifa de avaliação opcional */
  tarifaAvaliacao?: Decimal;

  /** Seguro opcional */
  seguro?: {
    /** Tipo do seguro: valor fixo mensal ou percentual sobre principal */
    tipo: "fixo" | "percentual";
    /** Valor do seguro */
    valor: Decimal;
  };

  /** Se deve incluir IOF no cálculo */
  incluirIOF: boolean;
}

/**
 * Resultado do cálculo de CET
 */
export interface CetOutput {
  /** CET mensal (ex: 0.0248 para 2,48% a.m.) */
  cetMensal: Decimal;

  /** CET anual: (1 + cetMensal)^12 - 1 */
  cetAnual: Decimal;

  /** Valor líquido liberado (principal - tarifas - IOF) */
  valorLiquidoLiberado: Decimal;

  /** Total de IOF cobrado */
  iofTotal: Decimal;

  /** Custo total da operação (soma de todas as parcelas) */
  custoTotal: Decimal;

  /** Número de iterações do Newton-Raphson */
  iteracoes: number;

  /** Se o algoritmo convergiu */
  convergiu: boolean;
}

/**
 * Detalhamento do cálculo de IOF
 */
export interface IOFCalculation {
  /** IOF fixo: 0,38% sobre o principal */
  fixo: Decimal;

  /** IOF diário: 0,0082% ao dia (limitado a 365 dias) */
  diario: Decimal;

  /** Total: fixo + diário */
  total: Decimal;
}
