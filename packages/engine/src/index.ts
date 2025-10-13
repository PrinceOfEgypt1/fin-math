/**
 * @finmath/engine
 * Financial mathematics calculation engine
 */

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
export * from "./day-count";
export * from "./amortization";

export const ENGINE_VERSION = "0.4.0";
