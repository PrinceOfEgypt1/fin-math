# Changelog - FinMath

Todas as mudanças notáveis do projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

---

## [0.5.0] - 2025-10-19

### ✨ Adicionado

- **HU-24:** Página de comparação PRICE vs SAC
  - Interface lado a lado para comparar sistemas
  - Cálculo automático de economia
  - Destaque visual da diferença de juros
  - Navegação via menu "Comparar"
  - Responsivo (desktop e mobile)

### 🔧 Alterado

- Header: Adicionado botão "Comparar" com ícone GitCompare
- App.tsx: Incluída rota `/#comparison`
- Navegação: Hash routing para todas as páginas

### 📚 Documentado

- Criada documentação completa da HU-24
- Adicionados casos de teste E2E
- Atualizado README com nova funcionalidade

---

## [0.4.0] - 2025-10-19

### ✨ Adicionado

- **HU-10:** Simulador SAC funcional
  - Cálculo de amortização constante
  - Parcelas decrescentes
  - Primeira vs última parcela
  - Total de juros otimizado

### 🔧 Alterado

- App.tsx: Incluída rota `/#sac`
- Header: Adicionado link para SAC

---

## [0.3.0] - 2025-10-19

### ✨ Adicionado

- **HU-9:** Simulador PRICE funcional
  - Formulário interativo
  - Cálculo de PMT com Decimal.js
  - Exibição de total pago e juros
  - Animações com Framer Motion

### 🔧 Alterado

- Criada estrutura de navegação hash-based
- Header: Adicionado sistema de navegação

---

## [0.2.0] - 2025-10-19

### ✨ Adicionado

- Design System completo
  - Tailwind CSS configurado
  - Paleta de cores (primary/secondary)
  - Componentes glass/glassmorphism
  - Tipografia (Inter + JetBrains Mono)
- Dashboard landing page
- Header responsivo
- Container component

---

## [0.1.0] - 2025-10-18

### ✨ Adicionado

- Estrutura inicial do monorepo
- Pacote @finmath/engine (motor de cálculos)
- Pacote @finmath/ui (interface React)
- Configuração TypeScript
- Configuração pnpm workspaces

---

## Formato das Versões

- **MAJOR:** Mudanças incompatíveis com versões anteriores
- **MINOR:** Novas funcionalidades compatíveis
- **PATCH:** Correções de bugs compatíveis

---

**Mantido por:** Moses & Claude  
**Última atualização:** 2025-10-19
