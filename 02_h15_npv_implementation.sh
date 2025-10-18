#!/usr/bin/env bash
set -Eeuo pipefail

echo "🔢 =========================================="
echo "🔢 H15 - PARTE 1: Implementação NPV"
echo "🔢 =========================================="
echo ""

REPO_DIR="${REPO_DIR:-$HOME/workspace/fin-math}"
cd "$REPO_DIR"

# -----------------------------------------------------------------------------
# Garantir diretórios
# -----------------------------------------------------------------------------
mkdir -p packages/engine/src/irr
mkdir -p packages/engine/test/unit/irr

# -----------------------------------------------------------------------------
# Criar: packages/engine/src/irr/npv.ts
# -----------------------------------------------------------------------------
echo "📝 Criando packages/engine/src/irr/npv.ts..."
cat > packages/engine/src/irr/npv.ts <<'EOF'
/**
 * NPV (Net Present Value / Valor Presente Líquido)
 * NPV(r, CF) = Σ(CF[k] / (1 + r)^k) para k = 0..n
 *
 * Observação sobre sinais:
 * - Em fluxo de EMPRÉSTIMO modelado como CF0 > 0 (entrada) e CFk<0 (saídas),
 *   o NPV tende a AUMENTAR quando a taxa (r) aumenta.
 *   Logo:
 *     • se r < IRR  => NPV < 0
 *     • se r = IRR  => NPV ≈ 0
 *     • se r > IRR  => NPV > 0
 */

import { Decimal } from 'decimal.js';

export function calculateNPV(rate: Decimal, cashflows: Decimal[]): Decimal {
  if (cashflows.length === 0) {
    throw new Error('Cashflows array cannot be empty');
  }
  // Evita divisão por zero: (1 + r)^k com r <= -1 é inválido
  if (rate.lte(-1)) {
    throw new Error('Rate must be greater than -1');
  }

  const one = new Decimal(1);
  const onePlusRate = one.plus(rate);
  let npv = new Decimal(0);

  for (let k = 0; k < cashflows.length; k++) {
    const discount = onePlusRate.pow(k);
    const pv = cashflows[k].div(discount);
    npv = npv.plus(pv);
  }
  return npv;
}

/**
 * Detecta mudança de sinal ignorando zeros.
 */
export function hasSignChange(cashflows: Decimal[]): boolean {
  if (cashflows.length < 2) return false;

  let prevSign: number | null = null;
  for (let i = 0; i < cashflows.length; i++) {
    const cf = cashflows[i];
    if (cf.isZero()) continue;
    const sign = cf.isPositive() ? 1 : -1;
    if (prevSign === null) {
      prevSign = sign;
      continue;
    }
    if (sign !== prevSign) return true;
    prevSign = sign;
  }
  return false;
}

/**
 * Conta mudanças de sinal ignorando zeros.
 */
export function countSignChanges(cashflows: Decimal[]): number {
  if (cashflows.length < 2) return 0;

  let prevSign: number | null = null;
  let changes = 0;

  for (let i = 0; i < cashflows.length; i++) {
    const cf = cashflows[i];
    if (cf.isZero()) continue;
    const sign = cf.isPositive() ? 1 : -1;
    if (prevSign === null) {
      prevSign = sign;
      continue;
    }
    if (sign !== prevSign) {
      changes += 1;
      prevSign = sign;
    }
  }
  return changes;
}
EOF
echo "✅ Arquivo criado: packages/engine/src/irr/npv.ts"

# -----------------------------------------------------------------------------
# Criar: packages/engine/test/unit/irr/npv.test.ts
# -----------------------------------------------------------------------------
echo "📝 Criando packages/engine/test/unit/irr/npv.test.ts..."
cat > packages/engine/test/unit/irr/npv.test.ts <<'EOF'
import { describe, it, expect } from 'vitest';
import { Decimal } from 'decimal.js';
import { calculateNPV, hasSignChange, countSignChanges } from '../../../src/irr/npv';

// PMT para anuidade postecipada: PMT = PV * [r(1+r)^n]/[(1+r)^n - 1]
function pmtAnnuityPostec(PV: Decimal, r: Decimal, n: number): Decimal {
  if (r.eq(0)) {
    return PV.div(n);
  }
  const one = new Decimal(1);
  const pow = one.plus(r).pow(n);
  return PV.mul(r).mul(pow).div(pow.minus(1));
}

describe('NPV - Net Present Value', () => {
  describe('calculateNPV', () => {
    it('calcula NPV corretamente para fluxo simples', () => {
      // Fluxo: [1000, -500, -600], r = 10%
      // NPV ≈ 49.59
      const cash = [new Decimal(1000), new Decimal(-500), new Decimal(-600)];
      const r = new Decimal(0.10);
      const npv = calculateNPV(r, cash);
      expect(npv.toNumber()).toBeCloseTo(49.59, 2);
    });

    it('NPV ≈ 0 quando r é a IRR do fluxo (empréstimo CF0>0, saídas negativas)', () => {
      const PV = new Decimal(10000);
      const irr = new Decimal(0.025); // 2.5% a.m.
      const n = 12;
      const pmt = pmtAnnuityPostec(PV, irr, n); // ≈ 974.87
      const cash = [PV, ...Array.from({ length: n }, () => pmt.neg())];
      const npv = calculateNPV(irr, cash);
      expect(Math.abs(npv.toNumber())).toBeLessThan(1e-2); // 1 centavo
    });

    it('para fluxo de empréstimo: se r < IRR => NPV < 0', () => {
      const PV = new Decimal(10000);
      const irr = new Decimal(0.025);
      const n = 12;
      const pmt = pmtAnnuityPostec(PV, irr, n);
      const cash = [PV, ...Array.from({ length: n }, () => pmt.neg())];

      const rLower = new Decimal(0.020); // menor que IRR
      const npvLower = calculateNPV(rLower, cash);
      expect(npvLower.isNegative()).toBe(true);
    });

    it('para fluxo de empréstimo: se r > IRR => NPV > 0', () => {
      const PV = new Decimal(10000);
      const irr = new Decimal(0.025);
      const n = 12;
      const pmt = pmtAnnuityPostec(PV, irr, n);
      const cash = [PV, ...Array.from({ length: n }, () => pmt.neg())];

      const rHigher = new Decimal(0.030); // maior que IRR
      const npvHigher = calculateNPV(rHigher, cash);
      expect(npvHigher.isPositive()).toBe(true);
    });

    it('lança erro para array vazio', () => {
      expect(() => calculateNPV(new Decimal(0.1), [])).toThrow('Cashflows array cannot be empty');
    });

    it('trata taxa zero (NPV = soma dos fluxos)', () => {
      const cash = [new Decimal(1000), new Decimal(-500), new Decimal(-600)];
      const r = new Decimal(0);
      const npv = calculateNPV(r, cash);
      expect(npv.toNumber()).toBeCloseTo(-100, 10);
    });

    it('lança erro quando rate <= -1 (evita divisão por zero)', () => {
      const cash = [new Decimal(100), new Decimal(-100)];
      expect(() => calculateNPV(new Decimal(-1), cash)).toThrow();
      expect(() => calculateNPV(new Decimal(-1.5), cash)).toThrow();
    });
  });

  describe('hasSignChange / countSignChanges (ignorando zeros)', () => {
    it('detecta mudança (+ → -) ignorando zeros', () => {
      const cash = [new Decimal(0), new Decimal(100), new Decimal(0), new Decimal(-10)];
      expect(hasSignChange(cash)).toBe(true);
    });

    it('detecta mudança (- → +)', () => {
      const cash = [new Decimal(-1000), new Decimal(0), new Decimal(500)];
      expect(hasSignChange(cash)).toBe(true);
    });

    it('false quando todos positivos ou todos negativos (zeros ignorados)', () => {
      expect(hasSignChange([new Decimal(0), new Decimal(1), new Decimal(2)])).toBe(false);
      expect(hasSignChange([new Decimal(-1), new Decimal(0), new Decimal(-2)])).toBe(false);
    });

    it('contagem de mudanças (zeros ignorados)', () => {
      const cash = [
        new Decimal(1000),  // +
        new Decimal(0),
        new Decimal(-500),  // - (1)
        new Decimal(200),   // + (2)
        new Decimal(0),
        new Decimal(-100),  // - (3)
      ];
      expect(countSignChanges(cash)).toBe(3);
    });
  });
});
EOF
echo "✅ Arquivo criado: packages/engine/test/unit/irr/npv.test.ts"

# -----------------------------------------------------------------------------
# Executar testes NPV (somente esse arquivo)
# -----------------------------------------------------------------------------
echo ""
echo "🧪 Executando testes NPV (engine)..."

run_vitest() {
  if command -v pnpm >/dev/null 2>&1; then
    if pnpm -C packages/engine exec --silent vitest --version >/dev/null 2>&1; then
      pnpm -C packages/engine exec vitest run test/unit/irr/npv.test.ts
      return $?
    fi
  fi
  if command -v npx >/dev/null 2>&1; then
    if npx --yes vitest --version >/dev/null 2>&1; then
      npx vitest run --dir packages/engine test/unit/irr/npv.test.ts
      return $?
    fi
  fi
  echo "❌ Vitest não está disponível no ambiente. Instale as dependências."
  return 127
}

if run_vitest; then
  echo "✅ Testes NPV passaram."
else
  echo "❌ Testes NPV falharam (ou vitest não disponível). Verifique dependências e scripts do pacote engine."
  exit 1
fi

echo ""
echo "✅ H15 - PARTE 1 (NPV): CONCLUÍDA"
echo "🎯 PRÓXIMO PASSO: Executar 03_h15_irr_brent_solver.sh"
