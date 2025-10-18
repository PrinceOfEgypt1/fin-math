#!/bin/bash

################################################################################
# SCRIPT: 06_h15_recreate_brent.sh
# DESCRIÇÃO: Recriar brent.ts COMPLETO com funções corretas
# AUTOR: FinMath Team
# DATA: 2025-10-18
# VERSÃO: 1.0.0
################################################################################

set -e

echo "🔧 =========================================="
echo "🔧 RECRIANDO brent.ts COMPLETO"
echo "🔧 =========================================="
echo ""

cd ~/workspace/fin-math

# ============================================================================
# BACKUP DO ARQUIVO ANTIGO
# ============================================================================
echo "💾 Fazendo backup do arquivo antigo..."
cp packages/engine/src/irr/brent.ts packages/engine/src/irr/brent.ts.old
echo "✅ Backup criado: brent.ts.old"
echo ""

# ============================================================================
# CRIAR ARQUIVO COMPLETO
# ============================================================================
echo "📝 Criando brent.ts COMPLETO..."

cat > packages/engine/src/irr/brent.ts << 'EOFBRENT'
/**
 * Solver de IRR usando Método de Brent
 * 
 * Implementação do algoritmo de Brent para encontrar raízes de funções.
 * Usado para calcular IRR (Internal Rate of Return / TIR).
 * 
 * @module irr/brent
 * @see ADR-002 (Solver de IRR: Brent com fallbacks)
 * @see Guia CET — SoT §4
 * @see Playbook §4 (IRR: erro relativo ≤ 0.01%)
 */

import { Decimal } from 'decimal.js';
import { calculateNPV, hasSignChange, countSignChanges } from './npv';

/**
 * Resultado do solver de IRR
 */
export interface IRRResult {
  /** Taxa IRR encontrada (mensal) */
  irr: Decimal | null;
  
  /** Número de iterações executadas */
  iterations: number;
  
  /** Método usado: 'brent' ou 'bisection' */
  method: 'brent' | 'bisection';
  
  /** Se o solver convergiu */
  converged: boolean;
  
  /** Diagnósticos adicionais */
  diagnostics?: {
    /** Múltiplas raízes podem existir (>1 mudança de sinal) */
    multipleRoots?: boolean;
    
    /** Sem mudança de sinal (IRR não existe) */
    noSignChange?: boolean;
    
    /** NPV final após convergência */
    finalNPV?: Decimal;
  };
}

/**
 * Opções para o solver de IRR
 */
export interface IRROptions {
  /** Chute inicial (default: 0.1 = 10%) */
  guess?: Decimal;
  
  /** Intervalo de busca (default: [0, 1]) */
  range?: {
    lo: Decimal;
    hi: Decimal;
  };
  
  /** Tolerância para convergência (default: 1e-8) */
  tolerance?: Decimal;
  
  /** Número máximo de iterações (default: 100) */
  maxIterations?: number;
  
  /** Forçar uso de bissecção (default: false) */
  forceBisection?: boolean;
}

/**
 * Resolve IRR (TIR) usando método de Brent.
 * 
 * @param cashflows - Array de fluxos de caixa [CF0, CF1, ..., CFn]
 * @param options - Opções do solver
 * @returns Resultado com IRR, iterações e diagnósticos
 * 
 * @example
 * ```typescript
 * const cashflows = [
 *   new Decimal('10000'),
 *   ...Array(12).fill(new Decimal('-946.56'))
 * ];
 * 
 * const result = solveIRR(cashflows);
 * // result.irr ≈ 0.025 (2.5% a.m.)
 * // result.converged === true
 * // result.method === 'brent'
 * ```
 */
export function solveIRR(
  cashflows: Decimal[],
  options: IRROptions = {}
): IRRResult {
  // Valores padrão
  const tolerance = options.tolerance ?? new Decimal('1e-8');
  const maxIterations = options.maxIterations ?? 100;
  const forceBisection = options.forceBisection ?? false;
  
  // Diagnóstico 1: Verificar mudança de sinal
  if (!hasSignChange(cashflows)) {
    return {
      irr: null,
      iterations: 0,
      method: 'brent',
      converged: false,
      diagnostics: {
        noSignChange: true
      }
    };
  }
  
  // Diagnóstico 2: Verificar múltiplas raízes potenciais
  const signChanges = countSignChanges(cashflows);
  const multipleRoots = signChanges > 1;
  
  // Definir intervalo de busca
  let a = options.range?.lo ?? new Decimal('0');
  let b = options.range?.hi ?? new Decimal('1');
  
  // Aplicar chute inicial se fornecido
  if (options.guess) {
    const guess = options.guess;
    const margin = new Decimal('0.1');
    a = Decimal.max(new Decimal('0'), guess.minus(margin));
    b = guess.plus(margin);
  }
  
  // Calcular NPV nos extremos
  let fa = calculateNPV(a, cashflows);
  let fb = calculateNPV(b, cashflows);
  
  // Verificar se há raiz no intervalo
  if (fa.mul(fb).isPositive()) {
    // Expandir intervalo se necessário
    a = new Decimal('-0.99'); // -99% (limite inferior razoável)
    b = new Decimal('10');    // 1000% (limite superior razoável)
    fa = calculateNPV(a, cashflows);
    fb = calculateNPV(b, cashflows);
    
    if (fa.mul(fb).isPositive()) {
      return {
        irr: null,
        iterations: 0,
        method: 'brent',
        converged: false,
        diagnostics: {
          noSignChange: true
        }
      };
    }
  }
  
  // Escolher método
  if (forceBisection) {
    return solveBisection(cashflows, a, b, tolerance, maxIterations, multipleRoots);
  } else {
    return solveBrentMethod(cashflows, a, b, fa, fb, tolerance, maxIterations, multipleRoots);
  }
}

/**
 * Método de Brent (implementação completa)
 */
function solveBrentMethod(
  cashflows: Decimal[],
  a: Decimal,
  b: Decimal,
  fa: Decimal,
  fb: Decimal,
  tolerance: Decimal,
  maxIterations: number,
  multipleRoots: boolean
): IRRResult {
  let iterations = 0;
  
  // Garantir que |f(a)| >= |f(b)|
  if (fa.abs().lt(fb.abs())) {
    [a, b] = [b, a];
    [fa, fb] = [fb, fa];
  }
  
  let c = a;
  let fc = fa;
  let d = b.minus(a);
  let e = d;
  
  while (iterations < maxIterations) {
    iterations++;
    
    // Verificar convergência
    if (fb.abs().lt(tolerance)) {
      return {
        irr: b,
        iterations,
        method: 'brent',
        converged: true,
        diagnostics: {
          multipleRoots,
          finalNPV: fb
        }
      };
    }
    
    if (fa.abs().lt(fb.abs())) {
      [a, b, c] = [b, a, b];
      [fa, fb, fc] = [fb, fa, fb];
    }
    
    const tol = new Decimal('2').mul(tolerance).mul(b.abs()).plus(tolerance.div(2));
    const m = c.minus(b).div(2);
    
    if (m.abs().lt(tol) || fb.isZero()) {
      return {
        irr: b,
        iterations,
        method: 'brent',
        converged: true,
        diagnostics: {
          multipleRoots,
          finalNPV: fb
        }
      };
    }
    
    let p: Decimal, q: Decimal, s: Decimal;
    
    if (e.abs().gte(tol) && fa.abs().gt(fb.abs())) {
      const cb = c.minus(b);
      
      if (a.eq(c)) {
        // Secante
        s = fb.div(fa);
        p = cb.mul(s);
        q = new Decimal(1).minus(s);
      } else {
        // Interpolação quadrática inversa
        q = fa.div(fc);
        const r = fb.div(fc);
        s = fb.div(fa);
        p = s.mul(cb.mul(q.minus(r)).mul(q.minus(new Decimal(1))).minus(b.minus(a).mul(r.minus(1))));
        q = q.minus(1).mul(r.minus(1)).mul(s.minus(1));
      }
      
      if (p.isPositive()) {
        q = q.neg();
      } else {
        p = p.neg();
      }
      
      const min1 = new Decimal(3).mul(m).mul(q).minus(tol.mul(q).abs());
      const min2 = e.mul(q).abs();
      
      if (p.mul(2).lt(Decimal.min(min1, min2))) {
        e = d;
        d = p.div(q);
      } else {
        d = m;
        e = d;
      }
    } else {
      // Bissecção
      d = m;
      e = d;
    }
    
    a = b;
    fa = fb;
    
    if (d.abs().gt(tol)) {
      b = b.plus(d);
    } else {
      b = b.plus(m.isPositive() ? tol : tol.neg());
    }
    
    fb = calculateNPV(b, cashflows);
    
    if ((fb.isPositive() && fc.isPositive()) || (fb.isNegative() && fc.isNegative())) {
      c = a;
      fc = fa;
      d = b.minus(a);
      e = d;
    }
  }
  
  return {
    irr: b,
    iterations,
    method: 'brent',
    converged: false,
    diagnostics: {
      multipleRoots,
      finalNPV: fb
    }
  };
}

/**
 * Método de Bissecção (fallback)
 */
function solveBisection(
  cashflows: Decimal[],
  a: Decimal,
  b: Decimal,
  tolerance: Decimal,
  maxIterations: number,
  multipleRoots: boolean
): IRRResult {
  let iterations = 0;
  let fa = calculateNPV(a, cashflows);
  let fb = calculateNPV(b, cashflows);
  
  while (iterations < maxIterations) {
    iterations++;
    
    const mid = a.plus(b).div(2);
    const fmid = calculateNPV(mid, cashflows);
    
    if (fmid.abs().lt(tolerance) || b.minus(a).abs().lt(tolerance)) {
      return {
        irr: mid,
        iterations,
        method: 'bisection',
        converged: true,
        diagnostics: {
          multipleRoots,
          finalNPV: fmid
        }
      };
    }
    
    if (fa.mul(fmid).isNegative()) {
      b = mid;
      fb = fmid;
    } else {
      a = mid;
      fa = fmid;
    }
  }
  
  const mid = a.plus(b).div(2);
  const fmid = calculateNPV(mid, cashflows);
  
  return {
    irr: mid,
    iterations,
    method: 'bisection',
    converged: false,
    diagnostics: {
      multipleRoots,
      finalNPV: fmid
    }
  };
}

/**
 * Converte IRR mensal para anual usando taxa efetiva.
 * 
 * @param irrMonthly - IRR mensal
 * @param baseAnnual - Base anual (default: 12 meses)
 * @returns IRR anualizado
 * 
 * @example
 * ```typescript
 * const irrMonthly = new Decimal('0.025'); // 2.5% a.m.
 * const irrAnnual = convertToAnnual(irrMonthly);
 * // irrAnnual ≈ 0.3449 (34.49% a.a.)
 * ```
 */
export function convertToAnnual(irrMonthly: Decimal, baseAnnual: number = 12): Decimal {
  // IRR_anual = (1 + IRR_mensal)^baseAnnual - 1
  return new Decimal(1).plus(irrMonthly).pow(baseAnnual).minus(1);
}
EOFBRENT

echo "✅ Arquivo brent.ts COMPLETO criado"
echo ""

# ============================================================================
# VERIFICAR EXPORTS
# ============================================================================
echo "🔍 Verificando exports no novo arquivo..."
grep -n "^export function" packages/engine/src/irr/brent.ts
echo ""

# ============================================================================
# VERIFICAR TAMANHO
# ============================================================================
echo "📊 Informações do novo arquivo:"
wc -l packages/engine/src/irr/brent.ts
ls -lh packages/engine/src/irr/brent.ts
echo ""

# ============================================================================
# EXECUTAR TESTES
# ============================================================================
echo "🧪 Executando testes..."
pnpm -C packages/engine exec vitest run test/unit/irr/brent.test.ts

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ =========================================="
    echo "✅ SUCESSO! Todos os testes passaram!"
    echo "✅ =========================================="
    echo ""
    echo "📊 Resumo:"
    echo "   ✓ solveIRR: implementado e testado"
    echo "   ✓ convertToAnnual: implementado e testado"
    echo "   ✓ Algoritmo de Brent: completo"
    echo "   ✓ Fallback bissecção: funcional"
    echo "   ✓ Diagnósticos: implementados"
    echo ""
    echo "🎯 H15 - PARTE 2 (Brent): CONCLUÍDA!"
else
    echo ""
    echo "❌ Ainda há testes falhando. Verificar saída acima."
    exit 1
fi
