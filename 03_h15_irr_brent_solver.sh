#!/usr/bin/env bash
set -Eeuo pipefail

echo "🎯 =========================================="
echo "🎯 H15 - PARTE 2: Solver de Brent (IRR)"
echo "🎯 =========================================="
echo ""

REPO_DIR="${REPO_DIR:-$HOME/workspace/fin-math}"
cd "$REPO_DIR"

# -----------------------------------------------------------------------------
# Garantir diretórios
# -----------------------------------------------------------------------------
mkdir -p packages/engine/src/irr
mkdir -p packages/engine/test/unit/irr

# -----------------------------------------------------------------------------
# Criar: packages/engine/src/irr/brent.ts
# -----------------------------------------------------------------------------
echo "📝 Criando packages/engine/src/irr/brent.ts..."
cat > packages/engine/src/irr/brent.ts <<'EOF'
import { Decimal } from 'decimal.js';
import { calculateNPV, hasSignChange } from './npv';

export interface BrentOptions {
  lower?: Decimal;   // limite inferior de busca (r > -1)
  upper?: Decimal;   // limite superior de busca
  tol?: Decimal;     // tolerância
  maxIter?: number;  // iterações máximas
}

/**
 * Faz varredura para encontrar um intervalo [a,b] com mudança de sinal em NPV(r).
 * Se não encontrar, lança erro informativo.
 */
export function bracketIRR(
  cashflows: Decimal[],
  startLower = new Decimal(-0.90),
  startUpper = new Decimal(1.00),
  steps = 200
): { a: Decimal; b: Decimal } {
  // sanity
  if (!hasSignChange(cashflows)) {
    throw new Error('No sign change in cashflows; IRR may not exist');
  }

  const lower = Decimal.max(startLower, new Decimal(-0.99)); // protege contra r <= -1
  const upper = startUpper;

  const step = upper.minus(lower).div(steps);
  let a = lower;
  let fa = calculateNPV(a, cashflows);

  for (let i = 1; i <= steps; i++) {
    const b = lower.plus(step.mul(i));
    const fb = calculateNPV(b, cashflows);
    if (fa.isZero()) return { a, b: a };
    if (fa.mul(fb).isNegative() || fb.isZero()) {
      return { a, b };
    }
    a = b;
    fa = fb;
  }

  throw new Error('Failed to bracket IRR in search range');
}

/**
 * Brent "light" (com fallback para bissecção) usando Decimal.js.
 * Retorna r tal que NPV(r) ≈ 0.
 */
export function brentIRR(
  cashflows: Decimal[],
  opts: BrentOptions = {}
): Decimal {
  const tol = opts.tol ?? new Decimal(1e-10);
  const maxIter = opts.maxIter ?? 100;

  let a: Decimal;
  let b: Decimal;

  if (opts.lower && opts.upper) {
    a = opts.lower;
    b = opts.upper;
  } else {
    const br = bracketIRR(cashflows);
    a = br.a;
    b = br.b;
  }

  let fa = calculateNPV(a, cashflows);
  let fb = calculateNPV(b, cashflows);

  if (fa.isZero()) return a;
  if (fb.isZero()) return b;

  // Garante que fa e fb têm sinais opostos
  if (fa.mul(fb).isPositive()) {
    throw new Error('Invalid bracket: NPV(a) and NPV(b) must have opposite signs');
  }

  // Inicializa c como o melhor
  let c = a;
  let fc = fa;
  let d = new Decimal(0);
  let e = new Decimal(0);

  for (let iter = 0; iter < maxIter; iter++) {
    if (fb.abs().lt(fc.abs())) {
      // swap b<->c e fb<->fc
      [a, b] = [b, a];
      [fa, fb] = [fb, fa];
    }

    const tol1 = tol.mul(new Decimal(0.5)).add(new Decimal(2)).mul(b.abs()).add(tol);
    const m = c.minus(b).mul(new Decimal(0.5));

    // Convergência por bissecção
    if (m.abs().lte(tol1) || fb.isZero()) {
      return b;
    }

    // Tentativa de interpolação (secante / inverse quadratic)
    if (fa.equals(fc) || fb.equals(fc)) {
      // secante
      d = b.minus(a).mul(fb).div(fb.minus(fa));
    } else {
      // interpolação quadrática inversa
      const s1 = fb.div(fa);
      const s2 = fb.div(fc);
      const s3 = fa.div(fc);
      d = s1.mul(
        m.mul(new Decimal(2))
          .mul(s2.plus(s3))
          .div(s1.mul(s2).minus(new Decimal(1)).mul(s1.mul(s3).minus(new Decimal(1))))
      );
    }

    let newStepOk = false;
    let p = d;
    const bPlusP = b.minus(p);

    // Restrições para aceitar a interpolação; caso contrário, bissecção
    if (bPlusP.gt(Decimal.min(b, c)) && bPlusP.lt(Decimal.max(b, c))) {
      newStepOk = true;
    }

    if (!newStepOk || p.abs().gt(m.mul(new Decimal(0.75))) || p.abs().lt(tol1)) {
      // Bissecção
      d = m;
    }

    a = b;
    fa = fb;
    if (d.abs().gt(tol1)) {
      b = b.minus(d);
    } else {
      b = b.minus(m.sign());
    }
    fb = calculateNPV(b, cashflows);

    // Mantém c como o ponto com sinal oposto a b
    if (fa.mul(fb).isPositive()) {
      c = a;
      fc = fa;
    }
  }

  throw new Error('Brent method did not converge within maxIter');
}
EOF
echo "✅ packages/engine/src/irr/brent.ts criado"

# -----------------------------------------------------------------------------
# Criar: packages/engine/test/unit/irr/brent.test.ts
# -----------------------------------------------------------------------------
echo "📝 Criando packages/engine/test/unit/irr/brent.test.ts..."
cat > packages/engine/test/unit/irr/brent.test.ts <<'EOF'
import { describe, it, expect } from 'vitest';
import { Decimal } from 'decimal.js';
import { brentIRR } from '../../../src/irr/brent';
import { calculateNPV } from '../../../src/irr/npv';

// PMT para anuidade postecipada
function pmt(PV: Decimal, r: Decimal, n: number): Decimal {
  if (r.eq(0)) return PV.div(n);
  const one = new Decimal(1);
  const pow = one.plus(r).pow(n);
  return PV.mul(r).mul(pow).div(pow.minus(1));
}

describe('brentIRR', () => {
  it('encontra IRR ≈ 2.5% para fluxo de 12 parcelas (empréstimo)', () => {
    const PV = new Decimal(10000);
    const irr = new Decimal(0.025);
    const n = 12;
    const pm = pmt(PV, irr, n);
    const cash = [PV, ...Array.from({ length: n }, () => pm.neg())];

    const found = brentIRR(cash, { tol: new Decimal(1e-10), maxIter: 200 });
    expect(found.toNumber()).toBeCloseTo(0.025, 4);

    // sanity: NPV(found) ≈ 0
    const npv = calculateNPV(found, cash);
    expect(Math.abs(npv.toNumber())).toBeLessThan(1e-6);
  });

  it('lança erro quando não há mudança de sinal no fluxo', () => {
    const cash = [new Decimal(100), new Decimal(50), new Decimal(25)]; // todos positivos
    expect(() => brentIRR(cash)).toThrow();
  });
});
EOF
echo "✅ Testes criados"

echo ""
echo "✅ H15 - PARTE 2 (Brent Solver): CONCLUÍDA"
echo ""
echo "🎯 Arquivos criados:"
echo "   - packages/engine/src/irr/brent.ts"
echo "   - packages/engine/test/unit/irr/brent.test.ts"
echo ""
echo "🎯 Para executar os testes do engine:"
echo "   pnpm -C packages/engine exec vitest run"
