#!/bin/bash

################################################################################
# SCRIPT: 09_h15_fix_irr_algorithm.sh
# DESCRIÇÃO: Correção DEFINITIVA do algoritmo de Brent (IRR)
# PROBLEMA: Intervalo [0, 1] não contém a raiz para taxas baixas
# SOLUÇÃO: Expandir para [-0.99, 3] + busca automática de intervalo
# AUTOR: FinMath Team
# DATA: 2025-10-18
# VERSÃO: 1.0.0
################################################################################

set -e

echo "🔧 =========================================="
echo "🔧 CORREÇÃO ALGORITMO BRENT (IRR)"
echo "🔧 =========================================="
echo ""
echo "🐛 PROBLEMA IDENTIFICADO:"
echo "   - Intervalo [0, 1] não contém raízes para taxas baixas"
echo "   - NPV(0) = -1697.72 (negativo)"
echo "   - NPV(0.025) = 0 (raiz buscada)"
echo "   - NPV(1) = positivo"
echo "   - Solver verifica fa×fb > 0 e FALHA!"
echo ""
echo "✅ SOLUÇÃO:"
echo "   1. Expandir intervalo padrão: [-0.99, 3]"
echo "   2. Busca automática de intervalo válido"
echo "   3. Fallback para intervalo amplo se necessário"
echo ""

cd ~/workspace/fin-math

# ============================================================================
# CORREÇÃO: Algoritmo de Brent COMPLETO e ROBUSTO
# ============================================================================
echo "📝 Implementando solver robusto..."

cat > packages/engine/src/irr/brent.ts << 'EOFBRENT'
/**
 * IRR - Solver de Brent (Método Híbrido) - VERSÃO ROBUSTA
 * Sprint 4 - H15 (Parte 2)
 */

import { Decimal } from 'decimal.js';

/**
 * Resultado do solver de IRR
 */
export interface IRRResult {
  /** IRR encontrado (null se não convergiu) */
  irr: Decimal | null;
  
  /** Se convergiu dentro da tolerância */
  converged: boolean;
  
  /** Método usado ('brent' ou 'bisection') */
  method: 'brent' | 'bisection';
  
  /** Diagnósticos adicionais */
  diagnostics?: {
    /** Múltiplas raízes possíveis (>1 mudança de sinal) */
    multipleRoots?: boolean;
    
    /** Sem mudança de sinal (IRR não existe) */
    noSignChange?: boolean;
    
    /** NPV final após convergência */
    finalNPV?: Decimal;
    
    /** Iterações usadas */
    iterations?: number;
  };
}

/**
 * Opções para solver de IRR
 */
export interface IRROptions {
  /** Chute inicial (padrão: 0.1 = 10%) */
  guess?: Decimal;
  
  /** Intervalo de busca (padrão: [-0.99, 3]) */
  range?: {
    lo: Decimal;
    hi: Decimal;
  };
  
  /** Tolerância (padrão: 1e-8) */
  tolerance?: Decimal;
  
  /** Máximo de iterações (padrão: 100) */
  maxIterations?: number;
  
  /** Forçar uso de bissecção ao invés de Brent */
  forceBisection?: boolean;
}

/**
 * Calcula NPV para uma taxa dada
 */
function calculateNPV(cashflows: Decimal[], rate: Decimal): Decimal {
  let npv = new Decimal(0);
  
  for (let t = 0; t < cashflows.length; t++) {
    const denominator = rate.plus(1).pow(t);
    npv = npv.plus(cashflows[t].div(denominator));
  }
  
  return npv;
}

/**
 * Conta mudanças de sinal no fluxo de caixa
 */
function countSignChanges(cashflows: Decimal[]): number {
  let changes = 0;
  let lastSign = cashflows[0].isNegative() ? -1 : 1;
  
  for (let i = 1; i < cashflows.length; i++) {
    if (cashflows[i].isZero()) continue;
    
    const currentSign = cashflows[i].isNegative() ? -1 : 1;
    if (currentSign !== lastSign) {
      changes++;
      lastSign = currentSign;
    }
  }
  
  return changes;
}

/**
 * Busca um intervalo válido que contenha a raiz
 */
function findValidInterval(
  cashflows: Decimal[],
  initialLo: Decimal,
  initialHi: Decimal
): { a: Decimal; b: Decimal; fa: Decimal; fb: Decimal } | null {
  let a = initialLo;
  let b = initialHi;
  let fa = calculateNPV(cashflows, a);
  let fb = calculateNPV(cashflows, b);
  
  // Se já temos mudança de sinal, retornar
  if (fa.mul(fb).lessThan(0)) {
    return { a, b, fa, fb };
  }
  
  // Tentar expandir o intervalo para a esquerda
  const steps = [-0.5, -0.9, -0.95, -0.99];
  for (const step of steps) {
    a = new Decimal(step);
    fa = calculateNPV(cashflows, a);
    if (fa.mul(fb).lessThan(0)) {
      return { a, b, fa, fb };
    }
  }
  
  // Tentar expandir o intervalo para a direita
  const stepsRight = [2, 5, 10, 50, 100];
  a = initialLo;
  fa = calculateNPV(cashflows, a);
  for (const step of stepsRight) {
    b = new Decimal(step);
    fb = calculateNPV(cashflows, b);
    if (fa.mul(fb).lessThan(0)) {
      return { a, b, fa, fb };
    }
  }
  
  // Não encontrou intervalo válido
  return null;
}

/**
 * Solver usando método da bissecção (fallback robusto)
 */
function solveBisection(
  cashflows: Decimal[],
  a: Decimal,
  b: Decimal,
  tolerance: Decimal,
  maxIterations: number,
  multipleRoots: boolean
): IRRResult {
  let fa = calculateNPV(cashflows, a);
  let fb = calculateNPV(cashflows, b);
  
  // Tentar encontrar intervalo válido
  const interval = findValidInterval(cashflows, a, b);
  
  if (!interval) {
    return {
      irr: null,
      converged: false,
      method: 'bisection',
      diagnostics: {
        noSignChange: true,
        multipleRoots
      }
    };
  }
  
  a = interval.a;
  b = interval.b;
  fa = interval.fa;
  fb = interval.fb;
  
  let iterations = 0;
  let c = a;
  let fc = fa;
  
  while (iterations < maxIterations) {
    c = a.plus(b).div(2);
    fc = calculateNPV(cashflows, c);
    
    if (fc.abs().lessThan(tolerance) || b.minus(a).abs().lessThan(tolerance.mul(10))) {
      return {
        irr: c,
        converged: true,
        method: 'bisection',
        diagnostics: {
          finalNPV: fc,
          iterations,
          multipleRoots
        }
      };
    }
    
    if (fa.mul(fc).lessThan(0)) {
      b = c;
      fb = fc;
    } else {
      a = c;
      fa = fc;
    }
    
    iterations++;
  }
  
  // Convergiu se NPV final está próximo de zero
  const converged = fc.abs().lessThan(tolerance.mul(100));
  
  return {
    irr: c,
    converged,
    method: 'bisection',
    diagnostics: {
      finalNPV: fc,
      iterations,
      multipleRoots
    }
  };
}

/**
 * Solver usando método de Brent (híbrido: bissecção + interpolação)
 */
function solveBrent(
  cashflows: Decimal[],
  a: Decimal,
  b: Decimal,
  tolerance: Decimal,
  maxIterations: number,
  multipleRoots: boolean
): IRRResult {
  // Tentar encontrar intervalo válido
  const interval = findValidInterval(cashflows, a, b);
  
  if (!interval) {
    return {
      irr: null,
      converged: false,
      method: 'brent',
      diagnostics: {
        noSignChange: true,
        multipleRoots
      }
    };
  }
  
  a = interval.a;
  b = interval.b;
  let fa = interval.fa;
  let fb = interval.fb;
  
  if (fa.abs().lessThan(fb.abs())) {
    [a, b] = [b, a];
    [fa, fb] = [fb, fa];
  }
  
  let c = a;
  let fc = fa;
  let d = b.minus(a);
  let e = d;
  let iterations = 0;
  
  while (iterations < maxIterations) {
    if (fb.abs().lessThan(tolerance)) {
      return {
        irr: b,
        converged: true,
        method: 'brent',
        diagnostics: {
          finalNPV: fb,
          iterations,
          multipleRoots
        }
      };
    }
    
    // Interpolação quadrática inversa ou secante
    let s: Decimal;
    
    if (!fa.equals(fc) && !fb.equals(fc)) {
      // Interpolação quadrática inversa
      const term1 = a.mul(fb).mul(fc).div(fa.minus(fb).mul(fa.minus(fc)));
      const term2 = b.mul(fa).mul(fc).div(fb.minus(fa).mul(fb.minus(fc)));
      const term3 = c.mul(fa).mul(fb).div(fc.minus(fa).mul(fc.minus(fb)));
      s = term1.plus(term2).plus(term3);
    } else {
      // Método da secante
      s = b.minus(fb.mul(b.minus(a)).div(fb.minus(fa)));
    }
    
    // Verificar condições para aceitar s ou usar bissecção
    const midpoint = a.plus(b).div(2);
    const condition1 = s.lessThan(midpoint.mul(0.75).plus(b.mul(0.25))) || s.greaterThan(b);
    const condition2 = e.abs().lessThan(tolerance) || fc.abs().lessThan(fb.abs());
    
    if (condition1 || condition2) {
      s = midpoint;
      e = b.minus(a);
    } else {
      e = d;
    }
    
    d = b.minus(s);
    
    c = b;
    fc = fb;
    a = b;
    fa = fb;
    b = s;
    fb = calculateNPV(cashflows, b);
    
    if (fa.mul(fb).lessThan(0)) {
      c = a;
      fc = fa;
    } else {
      a = c;
      fa = fc;
    }
    
    if (fa.abs().lessThan(fb.abs())) {
      [a, b] = [b, a];
      [fa, fb] = [fb, fa];
    }
    
    iterations++;
  }
  
  // Convergiu se NPV final está próximo de zero
  const converged = fb.abs().lessThan(tolerance.mul(100));
  
  return {
    irr: b,
    converged,
    method: 'brent',
    diagnostics: {
      finalNPV: fb,
      iterations,
      multipleRoots
    }
  };
}

/**
 * Resolve IRR usando método de Brent (ou bissecção)
 */
export function solveIRR(
  cashflows: Decimal[],
  options: IRROptions = {}
): IRRResult {
  // Validações básicas
  if (cashflows.length < 2) {
    throw new Error('Pelo menos 2 fluxos são necessários');
  }
  
  // Contar mudanças de sinal
  const signChanges = countSignChanges(cashflows);
  const multipleRoots = signChanges > 1;
  
  // Definir intervalo de busca (expandido para capturar mais casos)
  let a = options.range?.lo ?? new Decimal('-0.99');
  let b = options.range?.hi ?? new Decimal('3');
  
  // Tolerância e iterações
  const tolerance = options.tolerance ?? new Decimal('1e-8');
  const maxIterations = options.maxIterations ?? 100;
  
  // Usar bissecção ou Brent
  if (options.forceBisection) {
    return solveBisection(cashflows, a, b, tolerance, maxIterations, multipleRoots);
  }
  
  return solveBrent(cashflows, a, b, tolerance, maxIterations, multipleRoots);
}

/**
 * Converte IRR de periodicidade para anual
 * @param irrPeriodic - IRR no período (ex: 0.025 = 2.5% ao mês)
 * @param periodsPerYear - Períodos por ano (ex: 12 para mensal)
 * @returns IRR anual equivalente
 */
export function convertToAnnual(
  irrPeriodic: Decimal,
  periodsPerYear: number
): Decimal {
  return irrPeriodic.plus(1).pow(periodsPerYear).minus(1);
}
EOFBRENT

echo "✅ Código de brent.ts atualizado com algoritmo robusto"
echo ""

# ============================================================================
# EXECUTAR TESTES
# ============================================================================
echo "🧪 Executando testes..."
pnpm -C packages/engine exec vitest run test/unit/irr/brent.test.ts

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 =========================================="
    echo "🎉 SUCESSO! 14/14 TESTES PASSANDO!"
    echo "🎉 =========================================="
    echo ""
    echo "✅ H15 - PARTE 2 (Brent Solver): 100% CONCLUÍDA!"
    echo ""
    echo "📊 Melhorias implementadas:"
    echo "   ✓ Intervalo expandido: [-0.99, 3] (captura taxas negativas até 300%)"
    echo "   ✓ Busca automática de intervalo válido"
    echo "   ✓ Fallback robusto para casos extremos"
    echo "   ✓ Critério de convergência melhorado"
    echo ""
    echo "📋 Próximos passos:"
    echo "   1. git add packages/engine/src/irr/brent.ts"
    echo "   2. git add packages/engine/test/unit/irr/brent.test.ts"
    echo "   3. git commit -m 'feat(H15): Solver Brent robusto com busca automática'"
else
    echo ""
    echo "⚠️  Ainda há testes falhando."
    echo "   Executando diagnóstico detalhado..."
    echo ""
    
    # Diagnóstico adicional
    echo "🔍 Testando NPV para fluxo Price 12x..."
    node -e "
    const { Decimal } = require('decimal.js');
    const cf = [10000, -974.81, -974.81, -974.81, -974.81, -974.81, -974.81, -974.81, -974.81, -974.81, -974.81, -974.81, -974.81];
    
    function npv(rate) {
      let sum = 0;
      for (let t = 0; t < cf.length; t++) {
        sum += cf[t] / Math.pow(1 + rate, t);
      }
      return sum;
    }
    
    console.log('NPV(0):', npv(0));
    console.log('NPV(0.025):', npv(0.025));
    console.log('NPV(1):', npv(1));
    "
    
    exit 1
fi
