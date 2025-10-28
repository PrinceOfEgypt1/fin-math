# Issue #001: Testes Unitários para ComparisonPage

**Tipo:** Débito Técnico  
**Prioridade:** Média  
**Estimativa:** 2 pontos  
**Relacionada a:** HU-24  
**Sprint:** 6

---

## Descrição

Implementar testes unitários para o componente `ComparisonPage.tsx` que foi criado na HU-24 sem testes unitários.

## Critérios de Aceite

- [ ] Cobertura ≥ 80% do componente
- [ ] Testes para função `calculatePRICE`
- [ ] Testes para função `calculateSAC`
- [ ] Testes para cálculo de economia (savings)
- [ ] Testes para renderização condicional (com/sem resultados)
- [ ] Testes de integração com Decimal.js

## Casos de Teste Mínimos

```typescript
describe('ComparisonPage', () => {
  it('deve calcular PRICE corretamente', () => { ... })
  it('deve calcular SAC corretamente', () => { ... })
  it('deve calcular economia corretamente', () => { ... })
  it('deve renderizar sem resultados inicialmente', () => { ... })
  it('deve renderizar com resultados após cálculo', () => { ... })
})
```

## Referência

- Arquivo: `packages/ui/src/pages/ComparisonPage.tsx`
- Testes em: `packages/ui/test/unit/ComparisonPage.test.tsx`
