# Dependências entre HUs e Replanejamento Realista

**Data:** 2025-10-17  
**Versão:** 1.0  
**Autor:** Equipe FinMath

---

## 🎯 PRINCÍPIOS

### **Regra #1: HUs Dependentes → Mesma Sprint ou Sequenciais**

Se HU-B depende de HU-A, então:

- ✅ **Opção A:** Ambas na mesma sprint
- ✅ **Opção B:** HU-A na Sprint N, HU-B na Sprint N+1
- ❌ **ERRADO:** HU-B antes de HU-A

### **Regra #2: Capacidade Observada**

- **5-6 HUs por sprint** (baseado em Sprints 1 e 2)
- **2-3 semanas** por sprint
- **1 dev full-stack + 1 especialista mat.fin.**

### **Regra #3: Foco por Sprint**

- **Sprint de Engine:** Apenas motor/cálculos
- **Sprint de API:** Apenas endpoints REST
- **Sprint de UI:** Apenas interface/frontend
- **Sprint Mista:** Somente se houver dependência crítica

---

## 📊 MAPA DE DEPENDÊNCIAS

### **Legenda:**

- `→` Depende de (bloqueante)
- `⇄` Deve estar junto (integração)
- `◇` Opcional (não bloqueia)

###

**Grupo 1: Fundamentos (Infraestrutura)**

```
H1 (CI/CD)
  → TODAS as outras HUs
  Tipo: Infraestrutura base
  Prioridade: MÁXIMA

H2 (Decimal.js)
  → H4, H5, H6, H9, H11, H12 (todos os cálculos)
  Tipo: Biblioteca base
  Prioridade: MÁXIMA
```

### **Grupo 2: Motor de Cálculos**

```
H4 (Juros) → H5 (Equivalência) → H6 (Séries)
  Tipo: Sequencial (conceitos se constroem)

H9 (Price - Motor)
  → H2 (Decimal)
  → H10 (Day Count) ◇ opcional
  Tipo: Amortização

H11 (SAC - Motor)
  → H2 (Decimal)
  → H10 (Day Count) ◇ opcional
  Tipo: Amortização

H10 (Day Count)
  → H2 (Decimal)
  ◇ H9, H11 (opcional, mas recomendado)
  Tipo: Utilitário
```

### **Grupo 3: CET e IRR**

```
H12 (CET Básico)
  → H9 (Price) - precisa do cronograma
  → H11 (SAC) - precisa do cronograma
  → H15 (IRR) - método de cálculo ◇ ou usar simplificado
  Tipo: Cálculo avançado

H15 (IRR com Brent)
  → H2 (Decimal)
  ◇ H12 (pode usar IRR simplificado antes)
  Tipo: Solver numérico

H16 (CET Completo)
  → H12 (CET Básico)
  → H15 (IRR robusto)
  Tipo: Evolução de H12

H17 (Perfis CET)
  → H16 (CET Completo)
  Tipo: Parametrização
```

### **Grupo 4: APIs (depende do motor)**

```
H9 (Price - API)
  → H9 (Price - Motor) BLOQUEANTE
  ⇄ H21 (Snapshots) - integração obrigatória
  Tipo: Endpoint REST

H11 (SAC - API)
  → H11 (SAC - Motor) BLOQUEANTE
  ⇄ H21 (Snapshots) - integração obrigatória
  Tipo: Endpoint REST

H12 (CET - API)
  → H12 (CET - Motor) BLOQUEANTE
  ⇄ H21 (Snapshots) - integração obrigatória
  Tipo: Endpoint REST
```

### **Grupo 5: Auditoria e Validação**

```
H21 (Snapshots)
  → H1 (CI/CD)
  → H2 (Decimal) - para hash
  ⇄ H9, H11, H12 (APIs) - integração
  Tipo: Infraestrutura de auditoria

H22 (Validador)
  → H21 (Snapshots) ◇ opcional
  → H9, H11 (para validar cronogramas)
  Tipo: Ferramenta de QA

H3 (Observabilidade)
  → H1 (CI/CD)
  ⇄ Todas as HUs (logs, correlation-id)
  Tipo: Cross-cutting concern
```

### **Grupo 6: Exportações**

```
H13 (CSV/PDF)
  → H9 (Price)
  → H11 (SAC)
  ◇ H8 (Explain Panel) - opcional
  Tipo: Exportação

H19 (XLSX)
  → H13 (CSV/PDF) - similar
  → H9, H11 (cronogramas)
  Tipo: Exportação avançada
```

### **Grupo 7: UI/Frontend**

```
H7 (Simuladores)
  → H4, H5, H6 (Motor funcionando)
  ◇ APIs (pode usar motor direto inicialmente)
  Tipo: Interface

H8 (Explain Panel)
  → H7 (Simuladores) - precisa da UI base
  → H13 (PDF) ◇ ou pode ser independente
  Tipo: Visualização

H20 (Academy)
  → H7 (Simuladores) - deep-link
  Tipo: Conteúdo educacional
```

### **Grupo 8: Avançados**

```
H14 (NPV)
  → H2 (Decimal)
  → H15 (IRR) ◇ relacionado
  Tipo: Cálculo financeiro

H18 (Comparador)
  → H12 ou H16 (CET)
  → H9, H11 (cronogramas)
  Tipo: Análise comparativa

H23 (Casos Gabaritados)
  → H9, H11, H12 (funcionalidades completas)
  → H21 (Snapshots) - Golden Files
  Tipo: QA avançado

H24 (Acessibilidade + E2E)
  → H7 (Simuladores)
  → Todas as APIs
  Tipo: Qualidade end-to-end
```

---

## 🗺️ GRAFO DE DEPENDÊNCIAS

```
Sprint 0 (Base):
  H1 (CI/CD) ──────────────────────┐
  H2 (Decimal) ────────────────────┼──┐
                                   ↓  ↓
Sprint 1 (Motor Básico):           ↓  ↓
  H3 (Observ.) ←───────────────────┘  │
  H4 (Juros) ←────────────────────────┤
  H5 (Equiv.) ←───────────────────────┤
  H6 (Séries) ←───────────────────────┘
                                   ↓
Sprint 2 (Amortizações + Auditoria):
  H9 (Price-Motor) ←───────────────┐
  H10 (DayCount) ←─────────────────┤
  H11 (SAC-Motor) ←────────────────┤
  H12 (CET-Motor) ←────────────────┤
  H21 (Snapshots) ←────────────────┘
                                   ↓
Sprint 3 (APIs + Validação):
  H9 (Price-API) ←─────────────────┐
  H11 (SAC-API) ←──────────────────┤
  H12 (CET-API) ←──────────────────┤
  H22 (Validador) ←────────────────┘
                                   ↓
Sprint 4 (Exportações + UI Base):
  H13 (CSV/PDF) ←──────────────────┐
  H7 (Simuladores) ←───────────────┘
                                   ↓
Sprint 5 (UI Avançado + Academy):
  H8 (Explain) ←───────────────────┐
  H20 (Academy) ←──────────────────┘
                                   ↓
Sprint 6 (IRR + CET Completo):
  H14 (NPV) ←──────────────────────┐
  H15 (IRR-Brent) ←────────────────┤
  H16 (CET-Completo) ←─────────────┘
                                   ↓
Sprint 7 (Perfis + Comparador):
  H17 (Perfis) ←───────────────────┐
  H18 (Comparador) ←───────────────┤
  H19 (XLSX) ←─────────────────────┘
                                   ↓
Sprint 8 (Qualidade Final):
  H23 (Casos) ←────────────────────┐
  H24 (A11y + E2E) ←───────────────┘
```

---

## 📅 PROPOSTA DE REPLANEJAMENTO

### **SPRINT 0 (Pré-requisitos) - JÁ CONCLUÍDA ✅**

```
Objetivo: Infraestrutura base
HUs: H1, H2
Status: ✅ COMPLETAS
Duração: Kickoff (4 semanas)
```

### **SPRINT 1 (Motor Básico) - JÁ CONCLUÍDA ✅**

```
Objetivo: Cálculos fundamentais
HUs: H3, H4, H5, H6
Status: ✅ 5/6 (H3 parcial)
Duração: 3 semanas (real)
Capacidade: 6 HUs
```

### **SPRINT 2 (Amortizações) - JÁ CONCLUÍDA ✅**

```
Objetivo: Price, SAC, CET + Snapshots
HUs: H9, H10, H11, H12, H21
Status: ✅ 4/5 (H10, H11 parciais)
Duração: 3 semanas (real)
Capacidade: 5 HUs
Nota: H22 foi implementado também!
```

### **SPRINT 3 (APIs) - PRÓXIMA 📋**

```
Objetivo: Completar APIs REST + Validação
HUs:
  - ⚠️ H10: Completar Day Count (testes)
  - ⚠️ H11: Completar SAC API (501 → 200)
  - ✅ H9: API já funcional
  - ✅ H12: API já funcional
  - ✅ H22: Validador já funcional

Ajuste: Focar apenas em completar H10 e H11
  - H10: Day Count completo
  - H11: SAC API funcional
  - H13: Exportações CSV/PDF

Estimativa: 3 HUs
Duração: 2 semanas
Dependências respeitadas: ✅
```

### **SPRINT 4 (UI Base) - FUTURA 🔮**

```
Objetivo: Interface de simuladores
HUs:
  - H7: Simuladores (Juros/Equiv/Séries/Price/SAC)
  - H3: Completar Observabilidade

Estimativa: 2 HUs
Duração: 2-3 semanas
Dependências: H4,H5,H6,H9,H11 (✅ prontas)
```

### **SPRINT 5 (UI Avançado) - FUTURA 🔮**

```
Objetivo: Explain Panel + Academy
HUs:
  - H8: Explain Panel + PDF export
  - H20: Academy (5 tópicos)

Estimativa: 2 HUs
Duração: 2-3 semanas
Dependências: H7 (Sprint 4)
```

### **SPRINT 6 (IRR + CET Completo) - FUTURA 🔮**

```
Objetivo: Solver robusto + CET avançado
HUs:
  - H14: NPV
  - H15: IRR com Brent
  - H16: CET Completo (IOF/seguros)

Estimativa: 3 HUs
Duração: 3 semanas
Dependências: H12 (✅ pronta)
```

### **SPRINT 7 (Perfis + Comparador) - FUTURA 🔮**

```
Objetivo: Perfis institucionais + análise
HUs:
  - H17: Perfis CET
  - H18: Comparador
  - H19: XLSX export

Estimativa: 3 HUs
Duração: 2-3 semanas
Dependências: H16 (Sprint 6)
```

### **SPRINT 8 (Qualidade Final) - FUTURA 🔮**

```
Objetivo: QA completo + acessibilidade
HUs:
  - H23: Casos gabaritados
  - H24: A11y + E2E

Estimativa: 2 HUs
Duração: 2 semanas
Dependências: Todas as anteriores
```

---

## 📊 COMPARAÇÃO: PLANEJADO vs REAL vs PROPOSTO

| Item                  | Planejado Original    | Realidade             | Proposto       |
| --------------------- | --------------------- | --------------------- | -------------- |
| **Sprint 1**          | 9 HUs (H1-8, H20)     | 6 HUs (H1-6)          | 6 HUs ✅       |
| **Sprint 2**          | 7 HUs (H9-13, H21-22) | 6 HUs (H9-12, H21-22) | 5 HUs ✅       |
| **Sprint 3**          | 7 HUs (H14-19, H23)   | 0 HUs                 | 3 HUs ✅       |
| **Capacidade/Sprint** | ~7-9 HUs              | ~5-6 HUs              | **5-6 HUs** ✅ |
| **Total Sprints MVP** | 3 sprints             | N/A                   | **8 sprints**  |

---

## ✅ VALIDAÇÃO DAS DEPENDÊNCIAS

### **Sprint 3 (Proposta):**

```
✅ H10 (Day Count) - sem dependências bloqueantes
✅ H11 (SAC API) - motor já pronto (Sprint 2)
✅ H13 (CSV/PDF) - cronogramas já prontos (H9, H11)
```

### **Sprint 4 (Proposta):**

```
✅ H7 (Simuladores) - motor completo (Sprint 1+2)
✅ H3 (Observabilidade) - CI/CD pronta (Sprint 0)
```

### **Sprint 5 (Proposta):**

```
✅ H8 (Explain) - H7 concluída (Sprint 4)
✅ H20 (Academy) - H7 concluída (Sprint 4)
```

Todas as dependências respeitadas! ✅

---

## 🎯 RECOMENDAÇÕES FINAIS

### **Imediato (Sprint 3):**

1. ✅ Completar H10 (Day Count)
2. ✅ Completar H11 (SAC API funcional)
3. ✅ Implementar H13 (Exportações)

### **Curto Prazo (Sprint 4-5):**

1. ✅ Implementar UI (H7, H8)
2. ✅ Academy (H20)
3. ✅ Completar Observabilidade (H3)

### **Médio Prazo (Sprint 6-7):**

1. ✅ IRR robusto (H15)
2. ✅ CET completo (H16-17)
3. ✅ Comparador (H18)

### **Longo Prazo (Sprint 8):**

1. ✅ QA completo (H23)
2. ✅ Acessibilidade (H24)

---

## 📝 CHANGELOG

**v1.0 (2025-10-17):**

- Mapeamento completo de dependências entre HUs
- Proposta de replanejamento baseado em capacidade real
- Validação de todas as dependências
- Cronograma realista de 8 sprints

---

**Próxima revisão:** Após completar Sprint 3
