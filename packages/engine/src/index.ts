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

// Export as namespaces (for backward compatibility with tests)
export const interest = interestModule;
export const rate = rateModule;
export const series = seriesModule;
export const amortization = amortizationModule;
export const irr = irrModule;
export const cet = cetModule;

// Export utilities
export * from "./util/round";

// NEW: Day count conventions (ONDA 1) - direct exports
export * from "./day-count";

// Version
export const ENGINE_VERSION = "0.3.0";
