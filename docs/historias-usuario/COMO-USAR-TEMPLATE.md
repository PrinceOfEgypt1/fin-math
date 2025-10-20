# 📖 Como Usar o Template de História de Usuário

Este guia explica como criar uma nova HU usando o template.

---

## 🚀 Processo Passo a Passo

### 1. Copiar o Template

```bash
cd ~/workspace/fin-math/docs/historias-usuario

# Copiar template para nova HU
cp HU-template.md HU-25-titulo-da-historia.md

# Abrir no editor
nano HU-25-titulo-da-historia.md
```

### 2. Preencher Metadados

```markdown
# HU-25: Simulador de CET Básico

                    ↑ Título claro e conciso

**Sprint:** 6
↑ Número da sprint planejada

**Status:** 📋 Planejada
↑ Status atual

**Complexidade:** Alta (8 pontos)
↑ Estimativa em pontos de história
```

### 3. Escrever a História

Use o formato:

```
Como [persona específica]
Quero [funcionalidade concreta]
Para [benefício mensurável]
```

**✅ BOM:**

```
Como usuário do FinMath que precisa calcular o custo real de um empréstimo
Quero calcular o CET (Custo Efetivo Total) incluindo tarifas
Para comparar ofertas de diferentes instituições financeiras
```

**❌ RUIM:**

```
Como usuário
Quero calcular CET
Para saber o custo
```

### 4. Definir Critérios de Aceite

Use o formato **INVEST**:

- **I**ndependente
- **N**egociável
- **V**alioso
- **E**stimável
- **S**mall (pequeno)
- **T**estável

**✅ BOM:**

```markdown
### AC1: Cálculo de CET

- [ ] Aceita valor principal, taxa nominal, prazo e tarifas como entrada
- [ ] Calcula CET usando fórmula do Banco Central
- [ ] Exibe resultado com 4 casas decimais
- [ ] Tolerância de ±0.01% comparado com calculadora BC
```

**❌ RUIM:**

```markdown
### AC1: CET

- [ ] Deve calcular o CET
- [ ] Deve funcionar
```

### 5. Criar Casos de Teste

Use **Given-When-Then** (Dado-Quando-Então):

```markdown
### CT-25.1: Cálculo de CET com Tarifas

**Dado** que o usuário informa:

- Valor: R$ 10.000,00
- Taxa nominal: 2% a.m.
- Prazo: 12 meses
- Tarifas: R$ 500,00 (t0)
  **Quando** clicar em "Calcular CET"
  **Então** deve exibir CET = 3,15% a.m.
  **E** deve destacar a diferença entre taxa nominal e CET
```

### 6. Definir Métricas de Sucesso

Seja **específico e mensurável**:

**✅ BOM:**

```markdown
- Precisão: CET com erro < 0.01% vs calculadora BC
- Performance: Cálculo em < 50ms
- Usabilidade: 90% dos usuários conseguem calcular sem ajuda
```

**❌ RUIM:**

```markdown
- Deve ser preciso
- Deve ser rápido
- Deve ser fácil
```

### 7. Documentar Implementação Técnica

```markdown
### Arquivos Afetados

packages/engine/src/modules/cet/index.ts (novo)
packages/ui/src/pages/simulators/CetSimulator.tsx (novo)
packages/ui/test/unit/cet.test.ts (novo)
```

### 8. Identificar Débito Técnico

**Seja honesto:**

```markdown
### Dívidas Atuais

- [ ] **Falta validação de tarifas negativas:** Não valida se tarifas < 0
- [ ] **Sem testes de propriedade:** Apenas testes unitários implementados

### Riscos Técnicos

- ⚠️ **Convergência numérica:** Método de Newton pode não convergir para casos extremos
```

---

## 📋 Checklist de Qualidade

Antes de considerar a HU pronta, verifique:

- [ ] Título é claro e auto-explicativo?
- [ ] História segue formato "Como-Quero-Para"?
- [ ] Critérios de aceite são testáveis?
- [ ] Casos de teste cobrem cenários principais?
- [ ] Casos de teste incluem edge cases?
- [ ] Métricas são mensuráveis?
- [ ] Implementação técnica está documentada?
- [ ] Débito técnico está identificado?
- [ ] DoD está completo?
- [ ] Referências estão incluídas?

---

## 🎯 Exemplos Práticos

### Exemplo Completo

Veja `HU-24-comparacao-price-sac.md` como referência de HU bem documentada.

### Anti-Padrões Comuns

❌ **Critérios vagos:**

```markdown
- [ ] Deve ter boa performance
```

✅ **Critérios específicos:**

```markdown
- [ ] Cálculo completa em < 100ms para n ≤ 360 meses
```

---

❌ **Casos de teste incompletos:**

```markdown
### CT-25.1: Teste básico

Testar o cálculo de CET
```

✅ **Casos de teste detalhados:**

```markdown
### CT-25.1: CET com múltiplas tarifas

**Dado** que há 3 tarifas:

- T0: R$ 500 (abertura)
- T12: R$ 50 (mensal, toda parcela)
- T24: R$ 100 (avaliação semestral)
  **Quando** calcular CET para 24 meses
  **Então** CET deve considerar todas as tarifas no fluxo
  **E** resultado deve ser > taxa nominal
```

---

## 🔗 Próximos Passos Após Criar HU

1. Adicionar ao índice (`docs/historias-usuario/README.md`)
2. Incluir no backlog do projeto
3. Estimar complexidade em reunião de refinamento
4. Priorizar com Product Owner
5. Incluir em sprint quando apropriado

---

**Dúvidas?** Consulte `HU-24-comparacao-price-sac.md` ou pergunte ao Tech Lead.
