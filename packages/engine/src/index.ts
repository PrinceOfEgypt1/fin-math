/**
 * @packageDocumentation
 * @module finmath-engine
 *
 * Motor de cálculos financeiros de alta precisão para o mercado brasileiro.
 */

// Remover .js dos imports - deixar TypeScript resolver
import * as interestModule from "./modules/interest";
import * as rateModule from "./modules/rate";
import * as seriesModule from "./modules/series";
import * as amortizationModule from "./modules/amortization";
import * as irrModule from "./modules/irr";
import * as cetModule from "./modules/cet";

export const interest = interestModule;
export const rate = rateModule;
export const series = seriesModule;
export const amortization = amortizationModule;
export const irr = irrModule;
export const cet = cetModule;

export * from "./util/round";
export * from "./day-count/index";
export * from "./amortization/index";

export const ENGINE_VERSION = "0.4.1";

export { cetBasic } from "./modules/cet";
