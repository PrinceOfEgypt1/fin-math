# Guia de Uso - finmath-engine

## 📦 Instalação

```bash
npm install @finmath/engine
# ou
pnpm add @finmath/engine
# ou
yarn add @finmath/engine
```

## 🎯 Visão Geral

O `@finmath/engine` é uma biblioteca de cálculos financeiros para o mercado brasileiro com precisão decimal. Utiliza `decimal.js` internamente para evitar erros de ponto flutuante comuns em operações financeiras.

**Características principais:**

- ✅ Precisão decimal (sem erros de arredondamento)
- ✅ Sistemas de amortização PRICE e SAC
- ✅ Cálculo de CET (Custo Efetivo Total) completo
- ✅ NPV (Valor Presente Líquido) e IRR (Taxa Interna de Retorno)
- ✅ Equivalência de taxas e juros compostos
- ✅ TypeScript nativo com types completos

## 🚀 Uso Básico

### Importando a Biblioteca

```typescript
import Decimal from "decimal.js";
import {
  calculatePMT,
  generatePriceSchedule,
  generateSacSchedule,
  calculateCET,
  calculateNPV,
  calculateIRR,
} from "@finmath/engine";
```

**Importante:** Todos os valores monetários e taxas devem ser passados como instâncias de `Decimal` para garantir precisão.

## 📊 Sistema PRICE

O sistema PRICE (Tabela Price) possui parcelas fixas durante todo o período, com juros decrescentes e amortização crescente.

### Calcular Prestação (PMT)

```typescript
import Decimal from "decimal.js";
import { calculatePMT } from "@finmath/engine";

// Calcular prestação de um financiamento de R$ 100.000
// com taxa de 1,5% ao mês por 360 meses
const pmt = calculatePMT({
  pv: new Decimal("100000"), // Valor presente (principal)
  rate: new Decimal("0.015"), // Taxa mensal (1,5% = 0.015)
  n: 360, // Número de parcelas
});

console.log(pmt.toFixed(2)); // "1264.14"
```

**Parâmetros:**

- `pv` (Decimal): Valor presente (valor do empréstimo/financiamento)
- `rate` (Decimal): Taxa de juros por período (decimal, não percentual)
- `n` (number): Número de períodos (parcelas)

**Retorno:** `Decimal` - Valor da prestação

### Gerar Cronograma PRICE Completo

```typescript
import Decimal from "decimal.js";
import { generatePriceSchedule } from "@finmath/engine";

const schedule = generatePriceSchedule({
  pv: new Decimal("100000"),
  rate: new Decimal("0.015"),
  n: 360,
});

console.log("Parcela fixa:", schedule.parcela.toFixed(2));
console.log("Total pago:", schedule.totalPago.toFixed(2));
console.log("Total de juros:", schedule.totalJuros.toFixed(2));

// Acessar cronograma detalhado
schedule.cronograma.forEach((linha, index) => {
  console.log(`Mês ${linha.periodo}:`);
  console.log(`  Saldo inicial: R$ ${linha.saldoInicial.toFixed(2)}`);
  console.log(`  Juros: R$ ${linha.juros.toFixed(2)}`);
  console.log(`  Amortização: R$ ${linha.amortizacao.toFixed(2)}`);
  console.log(`  Parcela: R$ ${linha.parcela.toFixed(2)}`);
  console.log(`  Saldo final: R$ ${linha.saldoFinal.toFixed(2)}`);
});
```

**Retorno:**

```typescript
interface PriceResult {
  parcela: Decimal; // Valor da parcela fixa
  totalPago: Decimal; // Soma de todas as parcelas
  totalJuros: Decimal; // Total de juros pagos
  cronograma: Array<{
    periodo: number; // Número da parcela (1, 2, 3...)
    saldoInicial: Decimal; // Saldo devedor no início do período
    juros: Decimal; // Juros do período
    amortizacao: Decimal; // Amortização do período
    parcela: Decimal; // Valor da parcela (juros + amortização)
    saldoFinal: Decimal; // Saldo devedor no final do período
  }>;
}
```

## 📉 Sistema SAC

O Sistema de Amortização Constante (SAC) possui amortização fixa e parcelas decrescentes.

### Gerar Cronograma SAC

```typescript
import Decimal from "decimal.js";
import { generateSacSchedule } from "@finmath/engine";

const schedule = generateSacSchedule({
  pv: new Decimal("100000"),
  rate: new Decimal("0.015"),
  n: 360,
});

console.log("Primeira parcela:", schedule.parcelaInicial.toFixed(2));
console.log("Última parcela:", schedule.parcelaFinal.toFixed(2));
console.log("Total pago:", schedule.totalPago.toFixed(2));
console.log("Total de juros:", schedule.totalJuros.toFixed(2));

// Acessar cronograma detalhado
schedule.cronograma.forEach((linha) => {
  console.log(`Mês ${linha.periodo}: R$ ${linha.parcela.toFixed(2)}`);
});
```

**Retorno:**

```typescript
interface SacResult {
  parcelaInicial: Decimal; // Valor da primeira parcela (maior)
  parcelaFinal: Decimal; // Valor da última parcela (menor)
  totalPago: Decimal; // Soma de todas as parcelas
  totalJuros: Decimal; // Total de juros pagos
  cronograma: Array<{
    periodo: number;
    saldoInicial: Decimal;
    juros: Decimal;
    amortizacao: Decimal; // Sempre constante no SAC
    parcela: Decimal; // Decrescente
    saldoFinal: Decimal;
  }>;
}
```

## 💰 CET (Custo Efetivo Total)

O CET representa o custo total do crédito incluindo juros, tarifas, seguros e IOF.

### CET Básico (Apenas Tarifas)

```typescript
import Decimal from "decimal.js";
import { calculateCET } from "@finmath/engine";

const cet = calculateCET({
  pv: new Decimal("10000"), // Valor do empréstimo
  pmt: new Decimal("946.56"), // Valor da parcela
  n: 12, // Número de parcelas
  fees: [
    { name: "TAC", value: new Decimal("150") }, // Taxa de Abertura de Crédito
    { name: "Avaliação", value: new Decimal("300") }, // Taxa de avaliação
  ],
});

console.log("CET mensal:", cet.toFixed(4)); // Ex: "0.0235" (2.35%)
console.log("CET anual:", cet.times(12).toFixed(4)); // Aproximação
```

### CET Completo (Com IOF e Seguros)

```typescript
import Decimal from "decimal.js";
import { calculateCET } from "@finmath/engine";

const cet = calculateCET({
  pv: new Decimal("10000"),
  pmt: new Decimal("946.56"),
  n: 12,
  fees: [{ name: "TAC", value: new Decimal("150") }],
  iof: {
    daily: new Decimal("0.000082"), // IOF diário (0.0082%)
    fixed: new Decimal("0.0038"), // IOF fixo (0.38%)
  },
  insurance: {
    perPeriod: new Decimal("50"), // Seguro por período
  },
});

console.log("CET mensal (completo):", cet.toFixed(4));
```

**Parâmetros:**

- `pv` (Decimal): Valor presente (principal)
- `pmt` (Decimal): Valor da parcela
- `n` (number): Número de períodos
- `fees` (Array, opcional): Lista de tarifas cobradas no t0
  - `name` (string): Nome da tarifa
  - `value` (Decimal): Valor da tarifa
- `iof` (Object, opcional): Parâmetros do IOF
  - `daily` (Decimal): Taxa diária do IOF (padrão: 0.000082)
  - `fixed` (Decimal): Alíquota fixa do IOF (padrão: 0.0038)
- `insurance` (Object, opcional): Seguros
  - `perPeriod` (Decimal): Seguro por período

**Retorno:** `Decimal` - CET mensal

## 📈 NPV (Valor Presente Líquido)

Calcula o valor presente de uma série de fluxos de caixa.

```typescript
import Decimal from "decimal.js";
import { calculateNPV } from "@finmath/engine";

// Fluxos de caixa de um projeto
const cashFlows = [
  new Decimal("-10000"), // Investimento inicial (saída)
  new Decimal("3000"), // Entrada ano 1
  new Decimal("4000"), // Entrada ano 2
  new Decimal("5000"), // Entrada ano 3
  new Decimal("4000"), // Entrada ano 4
];

const npv = calculateNPV({
  cashFlows,
  rate: new Decimal("0.10"), // Taxa de desconto 10% ao ano
});

console.log("NPV:", npv.toFixed(2));

if (npv.greaterThan(0)) {
  console.log("Projeto viável (NPV positivo)");
} else {
  console.log("Projeto inviável (NPV negativo)");
}
```

**Parâmetros:**

- `cashFlows` (Array<Decimal>): Série de fluxos de caixa (valores negativos = saídas)
- `rate` (Decimal): Taxa de desconto por período

**Retorno:** `Decimal` - Valor presente líquido

## 📊 IRR (Taxa Interna de Retorno)

Calcula a taxa que torna o NPV igual a zero usando o método de Brent.

```typescript
import Decimal from "decimal.js";
import { calculateIRR } from "@finmath/engine";

const cashFlows = [
  new Decimal("-10000"),
  new Decimal("3000"),
  new Decimal("4000"),
  new Decimal("5000"),
  new Decimal("4000"),
];

const irr = calculateIRR({
  cashFlows,
  guess: new Decimal("0.1"), // Chute inicial (opcional)
  maxIterations: 100, // Máximo de iterações (opcional)
  tolerance: new Decimal("0.0001"), // Tolerância (opcional)
});

console.log("IRR:", irr.times(100).toFixed(2), "%"); // Ex: "18.45%"
```

**Parâmetros:**

- `cashFlows` (Array<Decimal>): Série de fluxos de caixa
- `guess` (Decimal, opcional): Estimativa inicial (padrão: 0.1)
- `maxIterations` (number, opcional): Limite de iterações (padrão: 100)
- `tolerance` (Decimal, opcional): Tolerância para convergência (padrão: 0.0001)

**Retorno:** `Decimal` - Taxa interna de retorno (decimal, não percentual)

## 🔄 Equivalência de Taxas

Converte entre taxas mensais e anuais.

```typescript
import Decimal from "decimal.js";
import { monthlyToAnnual, annualToMonthly } from "@finmath/engine";

// Converter 1% ao mês para taxa anual
const taxaMensal = new Decimal("0.01");
const taxaAnual = monthlyToAnnual(taxaMensal);
console.log("Taxa anual:", taxaAnual.times(100).toFixed(2), "%"); // "12.68%"

// Converter 12% ao ano para taxa mensal
const taxaAnualInput = new Decimal("0.12");
const taxaMensalOutput = annualToMonthly(taxaAnualInput);
console.log("Taxa mensal:", taxaMensalOutput.times(100).toFixed(2), "%"); // "0.95%"
```

## 💡 Boas Práticas

### 1. Sempre Use Decimal para Valores Monetários

```typescript
// ❌ ERRADO - Ponto flutuante causa erros
const pmt = calculatePMT({
  pv: 100000, // número nativo
  rate: 0.015,
  n: 360,
}); // TypeError!

// ✅ CORRETO
const pmt = calculatePMT({
  pv: new Decimal("100000"),
  rate: new Decimal("0.015"),
  n: 360,
});
```

### 2. Taxas em Decimal, Não Percentual

```typescript
// ❌ ERRADO
const rate = new Decimal("1.5"); // 1.5 como número, não como percentual

// ✅ CORRETO
const rate = new Decimal("0.015"); // 1.5% = 0.015
// ou
const ratePercent = new Decimal("1.5");
const rate = ratePercent.div(100);
```

### 3. Formatação para Exibição

```typescript
import Decimal from "decimal.js";

const valor = new Decimal("1234.56");

// Para BRL
function formatCurrency(value: Decimal): string {
  return `R$ ${value.toFixed(2).replace(".", ",")}`;
}

console.log(formatCurrency(valor)); // "R$ 1234,56"

// Com separador de milhares
function formatCurrencyFull(value: Decimal): string {
  const formatted = value
    .toFixed(2)
    .replace(".", ",")
    .replace(/\B(?=(\d{3})+(?!\d))/g, ".");
  return `R$ ${formatted}`;
}

console.log(formatCurrencyFull(new Decimal("123456.78"))); // "R$ 123.456,78"
```

### 4. Validação de Entrada

```typescript
function calcularPMT(valorStr: string, taxaStr: string, prazoStr: string) {
  try {
    const pv = new Decimal(valorStr);
    const rate = new Decimal(taxaStr).div(100);
    const n = parseInt(prazoStr, 10);

    if (pv.lessThanOrEqualTo(0)) {
      throw new Error("Valor deve ser positivo");
    }

    if (rate.lessThan(0)) {
      throw new Error("Taxa não pode ser negativa");
    }

    if (n <= 0 || !Number.isInteger(n)) {
      throw new Error("Prazo deve ser inteiro positivo");
    }

    return calculatePMT({ pv, rate, n });
  } catch (error) {
    console.error("Erro ao calcular:", error.message);
    return null;
  }
}
```

## 📖 Convenções

### Datas

A biblioteca trabalha com **períodos numéricos** (1, 2, 3...), não datas absolutas. Cabe à aplicação consumidora mapear períodos para datas calendário se necessário.

```typescript
// Exemplo: adicionar datas ao cronograma
const dataInicio = new Date("2025-01-01");

const cronogramaComDatas = schedule.cronograma.map((linha) => ({
  ...linha,
  data: new Date(
    dataInicio.getFullYear(),
    dataInicio.getMonth() + linha.periodo,
    dataInicio.getDate(),
  ),
}));
```

### Convenção de Day Count

Por padrão, a biblioteca assume **30/360** (30 dias por mês, 360 dias por ano) para cálculos de juros mensais. Para convenções diferentes (ACT/365, ACT/360), consulte módulos específicos ou ajuste manualmente.

### Tratamento de Erros

A biblioteca pode lançar exceções em casos de:

- Parâmetros inválidos (valores negativos onde não permitido)
- Convergência não atingida (IRR após maxIterations)
- Tipos incorretos (passar number em vez de Decimal)

Sempre envolva chamadas em `try-catch`:

```typescript
try {
  const irr = calculateIRR({ cashFlows });
} catch (error) {
  console.error("Não foi possível calcular a TIR:", error.message);
}
```

## 🧪 Testes e Validação

Todos os cálculos são validados por:

- **30 Golden Files**: Cenários de mercado com valores esperados
- **Testes Unitários**: Cobertura de 85%+
- **Comparação com Excel**: Funções PMT, PRICE, SAC validadas

Exemplo de validação local:

```bash
# Clone o repositório
git clone https://github.com/PrinceOfEgypt1/fin-math.git
cd fin-math

# Instale dependências
pnpm install

# Rode testes do engine
pnpm -F @finmath/engine test

# Rode golden files
pnpm -F @finmath/engine test:golden
```

## 📚 Recursos Adicionais

- **Código fonte:** [github.com/PrinceOfEgypt1/fin-math](https://github.com/PrinceOfEgypt1/fin-math)
- **Documentação de arquitetura:** [docs/ARCHITECTURE.md](./ARCHITECTURE.md)
- **Issues e suporte:** [github.com/PrinceOfEgypt1/fin-math/issues](https://github.com/PrinceOfEgypt1/fin-math/issues)

## 📄 Licença

MIT - Veja [LICENSE](../LICENSE) para detalhes.

---

**Versão do Engine:** 0.4.1
**Última atualização:** Sprint 4
