import { Decimal } from "decimal.js";

interface NPVParams {
  cashFlow: Decimal[];
  rate: Decimal;
  presentValue: Decimal;
}

export function calculateNPV(params: NPVParams): Decimal {
  const { cashFlow, rate, presentValue } = params;
  let sum = new Decimal(0);

  for (let t = 1; t <= cashFlow.length; t++) {
    const payment = cashFlow[t - 1];
    if (!payment) continue; // Skip undefined

    const denominator = new Decimal(1).plus(rate).pow(t);
    const discounted = payment.div(denominator);
    sum = sum.plus(discounted);
  }

  return presentValue.minus(sum);
}

export function calculateNPVDerivative(
  cashFlow: Decimal[],
  rate: Decimal,
): Decimal {
  let sum = new Decimal(0);

  for (let t = 1; t <= cashFlow.length; t++) {
    const payment = cashFlow[t - 1];
    if (!payment) continue; // Skip undefined

    const numerator = new Decimal(t).mul(payment);
    const denominator = new Decimal(1).plus(rate).pow(t + 1);
    sum = sum.plus(numerator.div(denominator));
  }

  return sum;
}

interface NewtonRaphsonParams {
  cashFlow: Decimal[];
  presentValue: Decimal;
  initialGuess: Decimal;
  tolerance?: Decimal;
  maxIterations?: number;
}

export interface NewtonRaphsonResult {
  rate: Decimal;
  iterations: number;
  converged: boolean;
}

export function solveNewtonRaphson(
  params: NewtonRaphsonParams,
): NewtonRaphsonResult {
  const {
    cashFlow,
    presentValue,
    initialGuess,
    tolerance = new Decimal(1e-6),
    maxIterations = 100,
  } = params;

  let rate = initialGuess;
  let iterations = 0;

  while (iterations < maxIterations) {
    const npv = calculateNPV({ cashFlow, rate, presentValue });
    const derivative = calculateNPVDerivative(cashFlow, rate);

    if (derivative.abs().lessThan(new Decimal(1e-10))) {
      return { rate, iterations, converged: false };
    }

    const rateNew = rate.minus(npv.div(derivative));

    if (rateNew.minus(rate).abs().lessThan(tolerance)) {
      return { rate: rateNew, iterations, converged: true };
    }

    rate = rateNew;
    iterations++;
  }

  return { rate, iterations, converged: false };
}
