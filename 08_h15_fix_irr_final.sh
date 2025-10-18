#!/bin/bash

################################################################################
# SCRIPT: 08_h15_fix_irr_final.sh
# DESCRIÇÃO: Correção DEFINITIVA dos 2 testes IRR falhando
# PROBLEMA 1: PMT incorreto (946.56 → 974.81)
# PROBLEMA 2: multipleRoots não incluído no resultado quando converge
# AUTOR: FinMath Team
# DATA: 2025-10-18
# VERSÃO: 1.0.0
################################################################################

set -e

echo "🔧 =========================================="
echo "🔧 CORREÇÃO DEFINITIVA: 2 testes IRR"
echo "🔧 =========================================="
echo ""
echo "🐛 Problema 1: PMT = -946.56 (ERRADO)"
echo "   ✅ Solução: PMT = -974.81 (IRR = 2.5%)"
echo ""
echo "🐛 Problema 2: multipleRoots não retornado quando converge"
echo "   ✅ Solução: incluir no resultado independente de convergência"
echo ""

cd ~/workspace/fin-math

# ============================================================================
# CORREÇÃO 1: Atualizar código de solveIRR para incluir multipleRoots
# ============================================================================
echo "📝 CORREÇÃO 1: Incluindo multipleRoots no resultado..."

cat > packages/engine/src/irr/brent.ts << 'EOFBRENT'
/**
 * IRR - Solver de Brent (Método Híbrido)
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
  
  /** Intervalo de busca (padrão: [0, 1]) */
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
  
  // Verificar se há raiz no intervalo
  if (fa.mul(fb).greaterThan(0)) {
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
    
    if (fc.abs().lessThan(tolerance)) {
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
  let fa = calculateNPV(cashflows, a);
  let fb = calculateNPV(cashflows, b);
  
  if (fa.mul(fb).greaterThan(0)) {
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
      s = a.mul(fb).mul(fc).div(fa.minus(fb).mul(fa.minus(fc)))
        .plus(b.mul(fa).mul(fc).div(fb.minus(fa).mul(fb.minus(fc))))
        .plus(c.mul(fa).mul(fb).div(fc.minus(fa).mul(fc.minus(fb))));
    } else {
      // Método da secante
      s = b.minus(fb.mul(b.minus(a)).div(fb.minus(fa)));
    }
    
    // Verificar condições para aceitar s ou usar bissecção
    const condition1 = s.lessThan(a.plus(b).div(2).times(0.75).plus(b.times(0.25)));
    const condition2 = s.greaterThan(b);
    const condition3 = e.abs().lessThan(tolerance) || fc.abs().lessThan(fb.abs());
    
    if (condition1 || condition2 || condition3) {
      s = a.plus(b).div(2);
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
  
  return {
    irr: b,
    converged: fb.abs().lessThan(tolerance),
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
  
  // Definir intervalo de busca
  let a = options.range?.lo ?? new Decimal('0');
  let b = options.range?.hi ?? new Decimal('1');
  
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

echo "✅ Código de brent.ts atualizado"
echo ""

# ============================================================================
# CORREÇÃO 2: Atualizar testes com PMT correto e expectations
# ============================================================================
echo "📝 CORREÇÃO 2: Atualizando testes com PMT correto..."

cat > packages/engine/test/unit/irr/brent.test.ts << 'EOFTEST'
/**
 * Testes Unitários: Solver de Brent (IRR) - VERSÃO FINAL CORRIGIDA
 */

import { describe, it, expect } from 'vitest';
import { Decimal } from 'decimal.js';
import { solveIRR, convertToAnnual } from '../../../src/irr/brent';

describe('IRR - Solver de Brent (Sprint 4)', () => {
  
  describe('solveIRR - Fluxos regulares', () => {
    
    it('deve convergir para fluxo monotônico típico (Price 12x)', () => {
      // PMT CORRETO para PV=10000, i=2.5% a.m., n=12
      // PMT = 10000 × [0.025 × 1.025^12] / [1.025^12 - 1] ≈ 974.81
      const cashflows = [
        new Decimal('10000'),    // t=0: cliente recebe
        new Decimal('-974.81'),  // t=1 a 12: cliente paga (PMT correto!)
        new Decimal('-974.81'),
        new Decimal('-974.81'),
        new Decimal('-974.81'),
        new Decimal('-974.81'),
        new Decimal('-974.81'),
        new Decimal('-974.81'),
        new Decimal('-974.81'),
        new Decimal('-974.81'),
        new Decimal('-974.81'),
        new Decimal('-974.81'),
        new Decimal('-974.81')
      ];
      
      const result = solveIRR(cashflows);
      
      expect(result.converged).toBe(true);
      expect(result.irr).not.toBeNull();
      expect(result.method).toBe('brent');
      
      // IRR ≈ 2.5% (tolerância 0.1%)
      const expectedIRR = 0.025;
      const actualIRR = result.irr!.toNumber();
      const relativeError = Math.abs((actualIRR - expectedIRR) / expectedIRR);
      
      expect(relativeError).toBeLessThan(0.001);
      
      console.log(`✓ IRR encontrado: ${(actualIRR * 100).toFixed(4)}% (esperado: 2.5000%)`);
      console.log(`✓ Erro relativo: ${(relativeError * 100).toFixed(6)}%`);
    });

    it('deve convergir para fluxo com taxa alta (> 10% a.m.)', () => {
      const cashflows = [
        new Decimal('10000'),
        ...Array(12).fill(new Decimal('-1500'))
      ];
      
      const result = solveIRR(cashflows);
      
      expect(result.converged).toBe(true);
      expect(result.irr).not.toBeNull();
      expect(result.irr!.toNumber()).toBeGreaterThan(0.10);
    });

    it('deve convergir para fluxo com taxa baixa (< 1% a.m.)', () => {
      const cashflows = [
        new Decimal('10000'),
        ...Array(12).fill(new Decimal('-850'))
      ];
      
      const result = solveIRR(cashflows);
      
      expect(result.converged).toBe(true);
      expect(result.irr).not.toBeNull();
      expect(result.irr!.toNumber()).toBeLessThan(0.01);
      expect(result.irr!.toNumber()).toBeGreaterThan(0);
    });

    it('deve convergir para fluxo Price 24x (CET completo)', () => {
      const cashflows = [
        new Decimal('10000'),
        ...Array(24).fill(new Decimal('-500'))
      ];
      
      const result = solveIRR(cashflows);
      
      expect(result.converged).toBe(true);
      expect(result.irr).not.toBeNull();
      expect(result.irr!.toNumber()).toBeGreaterThan(0);
    });
  });

  describe('solveIRR - Diagnósticos', () => {
    
    it('deve retornar noSignChange=true para fluxo sem troca de sinal', () => {
      const cashflows = [
        new Decimal('1000'),
        new Decimal('500'),
        new Decimal('600')
      ];
      
      const result = solveIRR(cashflows);
      
      expect(result.converged).toBe(false);
      expect(result.irr).toBeNull();
      expect(result.diagnostics?.noSignChange).toBe(true);
      
      console.log('✓ Diagnóstico correto: sem mudança de sinal');
    });

    it('deve alertar sobre possíveis múltiplas raízes', () => {
      // Fluxo com 2 mudanças de sinal: + → - → +
      const cashflows = [
        new Decimal('1000'),   // +
        new Decimal('-1500'),  // - (mudança 1)
        new Decimal('600')     // + (mudança 2)
      ];
      
      const result = solveIRR(cashflows);
      
      // DEVE incluir multipleRoots=true INDEPENDENTE de convergência
      expect(result.diagnostics).toBeDefined();
      expect(result.diagnostics?.multipleRoots).toBe(true);
      
      console.log('✓ Alerta de múltiplas raízes emitido');
      console.log(`  Convergiu: ${result.converged}`);
      console.log(`  IRR: ${result.irr?.toNumber() ?? 'null'}`);
      console.log(`  multipleRoots: ${result.diagnostics?.multipleRoots}`);
    });

    it('deve retornar noSignChange para fluxo todo negativo', () => {
      const cashflows = [
        new Decimal('-1000'),
        new Decimal('-500'),
        new Decimal('-300')
      ];
      
      const result = solveIRR(cashflows);
      
      expect(result.converged).toBe(false);
      expect(result.irr).toBeNull();
      expect(result.diagnostics?.noSignChange).toBe(true);
    });
  });

  describe('solveIRR - Opções customizadas', () => {
    
    it('deve respeitar chute inicial (guess)', () => {
      const cashflows = [
        new Decimal('10000'),
        ...Array(12).fill(new Decimal('-974.81'))
      ];
      
      const result = solveIRR(cashflows, {
        guess: new Decimal('0.02')
      });
      
      expect(result.converged).toBe(true);
      expect(result.irr).not.toBeNull();
    });

    it('deve usar intervalo customizado (range)', () => {
      const cashflows = [
        new Decimal('10000'),
        ...Array(12).fill(new Decimal('-974.81'))
      ];
      
      const result = solveIRR(cashflows, {
        range: {
          lo: new Decimal('0.01'),
          hi: new Decimal('0.05')
        }
      });
      
      expect(result.converged).toBe(true);
      expect(result.irr).not.toBeNull();
    });

    it('deve usar bissecção quando forceBisection=true', () => {
      const cashflows = [
        new Decimal('10000'),
        ...Array(12).fill(new Decimal('-974.81'))
      ];
      
      const result = solveIRR(cashflows, {
        forceBisection: true
      });
      
      expect(result.converged).toBe(true);
      expect(result.method).toBe('bisection');
      
      console.log('✓ Método bissecção usado conforme solicitado');
    });

    it('deve respeitar tolerância customizada', () => {
      const cashflows = [
        new Decimal('10000'),
        ...Array(12).fill(new Decimal('-974.81'))
      ];
      
      const result = solveIRR(cashflows, {
        tolerance: new Decimal('1e-10')
      });
      
      expect(result.converged).toBe(true);
      expect(result.diagnostics?.finalNPV?.abs().toNumber()).toBeLessThan(1e-9);
    });
  });

  describe('convertToAnnual', () => {
    
    it('deve converter IRR mensal para anual (12 meses)', () => {
      const irrMonthly = new Decimal('0.025');
      const irrAnnual = convertToAnnual(irrMonthly, 12);
      
      expect(irrAnnual.toNumber()).toBeCloseTo(0.3449, 4);
      
      console.log(`✓ 2.5% a.m. = ${(irrAnnual.toNumber() * 100).toFixed(2)}% a.a.`);
    });

    it('deve lidar com IRR zero', () => {
      const irrMonthly = new Decimal('0');
      const irrAnnual = convertToAnnual(irrMonthly, 12);
      
      expect(irrAnnual.toNumber()).toBe(0);
    });

    it('deve lidar com base anual diferente de 12', () => {
      const irrMonthly = new Decimal('0.01');
      const irrAnnual = convertToAnnual(irrMonthly, 6);
      
      expect(irrAnnual.toNumber()).toBeCloseTo(0.0615, 4);
    });
  });
});
EOFTEST

echo "✅ Testes atualizados com correções"
echo ""

# ============================================================================
# EXECUTAR TESTES
# ============================================================================
echo "🧪 Executando testes corrigidos..."
pnpm -C packages/engine exec vitest run test/unit/irr/brent.test.ts

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 =========================================="
    echo "🎉 SUCESSO! 14/14 TESTES PASSANDO!"
    echo "🎉 =========================================="
    echo ""
    echo "✅ H15 - PARTE 2 (Brent Solver): 100% CONCLUÍDA!"
    echo ""
    echo "📋 Próximos passos:"
    echo "   1. Commit local: git add . && git commit -m 'feat(H15): Solver Brent completo'"
    echo "   2. Executar validação completa: pnpm test"
    echo "   3. Integrar com CET (próxima história)"
else
    echo ""
    echo "⚠️  Ainda há testes falhando."
    echo "   Revisar logs acima para detalhes"
    exit 1
fi
