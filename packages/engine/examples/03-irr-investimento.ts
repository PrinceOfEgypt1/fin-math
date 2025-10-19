/**
 * Exemplo 3: IRR de um Investimento
 *
 * Calcula a Taxa Interna de Retorno (TIR) de um
 * projeto de investimento usando o Método de Brent.
 */

import { Decimal } from "decimal.js";
import { irr } from "../src/index.js";

// Fluxo de caixa de um projeto
const fluxoCaixa = [
  new Decimal("-100000"), // Investimento inicial
  new Decimal("25000"), // Ano 1
  new Decimal("30000"), // Ano 2
  new Decimal("35000"), // Ano 3
  new Decimal("40000"), // Ano 4
  new Decimal("45000"), // Ano 5
];

console.log("📈 ANÁLISE DE INVESTIMENTO");
console.log("==========================");
console.log("Fluxo de Caixa:");
fluxoCaixa.forEach((valor, i) => {
  const label = i === 0 ? "Invest." : `Ano ${i}`;
  const sinal = valor.isNegative() ? "-" : "+";
  console.log(`  ${label}: ${sinal} R$ ${valor.abs().toFixed(2)}`);
});

// Calcular TIR
const tir = irr.calculateIRR(fluxoCaixa);

console.log("");
console.log(`🎯 TIR: ${tir.mul(100).toFixed(2)}% ao ano`);

// Verificar com NPV
const npv = irr.calculateNPV(fluxoCaixa, tir);

console.log("");
console.log("✅ Verificação:");
console.log(`NPV na TIR: R$ ${npv.toFixed(6)} (deve ser ≈ 0)`);

// Interpretação
if (tir.greaterThan(new Decimal("0.12"))) {
  console.log("");
  console.log("💡 Conclusão: Investimento atrativo!");
  console.log("   (TIR > 12% - supera o custo de oportunidade)");
} else {
  console.log("");
  console.log("⚠️  Conclusão: Revisar investimento");
  console.log("   (TIR < 12% - não supera custo de oportunidade)");
}
