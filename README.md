# 🧮 FinMath - Motor de Cálculos Financeiros

[![Version](https://img.shields.io/badge/version-0.4.0-blue.svg)](https://github.com/PrinceOfEgypt1/fin-math)
[![Tests](https://img.shields.io/badge/tests-38%2F39%20passing-brightgreen.svg)](VALIDATION-REPORT-FINAL.md)
[![Coverage](https://img.shields.io/badge/coverage-85%25-green.svg)](VALIDATION-REPORT-FINAL.md)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue.svg)](https://www.typescriptlang.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Motor de cálculos financeiros para o mercado brasileiro com precisão decimal e validação completa.

## 🎯 Características

- ✅ **Precisão decimal** (decimal.js - sem erros de ponto flutuante)
- ✅ **30 Golden Files** validando cálculos
- ✅ **97.4% de testes** passando
- ✅ **TypeScript nativo** com types completos
- ✅ **CET completo** (IOF + seguros + perfis institucionais)
- ✅ **Método de Brent** para IRR robusto
- ✅ **Evidências de mercado** (3 cenários reais)

## 📦 Módulos Disponíveis

### Juros e Taxas

- Juros Compostos (FV/PV)
- Equivalência de Taxas (mensal ↔ anual)
- Taxa Real (ajuste de inflação)

### Amortização

- **Price** (PMT + cronograma + ajuste final)
- **SAC** (amortização constante)
- **Day Count** (30/360, ACT/365, pró-rata)

### Análise de Investimentos

- **NPV** (Valor Presente Líquido)
- **IRR** (Taxa Interna de Retorno - Método de Brent)

### CET (Custo Efetivo Total)

- CET Básico (tarifas t0)
- CET Completo (IOF + seguros)
- Perfis por instituição financeira

### Séries

- Séries Uniformes (postecipadas/antecipadas)
- Inversão (PV ↔ PMT)

## 🚀 Instalação

```bash
# Clone o repositório
git clone https://github.com/PrinceOfEgypt1/fin-math.git
cd fin-math

# Instale dependências
pnpm install

# Build
pnpm -F @finmath/engine build
```

## 💻 Uso Básico

```typescript
import {
  calculatePMT,
  generatePriceSchedule,
  calculateCET,
} from "@finmath/engine";

// Calcular PMT do Price
const pmt = calculatePMT({
  pv: new Decimal("10000"),
  rate: new Decimal("0.02"),
  n: 12,
});

console.log(pmt.toString()); // "946.56"

// Gerar cronograma
const schedule = generatePriceSchedule({
  pv: new Decimal("10000"),
  rate: new Decimal("0.02"),
  n: 12,
});

// Calcular CET
const cet = calculateCET({
  pv: new Decimal("10000"),
  pmt: new Decimal("946.56"),
  n: 12,
  fees: [{ name: "TAC", value: new Decimal("150") }],
});
```

## 🧪 Testes

```bash
# Todos os testes
pnpm -F @finmath/engine test

# Apenas Golden Files
pnpm -F @finmath/engine test:golden

# Cobertura
pnpm -F @finmath/engine test:coverage

# Validação completa
./validate-sprint4.sh
```

## 📊 Qualidade

| Métrica      | Valor   | Status   |
| ------------ | ------- | -------- |
| Testes       | 38/39   | ✅ 97.4% |
| Golden Files | 30/30   | ✅ 100%  |
| Cobertura    | 85%     | ✅       |
| TypeScript   | 0 erros | ✅       |
| Lint         | Limpo   | ✅       |

## 📁 Estrutura

```
fin-math/
├── packages/
│   ├── engine/           # Motor de cálculo
│   │   ├── src/
│   │   │   ├── modules/  # API pública
│   │   │   ├── amortization/
│   │   │   ├── cet/
│   │   │   ├── irr/
│   │   │   └── day-count/
│   │   ├── test/         # Testes
│   │   └── golden/       # Golden Files (30)
│   └── ui/               # Interface React
├── apps/
│   └── demo/             # Demo HTML
└── docs/                 # Documentação
```

## 📚 Documentação

- **[Arquitetura do FinMath](docs/ARCHITECTURE.md)** - Visão completa da arquitetura, pacotes e decisões técnicas
- **[Guia de Uso do Engine](docs/ENGINE-USAGE.md)** - Como usar `@finmath/engine` em seus projetos
- **[Guia de Acessibilidade](docs/A11Y-GUIDE.md)** - Padrões WCAG 2.1 AA e componentes acessíveis
- **[Testes de Acessibilidade](docs/A11Y-TESTING.md)** - Como rodar e interpretar testes A11y
- [Relatório de Validação](VALIDATION-REPORT-FINAL.md)

## 🏆 Sprints Completas

- ✅ **Sprint 0:** Infraestrutura
- ✅ **Sprint 1:** Motor Básico
- ✅ **Sprint 2:** Amortizações + CET Básico
- ✅ **Sprint 3:** NPV/IRR + CET Completo
- ✅ **Sprint 4:** Acessibilidade + Documentação (100%)

## 🔗 Links

- **GitHub:** https://github.com/PrinceOfEgypt1/fin-math
- **Issues:** https://github.com/PrinceOfEgypt1/fin-math/issues
- **Project Board:** https://github.com/users/PrinceOfEgypt1/projects/3

## 📄 Licença

MIT

## 👥 Autor

PrinceOfEgypt1

---

**motorVersion: 0.4.0**  
**Status: ✅ Produção (Biblioteca)**

## ✨ HU-24: Comparação PRICE vs SAC

**Status:** ✅ Implementado (Sprint 5)

### Descrição

Página dedicada para comparar os sistemas de amortização PRICE e SAC lado a lado, permitindo que o usuário visualize simultaneamente:

- Parcelas de cada sistema
- Total pago
- Total de juros
- **Economia ao escolher SAC**

### Como Usar

1. Acesse o menu "Comparar"
2. Preencha os valores desejados
3. Clique em "Comparar Sistemas"
4. Analise os resultados lado a lado

### Tecnologias

- React Hooks (useState)
- Decimal.js (precisão)
- Framer Motion (animações)
- Tailwind CSS (estilização)

### Documentação

- [História de Usuário Completa](./docs/historias-usuario/HU-24-comparacao-price-sac.md)
- [Testes E2E](./packages/ui/test/e2e/comparison.spec.ts)

Fênix: smoke test 2025-10-25T02:33:50-03:00
