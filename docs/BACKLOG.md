# 📋 Backlog Completo - FinMath Project

**Versão:** 1.1
**Última atualização:** 17 de Outubro de 2025
**Baseado em:** Backlog Detalhado v1.1 + Boards por Sprint

---

## 🎯 Visão Geral

Este documento consolida todas as Sprints e Histórias de Usuário (HUs) do projeto FinMath.

**Status Geral:**

- ✅ Sprint 0: Kickoff (Completa)
- ✅ Sprint 1: Motor Básico (Completa)
- ✅ Sprint 2: Amortizações + CET Básico (Completa)
- ✅ Sprint 3: APIs + Exportações (Completa)
- 🚀 Sprint 4: IRR Robusto + CET Completo (Planejada)

---

## 📊 Sprint 0 - Kickoff

**Objetivo:** Infraestrutura e fundações do projeto

### Histórias:

- **H1**: Repositórios e CI/CD ✅
- **H2**: Biblioteca Decimal.js e políticas de arredondamento ✅
- **H3**: Observabilidade básica (logs, motorVersion) ✅

**Status:** ✅ 100% Concluída

---

## 📊 Sprint 1 - Motor Básico

**Objetivo:** Implementar cálculos fundamentais de matemática financeira

### Histórias:

- **H4**: Juros Compostos (FV/PV) ✅
  - Cálculo de valor futuro e presente
  - Casos extremos: i=0, n=1, PV alto
  - Golden Files: 3

- **H5**: Equivalência de Taxas + Taxa Real ✅
  - Conversão mensal ↔ anual
  - Taxa real com inflação
  - Golden Files: 3

- **H6**: Séries/Anuidades (postecipada/antecipada) ✅
  - Cálculo de anuidades
  - Inversão (resolver n ou i)
  - Golden Files: 4

- **H7**: Simuladores Base (UI) ⚠️ Parcial
  - Simuladores de Juros/Equivalência/Séries
  - Campos com máscaras
  - Design System aplicado
- **H8**: Explain Panel + Exportar PDF ⚠️ Parcial
  - Painel "Como calculamos?"
  - Exportação PDF com snapshot

- **H20**: Academy - 5 tópicos ⚠️ Pendente
  - Conteúdo educacional
  - Exercícios guiados
  - Deep-link para Lab

**Status:** ✅ Motor 100% | ⚠️ UI Parcial

---

## 📊 Sprint 2 - Amortizações + CET Básico

**Objetivo:** Sistemas de amortização e CET básico

### Histórias:

- **H9**: Price (PMT/cronograma/ajuste final) ✅
  - Cálculo de PMT com Decimal.js
  - Cronograma completo
  - Ajuste final: saldo_n ≤ R$ 0,01
  - API: POST /api/price
  - Golden Files: 5

- **H12**: CET Básico (tarifas t0) ✅
  - IRR mensal → CET anual
  - Apenas tarifas no t0 (sem IOF/seguros)
  - API: POST /api/cet/basic
  - Golden Files: 2

- **H21**: Snapshots (hash + motorVersion) ✅
  - Sistema de versionamento
  - Hash SHA-256 para integridade
  - API: GET /api/snapshot/:id

- **H22**: Validador de cronogramas ✅
  - Upload CSV e comparação
  - Diffs por coluna
  - API: POST /api/validate/schedule

**Status:** ✅ 100% Concluída

---

## 📊 Sprint 3 - APIs + Exportações

**Objetivo:** Completar APIs e exportações de relatórios

### Histórias:

- **H10**: Day Count (30/360, ACT/365, ACT/360) + Pro-rata ✅
  - Convenções de contagem de dias
  - Pró-rata de primeira parcela
  - Suporte em Price e SAC

- **H11**: SAC (cronograma) ✅
  - Amortização constante
  - PMT decrescente
  - Ajuste final
  - API: POST /api/sac
  - Golden Files: 5

- **H13**: Exportações CSV/PDF ✅
  - Cronogramas em CSV
  - Relatórios em PDF
  - APIs: /api/reports/price.csv|pdf, /api/reports/sac.csv|pdf

**Status:** ✅ 100% Concluída

---

## 📊 Sprint 4 - IRR Robusto + CET Completo (PLANEJADA)

**Objetivo:** Solver IRR robusto, CET completo com IOF/seguros, e sistema de perfis

### Histórias Planejadas:

#### **H14**: NPV (Valor Presente Líquido)

- **Épico:** E1 (Motor Core)
- **Objetivo:** Implementar cálculo de VPL
- **Critérios:**
  - NPV monotônico em taxa quando há troca de sinal
  - Casos sem troca de sinal retornam diagnóstico
  - Função utilitária com Decimal.js
- **DoD:**
  - Função `calculateNPV(cashflows, rate)` implementada
  - 10+ testes unitários
  - 3 Golden Files
  - JSDoc completo

#### **H15**: IRR (TIR) com Método de Brent + Diagnósticos

- **Épico:** E1 (Motor Core)
- **Objetivo:** Solver robusto para IRR
- **Referências:** ADR-002, Guia CET (§4)
- **Critérios:**
  - Método Brent como padrão
  - Fallback para bissecção
  - Detecção de múltiplas raízes
  - Erro relativo ≤ 0.01%
  - Logs de método e iterações
- **DoD:**
  - Solver Brent implementado
  - Diagnósticos: `multipleRoots`, `noSignChange`
  - 5 Golden Files (S4)
  - API: POST /api/npv-irr

#### **H16**: CET Completo (IOF diário + adicional + seguros)

- **Épico:** E2 (CET)
- **Objetivo:** CET com todos os componentes financeiros
- **Referências:** Guia CET — SoT (§5-7, §8-9)
- **Critérios:**
  - IOF adicional (0.38% sobre PV)
  - IOF diário (0.0082% por dia)
  - Seguros (prestamista, desemprego)
  - Breakdown detalhado por componente
  - |Δ CET| ≤ 0.03 p.p. a.a. (3 cenários)
- **DoD:**
  - Função `calculateCETFull` implementada
  - 2 Golden Files CET completo + 1 por perfil
  - API: POST /api/cet/full
  - Explain exportável

#### **H17**: Perfis de CET por Instituição (versionados)

- **Épico:** E2 (CET)
- **Objetivo:** Sistema de parametrização por banco
- **Referências:** Guia CET — SoT (§7), ADR-004
- **Critérios:**
  - Estrutura de perfis JSON
  - Versionamento com vigência
  - Parâmetros: daycount, IOF, tarifas, seguros, arredondamento
- **DoD:**
  - 3 perfis exemplo (Bradesco, Itaú, Santander)
  - API: GET /api/cet/profiles
  - API: GET /api/cet/profiles/{id}
  - Documento "Divergências de Perfis CET" v1.0

#### **H18**: Comparador de Cenários

- **Épico:** E5 (UX/Mercado)
- **Objetivo:** Comparar múltiplas ofertas
- **Referências:** Guia CET — SoT, Contratos API
- **Critérios:**
  - Comparar N ofertas (2-5)
  - Destacar menor CET e menor total pago
  - Justificativa (drivers de diferença)
- **DoD:**
  - API: POST /api/compare
  - UI React com tabela comparativa
  - Exportação PDF comparativo

#### **H19**: Exportação XLSX (com fórmulas)

- **Épico:** E3 (Exportações)
- **Objetivo:** Exportar cronogramas com fórmulas Excel
- **Referências:** ADR-007
- **Critérios:**
  - Células com fórmulas Excel (=B2\*C2)
  - Números idênticos ao CSV/PDF
  - Formatação brasileira (moeda, percentuais)
- **DoD:**
  - APIs: /api/reports/price.xlsx, /api/reports/sac.xlsx
  - Biblioteca: exceljs ou xlsx
  - Testes de integridade

#### **H23**: Casos de Mercado Gabaritados

- **Épico:** E5 (UX/Mercado)
- **Objetivo:** Validar motor com casos reais
- **Critérios:**
  - 3 casos de mercado anonimizados
  - Inputs reais + outputs esperados
  - |Δ CET| ≤ 0.03 p.p. vs simulador bancário
- **DoD:**
  - 3 Golden Files de casos reais
  - Explain exportável de cada caso
  - Documentação de origem (anonimizada)
  - Linkados no Academy

**Status:** 🚀 Planejada (Sprint 4)

---

## 📊 Histórias Futuras (Pós-Sprint 4)

### **H24**: Acessibilidade & E2E

- Teclado cobre todos os fluxos
- Contraste ≥ 4.5:1
- Testes E2E (Chrome/Firefox/Edge)
- Relatório axe sem erros críticos

### Outras (H25+):

- HP-12C Compatibility
- Sistema de turmas (Academy)
- Gamificação
- Múltiplas moedas

---

## 📈 Métricas e Tolerâncias

### Precisão:

- **Monetário:** erro ≤ R$ 0,01
- **Taxas:** ≤ 0.01 p.p.
- **IRR:** erro relativo ≤ 0.01%

### Performance:

- **P95 cálculo:** ≤ 150ms
- **Exportações PDF/XLSX:** ≤ 2s

### Qualidade:

- **Cobertura de testes:** ≥ 80%
- **Golden Files:** 100% verdes
- **Build:** sem erros

---

## 🔗 Referências

- **Guia CET — SoT:** Única fonte de verdade para metodologia CET
- **ADRs:** Decisões arquiteturais (ADR-001 a ADR-010)
- **Playbook de Testes:** Estratégia de QA e Golden Files
- **Contratos de API:** Especificações OpenAPI
- **Design System:** Tokens e componentes UI

---

## 📝 Convenções

### IDs de Histórias:

- **H1-H24:** Histórias de usuário
- **E1-E5:** Épicos
  - E1: Motor Core
  - E2: CET
  - E3: Exportações
  - E4: Auditoria
  - E5: UX/Mercado

### Status:

- ✅ Concluído
- ⚠️ Parcial
- 🔴 Pendente
- 🚀 Planejado

---

**Última atualização:** 17/10/2025
**Próxima revisão:** Ao início de cada Sprint
