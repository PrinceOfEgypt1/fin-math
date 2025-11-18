#!/bin/bash

# ========================================
# FIX: Corrigir nome do pacote engine
# DIRETÓRIO DE EXECUÇÃO: ~/workspace/fin-math/
# ========================================

set -e

echo "🔧 Corrigindo nome do pacote @finmath/engine..."
echo ""

cd ~/workspace/fin-math/packages/engine

# Fazer backup do package.json original
cp package.json package.json.backup

# Atualizar o nome do pacote
cat > package.json << 'EOF'
{
  "name": "@finmath/engine",
  "version": "0.4.1",
  "description": "Motor de cálculos financeiros de alta precisão para o mercado brasileiro",
  "main": "./dist/src/index.js",
  "module": "./dist/src/index.js",
  "types": "./dist/src/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/src/index.d.ts",
      "import": "./dist/src/index.js",
      "default": "./dist/src/index.js"
    },
    "./package.json": "./package.json"
  },
  "files": [
    "dist",
    "README.md",
    "examples"
  ],
  "scripts": {
    "build": "tsc -p tsconfig.json",
    "typecheck": "tsc -p tsconfig.json --noEmit",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint src --ext .ts,.tsx",
    "lint:fix": "eslint src --ext .ts,.tsx --fix",
    "test:golden": "vitest run test/golden.spec.ts",
    "docs": "typedoc --skipErrorChecking",
    "docs:watch": "typedoc --watch --skipErrorChecking",
    "prepublishOnly": "pnpm build && pnpm test"
  },
  "keywords": [
    "finmath",
    "finance",
    "financial",
    "mathematics",
    "cet",
    "custo-efetivo-total",
    "price",
    "sac",
    "amortization",
    "amortização",
    "irr",
    "tir",
    "npv",
    "vpn",
    "brasil",
    "brazil",
    "brazilian",
    "decimal",
    "precision",
    "bacen",
    "banco-central"
  ],
  "author": "PrinceOfEgypt1",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/PrinceOfEgypt1/fin-math.git",
    "directory": "packages/engine"
  },
  "bugs": {
    "url": "https://github.com/PrinceOfEgypt1/fin-math/issues"
  },
  "homepage": "https://github.com/PrinceOfEgypt1/fin-math#readme",
  "publishConfig": {
    "access": "public"
  },
  "sideEffects": false,
  "dependencies": {
    "date-fns": "^4.1.0",
    "decimal.js": "^10.4.3",
    "zod": "^3.23.8"
  },
  "devDependencies": {
    "@types/node": "^22.7.5",
    "fast-check": "^3.18.0",
    "typedoc": "^0.28.14",
    "typescript": "^5.6.3",
    "vitest": "^1.6.0"
  },
  "engines": {
    "node": ">=18.0.0",
    "pnpm": ">=8.0.0"
  }
}
EOF

echo "✅ package.json atualizado!"
echo "   Nome: finmath-engine → @finmath/engine"
echo ""

# Voltar para raiz
cd ~/workspace/fin-math

# Reinstalar o workspace
echo "📦 Reinstalando workspace..."
pnpm install

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ PROBLEMA RESOLVIDO!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔧 Alteração realizada:"
echo "  • Nome alterado: finmath-engine → @finmath/engine"
echo "  • Backup salvo: packages/engine/package.json.backup"
echo ""
echo "🎯 Agora todos os pacotes podem usar:"
echo "  import { calculatePrice } from '@finmath/engine'"
echo ""
echo "📦 Próximos passos:"
echo "  cd packages/ui"
echo "  ./setup-parte4.sh"
echo "  pnpm run dev"
echo ""
