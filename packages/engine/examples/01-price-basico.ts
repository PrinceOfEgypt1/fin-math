/**
 * Exemplo 1: Cálculo Price Básico
 *
 * Demonstra como calcular o PMT de um empréstimo
 * usando o sistema Price (parcelas fixas).
 */

import { Decimal } from "decimal.js";
import { amortization } from "../src/index.js";

// Parâmetros do empréstimo
const params = {
  pv: new Decimal("10000"), // Principal: R$ 10.000,00
  rate: new Decimal("0.02"), // Taxa: 2% ao mês
  n: 12, // Prazo: 12 meses
};

// Calcular
const resultado = amortization.calculatePrice(params);

console.log("📊 SIMULAÇÃO PRICE");
console.log("==================");
console.log(`Principal: R$ ${params.pv.toFixed(2)}`);
console.log(`Taxa: ${params.rate.mul(100).toFixed(2)}% a.m.`);
console.log(`Prazo: ${params.n} meses`);
console.log("");
console.log(`💰 PMT: R$ ${resultado.pmt.toFixed(2)}`);
console.log(`📈 Total de Juros: R$ ${resultado.totalInterest.toFixed(2)}`);
console.log(`💵 Total Pago: R$ ${resultado.totalPaid.toFixed(2)}`);

// Mostrar primeiras 3 parcelas
console.log("");
console.log("📋 Primeiras 3 Parcelas:");
console.log("Mês | PMT      | Juros    | Amort    | Saldo");
console.log("----|----------|----------|----------|----------");

resultado.schedule.slice(0, 3).forEach((row) => {
  console.log(
    `${row.k.toString().padStart(3)} | ` +
      `${row.pmt.toFixed(2).padStart(8)} | ` +
      `${row.interest.toFixed(2).padStart(8)} | ` +
      `${row.amort.toFixed(2).padStart(8)} | ` +
      `${row.balance.toFixed(2).padStart(8)}`,
  );
});
