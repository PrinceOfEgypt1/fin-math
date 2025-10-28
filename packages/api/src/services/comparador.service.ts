// packages/api/src/services/comparador.service.ts
import Decimal from "decimal.js";

export interface CenarioInput {
  id: string;
  nome: string;
  pv: number;
  i: number;
  n: number;
}

export interface CenarioResultado {
  id: string;
  nome: string;
  pmt: number;
  totalPago: number;
  cetAnual: number;
  economiaVsMelhor?: number;
}

export interface ComparadorResultado {
  melhorCenario: string;
  justificativa: string;
  resultados: CenarioResultado[];
}

function calcularPMT(pv: number, i: number, n: number): number {
  const I = new Decimal(i);
  const N = new Decimal(n);
  const PV = new Decimal(pv);
  const num = PV.mul(I);
  const den = new Decimal(1).minus(new Decimal(1).plus(I).pow(N.neg()));
  return num.div(den).toNumber();
}

function estimarCETAnual(iMensal: number): number {
  return new Decimal(1).plus(iMensal).pow(12).minus(1).mul(100).toNumber();
}

export async function compararCenarios(
  cenarios: CenarioInput[],
): Promise<ComparadorResultado> {
  const resultados: CenarioResultado[] = cenarios.map((c) => {
    const pmt = calcularPMT(c.pv, c.i, c.n);
    const totalPago = pmt * c.n;
    const cetAnual = estimarCETAnual(c.i);
    return { id: c.id, nome: c.nome, pmt, totalPago, cetAnual };
  });

  resultados.sort((a, b) => a.totalPago - b.totalPago);

  if (resultados.length === 0) {
    throw new Error("Nenhum cenário calculado");
  }

  const melhor = resultados[0]!;

  resultados.forEach((r) => {
    r.economiaVsMelhor = r.totalPago - melhor.totalPago;
  });

  return {
    melhorCenario: melhor.id,
    justificativa: `${melhor.nome} tem o menor total pago (R$ ${melhor.totalPago.toFixed(2)}) e menor CET (${melhor.cetAnual.toFixed(2)}% a.a.)`,
    resultados,
  };
}
