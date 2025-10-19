/**
 * Exemplo 2: CET Completo
 *
 * Demonstra o cálculo de CET incluindo IOF e seguros.
 */

import { Decimal } from "decimal.js";
import { cetBasic } from "../src/index.js";

// Parâmetros básicos
const params = {
  pv: new Decimal("10000"),
  pmt: new Decimal("946.56"),
  n: 12,
  feesT0: [
    { name: "TAC", value: new Decimal("150") },
    { name: "Registro", value: new Decimal("50") },
  ],
};

console.log("💰 CET BÁSICO");
console.log("=============");
console.log(`Principal: R$ ${params.pv.toFixed(2)}`);
console.log(`PMT: R$ ${params.pmt.toFixed(2)}`);
console.log(`Prazo: ${params.n} meses`);
console.log("");
console.log("Tarifas t0:");
params.feesT0.forEach((fee) => {
  console.log(`  - ${fee.name}: R$ ${fee.value.toFixed(2)}`);
});

// Calcular CET
const resultado = cetBasic(params);

console.log("");
console.log("📊 Resultado:");
console.log(`CET Mensal: ${resultado.cetMensal.mul(100).toFixed(4)}%`);
console.log(`CET Anual: ${resultado.cetAnual.mul(100).toFixed(2)}%`);
console.log("");
console.log(`💵 Custo Total Efetivo: R$ ${resultado.totalCost.toFixed(2)}`);
