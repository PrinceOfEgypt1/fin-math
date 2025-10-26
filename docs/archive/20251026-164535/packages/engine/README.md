# @finmath/engine

Motor de cálculos financeiros de alta precisão para o mercado brasileiro.

[![Version](https://img.shields.io/npm/v/@finmath/engine.svg)](https://www.npmjs.com/package/@finmath/engine)
[![License](https://img.shields.io/npm/l/@finmath/engine.svg)](LICENSE)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.6-blue.svg)](https://www.typescriptlang.org/)

## 🎯 Características

- ✅ **Precisão decimal** (decimal.js - sem erros de ponto flutuante)
- ✅ **30 Golden Files** validando cálculos
- ✅ **TypeScript nativo** com types completos
- ✅ **CET completo** (IOF + seguros + perfis institucionais)
- ✅ **Método de Brent** para IRR robusto
- ✅ **85% de cobertura** de testes

## 📦 Instalação

```bash
npm install @finmath/engine decimal.js
# ou
pnpm add @finmath/engine decimal.js
# ou
yarn add @finmath/engine decimal.js
```

## 🚀 Uso Rápido

```typescript
import { Decimal } from 'decimal.js';
import { amortization, cet, irr } from '@finmath/engine';

// Price
const price = amortization.calculatePrice({
  pv: new Decimal('10000'),
  rate: new Decimal('0.02'),
  n: 12
});
console.log(`PMT: R$ ${price.pmt.toFixed(2)}`); // R$ 946.56

// CET
const cetResult = cetBasic({
  pv: new Decimal('10000'),
  pmt: new Decimal('946.56'),
  n: 12,
  feesT0: [{ name: 'TAC', value: new Decimal('150') }]
});
console.log(`CET Anual: ${cetResult.cetAnual.mul(100).toFixed(2)}%`);

// IRR
const cashflows = [
  new Decimal('-10000'),
  new Decimal('1000'),
  ...
];
const tir = irr.calculateIRR(cashflows);
console.log(`TIR: ${tir.mul(100).toFixed(2)}%`);
```

## 📚 Módulos Disponíveis

### Amortização

- `calculatePrice()` - Sistema Price
- `generatePriceSchedule()` - Cronograma Price
- `calculateSAC()` - Sistema SAC
- `generateSacSchedule()` - Cronograma SAC

### CET (Custo Efetivo Total)

- `cetBasic()` - CET básico (tarifas t0)
- `calculateCETFull()` - CET completo (IOF + seguros)

### IRR/NPV

- `calculateIRR()` - Taxa Interna de Retorno (Brent)
- `calculateNPV()` - Valor Presente Líquido

### Outros

- `interest` - Juros compostos (FV/PV)
- `rate` - Equivalência de taxas
- `series` - Séries uniformes
- `daycount` - Convenções de contagem de dias

## 📖 Documentação

- [Documentação API Completa](../../docs/api/index.html)
- [Exemplos](./examples/)
- [Changelog](../../CHANGELOG.md)

## 🧪 Exemplos

Ver diretório [examples/](./examples/) para exemplos detalhados:

- `01-price-basico.ts` - Cálculo Price completo
- `02-cet-completo.ts` - CET com tarifas
- `03-irr-investimento.ts` - TIR de projeto

## 🔬 Testes

```bash
# Todos os testes
pnpm test

# Apenas Golden Files
pnpm test:golden

# Cobertura
pnpm test:coverage
```

## 📊 Qualidade

- ✅ 30/30 Golden Files validados
- ✅ 85% cobertura de código
- ✅ 0 erros TypeScript
- ✅ Lint limpo

## 🤝 Contribuindo

Contribuições são bem-vindas! Veja [CONTRIBUTING.md](../../CONTRIBUTING.md).

## 📄 Licença

MIT © 2025 PrinceOfEgypt1

## 🔗 Links

- [Repositório](https://github.com/PrinceOfEgypt1/fin-math)
- [Issues](https://github.com/PrinceOfEgypt1/fin-math/issues)
- [npm](https://www.npmjs.com/package/@finmath/engine)
