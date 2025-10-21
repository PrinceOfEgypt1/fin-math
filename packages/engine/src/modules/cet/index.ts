import { Decimal } from "decimal.js";
import type { CetInput, CetOutput } from "./types";
import { calculateIOF } from "./iof";
import { buildCashFlow } from "./cash-flow";
import { solveNewtonRaphson } from "./newton-raphson";

/**
 * Calcula o CET (Custo Efetivo Total) de um financiamento
 *
 * O CET representa o custo REAL da operação, incluindo:
 * - Taxa de juros nominal
 * - Tarifas (cadastro, avaliação, etc.)
 * - IOF (Imposto sobre Operações Financeiras)
 * - Seguros opcionais
 *
 * Usa o método Newton-Raphson para encontrar a taxa efetiva que
 * iguala o valor presente líquido (PV) com a soma dos pagamentos descontados.
 *
 * Legislação: Resolução CMN 3.517/2007
 *
 * @param input - Parâmetros do financiamento
 * @returns Resultado do cálculo de CET
 * @throws {Error} Se o algoritmo não convergir
 *
 * @example
 * ```typescript
 * const resultado = calculateCET({
 *   valorPrincipal: new Decimal(10000),
 *   taxaNominal: new Decimal(0.02),
 *   prazo: 12,
 *   tarifaCadastro: new Decimal(500),
 *   incluirIOF: true
 * });
 *
 * console.log('CET Mensal:', resultado.cetMensal.toNumber());
 * console.log('CET Anual:', resultado.cetAnual.toNumber());
 * ```
 */
export function calculateCET(input: CetInput): CetOutput {
  // 1. Calcular IOF (se aplicável)
  const iofCalc = input.incluirIOF
    ? calculateIOF(input)
    : { total: new Decimal(0), fixo: new Decimal(0), diario: new Decimal(0) };

  // 2. Calcular tarifas iniciais (deduzidas do principal)
  const tarifasIniciais = (input.tarifaCadastro || new Decimal(0)).plus(
    input.tarifaAvaliacao || new Decimal(0),
  );

  // 3. Calcular valor líquido liberado
  // É o valor que realmente chega na mão do tomador
  const valorLiquido = input.valorPrincipal
    .minus(tarifasIniciais)
    .minus(iofCalc.total);

  // 4. Montar fluxo de caixa (todos os pagamentos mensais)
  const cashFlow = buildCashFlow(input);

  // 5. Usar Newton-Raphson para encontrar o CET
  // Chute inicial: taxa nominal × 1.2 (geralmente o CET é maior)
  const chute = input.taxaNominal.mul(1.2);

  const resultado = solveNewtonRaphson({
    cashFlow,
    presentValue: valorLiquido,
    initialGuess: chute,
  });

  // 6. Verificar se convergiu
  if (!resultado.converged) {
    throw new Error(
      "CET não convergiu. Verifique se os valores informados estão corretos.",
    );
  }

  // 7. Calcular CET anual
  // CET anual = (1 + CET mensal)^12 - 1
  const cetMensal = resultado.rate;
  const cetAnual = new Decimal(1).plus(cetMensal).pow(12).minus(1);

  // 8. Calcular custo total da operação
  const custoTotal = cashFlow.reduce(
    (sum, parcela) => sum.plus(parcela),
    new Decimal(0),
  );

  return {
    cetMensal,
    cetAnual,
    valorLiquidoLiberado: valorLiquido,
    iofTotal: iofCalc.total,
    custoTotal,
    iteracoes: resultado.iterations,
    convergiu: true,
  };
}

// Re-exports para facilitar importação
export * from "./types";
export { calculateIOF } from "./iof";
export { buildCashFlow } from "./cash-flow";
export {
  calculateNPV,
  calculateNPVDerivative,
  solveNewtonRaphson,
} from "./newton-raphson";
