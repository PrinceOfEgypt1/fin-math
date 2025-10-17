# 🧮 FinMath - Plataforma de Matemática Financeira

Ecossistema unificado para ensinar, experimentar e aplicar Matemática Financeira no contexto brasileiro.

[![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue)](https://www.typescriptlang.org/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green)](https://nodejs.org/)
[![Tests](https://img.shields.io/badge/tests-54%2F54-brightgreen)](https://github.com/PrinceOfEgypt1/fin-math)

## 🎯 Status do Projeto

### ✅ Sprint 0 - Kickoff (Completa)

- CI/CD configurado
- Decimal.js implementado (precisão monetária)

### ✅ Sprint 1 - Motor Básico (Completa)

- Juros compostos (FV/PV)
- Equivalência de taxas
- Séries/Anuidades
- 30 Golden Files validados

### ✅ Sprint 2 - Amortizações (Completa)

- Price (motor + API)
- CET Básico
- Snapshots
- Validador

### ✅ Sprint 3 - Completar APIs + Exportações (Completa) 🆕

- **H10**: Day Count (30/360, ACT/365, ACT/360) + Pro-rata
- **H11**: SAC API funcional - `POST /api/sac`
- **H13**: Exportações CSV/PDF para cronogramas

## 🚀 Quick Start

```bash
# Clonar repositório
git clone https://github.com/PrinceOfEgypt1/fin-math.git
cd fin-math

# Instalar dependências
pnpm install

# Rodar testes
pnpm -F @finmath/engine test

# Iniciar API
pnpm -F @finmath/api dev

# Acessar Swagger UI
open http://localhost:3001/api-docs
```

## 📦 Packages

### `@finmath/engine`

Motor de cálculos financeiros em TypeScript.

**Funcionalidades:**

- ✅ Juros compostos (FV/PV)
- ✅ Equivalência de taxas
- ✅ Séries/Anuidades (post/ant)
- ✅ Amortização Price
- ✅ Amortização SAC
- ✅ CET (Custo Efetivo Total)
- ✅ Day Count (30/360, ACT/365, ACT/360)
- ✅ Pro-rata de primeira parcela
- ✅ NPV/IRR

**Precisão:**

- Decimal.js (precisão monetária)
- Arredondamento Half-Up (2 casas)
- Tolerância: ≤ R$ 0,01

### `@finmath/api`

API REST com Fastify.

**Endpoints:**

- `POST /api/price` - Tabela Price
- `POST /api/sac` - Sistema SAC
- `POST /api/cet/basic` - CET básico
- `POST /api/reports/price.csv` - Exportar CSV Price
- `POST /api/reports/sac.csv` - Exportar CSV SAC
- `POST /api/reports/price.pdf` - Exportar PDF Price 🆕
- `POST /api/reports/sac.pdf` - Exportar PDF SAC 🆕
- `POST /api/validate/schedule` - Validar cronograma
- `GET /api/snapshot/:id` - Recuperar snapshot

## 🧪 Testes

```bash
# Testes unitários
pnpm -F @finmath/engine test

# Golden Files
pnpm -F @finmath/engine test:golden

# Testes de integração
pnpm -F @finmath/api test:integration

# Cobertura
pnpm -F @finmath/engine test:coverage
```

**Status:** 54/54 testes passando ✅

## 📚 Documentação

Documentação completa em `/docs`:

- **Backlog**: Histórias de usuário (H1-H24)
- **Boards**: Planejamento por sprint
- **ADRs**: Decisões arquiteturais
- **Guia CET**: Metodologia de cálculo (Fonte da Verdade)
- **Playbook QA**: Estratégia de testes e Golden Files
- **Contratos API**: Especificações OpenAPI

## 🏗️ Arquitetura

```
fin-math/
├── packages/
│   ├── engine/          # Motor de cálculos (TypeScript)
│   │   ├── src/
│   │   │   ├── amortization/  # Price, SAC
│   │   │   ├── day-count/     # Convenções de contagem
│   │   │   ├── modules/       # Juros, séries, CET
│   │   │   └── util/          # Decimal, arredondamento
│   │   └── test/
│   │       ├── unit/
│   │       ├── golden/        # Golden Files
│   │       └── integration/
│   │
│   └── api/             # API REST (Fastify)
│       ├── src/
│       │   ├── routes/        # Endpoints
│       │   ├── controllers/   # Lógica de negócio
│       │   ├── schemas/       # Validação Zod
│       │   └── services/      # Snapshots, validador
│       └── test/
│
├── docs/                # Documentação do projeto
└── tools/               # Scripts auxiliares
```

## 🛠️ Stack Tecnológico

- **Runtime**: Node.js 18+
- **Linguagem**: TypeScript 5.3
- **Monorepo**: pnpm workspaces
- **API**: Fastify 4.29
- **Testes**: Vitest 1.6
- **Validação**: Zod 3.23
- **Precisão**: Decimal.js 10.6
- **PDF**: pdfkit 0.17
- **CSV**: papaparse 5.5
- **Logs**: Pino 8.21
- **CI/CD**: GitHub Actions

## 🔄 Workflow de Desenvolvimento

```bash
# Criar branch da sprint
git checkout -b sprint-N

# Desenvolvimento local com commits frequentes
git add .
git commit -m "feat(HX): Descrição"

# Ao final da sprint: validação anti-regressão
pnpm -F @finmath/engine typecheck
pnpm -F @finmath/engine test
pnpm -F @finmath/engine build
pnpm -F @finmath/api build

# Merge e push
git checkout main
git merge sprint-N --no-ff
git push origin main
```

## 📊 Métricas de Qualidade

- **Cobertura**: ≥ 80%
- **Golden Files**: 30+ validados
- **Precisão monetária**: ≤ R$ 0,01
- **Precisão CET**: ≤ 0,01 p.p.
- **Performance**: P95 ≤ 150ms

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 📄 Licença

MIT

## 👥 Autores

FinMath Team

---

**Última atualização**: Sprint 3 - Outubro 2025
