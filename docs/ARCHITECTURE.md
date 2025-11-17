# Arquitetura do FinMath

## 📋 Visão Geral

O FinMath é um **ecossistema modular de matemática financeira** para o mercado brasileiro, composto por:

1. **Engine de cálculo** (`@finmath/engine`) - Biblioteca de cálculos com precisão decimal
2. **Interface web** (`@finmath/ui`) - Interface React acessível para simuladores
3. **API REST** (`@finmath/api`) - Backend para integração (futuro)
4. **Governança** (`.fenix/`) - Políticas, scripts e validações de qualidade

## 🏗️ Estrutura de Pacotes

```
fin-math/
├── packages/                      # Monorepo com pnpm workspaces
│   ├── engine/                    # Motor de cálculos financeiros
│   │   ├── src/                   # Código TypeScript
│   │   │   ├── modules/           # API pública (PRICE, SAC, CET, NPV, IRR)
│   │   │   ├── amortization/      # Sistemas de amortização
│   │   │   ├── cet/               # Cálculo de CET completo
│   │   │   ├── irr/               # Taxa Interna de Retorno (Método de Brent)
│   │   │   └── day-count/         # Convenções de contagem de dias
│   │   ├── test/                  # Testes unitários (Vitest)
│   │   └── golden/                # 30 Golden Files (validação real)
│   │
│   ├── ui/                        # Interface React
│   │   ├── src/
│   │   │   ├── components/        # Componentes React
│   │   │   │   ├── base/          # Componentes base acessíveis
│   │   │   │   └── Layout.tsx     # Layout principal
│   │   │   ├── pages/             # Páginas (Home, Comparador, etc.)
│   │   │   ├── utils/             # Utilitários (cálculos, formatação)
│   │   │   └── styles/            # CSS global e Tailwind
│   │   ├── index.html             # Entry point HTML
│   │   └── vite.config.ts         # Configuração Vite
│   │
│   └── api/                       # API REST (futuro)
│
├── tests/                         # Testes E2E e A11y (Playwright)
│   ├── e2e/                       # Testes end-to-end
│   ├── a11y/                      # Testes de acessibilidade
│   ├── fixtures/                  # Fixtures para testes
│   └── utils/                     # Utilitários de teste (gerador A11y)
│
├── .fenix/                        # Governança e qualidade
│   ├── policies/                  # Políticas de desenvolvimento
│   ├── scripts/                   # Scripts de validação (fenix-dry-run, etc.)
│   ├── checks/                    # Validadores (OpenAPI, etc.)
│   └── rag/                       # Índices RAG para documentação
│
├── docs/                          # Documentação
│   ├── ARCHITECTURE.md            # Este arquivo
│   ├── ENGINE-USAGE.md            # Guia de uso do engine
│   ├── A11Y-GUIDE.md              # Guia de acessibilidade
│   ├── A11Y-TESTING.md            # Testes de acessibilidade
│   └── a11y/                      # Relatórios A11y gerados
│
├── .github/workflows/             # CI/CD (GitHub Actions)
│   ├── ci.yml                     # Pipeline principal
│   ├── fenix-ci-ext.yml           # Validações Fênix estendidas
│   └── fenix-guard.yml            # Guardian de qualidade
│
├── pnpm-workspace.yaml            # Configuração do monorepo
├── tsconfig.base.json             # TypeScript base config
├── eslint.config.js               # ESLint raiz
└── playwright.config.ts           # Configuração Playwright
```

## 📦 Pacotes Principais

### 1. @finmath/engine

**Responsabilidade:** Cálculos financeiros com precisão decimal

**Características:**

- ✅ Precisão decimal usando `decimal.js`
- ✅ Sistemas de amortização PRICE e SAC
- ✅ CET (Custo Efetivo Total) completo (IOF + seguros + tarifas)
- ✅ NPV (Valor Presente Líquido)
- ✅ IRR (Taxa Interna de Retorno) com Método de Brent
- ✅ Equivalência de taxas
- ✅ TypeScript nativo com types completos

**Dependências críticas:**

- `decimal.js` (^10.4.3) - Precisão decimal

**API Pública:**

```typescript
// Módulos exportados
export {
  calculatePMT,
  generatePriceSchedule,
  generateSacSchedule,
  calculateCET,
  calculateNPV,
  calculateIRR,
  monthlyToAnnual,
  annualToMonthly,
};
```

**Validação:**

- 30 Golden Files com cenários reais
- Testes unitários (Vitest)
- Cobertura de 85%+

**Versão:** 1.0.0 (privado no workspace, publicável como npm package)

### 2. @finmath/ui

**Responsabilidade:** Interface web acessível para simuladores

**Características:**

- ✅ React 18 com TypeScript
- ✅ Vite para build e dev server
- ✅ Tailwind CSS para estilização
- ✅ WCAG 2.1 AA (acessibilidade)
- ✅ React Router para navegação
- ✅ Componentes base acessíveis

**Dependências críticas:**

- `react` (^18.3.1) - Framework UI
- `react-router-dom` (^6.22.0) - Roteamento
- `decimal.js` (^10.4.3) - Cálculos precisos
- `tailwindcss` (^3.4.1) - Estilização
- `lucide-react` (^0.263.1) - Ícones
- `recharts` (^2.12.7) - Gráficos (futuro)

**Estrutura de Componentes:**

```
src/
├── components/
│   ├── base/
│   │   ├── Button.tsx          # Botão acessível (WCAG 2.1 AA)
│   │   ├── Input.tsx           # Campo de entrada com label associado
│   │   ├── Card.tsx            # Card container
│   │   └── index.ts            # Exports
│   └── Layout.tsx              # Layout com navegação acessível
│
├── pages/
│   ├── Home.tsx                # Página inicial
│   ├── Comparador.tsx          # Comparador PRICE vs SAC
│   ├── Calculadora.tsx         # Calculadora (placeholder)
│   └── index.ts                # Exports
│
├── utils/
│   └── calculations.ts         # Wrapper do engine com formatação
│
└── styles/
    └── globals.css             # Estilos globais + Tailwind
```

**Rotas:**

| Rota           | Página      | Descrição                   |
| -------------- | ----------- | --------------------------- |
| `/`            | Home        | Página inicial com features |
| `/comparador`  | Comparador  | Comparação PRICE vs SAC     |
| `/calculadora` | Calculadora | Calculadora (placeholder)   |

**Versão:** 1.0.0 (privado no workspace)

### 3. @finmath/api (Futuro)

**Responsabilidade:** Backend REST para integração

**Status:** Planejado para Sprint 5+

**Características planejadas:**

- Express.js com TypeScript
- Endpoints REST para cálculos
- Validação de entrada com Zod
- Documentação OpenAPI 3.0
- Rate limiting e autenticação

## 🔄 Fluxo de Dados

### Simulação PRICE vs SAC (Exemplo)

```
┌─────────────┐
│   Usuário   │
└──────┬──────┘
       │ 1. Preenche formulário
       ↓
┌─────────────────────────────────┐
│  Comparador.tsx (React)         │
│  - Coleta inputs (valor, taxa,  │
│    prazo)                        │
│  - Valida entrada               │
└──────┬──────────────────────────┘
       │ 2. Chama funções de cálculo
       ↓
┌─────────────────────────────────┐
│  calculations.ts (Utils)        │
│  - generatePriceSchedule()      │
│  - generateSacSchedule()        │
└──────┬──────────────────────────┘
       │ 3. Usa engine
       ↓
┌─────────────────────────────────┐
│  @finmath/engine                │
│  - Calcula com Decimal.js       │
│  - Retorna PriceResult/SacResult│
└──────┬──────────────────────────┘
       │ 4. Retorna resultados
       ↓
┌─────────────────────────────────┐
│  Comparador.tsx                 │
│  - Formata valores              │
│  - Renderiza UI acessível       │
│  - Anuncia para leitores de tela│
└──────┬──────────────────────────┘
       │ 5. Exibe resultados
       ↓
┌─────────────┐
│   Usuário   │
│  (vê e ouve │
│  resultados)│
└─────────────┘
```

### Processamento de CET

```
Input: pv, pmt, n, fees, iof, insurance
   ↓
calculateCET() [@finmath/engine]
   ↓
1. Calcula VPL do fluxo de saída (parcelas)
2. Ajusta PV com tarifas t0
3. Adiciona IOF (diário + fixo)
4. Adiciona seguros por período
5. Resolve equação VPL = 0 usando método iterativo
   ↓
Output: CET mensal (Decimal)
```

## 🧪 Estratégia de Testes

### Pirâmide de Testes

```
         ╱────────╲
        ╱   E2E    ╲         - Playwright (testes/e2e/)
       ╱────────────╲        - Testes de fluxo completo
      ╱  Integração  ╲       - Testes de API (futuro)
     ╱────────────────╲
    ╱   Unitários      ╲     - Vitest (packages/*/test/)
   ╱────────────────────╲    - Golden Files (30 cenários)
  ╱  Linting & Types     ╲   - ESLint + TypeScript
 ╱________________________╲
```

### Tipos de Testes

| Tipo             | Ferramenta       | Localização               | Comando            |
| ---------------- | ---------------- | ------------------------- | ------------------ |
| **Unitários**    | Vitest           | `packages/*/test/`        | `pnpm test`        |
| **Golden Files** | Vitest           | `packages/engine/golden/` | `pnpm test:golden` |
| **E2E**          | Playwright       | `tests/e2e/`              | `pnpm test:e2e`    |
| **A11y**         | Playwright + axe | `tests/a11y/`             | `pnpm test:a11y`   |
| **Linting**      | ESLint           | Todos os pacotes          | `pnpm lint`        |
| **Type Check**   | TypeScript       | Todos os pacotes          | `pnpm typecheck`   |

### Golden Files (Validação Real)

Os **30 Golden Files** são cenários reais do mercado financeiro que validam:

- Financiamentos imobiliários (PRICE e SAC)
- Empréstimos pessoais
- CET com IOF e seguros
- NPV/IRR de projetos

Exemplo de estrutura:

```json
{
  "scenario": "Financiamento Imobiliário - PRICE",
  "input": {
    "pv": "200000",
    "rate": "0.008",
    "n": 360
  },
  "expected": {
    "pmt": "1670.48",
    "totalPago": "601372.80",
    "totalJuros": "401372.80"
  }
}
```

## 🔐 Governança (.fenix/)

O diretório `.fenix/` contém infraestrutura de governança e qualidade:

### Políticas

- **SOLID.md** - Princípios de design
- **DRY.md** - Don't Repeat Yourself
- **SEPARATION.md** - Separação de responsabilidades
- **VALIDATION.md** - Validação de entrada

### Scripts

- `fenix-dry-run.sh` - Valida mudanças antes de commit
- `fenix-report.sh` - Gera relatórios de KPIs
- `fenix-guard.sh` - Guardian de qualidade

### Checks

- `validators/openapi_check.cjs` - Valida spec OpenAPI

### RAG (Retrieval-Augmented Generation)

Índices de documentação para IA:

- `sources/finmath-docs-*.json` - Índices de documentação
- `embeddings/` - Embeddings para busca semântica

## 🚀 CI/CD Pipeline

### GitHub Actions Workflows

```yaml
# .github/workflows/ci.yml

Jobs:
  1. lint-and-typecheck
     - ESLint
     - TypeScript type check

  2. unit-tests
     - Testes unitários
     - Golden Files

  3. e2e-tests (matrix: chromium, firefox, webkit)
     - Testes E2E em 3 browsers

  4. a11y-tests
     - Testes de acessibilidade
     - Gera relatórios
     - FALHA se violations críticas/sérias

  5. build
     - Build de todos os pacotes
     - Upload de artifacts

  6. deploy (somente main)
     - Deploy para GitHub Pages
```

### Política de Merge

Para merge em `main`:

- ✅ Todos os testes passando
- ✅ Lint e type check limpos
- ✅ Sem violations A11y críticas/sérias
- ✅ Build bem-sucedido
- ✅ Revisão de código (se PR)

## 🛠️ Stack Tecnológico

### Core

| Camada              | Tecnologia | Versão  | Justificativa                  |
| ------------------- | ---------- | ------- | ------------------------------ |
| **Linguagem**       | TypeScript | 5.6.3   | Type safety, melhor DX         |
| **Runtime**         | Node.js    | 20+     | LTS estável                    |
| **Package Manager** | pnpm       | 10.19.0 | Monorepo eficiente, workspaces |

### Engine (@finmath/engine)

| Dependência  | Versão | Uso              |
| ------------ | ------ | ---------------- |
| `decimal.js` | 10.4.3 | Precisão decimal |
| `vitest`     | 2.0.0  | Testes unitários |

### UI (@finmath/ui)

| Dependência        | Versão  | Uso          |
| ------------------ | ------- | ------------ |
| `react`            | 18.3.1  | Framework UI |
| `react-router-dom` | 6.22.0  | Roteamento   |
| `decimal.js`       | 10.4.3  | Cálculos     |
| `tailwindcss`      | 3.4.1   | Estilização  |
| `lucide-react`     | 0.263.1 | Ícones       |
| `vite`             | 5.4.2   | Build tool   |

### Testes

| Ferramenta               | Versão | Uso              |
| ------------------------ | ------ | ---------------- |
| `playwright`             | 1.56.1 | E2E e A11y       |
| `@axe-core/playwright`   | 4.11.0 | Auditoria A11y   |
| `vitest`                 | 2.0.0  | Testes unitários |
| `eslint`                 | 9.9.0  | Linting          |
| `eslint-plugin-jsx-a11y` | 6.10.2 | Linting A11y     |

## 📊 Decisões de Arquitetura

### 1. Por que Decimal.js?

**Problema:** JavaScript usa ponto flutuante IEEE 754, causando erros:

```javascript
0.1 + 0.2; // 0.30000000000004
```

**Solução:** Decimal.js garante precisão decimal:

```javascript
new Decimal("0.1").plus("0.2").toString(); // "0.3"
```

**Trade-off:** Performance ligeiramente menor, mas precisão é crítica em finanças.

### 2. Por que Monorepo com pnpm?

**Vantagens:**

- Compartilhamento de código entre pacotes
- Versionamento consistente
- CI/CD unificado
- pnpm é rápido e eficiente (hard links)

**Alternativas consideradas:**

- Multi-repo (rejected: overhead de sincronização)
- npm workspaces (rejected: pnpm é mais rápido)
- Lerna (rejected: pnpm workspaces nativo é suficiente)

### 3. Por que React Router em SPA?

**Vantagens:**

- Navegação sem reload (melhor UX)
- State preservado entre rotas
- SEO pode ser resolvido com SSR futuro

**Alternativas consideradas:**

- Next.js (rejected: overhead desnecessário para MVP)
- Multi-page app (rejected: pior UX)

### 4. Por que Vite em vez de CRA?

**Vantagens:**

- Build extremamente rápido (esbuild)
- HMR instantâneo
- Configuração simples

**Alternativas consideradas:**

- Create React App (deprecated)
- Webpack manual (rejected: complexidade)

### 5. Por que Tailwind CSS?

**Vantagens:**

- Utility-first permite prototipagem rápida
- PurgeCSS remove CSS não usado
- Consistência de design
- Boa integração com componentes React

**Alternativas consideradas:**

- CSS Modules (rejected: verbosidade)
- Styled Components (rejected: runtime overhead)
- Plain CSS (rejected: difícil manter consistência)

## 🔮 Roadmap de Arquitetura

### Sprint 5-6 (Curto Prazo)

- [ ] Backend REST (`@finmath/api`)
  - Express.js + TypeScript
  - Endpoints: `/calculate/price`, `/calculate/sac`, `/calculate/cet`
  - OpenAPI 3.0 documentation
- [ ] Autenticação e rate limiting
- [ ] Cache de resultados (Redis)

### Sprint 7-8 (Médio Prazo)

- [ ] Persistência de simulações (PostgreSQL)
- [ ] Histórico de cálculos por usuário
- [ ] Export de cronogramas (PDF, Excel)
- [ ] SSR com Next.js para SEO

### Sprint 9+ (Longo Prazo)

- [ ] App mobile (React Native)
- [ ] Integração com bancos (Open Finance)
- [ ] Machine Learning para recomendações
- [ ] Modo offline (PWA)

## 📚 Recursos e Referências

### Documentação Interna

- [Guia de Uso do Engine](./ENGINE-USAGE.md)
- [Guia de Acessibilidade](./A11Y-GUIDE.md)
- [Guia de Testes A11y](./A11Y-TESTING.md)

### Repositório

- **GitHub:** [github.com/PrinceOfEgypt1/fin-math](https://github.com/PrinceOfEgypt1/fin-math)
- **Issues:** [github.com/PrinceOfEgypt1/fin-math/issues](https://github.com/PrinceOfEgypt1/fin-math/issues)

### Padrões e Guidelines

- [WCAG 2.1](https://www.w3.org/WAI/WCAG21/quickref/)
- [React Best Practices](https://react.dev/learn)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

## 🤝 Contribuindo

Para contribuir com mudanças arquiteturais:

1. Abra uma issue descrevendo a proposta
2. Documente trade-offs e alternativas
3. Obtenha aprovação do time
4. Implemente com testes
5. Atualize este documento

## 📄 Licença

MIT - Veja [LICENSE](../LICENSE) para detalhes.

---

**Versão da Arquitetura:** 1.0 (Sprint 4)
**Última atualização:** Sprint 4
**Responsável:** Equipe FinMath
