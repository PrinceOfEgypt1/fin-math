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

export async function compararCenarios(cenarios: CenarioInput[]) {
  const resultados: CenarioResultado[] = [];

  for (const cenario of cenarios) {
    const pv = new Decimal(cenario.pv);
    const i = new Decimal(cenario.i);
    const n = cenario.n;

    // Calcular PMT (Price)
    const pmt = pv
      .mul(i)
      .div(new Decimal(1).sub(new Decimal(1).add(i).pow(-n)));

    const totalPago = pmt.mul(n);
    const cetAnual = i.add(1).pow(12).sub(1).mul(100);

    resultados.push({
      id: cenario.id,
      nome: cenario.nome,
      pmt: pmt.toNumber(),
      totalPago: totalPago.toNumber(),
      cetAnual: cetAnual.toNumber(),
    });
  }

  // Ordenar por total pago (menor = melhor)
  resultados.sort((a, b) => a.totalPago - b.totalPago);
  const melhor = resultados[0];

  // Calcular economia vs melhor
  resultados.forEach((r) => {
    r.economiaVsMelhor = r.totalPago - melhor.totalPago;
  });

  return {
    melhorCenario: melhor.id,
    justificativa: `${melhor.nome} tem o menor total pago (R$ ${melhor.totalPago.toFixed(2)}) e menor CET (${melhor.cetAnual.toFixed(2)}% a.a.)`,
    resultados,
  };
}
