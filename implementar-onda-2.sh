#!/bin/bash
# ============================================
# SCRIPT: implementar-onda-2.sh
# OBJETIVO: Implementar H9 (Sistema PRICE)
# ONDA: 2
# BASEADO EM: Lições ONDA 0 e ONDA 1
# ============================================

set -e

echo "🚀 IMPLEMENTANDO ONDA 2: H9 (Sistema PRICE)"
echo "Data: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "💡 IMPORTANTE: Este script cria a estrutura."
echo "   Arquivos TypeScript serão criados via NANO (não heredoc!)"
echo ""

# ============================================
# 0. PREPARAÇÃO
# ============================================
echo "📋 0. Preparação..."

# Limpar backups
echo "  → Limpando backups físicos..."
./limpar-backups.sh > /dev/null 2>&1 || true
echo "  ✅ Backups limpos"

# Verificar branch
BRANCH=$(git branch --show-current)
if [ "$BRANCH" != "sprint-2" ]; then
    echo "  ⚠️  Aviso: Branch atual é '$BRANCH' (esperado: sprint-2)"
fi

echo ""

# ============================================
# 1. ESTRUTURA DE DIRETÓRIOS
# ============================================
echo "📁 1. Criando estrutura de diretórios..."

mkdir -p packages/engine/src/amortization
mkdir -p packages/engine/test/unit/amortization
mkdir -p packages/engine/test/golden/onda2
mkdir -p packages/api/src/routes
mkdir -p packages/api/src/schemas
mkdir -p packages/api/test/integration

echo "  ✅ Diretórios criados"
echo ""

# ============================================
# 2. CRIAR ARQUIVOS DO MOTOR (VIA NANO)
# ============================================
echo "📦 2. Criando arquivos do motor..."
echo "  💡 ATENÇÃO: Você vai editar 3 arquivos TypeScript no nano"
echo ""

# 2.1 price.ts
echo "  📝 Criando: packages/engine/src/amortization/price.ts"
echo "     Aguarde o nano abrir..."
sleep 2

./criar-arquivo-ts.sh packages/engine/src/amortization/price.ts

# 2.2 index.ts do amortization
echo ""
echo "  📝 Criando: packages/engine/src/amortization/index.ts"
echo "     Aguarde o nano abrir..."
sleep 2

cat > packages/engine/src/amortization/index.ts << 'EOF'
/**
 * Amortization Systems Module
 * PRICE and SAC amortization systems
 */

export {
  calculatePMT,
  generatePriceSchedule,
  type PriceInput,
  type PriceScheduleRow,
  type PriceResult
} from './price';
EOF

echo "  ✅ index.ts criado"

# 2.3 Atualizar index.ts do motor
echo ""
echo "  📝 Atualizando: packages/engine/src/index.ts"

cat > packages/engine/src/index.ts << 'EOF'
/**
 * @finmath/engine
 * Financial mathematics calculation engine
 */

import * as interestModule from './modules/interest';
import * as rateModule from './modules/rate';
import * as seriesModule from './modules/series';
import * as amortizationModule from './modules/amortization';
import * as irrModule from './modules/irr';
import * as cetModule from './modules/cet';

// Export as namespaces (for backward compatibility with tests)
export const interest = interestModule;
export const rate = rateModule;
export const series = seriesModule;
export const amortization = amortizationModule;
export const irr = irrModule;
export const cet = cetModule;

// Export utilities
export * from './util/round';

// Day count conventions (ONDA 1)
export * from './day-count';

// Amortization systems (ONDA 2)
export * from './amortization';

// Version
export const ENGINE_VERSION = '0.4.0';
EOF

echo "  ✅ Motor index.ts atualizado (v0.4.0)"
echo ""

# ============================================
# 3. TESTES UNITÁRIOS DO MOTOR
# ============================================
echo "🧪 3. Criando testes unitários..."

./criar-arquivo-ts.sh packages/engine/test/unit/amortization/price.test.ts

echo ""

# ============================================
# 4. GOLDEN FILES
# ============================================
echo "📄 4. Criando Golden Files..."

# PRICE_001
cat > packages/engine/test/golden/onda2/PRICE_001.json << 'EOF'
{
  "id": "PRICE_001",
  "description": "PRICE básico - 12 meses",
  "motorVersion": "0.4.0",
  "input": {
    "pv": "10000.00",
    "annualRate": "0.12",
    "n": 12
  },
  "expected": {
    "pmt": "888.49",
    "schedule": {
      "rows": 12,
      "firstPayment": {
        "period": 1,
        "pmt": "888.49",
        "interest": "100.00",
        "amortization": "788.49",
        "balance": "9211.51"
      },
      "lastPayment": {
        "period": 12,
        "balance": 0.00
      }
    }
  },
  "tolerance": {
    "pmt": 0.01,
    "balance": 0.01
  }
}
EOF

# PRICE_002
cat > packages/engine/test/golden/onda2/PRICE_002.json << 'EOF'
{
  "id": "PRICE_002",
  "description": "PRICE - 24 meses",
  "motorVersion": "0.4.0",
  "input": {
    "pv": "50000.00",
    "annualRate": "0.15",
    "n": 24
  },
  "expected": {
    "pmt": "2543.16",
    "schedule": {
      "rows": 24,
      "lastPayment": {
        "period": 24,
        "balance": 0.00
      }
    }
  },
  "tolerance": {
    "pmt": 0.01,
    "balance": 0.01
  }
}
EOF

# PRICE_003
cat > packages/engine/test/golden/onda2/PRICE_003.json << 'EOF'
{
  "id": "PRICE_003",
  "description": "PRICE - 36 meses com ajuste final",
  "motorVersion": "0.4.0",
  "input": {
    "pv": "100000.00",
    "annualRate": "0.10",
    "n": 36
  },
  "expected": {
    "pmt": "3226.72",
    "schedule": {
      "rows": 36,
      "lastPayment": {
        "period": 36,
        "balance": 0.00
      }
    }
  },
  "tolerance": {
    "pmt": 0.01,
    "balance": 0.01
  }
}
EOF

# Runner
cat > packages/engine/test/golden/onda2/runner.test.ts << 'EOF'
import { describe, it, expect } from 'vitest';
import { readdirSync, readFileSync } from 'fs';
import { join } from 'path';
import { generatePriceSchedule } from '../../../src/amortization/price';
import { Decimal } from 'decimal.js';

describe('Golden Files - ONDA 2 (PRICE)', () => {
  const goldenDir = __dirname;
  const goldenFiles = readdirSync(goldenDir)
    .filter(f => f.startsWith('PRICE_') && f.endsWith('.json'));

  goldenFiles.forEach(filename => {
    it(`should match ${filename}`, () => {
      const filepath = join(goldenDir, filename);
      const golden = JSON.parse(readFileSync(filepath, 'utf-8'));

      const result = generatePriceSchedule({
        pv: new Decimal(golden.input.pv),
        annualRate: new Decimal(golden.input.annualRate),
        n: golden.input.n
      });

      // Validate PMT
      const pmtDiff = Math.abs(
        result.pmt.toNumber() - parseFloat(golden.expected.pmt)
      );
      expect(pmtDiff).toBeLessThanOrEqual(golden.tolerance.pmt);

      // Validate schedule rows
      expect(result.schedule.length).toBe(golden.expected.schedule.rows);

      // Validate first payment if specified
      if (golden.expected.schedule.firstPayment) {
        const first = result.schedule[0];
        expect(first.period).toBe(golden.expected.schedule.firstPayment.period);
      }

      // Validate last payment balance
      const last = result.schedule[result.schedule.length - 1];
      const balanceDiff = Math.abs(last.balance.toNumber());
      expect(balanceDiff).toBeLessThanOrEqual(golden.tolerance.balance);
    });
  });
});
EOF

echo "  ✅ Golden Files criados (3 arquivos + runner)"
echo ""

# ============================================
# 5. API - SCHEMAS E ROUTES
# ============================================
echo "🌐 5. Criando API..."

# Schema
./criar-arquivo-ts.sh packages/api/src/schemas/price.schema.ts

echo ""

# Route
./criar-arquivo-ts.sh packages/api/src/routes/price.routes.ts

echo ""

# Atualizar server.ts
echo "  📝 Atualizando server.ts para incluir route PRICE..."

# Instrução manual porque server.ts já existe
echo ""
echo "  ⚠️  AÇÃO MANUAL NECESSÁRIA:"
echo "     Abra: packages/api/src/server.ts"
echo "     Adicione após dayCountRoutes:"
echo ""
echo "     import { priceRoutes } from './routes/price.routes';"
echo "     ..."
echo "     await fastify.register(priceRoutes, { prefix: '/api' });"
echo ""
echo "     Pressione ENTER quando terminar..."
read

echo "  ✅ Server.ts atualizado"
echo ""

# ============================================
# 6. TESTES DE INTEGRAÇÃO API
# ============================================
echo "🧪 6. Criando testes de integração..."

./criar-arquivo-ts.sh packages/api/test/integration/price.test.ts

echo ""

# ============================================
# 7. ATUALIZAR VERSÃO
# ============================================
echo "📝 7. Atualizando versão do motor..."

cd packages/engine
npm version 0.4.0 --no-git-tag-version > /dev/null 2>&1
cd ../..

echo "  ✅ Motor atualizado para v0.4.0"
echo ""

# ============================================
# RESUMO FINAL
# ============================================
echo "=========================================="
echo "✅ ONDA 2 ESTRUTURA CRIADA!"
echo "=========================================="
echo ""
echo "📊 Arquivos criados:"
echo "   Motor:"
echo "   - src/amortization/price.ts"
echo "   - src/amortization/index.ts"
echo "   - test/unit/amortization/price.test.ts"
echo "   - test/golden/onda2/PRICE_001-003.json"
echo "   - test/golden/onda2/runner.test.ts"
echo ""
echo "   API:"
echo "   - src/schemas/price.schema.ts"
echo "   - src/routes/price.routes.ts"
echo "   - test/integration/price.test.ts"
echo ""
echo "🎯 PRÓXIMO PASSO:"
echo "   Execute: ./validar-onda-2.sh"
echo ""
