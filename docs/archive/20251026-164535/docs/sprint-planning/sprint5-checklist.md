# Sprint 5 - Checklist de Implementação

**Início:** 2025-10-20 (ou quando iniciar)  
**Fim Previsto:** 3 dias úteis  
**Pontos:** 16 (13 HU-25 + 2 Issue#001 + 1 Issue#002)  
**HU Principal:** HU-25 - Simulador CET Completo

---

## 🎯 OBJETIVO DA SPRINT

Implementar calculadora de CET (Custo Efetivo Total) completa, incluindo:

- ✅ Algoritmo Newton-Raphson para encontrar taxa efetiva
- ✅ Cálculo de IOF (fixo 0,38% + diário 0,0082%)
- ✅ Interface com formulário de 3 seções
- ✅ Validação contra calculadora Banco Central
- ✅ Alertas inteligentes baseados em thresholds

---

## 📅 DIA 1: ENGINE (Motor de Cálculo)

**Objetivo:** Implementar algoritmo Newton-Raphson e cálculo de IOF  
**Tempo:** 8 horas  
**Arquivos:** `packages/engine/src/modules/cet/`

### 🕐 09:00-10:00 - Estrutura Base

- [ ] Criar diretório `packages/engine/src/modules/cet/`
- [ ] Criar arquivos vazios:

```bash
  touch packages/engine/src/modules/cet/index.ts
  touch packages/engine/src/modules/cet/types.ts
  touch packages/engine/src/modules/cet/iof.ts
  touch packages/engine/src/modules/cet/newton-raphson.ts
  touch packages/engine/src/modules/cet/cash-flow.ts
```

- [ ] **types.ts** - Definir interfaces:

```typescript
import { Decimal } from "decimal.js";

export interface CetInput {
  valorPrincipal: Decimal;
  taxaNominal: Decimal;
  prazo: number;
  tarifaCadastro?: Decimal;
  tarifaAvaliacao?: Decimal;
  seguro?: {
    tipo: "fixo" | "percentual";
    valor: Decimal;
  };
  incluirIOF: boolean;
}

export interface CetOutput {
  cetMensal: Decimal;
  cetAnual: Decimal;
  valorLiquidoLiberado: Decimal;
  iofTotal: Decimal;
  custoTotal: Decimal;
  iteracoes: number;
  convergiu: boolean;
}

export interface IOFCalculation {
  fixo: Decimal;
  diario: Decimal;
  total: Decimal;
}
```

- [ ] Commit: `feat(engine): Adiciona estrutura base para cálculo CET`

---

### 🕐 10:00-12:00 - Cálculo de IOF

- [ ] **iof.ts** - Implementar `calculateIOF()`:

```typescript
import { Decimal } from "decimal.js";
import type { IOFCalculation, CetInput } from "./types";

/**
 * Calcula IOF (Imposto sobre Operações Financeiras)
 * - IOF Fixo: 0,38% sobre o principal
 * - IOF Diário: 0,0082% ao dia, limitado a 365 dias
 */
export function calculateIOF(input: CetInput): IOFCalculation {
  const { valorPrincipal, prazo } = input;

  // IOF Fixo: 0,38% sobre principal
  const iofFixo = valorPrincipal.mul(0.0038);

  // IOF Diário: 0,0082% ao dia (prazo em meses → dias)
  // Limitado a 365 dias
  const diasIOF = Math.min(prazo * 30, 365);
  const iofDiario = valorPrincipal.mul(0.000082).mul(diasIOF);

  const total = iofFixo.plus(iofDiario);

  return {
    fixo: iofFixo,
    diario: iofDiario,
    total,
  };
}
```

- [ ] Criar `packages/engine/test/unit/cet/iof.test.ts`:

```typescript
import { describe, it, expect } from "vitest";
import { Decimal } from "decimal.js";
import { calculateIOF } from "../../../src/modules/cet/iof";

describe("calculateIOF", () => {
  it("calcula IOF para 12 meses", () => {
    const result = calculateIOF({
      valorPrincipal: new Decimal(10000),
      taxaNominal: new Decimal(0.02),
      prazo: 12,
      incluirIOF: true,
    });

    expect(result.fixo.toNumber()).toBeCloseTo(38, 2);
    expect(result.diario.toNumber()).toBeCloseTo(29.52, 2);
    expect(result.total.toNumber()).toBeCloseTo(67.52, 2);
  });

  it("limita IOF diário a 365 dias", () => {
    const result = calculateIOF({
      valorPrincipal: new Decimal(10000),
      taxaNominal: new Decimal(0.02),
      prazo: 24, // 720 dias, mas limitado a 365
      incluirIOF: true,
    });

    expect(result.diario.toNumber()).toBeLessThanOrEqual(29.93);
  });
});
```

- [ ] Rodar testes: `npm run test -- iof.test.ts`
- [ ] ✅ Todos os testes passando
- [ ] Commit: `feat(engine): Implementa cálculo de IOF (fixo + diário)`

---

### 🕐 13:00-15:30 - Algoritmo Newton-Raphson

- [ ] **newton-raphson.ts** - Implementar algoritmo:

```typescript
import { Decimal } from "decimal.js";

interface NPVParams {
  cashFlow: Decimal[];
  rate: Decimal;
  presentValue: Decimal;
}

/**
 * Calcula NPV (Net Present Value)
 * NPV = PV - Σ[CF_t / (1 + rate)^t]
 */
export function calculateNPV(params: NPVParams): Decimal {
  const { cashFlow, rate, presentValue } = params;

  let sum = new Decimal(0);

  for (let t = 1; t <= cashFlow.length; t++) {
    const denominator = new Decimal(1).plus(rate).pow(t);
    const discounted = cashFlow[t - 1].div(denominator);
    sum = sum.plus(discounted);
  }

  return presentValue.minus(sum);
}

/**
 * Calcula derivada do NPV
 * NPV'(rate) = Σ[t × CF_t / (1 + rate)^(t+1)]
 */
export function calculateNPVDerivative(
  cashFlow: Decimal[],
  rate: Decimal,
): Decimal {
  let sum = new Decimal(0);

  for (let t = 1; t <= cashFlow.length; t++) {
    const numerator = new Decimal(t).mul(cashFlow[t - 1]);
    const denominator = new Decimal(1).plus(rate).pow(t + 1);
    sum = sum.plus(numerator.div(denominator));
  }

  return sum;
}

interface NewtonRaphsonParams {
  cashFlow: Decimal[];
  presentValue: Decimal;
  initialGuess: Decimal;
  tolerance?: Decimal;
  maxIterations?: number;
}

interface NewtonRaphsonResult {
  rate: Decimal;
  iterations: number;
  converged: boolean;
}

/**
 * Resolve equação NPV = 0 usando Newton-Raphson
 */
export function solveNewtonRaphson(
  params: NewtonRaphsonParams,
): NewtonRaphsonResult {
  const {
    cashFlow,
    presentValue,
    initialGuess,
    tolerance = new Decimal(1e-6),
    maxIterations = 100,
  } = params;

  let rate = initialGuess;
  let iterations = 0;

  while (iterations < maxIterations) {
    const npv = calculateNPV({ cashFlow, rate, presentValue });
    const derivative = calculateNPVDerivative(cashFlow, rate);

    // Evitar divisão por zero
    if (derivative.abs().lessThan(new Decimal(1e-10))) {
      return { rate, iterations, converged: false };
    }

    const rateNew = rate.minus(npv.div(derivative));

    // Verificar convergência
    if (rateNew.minus(rate).abs().lessThan(tolerance)) {
      return {
        rate: rateNew,
        iterations,
        converged: true,
      };
    }

    rate = rateNew;
    iterations++;
  }

  // Não convergiu
  return { rate, iterations, converged: false };
}
```

- [ ] Criar `packages/engine/test/unit/cet/newton-raphson.test.ts`
- [ ] Testar convergência em caso simples
- [ ] Testar não convergência (retornar erro)
- [ ] ✅ Todos os testes passando
- [ ] Commit: `feat(engine): Implementa solver Newton-Raphson para CET`

---

### 🕐 15:30-17:30 - Fluxo de Caixa e Integração

- [ ] **cash-flow.ts** - Montar fluxo de caixa:

```typescript
import { Decimal } from "decimal.js";
import type { CetInput } from "./types";

export function buildCashFlow(input: CetInput): Decimal[] {
  const { valorPrincipal, taxaNominal, prazo, seguro } = input;

  // Calcular PMT (parcela fixa) usando PRICE
  const i = taxaNominal;
  const n = prazo;
  const pmt = valorPrincipal
    .mul(i.mul(new Decimal(1).plus(i).pow(n)))
    .div(new Decimal(1).plus(i).pow(n).minus(1));

  // Adicionar seguro se houver
  let parcelaMensal = pmt;
  if (seguro) {
    if (seguro.tipo === "fixo") {
      parcelaMensal = parcelaMensal.plus(seguro.valor);
    } else {
      const seguroMensal = valorPrincipal.mul(seguro.valor).div(prazo);
      parcelaMensal = parcelaMensal.plus(seguroMensal);
    }
  }

  // Criar array com todas as parcelas
  return Array(prazo).fill(parcelaMensal);
}
```

- [ ] **index.ts** - Função principal `calculateCET()`:

```typescript
import { Decimal } from "decimal.js";
import type { CetInput, CetOutput } from "./types";
import { calculateIOF } from "./iof";
import { buildCashFlow } from "./cash-flow";
import { solveNewtonRaphson } from "./newton-raphson";

export function calculateCET(input: CetInput): CetOutput {
  // 1. Calcular IOF
  const iof = input.incluirIOF
    ? calculateIOF(input)
    : { total: new Decimal(0) };

  // 2. Calcular valor líquido liberado
  const tarifasIniciais = (input.tarifaCadastro || new Decimal(0)).plus(
    input.tarifaAvaliacao || new Decimal(0),
  );

  const valorLiquido = input.valorPrincipal
    .minus(tarifasIniciais)
    .minus(iof.total);

  // 3. Montar fluxo de caixa
  const cashFlow = buildCashFlow(input);

  // 4. Resolver usando Newton-Raphson
  const chute = input.taxaNominal.mul(1.2);

  const resultado = solveNewtonRaphson({
    cashFlow,
    presentValue: valorLiquido,
    initialGuess: chute,
  });

  if (!resultado.converged) {
    throw new Error("CET não convergiu. Verifique os valores.");
  }

  // 5. Calcular CET anual
  const cetMensal = resultado.rate;
  const cetAnual = new Decimal(1).plus(cetMensal).pow(12).minus(1);

  // 6. Calcular custo total
  const custoTotal = cashFlow.reduce(
    (sum, pmt) => sum.plus(pmt),
    new Decimal(0),
  );

  return {
    cetMensal,
    cetAnual,
    valorLiquidoLiberado: valorLiquido,
    iofTotal: iof.total,
    custoTotal,
    iteracoes: resultado.iterations,
    convergiu: true,
  };
}

// Re-exports
export * from "./types";
export { calculateIOF } from "./iof";
```

- [ ] Criar `packages/engine/test/unit/cet/index.test.ts`
- [ ] Testar caso sem tarifas (CET = taxa nominal)
- [ ] Testar caso com IOF
- [ ] Testar caso com múltiplas tarifas
- [ ] ✅ Todos os testes passando
- [ ] Commit: `feat(engine): Integra CET completo (Newton-Raphson + IOF + fluxo)`

---

### 🕐 17:30-18:00 - Testes de Propriedade

- [ ] Criar `packages/engine/test/property/cet.property.test.ts`:

```typescript
import { describe, it, expect } from "vitest";
import { Decimal } from "decimal.js";
import { calculateCET } from "../../src/modules/cet";
import fc from "fast-check";

describe("CET - Propriedades", () => {
  it("CET sempre >= taxa nominal", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 5000, max: 100000 }),
        fc.float({ min: 0.01, max: 0.1 }),
        fc.integer({ min: 6, max: 60 }),
        (valor, taxa, prazo) => {
          const resultado = calculateCET({
            valorPrincipal: new Decimal(valor),
            taxaNominal: new Decimal(taxa),
            prazo,
            incluirIOF: true,
          });

          expect(resultado.cetMensal.greaterThanOrEqualTo(taxa)).toBe(true);
        },
      ),
    );
  });

  it("Sem tarifas e sem IOF, CET = taxa nominal", () => {
    const resultado = calculateCET({
      valorPrincipal: new Decimal(10000),
      taxaNominal: new Decimal(0.02),
      prazo: 12,
      incluirIOF: false,
    });

    expect(resultado.cetMensal.toNumber()).toBeCloseTo(0.02, 4);
  });
});
```

- [ ] Rodar todos os testes: `npm run test`
- [ ] ✅ Cobertura >= 85%

---

### ✅ CHECKPOINT DIA 1

- [ ] Todos os testes unitários passando
- [ ] Função `calculateCET()` completa
- [ ] Cálculo de IOF validado
- [ ] Newton-Raphson convergindo
- [ ] Commit final do dia:

```bash
  git add packages/engine/src/modules/cet/
  git add packages/engine/test/
  git commit -m "feat(engine): Implementa CET completo - Dia 1

  Implementações:
  - Algoritmo Newton-Raphson para encontrar CET
  - Cálculo de IOF (fixo 0,38% + diário 0,0082%)
  - Montagem de fluxo de caixa
  - Função calculateCET() integrada

  Testes:
  - Unitários: 8 casos
  - Propriedade: 2 invariantes
  - Cobertura: 87%

  Refs: HU-25 (Dia 1/3)"
```

---

## 📅 DIA 2: INTERFACE (UI)

**Objetivo:** Criar formulário e exibição de resultados  
**Tempo:** 8 horas  
**Arquivos:** `packages/ui/src/pages/simulators/CetSimulator.tsx`

### 🕐 09:00-10:30 - Estrutura do Componente

- [ ] Criar `packages/ui/src/pages/simulators/CetSimulator.tsx`:

```typescript
import { useState } from "react";
import { motion } from "framer-motion";
import { Percent, Info } from "lucide-react";
import Container from "@/components/layout/Container";
import { calculateCET } from "@finmath/engine";
import { Decimal } from "decimal.js";

interface FormData {
  valor: string;
  taxa: string;
  prazo: string;
  tarifaCadastro: string;
  tarifaAvaliacao: string;
  seguro: string;
  incluirIOF: boolean;
}

export default function CetSimulator() {
  const [formData, setFormData] = useState<FormData>({
    valor: "10000",
    taxa: "2",
    prazo: "12",
    tarifaCadastro: "0",
    tarifaAvaliacao: "0",
    seguro: "0",
    incluirIOF: true,
  });

  const [resultado, setResultado] = useState(null);
  const [loading, setLoading] = useState(false);

  // ... resto do componente
}
```

- [ ] Commit: `feat(ui): Adiciona estrutura base CetSimulator`

---

### 🕐 10:30-12:00 - Formulário com Seções

- [ ] Seção 1: Dados Básicos (sempre visível)
- [ ] Seção 2: Tarifas (colapsável)
- [ ] Seção 3: IOF (sempre visível)
- [ ] Validações nos campos
- [ ] Máscaras de formatação

---

### 🕐 13:00-14:30 - Integração com Engine

- [ ] Função `handleSubmit()`
- [ ] Chamar `calculateCET()` do engine
- [ ] Tratar erros (não convergência)
- [ ] Loading state

---

### 🕐 14:30-16:30 - Exibição de Resultados

- [ ] Card principal com CET
- [ ] Comparação taxa nominal vs CET
- [ ] Valor líquido liberado
- [ ] Tabela de detalhamento

---

### 🕐 16:30-17:30 - Alertas e Responsividade

- [ ] Alertas condicionais
- [ ] Tooltips
- [ ] Responsivo mobile
- [ ] Animações

---

### ✅ CHECKPOINT DIA 2

- [ ] Interface funcional
- [ ] Cálculo end-to-end funcionando
- [ ] Commit final

---

## 📅 DIA 3: QUALIDADE E VALIDAÇÃO

**Objetivo:** Testes, validação BC, documentação  
**Tempo:** 8 horas

### 🕐 09:00-11:00 - Golden Files

- [ ] Criar 5 golden files
- [ ] Validar contra calculadora BC
- [ ] Todos passando

---

### 🕐 11:00-13:00 - Testes E2E

- [ ] Fluxo completo
- [ ] Validações
- [ ] Mobile

---

### 🕐 14:00-16:00 - Documentação

- [ ] README atualizado
- [ ] JSDoc completo
- [ ] CHANGELOG (v0.5.0)
- [ ] Screenshots

---

### 🕐 16:00-18:00 - Validação Final

- [ ] Todos os testes
- [ ] Build produção
- [ ] Push final

---

## ✅ DEFINITION OF DONE - SPRINT 5

- [ ] HU-25 100% implementada
- [ ] Todos os testes passando
- [ ] Validação BC (erro < 0,01%)
- [ ] Documentação completa
- [ ] Screenshots
- [ ] Push no GitHub

---

**Criado em:** 2025-10-20  
**Sprint:** 5  
**Status:** 📋 Pronta para execução
