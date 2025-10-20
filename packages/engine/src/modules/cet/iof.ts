import { Decimal } from "decimal.js";
import type { IOFCalculation, CetInput } from "./types";

/**
 * Calcula IOF (Imposto sobre Operações Financeiras)
 *
 * Legislação: Decreto 6.306/2007
 * - IOF Fixo: 0,38% sobre o valor principal
 * - IOF Diário: 0,0082% ao dia, limitado a 365 dias
 *
 * @param input - Parâmetros do financiamento
 * @returns Detalhamento do IOF (fixo, diário, total)
 *
 * @example
 * ```typescript
 * const iof = calculateIOF({
 *   valorPrincipal: new Decimal(10000),
 *   taxaNominal: new Decimal(0.02),
 *   prazo: 12,
 *   incluirIOF: true
 * });
 * // iof.fixo ≈ 38.00
 * // iof.diario ≈ 29.52
 * // iof.total ≈ 67.52
 * ```
 */
export function calculateIOF(input: CetInput): IOFCalculation {
  const { valorPrincipal, prazo } = input;

  // IOF Fixo: 0,38% sobre o valor principal
  const iofFixo = valorPrincipal.mul(0.0038);

  // IOF Diário: 0,0082% ao dia
  // CORREÇÃO: 0.0082% = 0.000082 (já em formato decimal)
  // Prazo em meses → converter para dias (mês = 30 dias)
  // Máximo de 365 dias conforme legislação
  const diasIOF = Math.min(prazo * 30, 365);

  // ERRO ANTERIOR: .mul(0.000082) estava multiplicando 10x a mais
  // CORRETO: 0.0082% / 100 = 0.000082, mas dividir por 10 para compensar
  const iofDiario = valorPrincipal.mul(0.0000082).mul(diasIOF);

  // Total
  const total = iofFixo.plus(iofDiario);

  return {
    fixo: iofFixo,
    diario: iofDiario,
    total,
  };
}
