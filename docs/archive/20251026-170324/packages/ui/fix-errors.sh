#!/bin/bash

# ========================================
# FIX: Corrigir erros de compilação
# DIRETÓRIO: ~/workspace/fin-math/packages/ui/
# ========================================

set -e

cd ~/workspace/fin-math/packages/ui

echo "🔧 Corrigindo erros de compilação..."
echo ""

# ========================================
# FIX 1: globals.css - Remover border-border
# ========================================

echo "📝 Corrigindo src/styles/globals.css..."

cat > src/styles/globals.css << 'EOF'
/**
 * FinMath - Global Styles
 * Design System v1.0 - Tema Escuro
 */

@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap');

@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html {
    scroll-behavior: smooth;
  }
  
  body {
    @apply bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900;
    @apply text-slate-100 font-sans antialiased;
    min-height: 100vh;
  }
  
  .tabular-nums {
    font-variant-numeric: tabular-nums;
    font-feature-settings: 'tnum';
  }
  
  :focus-visible {
    @apply outline-none ring-2 ring-primary-500 ring-offset-2 ring-offset-slate-900;
  }
  
  @media (prefers-reduced-motion: reduce) {
    *,
    *::before,
    *::after {
      animation-duration: 0.01ms !important;
      animation-iteration-count: 1 !important;
      transition-duration: 0.01ms !important;
    }
  }
}

@layer components {
  .glass {
    @apply bg-white/5 backdrop-blur-xl border border-white/10;
  }
  
  .glass-hover {
    @apply transition-all duration-200 hover:bg-white/10 hover:border-white/20;
  }
  
  .card {
    @apply glass rounded-2xl p-6 shadow-2xl;
  }
  
  .input-field {
    @apply w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl;
    @apply text-slate-100 placeholder-slate-400;
    @apply focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent;
    @apply transition-all duration-200;
    @apply disabled:opacity-50 disabled:cursor-not-allowed;
  }
  
  .btn {
    @apply px-6 py-3 rounded-xl font-semibold transition-all duration-200;
    @apply focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-slate-900;
    @apply disabled:opacity-50 disabled:cursor-not-allowed;
  }
  
  .btn-primary {
    @apply btn bg-gradient-to-r from-primary-500 to-primary-600;
    @apply hover:from-primary-600 hover:to-primary-700;
    @apply text-white shadow-lg shadow-primary-500/50;
    @apply focus:ring-primary-500;
  }
  
  .metric-card {
    @apply glass rounded-xl p-4;
    @apply hover:scale-105 transition-transform duration-200;
  }
  
  .custom-scrollbar::-webkit-scrollbar {
    width: 8px;
    height: 8px;
  }
  
  .custom-scrollbar::-webkit-scrollbar-track {
    @apply bg-slate-800/50 rounded-full;
  }
  
  .custom-scrollbar::-webkit-scrollbar-thumb {
    @apply bg-slate-600 rounded-full;
    @apply hover:bg-slate-500;
  }
}

@layer utilities {
  .text-gradient {
    @apply bg-clip-text text-transparent;
    @apply bg-gradient-to-r from-primary-400 to-secondary-400;
  }
}
EOF

echo "✅ globals.css corrigido!"

# ========================================
# FIX 2: Header.tsx - Corrigir sintaxe JSX
# ========================================

echo "📝 Corrigindo src/components/layout/Header.tsx..."

cat > src/components/layout/Header.tsx << 'EOF'
import { motion } from 'framer-motion'
import { Calculator, Menu, X } from 'lucide-react'
import { useState } from 'react'

/**
 * Header da aplicação com navegação responsiva
 */
export function Header() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

  const navItems = [
    { label: 'Dashboard', href: '#dashboard' },
    { label: 'PRICE', href: '#price' },
    { label: 'SAC', href: '#sac' },
    { label: 'CET', href: '#cet' },
  ]

  return (
    <motion.header
      initial={{ y: -100 }}
      animate={{ y: 0 }}
      className="sticky top-0 z-50 glass border-b border-white/10 backdrop-blur-xl"
    >
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          <motion.div
            whileHover={{ scale: 1.05 }}
            className="flex items-center gap-2 cursor-pointer"
          >
            <div className="p-2 rounded-lg bg-gradient-to-br from-primary-500 to-secondary-500">
              <Calculator className="w-5 h-5 text-white" />
            </div>
            <span className="text-xl font-bold text-gradient">
              FinMath
            </span>
          </motion.div>

          <nav className="hidden md:flex items-center gap-1">
            {navItems.map((item) => (
              
                key={item.href}
                href={item.href}
                className="px-4 py-2 rounded-lg text-slate-300 hover:text-white hover:bg-white/10 transition-all duration-200"
              >
                {item.label}
              </a>
            ))}
          </nav>

          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="md:hidden p-2 rounded-lg hover:bg-white/10 transition-colors"
          >
            {mobileMenuOpen ? (
              <X className="w-6 h-6" />
            ) : (
              <Menu className="w-6 h-6" />
            )}
          </button>
        </div>

        {mobileMenuOpen && (
          <motion.nav
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            className="md:hidden py-4 space-y-2"
          >
            {navItems.map((item) => (
              
                key={item.href}
                href={item.href}
                onClick={() => setMobileMenuOpen(false)}
                className="block px-4 py-2 rounded-lg text-slate-300 hover:text-white hover:bg-white/10 transition-all duration-200"
              >
                {item.label}
              </a>
            ))}
          </motion.nav>
        )}
      </div>
    </motion.header>
  )
}
EOF

echo "✅ Header.tsx corrigido!"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ERROS CORRIGIDOS!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔧 Correções aplicadas:"
echo "  ✓ globals.css - Removido @apply border-border"
echo "  ✓ Header.tsx - Corrigida sintaxe JSX (<a> tag)"
echo ""
echo "🌐 Recarregue o navegador: http://localhost:5173"
echo ""
