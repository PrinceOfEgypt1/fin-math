# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

## [0.3.0] - 2025-10-17

### Sprint 3 - Completar APIs + Exportações

#### Added

- **SAC API**: Endpoint `POST /api/sac` funcional (200 OK)
  - Motor `generateSacSchedule` com amortização constante
  - Integração com snapshots
  - Cronograma completo com 12 parcelas
  - Commit: `a11a2a6`

- **Exportações CSV**: Implementação completa
  - `POST /api/reports/price.csv` - Exportar cronograma Price
  - `POST /api/reports/sac.csv` - Exportar cronograma SAC
  - Formato padrão: `#;PMT;Juros;Amortizacao;Saldo;Data`
  - Separador: ponto-e-vírgula (`;`)
  - Commit: `30cb764`

- **Exportações PDF**: Implementação completa
  - `POST /api/reports/price.pdf` - Exportar PDF Price
  - `POST /api/reports/sac.pdf` - Exportar PDF SAC
  - Biblioteca: pdfkit ^0.17.2
  - Tabela formatada com cabeçalho e rodapé
  - Commit: `40a7b59`

#### Fixed

- **TypeScript**: Corrigido erro `TS2532` em `reports.routes.ts`
  - Adicionado tipo explícito para `colWidths`
  - Fallback seguro para larguras de colunas
  - Commit: `a1bb7cf`

#### Changed

- **API Version**: Atualizada para 0.3.0 (Sprint 3)
- **Dependencies**:
  - Adicionado pdfkit ^0.17.2
  - Adicionado @types/pdfkit ^0.17.3
  - Commit: `666ce88`

### Quality Metrics

- ✅ Testes: 54/54 passando (100%)
- ✅ Cobertura: ≥ 80%
- ✅ Build: Engine + API sem erros
- ✅ TypeCheck: Sem erros TypeScript

---

## [0.2.0] - 2025-10-15

### Sprint 2 - Amortizações + CET Básico

#### Added

- **Price API**: Endpoint `POST /api/price`
- **CET Básico**: Endpoint `POST /api/cet/basic`
- **Snapshots**: Sistema de versionamento com hash
- **Validador**: Endpoint `POST /api/validate/schedule`

#### Changed

- Motor de cálculo consolidado
- Integração com decimal.js

---

## [0.1.0] - 2025-10-13

### Sprint 1 - Motor Básico

#### Added

- **Day Count**: Convenções 30/360, ACT/365, ACT/360
- **Pro-rata**: Cálculo de primeira parcela
- **Juros Compostos**: FV/PV
- **Equivalência de Taxas**: Mensal/Anual
- **Séries/Anuidades**: Post/Ant
- **Golden Files**: 30 arquivos de validação

#### Changed

- Estrutura de monorepo com pnpm
- CI/CD com GitHub Actions

---

## [0.0.1] - 2025-10-11

### Sprint 0 - Kickoff

#### Added

- Estrutura inicial do projeto
- Configuração TypeScript
- Decimal.js para precisão monetária
- Vitest para testes
- ESLint + Prettier

---

## Notas de Versão

### Convenções de Commit

- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Apenas documentação
- `chore`: Manutenção/config
- `test`: Adicionar testes

### Tipos de Mudança

- `Added`: Nova funcionalidade
- `Changed`: Mudança em funcionalidade existente
- `Deprecated`: Funcionalidade obsoleta
- `Removed`: Funcionalidade removida
- `Fixed`: Correção de bug
- `Security`: Vulnerabilidade corrigida
