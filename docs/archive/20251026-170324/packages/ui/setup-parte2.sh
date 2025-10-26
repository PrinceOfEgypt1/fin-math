#!/bin/bash

# ========================================
# SPRINT 5 - FRONTEND FINMATH
# H25: Layout e Navegação (Parte 2/3)
# 
# DIRETÓRIO DE EXECUÇÃO: packages/ui/
# 
# Executar de: ~/workspace/fin-math/packages/ui/
# ========================================

set -e

echo "🚀 Continuando Setup do Projeto FinMath UI (Parte 2)..."
echo "📍 Diretório atual: $(pwd)"
echo ""

# Verificar se estamos no diretório correto
if [[ ! "$(pwd)" =~ packages/ui$ ]]; then
    echo "⚠️  ATENÇÃO: Este script deve ser executado em packages/ui/"
    echo "Execute: cd ~/workspace/fin-math/packages/ui"
    exit 1
fi

# ========================================
# ARQUIVO 1: vite.config.ts
# Build tool configuration
# ========================================

echo "⚡ Criando vite.config.ts..."

cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@/components': path.resolve(__dirname, './src/components'),
      '@/pages': path.resolve(__dirname, './src/pages'),
      '@/hooks': path.resolve(__dirname, './src/hooks'),
      '@/lib': path.resolve(__dirname, './src/lib'),
      '@/types': path.resolve(__dirname, './src/types'),
      '@/styles': path.resolve(__dirname, './src/styles'),
    },
  },
  
  server: {
    port: 5173,
    strictPort: true,
    open: true,
    host: true,
  },
  
  build: {
    outDir: 'dist',
    sourcemap: true,
    // Performance budget (Guia de Excelência)
    chunkSizeWarningLimit: 600,
    rollupOptions: {
      output: {
        manualChunks: {
          // Code splitting para otimização
          'react-vendor': ['react', 'react-dom'],
          'finmath': ['finmath-engine', 'decimal.js'],
          'charts': ['recharts'],
          'animations': ['framer-motion'],
        },
      },
    },
  },
  
  optimizeDeps: {
    include: [
      'react',
      'react-dom',
      'finmath-engine',
      'decimal.js',
      'recharts',
      'framer-motion',
      'lucide-react',
    ],
  },
  
  // Performance: Limite de tamanho JS ≤ 170 kB gzip (Guia)
  preview: {
    port: 4173,
    strictPort: true,
  },
})
EOF

echo "✅ vite.config.ts criado com sucesso!"
echo ""

# ========================================
# ARQUIVO 2: tailwind.config.js
# Design System tokens (Tema Escuro)
# ========================================

echo "🎨 Criando tailwind.config.js..."

cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      // Design System - Cores (Tema Escuro)
      colors: {
        // Primary/Secondary do Design System
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          800: '#1e40af',
          900: '#1e3a8a',
        },
        secondary: {
          50: '#faf5ff',
          100: '#f3e8ff',
          200: '#e9d5ff',
          300: '#d8b4fe',
          400: '#c084fc',
          500: '#a855f7',
          600: '#9333ea',
          700: '#7e22ce',
          800: '#6b21a8',
          900: '#581c87',
        },
      },
      
      // Tipografia (Design System)
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'Consolas', 'monospace'],
      },
      
      // Font sizes (12/14/16/20/24/32/40)
      fontSize: {
        xs: ['12px', { lineHeight: '1.5' }],
        sm: ['14px', { lineHeight: '1.5' }],
        base: ['16px', { lineHeight: '1.5' }],
        lg: ['20px', { lineHeight: '1.4' }],
        xl: ['24px', { lineHeight: '1.4' }],
        '2xl': ['32px', { lineHeight: '1.2' }],
        '3xl': ['40px', { lineHeight: '1.2' }],
      },
      
      // Animações (150-250ms conforme Guia)
      animation: {
        'fade-in': 'fadeIn 0.2s ease-out',
        'slide-up': 'slideUp 0.2s ease-out',
        'slide-down': 'slideDown 0.2s ease-out',
        'scale-in': 'scaleIn 0.15s ease-out',
      },
      
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        slideDown: {
          '0%': { transform: 'translateY(-10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        scaleIn: {
          '0%': { transform: 'scale(0.95)', opacity: '0' },
          '100%': { transform: 'scale(1)', opacity: '1' },
        },
      },
      
      // Espaçamento base 8pt (Design System)
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
      },
      
      // Border radius (Design System)
      borderRadius: {
        'xl': '16px',
        '2xl': '20px',
      },
    },
  },
  plugins: [],
}
EOF

echo "✅ tailwind.config.js criado com sucesso!"
echo ""

# ========================================
# ARQUIVO EXTRA: tsconfig.node.json
# (Necessário para vite.config.ts)
# ========================================

echo "⚙️  Criando tsconfig.node.json..."

cat > tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true,
    "strict": true
  },
  "include": ["vite.config.ts"]
}
EOF

echo "✅ tsconfig.node.json criado!"
echo ""

# ========================================
# ARQUIVO EXTRA: postcss.config.js
# (Necessário para Tailwind)
# ========================================

echo "🎨 Criando postcss.config.js..."

cat > postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

echo "✅ postcss.config.js criado!"
echo ""

# ========================================
# RESUMO
# ========================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CONFIGURAÇÃO PARTE 2 CONCLUÍDA!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Arquivos criados:"
echo "  ✓ vite.config.ts (build tool + code splitting)"
echo "  ✓ tailwind.config.js (Design System tokens)"
echo "  ✓ tsconfig.node.json (suporte Vite)"
echo "  ✓ postcss.config.js (Tailwind processor)"
echo ""
echo "🎯 Próximos arquivos (Parte 3 - MAX 2 arquivos):"
echo "  • index.html"
echo "  • src/styles/globals.css"
echo ""
echo "📦 Se houver erros de dependências, execute:"
echo "  pnpm install --filter @finmath/ui"
echo ""
