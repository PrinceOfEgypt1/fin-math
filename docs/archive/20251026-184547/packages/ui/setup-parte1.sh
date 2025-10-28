#!/bin/bash

# ========================================
# SPRINT 5 - FRONTEND FINMATH
# H25: Layout e Navegação (Parte 1/3)
# 
# DIRETÓRIO DE EXECUÇÃO: packages/ui/
# 
# Pré-requisito: Criar o diretório se não existir
#   mkdir -p packages/ui
#   cd packages/ui
# ========================================

set -e  # Exit on error

echo "🚀 Iniciando Setup do Projeto FinMath UI..."
echo "📍 Diretório atual: $(pwd)"
echo ""

# Verificar se estamos no diretório correto
if [[ ! "$(pwd)" =~ packages/ui$ ]]; then
    echo "⚠️  ATENÇÃO: Este script deve ser executado em packages/ui/"
    echo "Execute: cd packages/ui"
    exit 1
fi

# ========================================
# ARQUIVO 1: package.json
# Seguindo exatamente o padrão de referência
# ========================================

echo "📦 Criando package.json..."

cat > package.json << 'EOF'
{
  "name": "@finmath/ui",
  "version": "1.0.0",
  "type": "module",
  "description": "Interface moderna para cálculos de matemática financeira - FinMath",
  "keywords": [
    "finmath",
    "matemática-financeira",
    "calculadora",
    "price",
    "sac",
    "cet"
  ],
  "author": "FinMath Team",
  "license": "MIT",
  "packageManager": "pnpm@10.18.3",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "tsc --noEmit",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "clsx": "^2.1.1",
    "framer-motion": "^12.23.24",
    "lucide-react": "^0.545.0",
    "react": "^19.2.0",
    "react-dom": "^19.2.0",
    "recharts": "^3.2.1",
    "tailwind-merge": "^3.3.1",
    "finmath-engine": "^0.4.1",
    "decimal.js": "^10.4.3"
  },
  "devDependencies": {
    "@types/react": "^19.2.2",
    "@types/react-dom": "^19.2.2",
    "@vitejs/plugin-react": "^5.0.4",
    "autoprefixer": "^10.4.21",
    "postcss": "^8.5.6",
    "tailwindcss": "^3.4.18",
    "typescript": "^5.9.3",
    "vite": "^7.1.10"
  }
}
EOF

echo "✅ package.json criado com sucesso!"
echo ""

# ========================================
# ARQUIVO 2: tsconfig.json
# TypeScript strict mode + path mapping
# ========================================

echo "⚙️  Criando tsconfig.json..."

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    /* Language and Environment */
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",

    /* Modules */
    "module": "ESNext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "noEmit": true,

    /* Type Checking - STRICT MODE (Excelência) */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noImplicitReturns": true,
    "noUncheckedIndexedAccess": true,

    /* Path Mapping */
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/pages/*": ["./src/pages/*"],
      "@/hooks/*": ["./src/hooks/*"],
      "@/lib/*": ["./src/lib/*"],
      "@/types/*": ["./src/types/*"],
      "@/styles/*": ["./src/styles/*"]
    },

    /* Interop */
    "skipLibCheck": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

echo "✅ tsconfig.json criado com sucesso!"
echo ""

# ========================================
# RESUMO E PRÓXIMOS PASSOS
# ========================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SETUP INICIAL CONCLUÍDO!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Arquivos criados em $(pwd):"
echo "  ✓ package.json (com finmath-engine@0.4.1)"
echo "  ✓ tsconfig.json (TypeScript strict)"
echo ""
echo "🎯 Características implementadas:"
echo "  • React 19 + TypeScript 5.9"
echo "  • Framer Motion para animações"
echo "  • Recharts para gráficos"
echo "  • Integração com finmath-engine"
echo "  • Path aliases configurados (@/*)"
echo "  • Strict mode TypeScript"
echo ""
echo "📦 Próximo passo:"
echo "  cd packages/ui"
echo "  pnpm install"
echo ""
echo "🚀 Aguardando aprovação para criar os próximos 2 arquivos:"
echo "  • vite.config.ts"
echo "  • tailwind.config.js"
echo ""
