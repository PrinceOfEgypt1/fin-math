import { Decimal } from "decimal.js";

/**
 * Parâmetros para cálculo de NPV (Net Present Value)
 */
interface NPVParams {
  /** Fluxo de caixa (pagamentos mensais) */
  cashFlow: Decimal[];
  /** Taxa de desconto */
  rate: Decimal;
  /** Valor presente (valor líquido liberado) */
  presentValue: Decimal;
}

/**
 * Calcula NPV (Valor Presente Líquido)
 *
 * Fórmula: NPV = PV - Σ[CF_t / (1 + rate)^t]
 *
 * Objetivo: Encontrar rate tal que NPV = 0
 *
 * @param params - Parâmetros do cálculo
 * @returns Valor do NPV
 *
 * @example
 * ```typescript
 * const npv = calculateNPV({
 *   cashFlow: [new Decimal(946.56), new Decimal(946.56), ...],
 *   rate: new Decimal(0.02),
 *   presentValue: new Decimal(10000)
 * });
 * // npv ≈ 0 quando rate é o CET correto
 * ```
 */
export function calculateNPV(params: NPVParams): Decimal {
  const { cashFlow, rate, presentValue } = params;

  let sum = new Decimal(0);

  // Calcular valor presente de cada pagamento
  for (let t = 1; t <= cashFlow.length; t++) {
    const denominator = new Decimal(1).plus(rate).pow(t);
    const discounted = cashFlow[t - 1].div(denominator);
    sum = sum.plus(discounted);
  }

  // NPV = PV - soma dos fluxos descontados
  return presentValue.minus(sum);
}

/**
 * Calcula a derivada do NPV em relação à taxa
 *
 * Fórmula: NPV'(rate) = Σ[t × CF_t / (1 + rate)^(t+1)]
 *
 * Usada no método Newton-Raphson para encontrar a taxa
 *
 * @param cashFlow - Fluxo de caixa
 * @param rate - Taxa atual
 * @returns Valor da derivada
 */
export function calculateNPVDerivative(
  cashFlow: Decimal[],
  rate: Decimal,
): Decimal {
  let sum = new Decimal(0);

  for (let t = 1; t <= cashFlow.length; t++) {
    const numerator = new Decimal(t).mul(cashFlow[t - 1]);
    const denominator = new Decimal(1).plus(rate).pow(t + 1);
    sum = sum.plus(numerator.div(denominator));
  }

  return sum;
}

/**
 * Parâmetros para o solver Newton-Raphson
 */
interface NewtonRaphsonParams {
  /** Fluxo de caixa (pagamentos) */
  cashFlow: Decimal[];
  /** Valor presente (líquido liberado) */
  presentValue: Decimal;
  /** Chute inicial para a taxa */
  initialGuess: Decimal;
  /** Tolerância de convergência (padrão: 1e-6) */
  tolerance?: Decimal;
  /** Número máximo de iterações (padrão: 100) */
  maxIterations?: number;
}

/**
 * Resultado do solver Newton-Raphson
 */
export interface NewtonRaphsonResult {
  /** Taxa encontrada (CET) */
  rate: Decimal;
  /** Número de iterações executadas */
  iterations: number;
  /** Se o algoritmo convergiu */
  converged: boolean;
}

/**
 * Resolve a equação NPV = 0 usando o método Newton-Raphson
 *
 * Método iterativo:
 * 1. Começa com um chute inicial (initialGuess)
 * 2. Calcula NPV e sua derivada
 * 3. Atualiza: rate_novo = rate_atual - NPV / NPV'
 * 4. Repete até convergir (|rate_novo - rate_atual| < tolerance)
 *
 * @param params - Parâmetros do solver
 * @returns Resultado com a taxa encontrada
 *
 * @throws {Error} Não lança erro, mas retorna converged: false se não convergir
 *
 * @example
 * ```typescript
 * const resultado = solveNewtonRaphson({
 *   cashFlow: Array(12).fill(new Decimal(946.56)),
 *   presentValue: new Decimal(9952.14),
 *   initialGuess: new Decimal(0.024) // taxa nominal * 1.2
 * });
 *
 * if (resultado.converged) {
 *   console.log('CET encontrado:', resultado.rate.toNumber());
 * }
 * ```
 */
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
    // Calcular NPV e sua derivada
    const npv = calculateNPV({ cashFlow, rate, presentValue });
    const derivative = calculateNPVDerivative(cashFlow, rate);

    // Evitar divisão por zero
    if (derivative.abs().lessThan(new Decimal(1e-10))) {
      return {
        rate,
        iterations,
        converged: false,
      };
    }

    // Newton-Raphson: rate_novo = rate_atual - f(rate) / f'(rate)
    const rateNew = rate.minus(npv.div(derivative));

    // Verificar convergência
    if (rateNew.minus(rate).abs().lessThan(tolerance)) {
      return {
        rate: rateNew,
        iterations,
        converged: true,
      };
    }

    // Atualizar para próxima iteração
    rate = rateNew;
    iterations++;
  }

  // Não convergiu em maxIterations
  return {
    rate,
    iterations,
    converged: false,
  };
}
