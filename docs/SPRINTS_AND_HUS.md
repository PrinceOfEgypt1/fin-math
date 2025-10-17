# 📋 Sprints & Histórias de Usuário - FinMath

**Owner:** @PrinceOfEgypt1  
**Última revisão:** 2025-10-17  
**Fonte de verdade:** [GitHub Project Board](https://github.com/users/PrinceOfEgypt1/projects/[NÚMERO])

---

## 🗺️ Mapa de Dependências

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
Sprint 2 (Amortizações):
  H9 (Price) ←─────────────────────┐
  H10 (DayCount) ←─────────────────┤
  H11 (SAC) ←──────────────────────┤
  H12 (CET) ←──────────────────────┤
  H21 (Snapshots) ←────────────────┘
                                   ↓
Sprint 3 (APIs):
  H13 (CSV/PDF) ←──────────────────┘
  H22 (Validador) ←────────────────┘
                                   ↓
Sprint 4 (IRR + CET Completo):
  H14 (NPV) ←──────────────────────┐
  H15 (IRR-Brent) ←────────────────┤
  H16 (CET-Completo) ←─────────────┘
```

---

## 📊 Sprints e Status

**Nota:** Status reflete o [Project Board](https://github.com/users/PrinceOfEgypt1/projects/).
Para atualizar status, mova cards no board - não edite este documento manualmente.

### **Sprint 0 - Kickoff** ✅ Completa

| HU  | Título          | Status     | Issue |
| --- | --------------- | ---------- | ----- |
| H1  | CI/CD           | ✅ Done    | -     |
| H2  | Decimal.js      | ✅ Done    | -     |
| H3  | Observabilidade | ⚠️ Parcial | -     |

### **Sprint 1 - Motor Básico** ✅ Completa

| HU  | Título          | Status  | Issue |
| --- | --------------- | ------- | ----- |
| H4  | Juros Compostos | ✅ Done | -     |
| H5  | Equivalência    | ✅ Done | -     |
| H6  | Séries          | ✅ Done | -     |

### **Sprint 2 - Amortizações** ✅ Completa

| HU  | Título     | Status  | Dependências | Issue |
| --- | ---------- | ------- | ------------ | ----- |
| H9  | Price      | ✅ Done | H2           | -     |
| H10 | Day Count  | ✅ Done | H2           | -     |
| H11 | SAC        | ✅ Done | H2           | -     |
| H12 | CET Básico | ✅ Done | H9, H11      | -     |
| H21 | Snapshots  | ✅ Done | H1, H2       | -     |
| H22 | Validador  | ✅ Done | H9, H11      | -     |

### **Sprint 3 - APIs** ✅ Completa

| HU  | Título  | Status  | Dependências | Issue |
| --- | ------- | ------- | ------------ | ----- |
| H13 | CSV/PDF | ✅ Done | H9, H11      | -     |

### **Sprint 4 - IRR + CET** 📋 Planejada

| HU  | Título            | Status     | Dependências | Issue |
| --- | ----------------- | ---------- | ------------ | ----- |
| H14 | NPV               | 📋 Backlog | H2           | -     |
| H15 | IRR Brent         | 📋 Backlog | H2           | -     |
| H16 | CET Completo      | 📋 Backlog | H12, H15     | -     |
| H17 | Perfis CET        | 📋 Backlog | H16          | -     |
| H18 | Comparador        | 📋 Backlog | H16          | -     |
| H19 | XLSX              | 📋 Backlog | H13          | -     |
| H23 | Casos Gabaritados | 📋 Backlog | H9, H11, H12 | -     |

---

## 🔗 Dependências Críticas

| HU Bloqueante | Bloqueia               | Prioridade |
| ------------- | ---------------------- | ---------- |
| H1 (CI/CD)    | TODAS                  | 🔴 CRÍTICO |
| H2 (Decimal)  | H4-H6, H9-H12, H14-H16 | 🔴 CRÍTICO |
| H9 (Price)    | H12, H13, H18, H22     | 🟡 ALTO    |
| H11 (SAC)     | H12, H13, H18, H22     | 🟡 ALTO    |
| H12 (CET)     | H16, H17, H18          | 🟡 ALTO    |
| H15 (IRR)     | H16                    | 🟡 ALTO    |

---

## 📝 Convenções

- **Status:** Reflete colunas do Project Board (Backlog/In Progress/Done)
- **Issue:** Link para Issue no GitHub
- **Dependências:** HUs que devem estar Done antes de iniciar

**Para adicionar nova HU:**

1. Criar Issue no GitHub
2. Adicionar ao Project Board
3. Atualizar esta tabela (apenas estrutura, não status)

---

**Última atualização:** 2025-10-17
