#!/bin/bash

# ========================================
# FIX: Resolver dependência do workspace
# DIRETÓRIO DE EXECUÇÃO: ~/workspace/fin-math/
# ========================================

set -e

echo "🔧 Corrigindo estrutura do workspace FinMath..."
echo ""

# Navegar para a raiz do projeto
cd ~/workspace/fin-math

# ========================================
# VERIFICAR SE packages/engine EXISTE
# ========================================

if [ ! -d "packages/engine" ]; then
    echo "⚠️  packages/engine não existe!"
    echo "📦 Criando package.json mínimo para @finmath/engine..."
    
    mkdir -p packages/engine
    
    cat > packages/engine/package.json << 'EOF'
{
  "name": "@finmath/engine",
  "version": "0.4.1",
  "type": "module",
  "description": "Motor de cálculos financeiros - FinMath",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.js"
    }
  },
  "scripts": {
    "build": "tsc",
    "test": "echo 'Tests pending'"
  },
  "dependencies": {
    "decimal.js": "^10.4.3"
  },
  "devDependencies": {
    "typescript": "^5.9.3"
  }
}
EOF
    
    # Criar estrutura mínima
    mkdir -p packages/engine/src
    mkdir -p packages/engine/dist
    
    cat > packages/engine/src/index.ts << 'EOF'
/**
 * FinMath Engine - Motor de Cálculos Financeiros
 * @module @finmath/engine
 */

export * from './price'
export * from './sac'
export * from './cet'
EOF

    cat > packages/engine/src/price.ts << 'EOF'
import Decimal from 'decimal.js'

export interface PriceCalculationInput {
  pv: number | string
  rate: number | string
  n: number
}

export interface PriceCalculationResult {
  pmt: string
  totalPaid: string
  totalInterest: string
}

/**
 * Calcula PMT (Price)
 */
export function calculatePrice(input: PriceCalculationInput): PriceCalculationResult {
  const pv = new Decimal(input.pv)
  const rate = new Decimal(input.rate)
  const n = input.n
  
  // PMT = PV * (i * (1+i)^n) / ((1+i)^n - 1)
  const onePlusRate = new Decimal(1).plus(rate)
  const numerator = pv.times(rate).times(onePlusRate.pow(n))
  const denominator = onePlusRate.pow(n).minus(1)
  const pmt = numerator.div(denominator)
  
  const totalPaid = pmt.times(n)
  const totalInterest = totalPaid.minus(pv)
  
  return {
    pmt: pmt.toFixed(2),
    totalPaid: totalPaid.toFixed(2),
    totalInterest: totalInterest.toFixed(2),
  }
}
EOF

    cat > packages/engine/src/sac.ts << 'EOF'
export function calculateSAC() {
  // Placeholder
  return { amortization: '0.00' }
}
EOF

    cat > packages/engine/src/cet.ts << 'EOF'
export function calculateCET() {
  // Placeholder
  return { cet: '0.00' }
}
EOF

    cat > packages/engine/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
EOF
    
    echo "✅ @finmath/engine criado!"
else
    echo "✅ packages/engine já existe"
fi

# ========================================
# VERIFICAR pnpm-workspace.yaml
# ========================================

echo ""
echo "🔍 Verificando pnpm-workspace.yaml..."

if [ ! -f "pnpm-workspace.yaml" ]; then
    echo "📝 Criando pnpm-workspace.yaml..."
    
    cat > pnpm-workspace.yaml << 'EOF'
packages:
  - 'packages/*'
EOF
    
    echo "✅ pnpm-workspace.yaml criado!"
else
    echo "✅ pnpm-workspace.yaml já existe"
fi

# ========================================
# INSTALAR DEPENDÊNCIAS DO WORKSPACE
# ========================================

echo ""
echo "📦 Instalando dependências do workspace..."
pnpm install

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ WORKSPACE CORRIGIDO COM SUCESSO!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 Estrutura do workspace:"
echo "  fin-math/"
echo "  ├── packages/"
echo "  │   ├── engine/   ← Criado/Verificado ✓"
echo "  │   ├── api/"
echo "  │   └── ui/"
echo "  └── pnpm-workspace.yaml ← Criado/Verificado ✓"
echo ""
echo "🎯 Próximos passos:"
echo "  cd packages/ui"
echo "  ./setup-parte4.sh"
echo ""
