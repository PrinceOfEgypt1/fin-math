# Guia de Uso - finmath-engine

## 📋 Índice

- [Instalação](#instalação)
- [Conceitos Básicos](#conceitos-básicos)
- [Módulos Disponíveis](#módulos-disponíveis)
  - [PRICE - Sistema de Amortização](#price---sistema-de-amortização)
  - [SAC - Sistema de Amortização Constante](#sac---sistema-de-amortização-constante)
  - [CET - Custo Efetivo Total](#cet---custo-efetivo-total)
  - [NPV - Valor Presente Líquido](#npv---valor-presente-líquido)
  - [IRR - Taxa Interna de Retorno](#irr---taxa-interna-de-retorno)
  - [Juros e Taxas](#juros-e-taxas)
- [Trabalhando com Decimal.js](#trabalhando-com-decimaljs)
- [Tratamento de Erros](#tratamento-de-erros)
- [Exemplos Completos](#exemplos-completos)

---

## 🚀 Instalação

### Via npm (quando publicado)

```bash
npm install @finmath/engine
```

### Via pnpm (workspace local)

```bash
pnpm add @finmath/engine
```

### Importação

```typescript
import {
  calculatePMT,
  generatePriceSchedule,
  generateSACSchedule,
  calculateCET,
  calculateNPV,
  calculateIRR,
  // ... outras funções
} from '@finmath/engine';

import Decimal from 'decimal.js';
```

---

## 🧮 Conceitos Básicos

### Precisão Decimal

O `finmath-engine` utiliza a biblioteca [decimal.js](https://github.com/MikeMcl/decimal.js/) para garantir precisão em cálculos financeiros, evitando erros de ponto flutuante.

**Sempre use `Decimal` para valores monetários e taxas:**

```typescript
// ✅ CORRETO
const principal = new Decimal('10000.00');
const rate = new Decimal('0.015'); // 1.5% ao mês

// ❌ INCORRETO (pode causar imprecisão)
const principal = 10000;
const rate = 0.015;
```

### Convenções de Datas

- **Datas** são representadas como strings ISO 8601 (`YYYY-MM-DD`)
- **Períodos** são inteiros representando meses (por padrão)
- **Day Count Conventions** suportadas: 30/360, ACT/365, PRO-RATA

---

## 📦 Módulos Disponíveis

### PRICE - Sistema de Amortização

Sistema de amortização com **parcelas fixas** (PMT constante).

#### Calcular PMT (Parcela Fixa)

```typescript
import { calculatePMT } from '@finmath/engine';
import Decimal from 'decimal.js';

const pmt = calculatePMT({
  pv: new Decimal('100000'), // Valor presente (principal)
  rate: new Decimal('0.02'),  // Taxa mensal (2%)
  n: 12,                       // Número de parcelas
});

console.log(pmt.toString()); // "9456.59"
```

#### Gerar Cronograma PRICE Completo

```typescript
import { generatePriceSchedule } from '@finmath/engine';
import Decimal from 'decimal.js';

const schedule = generatePriceSchedule({
  pv: new Decimal('100000'),
  rate: new Decimal('0.02'),
  n: 12,
  startDate: '2025-01-01', // Opcional
});

// Estrutura do cronograma:
schedule.forEach((entry, index) => {
  console.log(`Parcela ${index + 1}:`);
  console.log(`  PMT: R$ ${entry.pmt.toString()}`);
  console.log(`  Juros: R$ ${entry.interest.toString()}`);
  console.log(`  Amortização: R$ ${entry.amortization.toString()}`);
  console.log(`  Saldo: R$ ${entry.balance.toString()}`);
  console.log(`  Data: ${entry.date}`);
});
```

**Saída esperada:**

```
Parcela 1:
  PMT: R$ 9456.59
  Juros: R$ 2000.00
  Amortização: R$ 7456.59
  Saldo: R$ 92543.41
  Data: 2025-02-01
...
```

---

### SAC - Sistema de Amortização Constante

Sistema com **amortização constante** e **parcelas decrescentes**.

#### Gerar Cronograma SAC

```typescript
import { generateSACSchedule } from '@finmath/engine';
import Decimal from 'decimal.js';

const schedule = generateSACSchedule({
  pv: new Decimal('100000'),
  rate: new Decimal('0.02'),
  n: 12,
  startDate: '2025-01-01',
});

// Primeira parcela (maior)
console.log(`Primeira parcela: R$ ${schedule[0].pmt.toString()}`);
// "10333.33"

// Última parcela (menor)
console.log(`Última parcela: R$ ${schedule[11].pmt.toString()}`);
// "8500.00"

// Amortização constante em todas as parcelas
console.log(`Amortização fixa: R$ ${schedule[0].amortization.toString()}`);
// "8333.33" (100000 / 12)
```

---

### CET - Custo Efetivo Total

Calcula o **Custo Efetivo Total** incluindo IOF, tarifas e seguros.

#### CET Básico (apenas tarifas)

```typescript
import { calculateCET } from '@finmath/engine';
import Decimal from 'decimal.js';

const cet = calculateCET({
  pv: new Decimal('10000'),      // Valor financiado
  pmt: new Decimal('946.56'),    // Parcela mensal
  n: 12,                          // Número de parcelas
  fees: [
    { name: 'TAC', value: new Decimal('150') },
    { name: 'Registro', value: new Decimal('50') },
  ],
});

console.log(`CET Mensal: ${cet.cetMonthly.toString()}%`);
console.log(`CET Anual: ${cet.cetAnnual.toString()}%`);
```

#### CET Completo (com IOF e seguros)

```typescript
import { calculateCETComplete } from '@finmath/engine';
import Decimal from 'decimal.js';

const cet = calculateCETComplete({
  pv: new Decimal('10000'),
  pmt: new Decimal('946.56'),
  n: 12,
  fees: [{ name: 'TAC', value: new Decimal('150') }],
  iof: {
    daily: new Decimal('0.000082'), // 0.0082% ao dia
    fixed: new Decimal('0.0038'),   // 0.38% fixo
  },
  insurance: {
    lifeInsurance: new Decimal('5.50'), // Por mês
    propertyInsurance: new Decimal('3.00'),
  },
});

console.log(`CET Total Mensal: ${cet.cetMonthly.toString()}%`);
console.log(`CET Total Anual: ${cet.cetAnnual.toString()}%`);
```

---

### NPV - Valor Presente Líquido

Calcula o **Valor Presente Líquido** de fluxos de caixa.

#### NPV de Fluxo de Investimento

```typescript
import { calculateNPV } from '@finmath/engine';
import Decimal from 'decimal.js';

const cashFlows = [
  new Decimal('-10000'), // Investimento inicial (saída)
  new Decimal('3000'),   // Retorno ano 1
  new Decimal('4000'),   // Retorno ano 2
  new Decimal('5000'),   // Retorno ano 3
  new Decimal('2000'),   // Retorno ano 4
];

const npv = calculateNPV({
  rate: new Decimal('0.10'), // Taxa de desconto 10% a.a.
  cashFlows,
});

console.log(`NPV: R$ ${npv.toString()}`);
// Se NPV > 0, investimento é viável
```

**Interpretação:**

- **NPV > 0**: Investimento rentável
- **NPV = 0**: Investimento no ponto de equilíbrio
- **NPV < 0**: Investimento não rentável

---

### IRR - Taxa Interna de Retorno

Calcula a **Taxa Interna de Retorno** usando o **Método de Brent** (robusto e eficiente).

#### IRR de Projeto

```typescript
import { calculateIRR } from '@finmath/engine';
import Decimal from 'decimal.js';

const cashFlows = [
  new Decimal('-10000'), // Investimento inicial
  new Decimal('3000'),
  new Decimal('4000'),
  new Decimal('5000'),
  new Decimal('2000'),
];

const irr = calculateIRR({ cashFlows });

console.log(`TIR: ${irr.times(100).toString()}% a.a.`);
// Exemplo: "15.09% a.a."
```

**Interpretação:**

- Se **IRR > taxa de desconto**: Investimento viável
- Se **IRR < taxa de desconto**: Investimento não viável

**Validações:**

```typescript
// O primeiro fluxo deve ser negativo (investimento inicial)
// Deve haver pelo menos um fluxo positivo

// ❌ INCORRETO (sem fluxo negativo)
const invalid = [
  new Decimal('1000'),
  new Decimal('2000'),
];

// ✅ CORRETO
const valid = [
  new Decimal('-1000'), // Investimento
  new Decimal('1200'),  // Retorno
];
```

---

### Juros e Taxas

#### Equivalência de Taxas

Converter taxa mensal para anual e vice-versa.

```typescript
import { monthlyToAnnualRate, annualToMonthlyRate } from '@finmath/engine';
import Decimal from 'decimal.js';

// Mensal → Anual
const monthlyRate = new Decimal('0.02'); // 2% a.m.
const annualRate = monthlyToAnnualRate(monthlyRate);
console.log(`Taxa anual: ${annualRate.times(100).toFixed(2)}%`);
// "26.82%"

// Anual → Mensal
const annual = new Decimal('0.2682'); // 26.82% a.a.
const monthly = annualToMonthlyRate(annual);
console.log(`Taxa mensal: ${monthly.times(100).toFixed(2)}%`);
// "2.00%"
```

#### Taxa Real (ajuste de inflação)

```typescript
import { calculateRealRate } from '@finmath/engine';
import Decimal from 'decimal.js';

const nominalRate = new Decimal('0.12'); // 12% a.a.
const inflation = new Decimal('0.05');   // 5% a.a.

const realRate = calculateRealRate(nominalRate, inflation);

console.log(`Taxa real: ${realRate.times(100).toFixed(2)}%`);
// "6.67%"
```

---

## 💎 Trabalhando com Decimal.js

### Criação de Decimals

```typescript
import Decimal from 'decimal.js';

// A partir de string (RECOMENDADO para precisão)
const a = new Decimal('123.456');

// A partir de número (use com cautela)
const b = new Decimal(123.456);

// A partir de outro Decimal
const c = new Decimal(a);
```

### Operações Básicas

```typescript
const a = new Decimal('100');
const b = new Decimal('25');

// Soma
const sum = a.plus(b); // "125"

// Subtração
const diff = a.minus(b); // "75"

// Multiplicação
const product = a.times(b); // "2500"

// Divisão
const quotient = a.dividedBy(b); // "4"

// Potência
const power = a.pow(2); // "10000"
```

### Comparações

```typescript
const a = new Decimal('100');
const b = new Decimal('50');

a.greaterThan(b);        // true
a.lessThan(b);           // false
a.equals(b);             // false
a.greaterThanOrEqualTo(b); // true
```

### Conversão

```typescript
const decimal = new Decimal('123.456');

decimal.toString();     // "123.456"
decimal.toNumber();     // 123.456
decimal.toFixed(2);     // "123.46"
decimal.toFixed(0);     // "123"
```

---

## ⚠️ Tratamento de Erros

### Validação de Parâmetros

Todas as funções do `finmath-engine` validam parâmetros e lançam erros descritivos:

```typescript
import { calculatePMT } from '@finmath/engine';
import Decimal from 'decimal.js';

try {
  const pmt = calculatePMT({
    pv: new Decimal('-10000'), // ❌ Valor negativo
    rate: new Decimal('0.02'),
    n: 12,
  });
} catch (error) {
  console.error(error.message);
  // "PV must be greater than zero"
}
```

### Erros Comuns

#### 1. Taxa Negativa ou Zero

```typescript
// ❌ INCORRETO
const pmt = calculatePMT({
  pv: new Decimal('10000'),
  rate: new Decimal('0'), // Taxa zero
  n: 12,
});
// Erro: "Rate must be greater than zero"
```

#### 2. Número de Parcelas Inválido

```typescript
// ❌ INCORRETO
const schedule = generatePriceSchedule({
  pv: new Decimal('10000'),
  rate: new Decimal('0.02'),
  n: 0, // Zero parcelas
});
// Erro: "Number of periods must be greater than zero"
```

#### 3. Fluxos de Caixa Vazios (NPV/IRR)

```typescript
// ❌ INCORRETO
const irr = calculateIRR({
  cashFlows: [], // Vazio
});
// Erro: "Cash flows array cannot be empty"
```

### Tratamento Recomendado

```typescript
function calculateLoan(principal: string, rateStr: string, periods: number) {
  try {
    const pv = new Decimal(principal);
    const rate = new Decimal(rateStr);

    if (pv.lessThanOrEqualTo(0)) {
      throw new Error('Principal deve ser maior que zero');
    }

    if (rate.lessThanOrEqualTo(0)) {
      throw new Error('Taxa deve ser maior que zero');
    }

    if (periods <= 0 || !Number.isInteger(periods)) {
      throw new Error('Número de parcelas deve ser um inteiro positivo');
    }

    const pmt = calculatePMT({ pv, rate, n: periods });

    return {
      success: true,
      pmt: pmt.toFixed(2),
    };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Erro desconhecido',
    };
  }
}
```

---

## 🎯 Exemplos Completos

### Exemplo 1: Simulador de Financiamento Imobiliário

```typescript
import { generatePriceSchedule, calculateCETComplete } from '@finmath/engine';
import Decimal from 'decimal.js';

function simulateRealEstateLoan(
  propertyValue: string,
  downPayment: string,
  annualRatePercent: string,
  years: number
) {
  const property = new Decimal(propertyValue);
  const down = new Decimal(downPayment);
  const principal = property.minus(down);

  // Converter taxa anual para mensal
  const annualRate = new Decimal(annualRatePercent).dividedBy(100);
  const monthlyRate = new Decimal(1)
    .plus(annualRate)
    .pow(new Decimal(1).dividedBy(12))
    .minus(1);

  const n = years * 12;

  // Gerar cronograma PRICE
  const schedule = generatePriceSchedule({
    pv: principal,
    rate: monthlyRate,
    n,
    startDate: '2025-01-01',
  });

  // Calcular CET completo
  const cet = calculateCETComplete({
    pv: principal,
    pmt: schedule[0].pmt,
    n,
    fees: [
      { name: 'Avaliação', value: new Decimal('800') },
      { name: 'Registro', value: new Decimal('1200') },
    ],
    iof: {
      daily: new Decimal('0.000082'),
      fixed: new Decimal('0.0038'),
    },
    insurance: {
      lifeInsurance: new Decimal('45.00'),
      propertyInsurance: new Decimal('80.00'),
    },
  });

  return {
    principal: principal.toFixed(2),
    firstPayment: schedule[0].pmt.toFixed(2),
    lastPayment: schedule[n - 1].pmt.toFixed(2),
    totalPaid: schedule.reduce((sum, entry) => sum.plus(entry.pmt), new Decimal(0)).toFixed(2),
    totalInterest: schedule.reduce((sum, entry) => sum.plus(entry.interest), new Decimal(0)).toFixed(2),
    cetMonthly: cet.cetMonthly.times(100).toFixed(2) + '%',
    cetAnnual: cet.cetAnnual.times(100).toFixed(2) + '%',
  };
}

// Usar
const loan = simulateRealEstateLoan('300000', '60000', '10', 20);
console.log(loan);
/*
{
  principal: "240000.00",
  firstPayment: "2317.36",
  lastPayment: "2317.36",
  totalPaid: "556166.40",
  totalInterest: "316166.40",
  cetMonthly: "0.87%",
  cetAnnual: "10.98%"
}
*/
```

### Exemplo 2: Comparação PRICE vs SAC

```typescript
import { generatePriceSchedule, generateSACSchedule } from '@finmath/engine';
import Decimal from 'decimal.js';

function comparePriceVsSAC(principal: string, ratePercent: string, years: number) {
  const pv = new Decimal(principal);
  const rate = new Decimal(ratePercent).dividedBy(100);
  const n = years * 12;

  const priceSchedule = generatePriceSchedule({ pv, rate, n });
  const sacSchedule = generateSACSchedule({ pv, rate, n });

  const priceTotalPaid = priceSchedule.reduce((sum, entry) => sum.plus(entry.pmt), new Decimal(0));
  const sacTotalPaid = sacSchedule.reduce((sum, entry) => sum.plus(entry.pmt), new Decimal(0));

  const savings = priceTotalPaid.minus(sacTotalPaid);

  return {
    price: {
      payment: priceSchedule[0].pmt.toFixed(2),
      totalPaid: priceTotalPaid.toFixed(2),
    },
    sac: {
      firstPayment: sacSchedule[0].pmt.toFixed(2),
      lastPayment: sacSchedule[n - 1].pmt.toFixed(2),
      totalPaid: sacTotalPaid.toFixed(2),
    },
    savingsWithSAC: savings.toFixed(2),
  };
}

const comparison = comparePriceVsSAC('100000', '1.5', 5);
console.log(comparison);
```

### Exemplo 3: Análise de Viabilidade de Projeto

```typescript
import { calculateNPV, calculateIRR } from '@finmath/engine';
import Decimal from 'decimal.js';

function analyzeProject(
  initialInvestment: string,
  annualReturns: string[],
  discountRate: string
) {
  const cashFlows = [
    new Decimal(initialInvestment).negated(), // Investimento inicial negativo
    ...annualReturns.map((r) => new Decimal(r)),
  ];

  const rate = new Decimal(discountRate).dividedBy(100);

  const npv = calculateNPV({ rate, cashFlows });
  const irr = calculateIRR({ cashFlows });

  return {
    npv: npv.toFixed(2),
    irr: irr.times(100).toFixed(2) + '%',
    viable: npv.greaterThan(0) && irr.greaterThan(rate),
    recommendation: npv.greaterThan(0)
      ? 'Investimento recomendado'
      : 'Investimento não recomendado',
  };
}

const project = analyzeProject('50000', ['15000', '20000', '25000', '18000'], '10');
console.log(project);
/*
{
  npv: "12345.67",
  irr: "18.52%",
  viable: true,
  recommendation: "Investimento recomendado"
}
*/
```

---

## 📚 Recursos Adicionais

### Documentação Relacionada

- [Arquitetura do FinMath](./ARCHITECTURE.md)
- [Guia de Acessibilidade](./A11Y-GUIDE.md)
- [Relatório de Validação](../VALIDATION-REPORT-FINAL.md)

### Bibliotecas Utilizadas

- [Decimal.js](https://mikemcl.github.io/decimal.js/) - Aritmética de precisão arbitrária

### Referências Técnicas

- **PRICE**: Sistema Francês de Amortização
- **SAC**: Sistema de Amortização Constante
- **CET**: Resolução CMN 3.517/2007 (Banco Central do Brasil)
- **IRR**: Método de Brent para raízes de funções

---

## 🆘 Suporte

- **Issues**: [GitHub Issues](https://github.com/PrinceOfEgypt1/fin-math/issues)
- **Discussões**: [GitHub Discussions](https://github.com/PrinceOfEgypt1/fin-math/discussions)

---

**Versão do Engine**: 1.0.0
**Última atualização**: Sprint 4
**Licença**: MIT
