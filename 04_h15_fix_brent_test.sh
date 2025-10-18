#!/bin/bash

################################################################################
# SCRIPT: 04_h15_fix_brent_test.sh
# DESCRIÇÃO: H15 - Corrigir teste de Brent para usar solveIRR
# AUTOR: FinMath Team
# DATA: 2025-10-18
# VERSÃO: 1.0.0
################################################################################

set -e

echo "🔧 =========================================="
echo "🔧 H15 - CORREÇÃO: Teste Brent"
echo "🔧 =========================================="
echo ""

cd ~/workspace/fin-math

# ============================================================================
# ATUALIZAR: packages/engine/test/unit/irr/brent.test.ts
# ============================================================================
echo "📝 Atualizando packages/engine/test/unit/irr/brent.test.ts..."

cat > packages/engine/test/unit/irr/brent.test.ts << 'EOFTEST'
/**
 * Testes Unitários: Solver de Brent (IRR)
 * 
 * @see packages/engine/src/irr/brent.ts
 * @see ADR-002 (Solver de IRR: Brent com fallbacks)
 * @see Playbook §4.2 (Matriz de testes IRR)
 */

import { describe, it, expect } from 'vitest';
import { Decimal } from 'decimal.js';
import { solveIRR, convertToAnnual } from '../../../src/irr/brent';

describe('IRR - Solver de Brent (Sprint 4)', () => {
  
  describe('solveIRR - Fluxos regulares', () => {
    
    it('deve convergir para fluxo monotônico típico (Price 12x)', () => {
      // PV=10000, PMT=946.56, n=12
      // Taxa esperada: 2.5% a.m.
      const cashflows = [
        new Decimal('10000'),
        ...Array(12).fill(new Decimal('-946.56'))
      ];
      
      const result = solveIRR(cashflows);
      
      expect(result.converged).toBe(true);
      expect(result.irr).not.toBeNull();
      expect(result.method).toBe('brent');
      expect(result.iterations).toBeGreaterThan(0);
      expect(result.iterations).toBeLessThan(100);
      
      // IRR ≈ 2.5% (tolerância 0.01% = 0.0001)
      const expectedIRR = 0.025;
      const actualIRR = result.irr!.toNumber();
      const relativeError = Math.abs((actualIRR - expectedIRR) / expectedIRR);
      
      expect(relativeError).toBeLessThan(0.0001); // Erro relativo < 0.01%
      
      console.log(`✓ IRR encontrado: ${(actualIRR * 100).toFixed(4)}% (esperado: 2.5000%)`);
      console.log(`✓ Erro relativo: ${(relativeError * 100).toFixed(6)}%`);
      console.log(`✓ Iterações: ${result.iterations}`);
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
      // PV=10000, PMT≈500, n=24
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
      const cashflows = [
        new Decimal('1000'),
        new Decimal('-1500'),
        new Decimal('600')
      ];
      
      const result = solveIRR(cashflows);
      
      expect(result.diagnostics?.multipleRoots).toBe(true);
      
      console.log('✓ Alerta de múltiplas raízes emitido');
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
        ...Array(12).fill(new Decimal('-946.56'))
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
        ...Array(12).fill(new Decimal('-946.56'))
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
        ...Array(12).fill(new Decimal('-946.56'))
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
        ...Array(12).fill(new Decimal('-946.56'))
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
      
      // (1.025)^12 - 1 ≈ 0.3449 = 34.49% a.a.
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
      
      // (1.01)^6 - 1 ≈ 0.0615 = 6.15% a.s.
      expect(irrAnnual.toNumber()).toBeCloseTo(0.0615, 4);
    });
  });
});
EOFTEST

echo "✅ Teste atualizado para usar solveIRR"
echo ""

# ============================================================================
# EXECUTAR TESTES CORRIGIDOS
# ============================================================================
echo "🧪 Executando testes corrigidos..."
pnpm -C packages/engine exec vitest run test/unit/irr/brent.test.ts

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ =========================================="
    echo "✅ TODOS OS TESTES BRENT: PASSARAM"
    echo "✅ =========================================="
    echo ""
    echo "📊 Resumo H15 - Parte 2:"
    echo "   ✓ solveIRR implementado"
    echo "   ✓ Algoritmo de Brent completo"
    echo "   ✓ Fallback para bissecção"
    echo "   ✓ Diagnósticos (multipleRoots, noSignChange)"
    echo "   ✓ 13 testes passando"
    echo ""
    echo "🎯 PRÓXIMO PASSO: Criar Golden Files (05_h15_golden_files.sh)"
else
    echo ""
    echo "❌ Alguns testes ainda falhando. Verificar logs acima."
    exit 1
fi
