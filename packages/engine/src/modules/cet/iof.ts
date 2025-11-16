import type { IOFCalculation, CetInput } from "./types";

export function calculateIOF(input: CetInput): IOFCalculation {
  const { valorPrincipal, prazo } = input;

  const iofFixo = valorPrincipal.mul(0.0038);
  const diasIOF = Math.min(prazo * 30, 365);
  const iofDiario = valorPrincipal.mul(0.0000082).mul(diasIOF);
  const total = iofFixo.plus(iofDiario);

  return { fixo: iofFixo, diario: iofDiario, total };
}
