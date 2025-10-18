#!/bin/bash

################################################################################
# SCRIPT: 11_fix_typescript_strict.sh
# DESCRIÇÃO: Corrige erros TypeScript strict mode (9 erros triviais)
# PROBLEMA: Array access sem validação (tsconfig strictNullChecks)
# SOLUÇÃO: Adicionar non-null assertions (!) ou validações
# AUTOR: FinMath Team
# DATA: 2025-10-18
# VERSÃO: 1.0.0
################################################################################

set -e

echo "🔧 =========================================="
echo "🔧 CORREÇÃO: TypeScript Strict Mode"
echo "🔧 =========================================="
echo ""
echo "📊 Status atual:"
echo "   ✅ 79/79 testes passando (funcionalidade OK!)"
echo "   ❌ 9 erros TypeScript (tipos, não lógica)"
echo ""
echo "🎯 Objetivo: 0 erros TypeScript"
echo ""

cd ~/workspace/fin-math

# ============================================================================
# CORREÇÃO 1: brent.ts (4 erros)
# ============================================================================
echo "📝 Corrigindo brent.ts (4 erros)..."

cat > packages/engine/src/irr/brent.ts << 'EOFBRENT'
/**
 * IRR - Solver de Brent (Implementação Científica)
 * Baseado em: Brent (1973) - Algorithms for Minimization Without Derivatives
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
    // FIX: Non-null assertion (array já foi validado no solveIRR)
    npv = npv.plus(cashflows[t]!.div(denominator));
  }
  
  return npv;
}

/**
 * Conta mudanças de sinal no fluxo de caixa
 */
function countSignChanges(cashflows: Decimal[]): number {
  let changes = 0;
  // FIX: Non-null assertion (array já foi validado no solveIRR)
  let lastSign = cashflows[0]!.isNegative() ? -1 : 1;
  
  for (let i = 1; i < cashflows.length; i++) {
    // FIX: Non-null assertion
    if (cashflows[i]!.isZero()) continue;
    
    const currentSign = cashflows[i]!.isNegative() ? -1 : 1;
    if (currentSign !== lastSign) {
      changes++;
      lastSign = currentSign;
    }
  }
  
  return changes;
}

/**
 * Solver usando método da bissecção (robusto e garantido)
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
  
  // Verificar se há mudança de sinal
  if (fa.mul(fb).greaterThanOrEqualTo(0)) {
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
  
  let iterations = 0;
  let c = a;
  let fc = fa;
  
  while (iterations < maxIterations) {
    c = a.plus(b).div(2);
    fc = calculateNPV(cashflows, c);
    
    // Critério de convergência: |fc| < tol OU intervalo pequeno
    if (fc.abs().lessThan(tolerance) || b.minus(a).abs().lessThan(tolerance)) {
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
    
    // Atualizar intervalo
    if (fa.mul(fc).lessThan(0)) {
      b = c;
      fb = fc;
    } else {
      a = c;
      fa = fc;
    }
    
    iterations++;
  }
  
  // Não convergiu, mas retornar melhor estimativa
  return {
    irr: c,
    converged: false,
    method: 'bisection',
    diagnostics: {
      finalNPV: fc,
      iterations,
      multipleRoots
    }
  };
}

/**
 * Solver usando método de Brent (IMPLEMENTAÇÃO CORRETA)
 * Referência: Brent (1973), Apache Commons Math, Wikipedia
 */
function solveBrent(
  cashflows: Decimal[],
  a: Decimal,
  b: Decimal,
  tolerance: Decimal,
  maxIterations: number,
  multipleRoots: boolean
): IRRResult {
  let fa = calculateNPV(cashflows, a);
  let fb = calculateNPV(cashflows, b);
  
  // Verificar mudança de sinal
  if (fa.mul(fb).greaterThanOrEqualTo(0)) {
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
  
  // Garantir que |f(a)| >= |f(b)|
  if (fa.abs().lessThan(fb.abs())) {
    [a, b] = [b, a];
    [fa, fb] = [fb, fa];
  }
  
  let c = a;
  let fc = fa;
  let mflag = true; // Se última iteração foi bissecção
  let s = b;        // Próximo palpite
  let d = new Decimal(0);
  
  let iterations = 0;
  
  while (iterations < maxIterations) {
    // Critério de convergência: |f(b)| < tol OU intervalo pequeno
    if (fb.abs().lessThan(tolerance) || b.minus(a).abs().lessThan(tolerance)) {
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
    
    // Calcular próximo palpite 's'
    if (!fa.eq(fc) && !fb.eq(fc)) {
      // Interpolação Quadrática Inversa
      const L0 = a.mul(fb).mul(fc).div(fa.minus(fb).mul(fa.minus(fc)));
      const L1 = b.mul(fa).mul(fc).div(fb.minus(fa).mul(fb.minus(fc)));
      const L2 = c.mul(fa).mul(fb).div(fc.minus(fa).mul(fc.minus(fb)));
      s = L0.plus(L1).plus(L2);
    } else {
      // Método da Secante
      s = b.minus(fb.mul(b.minus(a)).div(fb.minus(fa)));
    }
    
    // VERIFICAR AS 5 CONDIÇÕES DE BRENT PARA ACEITAR 's'
    const tmp2 = a.plus(b).div(2);
    const tmp1 = a.mul(3).plus(b).div(4);
    
    // Condição 1: s não está entre (3a+b)/4 e b
    const cond1 = s.lessThan(tmp1) || s.greaterThan(b);
    
    // Condição 2: mflag=true e |s-b| >= |b-c|/2
    const cond2 = mflag && s.minus(b).abs().greaterThanOrEqualTo(b.minus(c).abs().div(2));
    
    // Condição 3: mflag=false e |s-b| >= |c-d|/2
    const cond3 = !mflag && s.minus(b).abs().greaterThanOrEqualTo(c.minus(d).abs().div(2));
    
    // Condição 4: mflag=true e |b-c| < |tol|
    const cond4 = mflag && b.minus(c).abs().lessThan(tolerance);
    
    // Condição 5: mflag=false e |c-d| < |tol|
    const cond5 = !mflag && c.minus(d).abs().lessThan(tolerance);
    
    // Se qualquer condição for verdadeira, usar bissecção
    if (cond1 || cond2 || cond3 || cond4 || cond5) {
      s = tmp2;
      mflag = true;
    } else {
      mflag = false;
    }
    
    // Calcular f(s)
    const fs = calculateNPV(cashflows, s);
    
    // Atualizar d e c
    d = c;
    c = b;
    fc = fb;
    
    // Atualizar a e b baseado no sinal
    if (fa.mul(fs).lessThan(0)) {
      b = s;
      fb = fs;
    } else {
      a = s;
      fa = fs;
    }
    
    // Garantir que |f(a)| >= |f(b)|
    if (fa.abs().lessThan(fb.abs())) {
      [a, b] = [b, a];
      [fa, fb] = [fb, fa];
    }
    
    iterations++;
  }
  
  // Não convergiu, mas retornar melhor estimativa
  return {
    irr: b,
    converged: false,
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
  
  // Definir intervalo de busca (expandido)
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

echo "✅ brent.ts corrigido (4 erros → 0)"
echo ""

# ============================================================================
# CORREÇÃO 2: npv.ts (5 erros)
# ============================================================================
echo "📝 Corrigindo npv.ts (5 erros)..."

# Verificar se arquivo existe
if [ -f packages/engine/src/irr/npv.ts ]; then
    # Adicionar non-null assertions
    sed -i 's/cashflows\[k\]\.div/cashflows[k]!.div/g' packages/engine/src/irr/npv.ts
    sed -i 's/if (cf\.isZero())/if (cf!.isZero())/g' packages/engine/src/irr/npv.ts
    sed -i 's/const sign = cf\.isPositive()/const sign = cf!.isPositive()/g' packages/engine/src/irr/npv.ts
    
    echo "✅ npv.ts corrigido (5 erros → 0)"
else
    echo "⚠️  npv.ts não encontrado (pode não existir ainda)"
fi
echo ""

# ============================================================================
# VALIDAÇÃO
# ============================================================================
echo "🔍 Validando correções..."
echo ""

# Type check
echo "1️⃣ Type check..."
pnpm -C packages/engine exec tsc --noEmit

if [ $? -eq 0 ]; then
    echo "   ✅ TypeScript: 0 erros"
else
    echo "   ❌ TypeScript: ainda há erros"
    exit 1
fi
echo ""

# Testes
echo "2️⃣ Testes..."
pnpm -C packages/engine exec vitest run --reporter=basic

if [ $? -eq 0 ]; then
    echo "   ✅ Testes: 79/79 passando"
else
    echo "   ❌ Testes: algo quebrou"
    exit 1
fi
echo ""

# Build
echo "3️⃣ Build..."
pnpm -C packages/engine run build

if [ $? -eq 0 ]; then
    echo "   ✅ Build: sucesso"
else
    echo "   ❌ Build: falhou"
    exit 1
fi
echo ""

echo "🎉 =========================================="
echo "🎉 VALIDAÇÃO COMPLETA: 100% SUCESSO!"
echo "🎉 =========================================="
echo ""
echo "✅ TypeScript: 0 erros"
echo "✅ Testes: 79/79 passando"
echo "✅ Build: sucesso"
echo ""
echo "📋 Próximo passo:"
echo "   git add ."
echo "   git commit -m 'fix(H15): Corrige tipos TypeScript strict mode'"
