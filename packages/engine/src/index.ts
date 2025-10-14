/**
 * @finmath/engine
 * Financial mathematics calculation engine
 */

// ESM requires explicit .js extensions
import * as interestModule from "./modules/interest.js";
import * as rateModule from "./modules/rate.js";
import * as seriesModule from "./modules/series.js";
import * as amortizationModule from "./modules/amortization.js";
import * as irrModule from "./modules/irr.js";
import * as cetModule from "./modules/cet.js";

export const interest = interestModule;
export const rate = rateModule;
export const series = seriesModule;
export const amortization = amortizationModule;
export const irr = irrModule;
export const cet = cetModule;

export * from "./util/round.js";
export * from "./day-count/index.js";
export * from "./amortization/index.js";

export const ENGINE_VERSION = "0.4.0";
