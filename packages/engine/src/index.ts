/**
 * @packageDocumentation
 * @module @finmath/engine
 *
 * Motor de cálculos financeiros de alta precisão para o mercado brasileiro.
 *
 * Este pacote fornece funções para cálculos de:
 * - Amortização (Price, SAC)
 * - CET (Custo Efetivo Total)
 * - IRR/NPV (Taxa Interna de Retorno / Valor Presente Líquido)
 * - Juros Compostos
 * - Equivalência de Taxas
 * - Séries Uniformes
 * - Day Count (convenções de contagem de dias)
 *
 * @example
 * ```typescript
 * import { amortization, cet, irr } from '@finmath/engine';
 * import { Decimal } from 'decimal.js';
 *
 * // Calcular Price
 * const price = amortization.calculatePrice({
 *   pv: new Decimal('10000'),
 *   rate: new Decimal('0.02'),
 *   n: 12
 * });
 *
 * console.log(`PMT: ${price.pmt.toFixed(2)}`);
 * ```
 *
 * @version 0.4.0
 * @license MIT
 */

// ESM requires explicit .js extensions
import * as interestModule from "./modules/interest.js";
import * as rateModule from "./modules/rate.js";
import * as seriesModule from "./modules/series.js";
import * as amortizationModule from "./modules/amortization.js";
import * as irrModule from "./modules/irr.js";
import * as cetModule from "./modules/cet.js";

/**
 * Módulo de juros compostos
 *
 * Funções para cálculo de valor futuro (FV) e valor presente (PV)
 * com juros compostos.
 *
 * @see {@link modules/interest}
 */
export const interest = interestModule;

/**
 * Módulo de equivalência de taxas
 *
 * Funções para conversão entre taxas mensais e anuais,
 * e cálculo de taxa real.
 *
 * @see {@link modules/rate}
 */
export const rate = rateModule;

/**
 * Módulo de séries uniformes
 *
 * Funções para cálculo de PMT de séries postecipadas e antecipadas,
 * e inversão (PV a partir de PMT).
 *
 * @see {@link modules/series}
 */
export const series = seriesModule;

/**
 * Módulo de amortização
 *
 * Funções para sistemas Price e SAC, incluindo geração
 * de cronogramas completos.
 *
 * @see {@link modules/amortization}
 */
export const amortization = amortizationModule;

/**
 * Módulo IRR/NPV
 *
 * Funções para cálculo de Taxa Interna de Retorno (IRR)
 * via Método de Brent e Valor Presente Líquido (NPV).
 *
 * @see {@link modules/irr}
 */
export const irr = irrModule;

/**
 * Módulo CET
 *
 * Funções para cálculo de Custo Efetivo Total (CET),
 * incluindo versões básica e completa (com IOF e seguros).
 *
 * @see {@link modules/cet}
 */
export const cet = cetModule;

// Utilitários
export * from "./util/round.js";

// Day Count
export * from "./day-count/index.js";

// Amortização (exports diretos)
export * from "./amortization/index.js";

/**
 * Versão do motor de cálculo
 *
 * Esta versão é incluída em todas as respostas e snapshots
 * para rastreabilidade e auditoria.
 *
 * @constant
 */
export const ENGINE_VERSION = "0.4.0";

/**
 * Função de CET básico (atalho)
 *
 * Calcula o CET considerando apenas tarifas no t0.
 * Para CET completo (com IOF e seguros), use `cet.calculateCETFull()`.
 *
 * @see {@link modules/cet.cetBasic}
 */
export { cetBasic } from "./modules/cet";
