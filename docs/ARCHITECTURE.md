# Arquitetura do FinMath

## 📋 Visão Geral

O **FinMath** é um ecossistema de cálculos financeiros para o mercado brasileiro, estruturado em um **monorepo** com múltiplos pacotes especializados. A arquitetura prioriza **separação de responsabilidades**, **precisão decimal**, **qualidade** e **acessibilidade**.

---

## 🏗️ Estrutura de Pacotes

```
fin-math/
├── packages/
│   ├── engine/          # Motor de cálculo (core)
│   ├── ui/              # Interface React (Vite)
│   └── api/             # API REST (futuro)
├── tests/
│   ├── a11y/            # Testes de acessibilidade
│   ├── e2e/             # Testes end-to-end
│   ├── fixtures/        # Dados de teste
│   └── utils/           # Utilitários de teste
├── .fenix/              # Governança e políticas
│   ├── policies/        # Políticas de qualidade
│   ├── scripts/         # Scripts de validação
│   ├── checks/          # Validadores
│   └── rag/             # Índices RAG para docs
├── docs/                # Documentação
├── reports/             # Relatórios de qualidade
└── .github/
    └── workflows/       # CI/CD
```

---

## 📦 Pacotes Principais

### 1. `@finmath/engine` (Core)

**Responsabilidade**: Motor de cálculos financeiros com precisão decimal.

**Tecnologias**:
- TypeScript 5.6+
- Decimal.js (precisão arbitrária)
- Vitest (testes unitários)

**Estrutura interna**:

```
packages/engine/
├── src/
│   ├── modules/           # API pública
│   │   ├── price.ts       # Sistema PRICE
│   │   ├── sac.ts         # Sistema SAC
│   │   ├── cet.ts         # CET
│   │   ├── npv.ts         # NPV
│   │   └── irr.ts         # IRR (Método de Brent)
│   ├── amortization/      # Lógica de amortização
│   ├── day-count/         # Convenções de data
│   ├── utils/             # Utilitários
│   └── index.ts           # Exportações públicas
├── test/                  # Testes unitários
├── golden/                # Golden files (validação)
└── dist/                  # Build artifacts
```

**Características**:
- ✅ **Precisão Decimal**: Todos os cálculos usam `Decimal.js`
- ✅ **Validação**: Parâmetros validados em tempo de execução
- ✅ **Imutabilidade**: Funções puras sem side effects
- ✅ **30 Golden Files**: Validação automática com cenários reais
- ✅ **Cobertura**: 85%+ de testes

**API Pública**:

```typescript
// PRICE
export function calculatePMT(params: PriceParams): Decimal;
export function generatePriceSchedule(params: PriceParams): Schedule[];

// SAC
export function generateSACSchedule(params: SACParams): Schedule[];

// CET
export function calculateCET(params: CETParams): CETResult;
export function calculateCETComplete(params: CETCompleteParams): CETResult;

// NPV/IRR
export function calculateNPV(params: NPVParams): Decimal;
export function calculateIRR(params: IRRParams): Decimal;

// Utilitários
export function monthlyToAnnualRate(rate: Decimal): Decimal;
export function annualToMonthlyRate(rate: Decimal): Decimal;
```

---

### 2. `@finmath/ui` (Interface)

**Responsabilidade**: Interface web acessível para simuladores e comparadores.

**Tecnologias**:
- React 18+
- TypeScript 5.6+
- Vite 5+ (build tool)
- Tailwind CSS 3+ (estilização)
- ESLint + jsx-a11y (linting + acessibilidade)

**Estrutura interna**:

```
packages/ui/
├── src/
│   ├── components/        # Componentes reutilizáveis
│   │   ├── Button.tsx     # Botão acessível
│   │   ├── Input.tsx      # Input com label e validação
│   │   ├── Layout.tsx     # Layout principal
│   │   └── index.ts       # Exportações
│   ├── pages/             # Páginas/rotas
│   │   ├── Home.tsx       # Página inicial
│   │   ├── Comparator.tsx # Comparador PRICE vs SAC
│   │   └── index.ts
│   ├── styles/
│   │   └── globals.css    # Estilos globais + Tailwind
│   ├── Router.tsx         # Roteador simples
│   ├── App.tsx            # App principal
│   └── main.tsx           # Entry point
├── public/                # Assets estáticos
├── index.html             # HTML base (lang="pt-BR")
├── tailwind.config.js
├── postcss.config.js
└── vite.config.ts
```

**Características**:
- ✅ **WCAG 2.1 AA**: Acessibilidade completa
- ✅ **Navegação por Teclado**: 100% navegável via TAB
- ✅ **Leitores de Tela**: Compatível com NVDA, JAWS, VoiceOver
- ✅ **Componentes Semânticos**: HTML5 landmarks corretos
- ✅ **Skip Link**: "Pular para conteúdo principal"
- ✅ **Contraste**: Atende WCAG AA (4.5:1 para texto)

**Padrão de Componentes Acessíveis**:

```tsx
// Todos os componentes seguem padrões A11y
<Input
  label="Valor Principal (R$)"  // Label obrigatório
  type="number"
  required                      // aria-required automaticamente
  error={errors.principal}      // aria-invalid + aria-describedby
  helperText="Valor do financiamento"
/>
```

---

### 3. `@finmath/api` (REST API - Futuro)

**Responsabilidade**: API REST para integração com sistemas externos.

**Status**: Planejado (estrutura básica criada).

---

## 🔄 Fluxo de Dados

### Simulação PRICE/SAC

```
┌─────────────────────────────────────────────────────────────┐
│                         UI (React)                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  1. Usuário preenche formulário                       │   │
│  │     - Valor: R$ 100.000                               │   │
│  │     - Taxa: 2% a.m.                                   │   │
│  │     - Parcelas: 12                                    │   │
│  └──────────────────────────────────────────────────────┘   │
│                          ↓                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  2. Validação no Frontend                             │   │
│  │     - Campos obrigatórios?                            │   │
│  │     - Valores positivos?                              │   │
│  │     - Formato correto?                                │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                     ENGINE (Core)                            │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  3. Conversão para Decimal                            │   │
│  │     const pv = new Decimal('100000');                 │   │
│  │     const rate = new Decimal('0.02');                 │   │
│  └──────────────────────────────────────────────────────┘   │
│                          ↓                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  4. Cálculo (PRICE ou SAC)                            │   │
│  │     - Aplicação de fórmulas matemáticas               │   │
│  │     - Geração de cronograma                           │   │
│  │     - Validação de resultados                         │   │
│  └──────────────────────────────────────────────────────┘   │
│                          ↓                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  5. Retorno                                            │   │
│  │     Schedule[] com PMT, juros, amortização, saldo     │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                         UI (React)                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  6. Renderização de Resultados                        │   │
│  │     - Exibição visual formatada                       │   │
│  │     - Anúncio para leitores de tela (aria-live)       │   │
│  │     - Gráficos e tabelas acessíveis                   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧪 Camadas de Qualidade

### 1. Testes Unitários

**Localização**: `packages/engine/test/`

**Ferramenta**: Vitest

**Cobertura**: 85%+

**Características**:
- Testes isolados por módulo
- Assertions com Decimal.js
- Mocking mínimo (funções puras)

```typescript
// Exemplo de teste unitário
test('calculatePMT with valid params', () => {
  const pmt = calculatePMT({
    pv: new Decimal('10000'),
    rate: new Decimal('0.02'),
    n: 12,
  });

  expect(pmt.toFixed(2)).toBe('946.56');
});
```

### 2. Golden Files

**Localização**: `packages/engine/golden/`

**Total**: 30 arquivos

**Propósito**: Validação com cenários reais de mercado.

**Formato**:

```json
{
  "scenario": "Financiamento Imobiliário CEF",
  "input": {
    "pv": "240000",
    "rate": "0.008",
    "n": 360
  },
  "expected": {
    "pmt": "2084.56",
    "totalPaid": "750441.60",
    "totalInterest": "510441.60"
  }
}
```

### 3. Testes E2E

**Localização**: `tests/e2e/`

**Ferramenta**: Playwright

**Browsers**: Chromium, Firefox, WebKit

**Cobertura**:
- Fluxos de usuário completos
- Navegação entre páginas
- Validação de formulários
- Exibição de resultados

```typescript
// Exemplo de teste E2E
test('User can compare PRICE vs SAC', async ({ page }) => {
  await page.goto('/comparator');
  await page.fill('#principal', '100000');
  await page.fill('#rate', '2');
  await page.fill('#periods', '12');
  await page.click('button[type="submit"]');

  await expect(page.locator('[role="region"]')).toBeVisible();
});
```

### 4. Testes de Acessibilidade

**Localização**: `tests/a11y/`

**Ferramenta**: axe-core via Playwright

**Padrão**: WCAG 2.1 AA

**Validações**:
- Estrutura semântica (headings, landmarks)
- Labels em formulários
- Contraste de cores
- Navegação por teclado
- Compatibilidade com leitores de tela

```typescript
// Exemplo de teste A11y
test('Comparator has no accessibility violations', async ({ page }) => {
  await page.goto('/comparator');

  const results = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
    .analyze();

  expect(results.violations).toEqual([]);
});
```

### 5. Linting e TypeScript

**ESLint**: Regras de código + jsx-a11y (acessibilidade)

**TypeScript**: Strict mode, zero erros de tipo

**Prettier**: Formatação consistente

---

## 🔧 Dependências Externas Críticas

### Core (Engine)

| Biblioteca  | Versão  | Propósito                          |
|-------------|---------|------------------------------------|
| decimal.js  | ^10.4.3 | Precisão decimal (evita float)     |
| typescript  | ^5.6.3  | Tipagem estática                   |
| vitest      | ^2.0.0  | Framework de testes                |

### UI

| Biblioteca         | Versão    | Propósito                          |
|--------------------|-----------|------------------------------------|
| react              | ^18.3.1   | Framework UI                       |
| react-dom          | ^18.3.1   | Renderização DOM                   |
| vite               | ^5.4.2    | Build tool (dev + prod)            |
| tailwindcss        | ^3.4.1    | Estilização utilitária             |
| lucide-react       | ^0.263.1  | Ícones acessíveis                  |
| recharts           | ^2.12.7   | Gráficos (futuro)                  |

### Testes

| Biblioteca         | Versão    | Propósito                          |
|--------------------|-----------|------------------------------------|
| @playwright/test   | ^1.56.1   | Testes E2E                         |
| @axe-core/playwright | ^4.11.0 | Testes de acessibilidade           |
| vitest             | ^4.0.4    | Testes unitários                   |

---

## 🚀 Pipeline de CI/CD

**Plataforma**: GitHub Actions

**Arquivo**: `.github/workflows/ci.yml`

**Jobs**:

1. **lint-and-typecheck**
   - ESLint em todos os pacotes
   - TypeScript type check

2. **unit-tests**
   - Testes unitários do engine
   - Testes de componentes

3. **e2e-tests** (matrix: chromium, firefox, webkit)
   - Testes end-to-end em 3 browsers
   - Upload de artifacts em falhas

4. **a11y-tests**
   - Testes de acessibilidade (axe-core)
   - Geração de relatório HTML/JSON
   - Falha se houver violações críticas

5. **build**
   - Build de todos os pacotes
   - Upload de artifacts

6. **deploy** (apenas branch `main`)
   - Deploy para GitHub Pages (futuro)

**Fluxo**:

```
┌─────────────┐
│  git push   │
└──────┬──────┘
       ↓
┌─────────────────────────────────────────────┐
│          GitHub Actions Triggers             │
└──────┬──────────────────────────────────────┘
       ↓
┌──────────────────┐  ┌──────────────────┐
│  Lint + TypeCheck │  │   Unit Tests     │
└────────┬─────────┘  └────────┬─────────┘
         ↓                     ↓
         └──────────┬──────────┘
                    ↓
         ┌──────────────────────┐
         │     E2E Tests         │
         │  (3 browsers)         │
         └──────────┬────────────┘
                    ↓
         ┌──────────────────────┐
         │    A11y Tests         │
         │  (axe-core)           │
         └──────────┬────────────┘
                    ↓
         ┌──────────────────────┐
         │       Build           │
         └──────────┬────────────┘
                    ↓
         ┌──────────────────────┐
         │  Deploy (main only)   │
         └───────────────────────┘
```

---

## 📐 Convenções de Código

### TypeScript

- **Strict mode**: Habilitado
- **Nomenclatura**:
  - `PascalCase` para tipos, interfaces, classes
  - `camelCase` para funções, variáveis
  - `UPPER_SNAKE_CASE` para constantes
- **Imports**: Sempre usar imports nomeados (exceto default export de componentes React)

### React/JSX

- **Componentes**: Functional components com hooks
- **Props**: Sempre tipar com interface
- **Acessibilidade**: Seguir checklist do `docs/A11Y-GUIDE.md`

```tsx
// ✅ CORRETO
interface ButtonProps {
  onClick: () => void;
  children: React.ReactNode;
  variant?: 'primary' | 'secondary';
}

export function Button({ onClick, children, variant = 'primary' }: ButtonProps) {
  return (
    <button type="button" onClick={onClick} className={variant}>
      {children}
    </button>
  );
}
```

### CSS/Tailwind

- **Utilizar**: Classes utilitárias do Tailwind
- **Evitar**: CSS inline extenso
- **Contraste**: Sempre verificar contraste WCAG AA (4.5:1)

---

## 🔐 Governança (.fenix/)

O diretório `.fenix/` contém políticas, scripts e validadores para garantir qualidade contínua.

**Estrutura**:

```
.fenix/
├── policies/           # Políticas de desenvolvimento
│   ├── code-standards.md
│   ├── testing-policy.md
│   └── a11y-policy.md
├── scripts/            # Scripts de automação
│   ├── fenix-dry-run.sh
│   └── fenix-report.sh
├── checks/             # Validadores customizados
│   └── validators/
│       └── openapi_check.cjs
└── rag/                # Índices RAG para documentação
    └── sources/
        ├── finmath-docs.sot.json
        └── finmath-docs-md.sot.json
```

**Comandos**:

```bash
# Gerar plano de validação
pnpm fenix:plan

# Gerar relatório de KPIs
pnpm fenix:kpis

# Validar OpenAPI (quando houver API)
pnpm fenix:openapi
```

---

## 📊 Métricas de Qualidade

| Métrica                  | Alvo    | Atual   | Status |
|--------------------------|---------|---------|--------|
| Cobertura de Testes      | ≥ 80%   | 85%     | ✅     |
| Golden Files Passando    | 100%    | 100%    | ✅     |
| Testes E2E Passando      | 100%    | 100%    | ✅     |
| Violações A11y (critical)| 0       | 0       | ✅     |
| Erros TypeScript         | 0       | 0       | ✅     |
| Erros ESLint             | 0       | 0       | ✅     |

---

## 🗺️ Roadmap Técnico

### Sprint 4 (Atual)
- ✅ Infraestrutura A11y global
- ✅ Comparador PRICE vs SAC acessível
- ✅ Relatórios automatizados de A11y
- ✅ Documentação de arquitetura
- ✅ Guia de uso do engine

### Sprints Futuras
- ⏳ API REST completa
- ⏳ Persistência (banco de dados)
- ⏳ Autenticação e autorização
- ⏳ Dashboards analíticos
- ⏳ Exportação de relatórios (PDF, Excel)

---

## 🆘 Troubleshooting

### Build Falha

```bash
# Limpar e reinstalar dependências
rm -rf node_modules pnpm-lock.yaml
pnpm install

# Build limpo
pnpm build
```

### Testes E2E Falhando

```bash
# Reinstalar browsers do Playwright
npx playwright install --with-deps

# Rodar em modo debug
pnpm test:e2e:debug
```

### Violações de A11y

```bash
# Gerar relatório detalhado
pnpm test:a11y:report

# Verificar: reports/a11y/a11y-report.md
```

---

## 📚 Referências

- [Guia de Uso do Engine](./ENGINE-USAGE.md)
- [Guia de Acessibilidade](./A11Y-GUIDE.md)
- [Relatório de Validação Final](../VALIDATION-REPORT-FINAL.md)
- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)

---

**Versão da Arquitetura**: 1.0
**Última atualização**: Sprint 4
**Mantenedores**: PrinceOfEgypt1
