# HU-25: Simulador CET Completo

**Sprint:** 5  
**Status:** ✅ APROVADO - Pronto para Implementação  
**Data de Criação:** 2025-10-19  
**Data de Aprovação:** 2025-10-20  
**Complexidade:** Muito Alta (13 pontos)  
**Prioridade:** 🔥 Alta  
**Estimativa:** 3 dias de desenvolvimento

---

## 📋 História de Usuário

**Como** consumidor que está avaliando propostas de crédito de diferentes instituições financeiras  
**Quero** calcular o Custo Efetivo Total (CET) incluindo todas as tarifas, IOF e encargos  
**Para** comparar o custo real das ofertas e tomar decisão informada sobre qual proposta é mais vantajosa, garantindo transparência total dos custos

---

## 🎯 Contexto de Negócio

### Problema

Consumidores frequentemente comparam apenas a taxa de juros nominal, ignorando:

- Tarifas (cadastro, avaliação, etc.) que podem somar R$ 1.000+
- IOF (0,38% do principal + 0,0082% ao dia)
- Seguros opcionais
- Outros encargos

**Resultado:** Decisões baseadas em informação incompleta, levando a custos maiores que o esperado.

### Solução

Calculadora de CET que:

- ✅ Mostra custo REAL com todos os encargos
- ✅ Segue Resolução CMN 3.517/2007 (obrigatória)
- ✅ Compara taxa nominal vs CET
- ✅ Destaca componentes do custo

### Valor de Negócio

- **Para usuário:** Transparência e decisão informada
- **Para FinMath:** Compliance regulatório + diferencial competitivo
- **ROI:** Alta conversão

---

## 🎯 Critérios de Aceite

### AC1: Formulário de Entrada - Dados Básicos

- [ ] Campo: Valor do Financiamento (R$) - obrigatório
- [ ] Campo: Taxa de Juros Nominal (% a.m.) - obrigatório
- [ ] Campo: Prazo (meses) - obrigatório
- [ ] Seção colapsável
- [ ] Valores padrão sensatos

### AC2: Formulário de Entrada - Tarifas

- [ ] Tarifa de Cadastro (R$)
- [ ] Tarifa de Avaliação (R$)
- [ ] Seguro (R$ ou %)
- [ ] Seção colapsável
- [ ] Badge "X tarifas configuradas"

### AC3: Formulário de Entrada - IOF

- [ ] Checkbox "Incluir IOF"
- [ ] Exibição automática dos valores
- [ ] Tooltip explicativo

### AC4: Cálculo de CET - Algoritmo

- [ ] Método Newton-Raphson
- [ ] Convergência: |i_novo - i_atual| < 1e-6
- [ ] Máximo 100 iterações
- [ ] Chute inicial: taxa nominal \* 1.2
- [ ] Precisão: erro < 0,01% vs BC

### AC5: Exibição de Resultados - Métricas

- [ ] CET Mensal (% a.m.) - 4 casas decimais
- [ ] CET Anual (% a.a.) - 2 casas decimais
- [ ] Comparação visual (barras)
- [ ] Valor Líquido Liberado

### AC6: Detalhamento de Custos

- [ ] Tabela de composição
- [ ] Total pago vs valor solicitado

### AC7: Alertas e Avisos

- [ ] Alerta vermelho: CET > 10% a.m.
- [ ] Alerta amarelo: diferença > 50%
- [ ] Mensagem sucesso: CET ≈ taxa nominal

### AC8: Validações e Edge Cases

- [ ] Sem tarifas → CET = Taxa Nominal
- [ ] Não convergência → Mensagem amigável
- [ ] Valores extremos → Validação

### AC9: UX e Responsividade

- [ ] Animações (Framer Motion)
- [ ] Seções colapsáveis
- [ ] Responsivo (mobile + desktop)
- [ ] Loading state
- [ ] Tooltips

### AC10: Integração e Navegação

- [ ] Menu "CET" no Header
- [ ] Rota: `/#cet`
- [ ] Link no Dashboard
- [ ] Ícone: Percent

---

## 🧪 Casos de Teste

### CT-25.1: CET Básico Sem Tarifas

- Valor: R$ 10.000,00
- Taxa: 2% a.m.
- Prazo: 12 meses
- Resultado: CET = 2,0000% a.m.

### CT-25.2: CET Com IOF

- Valor: R$ 10.000,00
- Taxa: 2% a.m.
- IOF incluso
- Resultado: CET > 2% a.m.

### CT-25.3: CET Com Tarifa de Cadastro

- Com tarifa de R$ 500
- Resultado: CET > taxa nominal

### CT-25.4: Múltiplas Tarifas

- Comparável com calculadora BC (erro < 0,01%)

### CT-25.5: Taxa Alta

- Taxa > 10% a.m.
- Exibir alerta vermelho

### CT-25.6: Não Convergência

- Mensagem amigável

### CT-25.7: Campos Obrigatórios

- Destacar campos com erro

### CT-25.8: Responsividade Mobile

- Viewport 375px
- Interface legível

### CT-25.9: Performance

- Cálculo < 200ms

### CT-25.10: Golden File BC

- Erro < 0,01% vs calculadora BC

---

## 📊 Métricas de Sucesso

- **Precisão:** < 0,01% vs BC
- **Performance:** < 200ms
- **Convergência:** ≥ 99,9%
- **Usabilidade:** 80% sem ajuda
- **Adoção:** 50%+ usam CET

---

## 🔧 Implementação Técnica

### Arquivos a Criar

```
packages/engine/src/modules/cet/
├── index.ts
├── newton-raphson.ts
├── iof.ts
├── cash-flow.ts
└── types.ts

packages/ui/src/pages/simulators/
└── CetSimulator.tsx
```

### Algoritmo Newton-Raphson

```typescript
interface CetInput {
  valorPrincipal: Decimal;
  taxaNominal: Decimal;
  prazo: number;
  tarifaCadastro?: Decimal;
  incluirIOF: boolean;
}

function calculateCET(input: CetInput): CetOutput {
  // 1. IOF
  const iof = input.incluirIOF ? calculateIOF(input) : Decimal(0);

  // 2. Valor líquido
  const valorLiquido = input.valorPrincipal
    .minus(input.tarifaCadastro || 0)
    .minus(iof);

  // 3. Newton-Raphson
  let cet = input.taxaNominal.mul(1.2);
  let iteracoes = 0;

  while (iteracoes < 100) {
    const npv = calculateNPV(cashFlow, cet, valorLiquido);
    const derivative = calculateNPVDerivative(cashFlow, cet);
    const cetNovo = cet.minus(npv.div(derivative));

    if (cetNovo.minus(cet).abs().lessThan(1e-6)) {
      return { cetMensal: cetNovo, convergiu: true };
    }

    cet = cetNovo;
    iteracoes++;
  }

  return { convergiu: false };
}

function calculateIOF(input: CetInput): Decimal {
  const iofFixo = input.valorPrincipal.mul(0.0038);
  const diasIOF = Math.min(input.prazo * 30, 365);
  const iofDiario = input.valorPrincipal.mul(0.000082).mul(diasIOF);
  return iofFixo.plus(iofDiario);
}
```

---

## 📚 Referências

- [Resolução CMN 3.517/2007](https://www.bcb.gov.br/pre/normativos/res/2007/pdf/res_3517_v1_O.pdf)
- [Calculadora BC](https://www3.bcb.gov.br/CALCIDADAO/)

---

## ✅ Definition of Done

### Pré-Implementação

- [x] HU aprovada
- [x] Critérios validados
- [x] Casos de teste definidos

### Implementação - Engine

- [ ] Algoritmo Newton-Raphson
- [ ] Cálculo de IOF
- [ ] Testes unitários (≥85%)
- [ ] Golden files

### Implementação - UI

- [ ] CetSimulator criado
- [ ] Formulário completo
- [ ] Responsivo

### Qualidade

- [ ] Type-check passa
- [ ] Lint passa
- [ ] Build passa
- [ ] Validação BC

### Documentação

- [ ] JSDoc completo
- [ ] README atualizado
- [ ] Screenshots

---

## 🔗 Relacionamentos

**Depende de:**

- HU-09: Simulador PRICE
- HU-24: Comparação

**Bloqueia:**

- HU-26: CET Avançado
- HU-27: Comparador

---

## 👥 Stakeholders

**Product Owner:** Moses  
**Tech Lead:** Claude  
**Status:** ✅ PRONTO PARA IMPLEMENTAÇÃO
