# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [0.4.0] - 2025-10-18

### Added

- ✨ **IRR com Método de Brent** (H15)
  - Implementação robusta do Método de Brent para cálculo de TIR
  - Fallback para bissecção em casos extremos
  - Precisão de ±0.01% em taxa
- ✨ **CET Completo** (H16)
  - Suporte a IOF (diário + adicional)
  - Suporte a seguros (fixo, % PV, % saldo)
  - Breakdown detalhado de custos
  - Precisão de ±0.01 p.p. em taxa
- ✨ **NPV (Valor Presente Líquido)** (H14)
  - Cálculo preciso com decimal.js
  - Suporte a fluxos irregulares
- ✨ **Perfis CET por Instituição** (H17)
  - Versionamento de perfis
  - Suporte a múltiplas instituições financeiras
- ✨ **Evidências de Mercado** (H23)
  - 3 cenários reais validados
  - Golden Files com casos de mercado
  - Documentação de divergências entre instituições

- 📚 **Documentação API Completa**
  - TypeDoc com navegação HTML
  - 30+ funções documentadas
  - 3 exemplos práticos (Price, CET, IRR)
  - JSDoc detalhado em todas as funções públicas

### Changed

- 🔧 **Migração de Bissecção para Brent**
  - Método de Brent é mais robusto e rápido
  - Convergência garantida em mais casos
- 📈 **Precisão de CET melhorada**
  - Erro máximo reduzido para ±0.01 p.p.
  - Arredondamento consistente Half-Up

### Fixed

- 🐛 **Ajuste final em cronogramas**
  - Saldo final sempre ≤ 0.01
  - Correção de acúmulo de erros de arredondamento
- 🐛 **Arredondamento Half-Up**
  - Implementação consistente em todos os módulos
  - Alinhamento com práticas de mercado

### Tests

- 🧪 **30 Golden Files validados**
  - PRICE: 5 arquivos
  - SAC: 5 arquivos
  - SERIES: 4 arquivos
  - NPVIRR: 5 arquivos
  - CET: 5 arquivos
  - EQ: 3 arquivos
  - JC: 3 arquivos

## [0.2.0] - 2025-10-15

### Added

- ✨ **Sistema Price completo** (H9)
  - Cálculo de PMT
  - Geração de cronograma
  - Ajuste final de centavos
- ✨ **Sistema SAC completo** (H11)
  - Amortização constante
  - Geração de cronograma
  - Ajuste final
- ✨ **CET Básico** (H12)
  - Cálculo com tarifas t0
  - Método de IRR simplificado
- ✨ **Day Count** (H10)
  - Convenções 30/360 e ACT/365
  - Pró-rata para primeira parcela
  - Year fraction preciso

- ✨ **Snapshots e Validador** (H21, H22)
  - Sistema de snapshots com hash SHA-256
  - Validador de cronogramas
  - motorVersion tracking

### Changed

- 🔧 Estrutura de módulos reorganizada
- 📊 Golden Files padronizados

## [0.1.0] - 2025-10-12

### Added

- ✨ **Juros Compostos** (H4)
  - FV (Valor Futuro)
  - PV (Valor Presente)
- ✨ **Equivalência de Taxas** (H5)
  - Conversão mensal ↔ anual
  - Taxa real (ajuste de inflação)
- ✨ **Séries Uniformes** (H6)
  - PMT postecipada
  - PMT antecipada
  - Inversão (PV a partir de PMT)

- 🏗️ **Infraestrutura Inicial**
  - Monorepo com pnpm
  - TypeScript + ESLint
  - Vitest para testes
  - GitHub Actions CI/CD

- 🧪 **Sistema de Testes**
  - Testes unitários
  - Testes de propriedade (fast-check)
  - Golden Files
  - 80%+ cobertura

### Dependencies

- decimal.js ^10.4.3 (precisão arbitrária)
- date-fns ^4.1.0 (manipulação de datas)
- zod ^3.23.8 (validação de schemas)

---

## Tipos de Mudanças

- `Added` para novas funcionalidades
- `Changed` para mudanças em funcionalidades existentes
- `Deprecated` para funcionalidades obsoletas
- `Removed` para funcionalidades removidas
- `Fixed` para correções de bugs
- `Security` para correções de vulnerabilidades
- `Tests` para adições/mudanças em testes
- `Docs` para documentação

## Links

- [Unreleased]: https://github.com/PrinceOfEgypt1/fin-math/compare/v0.4.0...HEAD
- [0.4.0]: https://github.com/PrinceOfEgypt1/fin-math/compare/v0.2.0...v0.4.0
- [0.2.0]: https://github.com/PrinceOfEgypt1/fin-math/compare/v0.1.0...v0.2.0
- [0.1.0]: https://github.com/PrinceOfEgypt1/fin-math/releases/tag/v0.1.0
