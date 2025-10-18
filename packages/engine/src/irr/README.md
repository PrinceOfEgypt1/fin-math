# IRR (Internal Rate of Return)

Implementação de solvers de IRR para cálculo de taxa interna de retorno.

## Módulos

### 1. NPV (Net Present Value)

- Cálculo de Valor Presente Líquido
- Análise de mudanças de sinal (Regra de Descartes)
- Detecção de múltiplas raízes

### 2. Brent Solver

- **Algoritmo híbrido**: bissecção + interpolação quadrática inversa
- **Baseado em**: Brent (1973) - Algorithms for Minimization Without Derivatives
- **Robustez**: garantia de convergência
- **Precisão**: erro < 0.1%

## Uso Básico

```typescript
import { solveIRR } from "./irr/brent";

const cashflows = [
  new Decimal("10000"), // PV (entrada)
  ...Array(12).fill(new Decimal("-974.81")), // PMT (saídas)
];

const result = solveIRR(cashflows);

if (result.converged) {
  console.log(`IRR: ${result.irr!.toNumber() * 100}%`);
} else {
  console.log("Não convergiu:", result.diagnostics);
}
```

## Referências

- Brent, R. P. (1973). _Algorithms for Minimization Without Derivatives_. Prentice-Hall.
- [Wikipedia: Brent's Method](https://en.wikipedia.org/wiki/Brent's_method)
- Apache Commons Math: BrentSolver
