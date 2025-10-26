#!/bin/bash

# ========================================
# SPRINT 5 - FRONTEND FINMATH
# H25: Layout e Navegação (Parte 3/3)
# 
# DIRETÓRIO DE EXECUÇÃO: packages/ui/
# 
# Executar de: ~/workspace/fin-math/packages/ui/
# ========================================

set -e

echo "🚀 Continuando Setup do Projeto FinMath UI (Parte 3 - Final)..."
echo "📍 Diretório atual: $(pwd)"
echo ""

# Verificar se estamos no diretório correto
if [[ ! "$(pwd)" =~ packages/ui$ ]]; then
    echo "⚠️  ATENÇÃO: Este script deve ser executado em packages/ui/"
    echo "Execute: cd ~/workspace/fin-math/packages/ui"
    exit 1
fi

# Criar estrutura de diretórios
echo "📁 Criando estrutura de diretórios..."
mkdir -p src/styles
mkdir -p public
echo "✅ Diretórios criados!"
echo ""

# ========================================
# ARQUIVO 1: index.html
# Entry point da aplicação
# ========================================

echo "🌐 Criando index.html..."

cat > index.html << 'EOF'
<!doctype html>
<html lang="pt-BR">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/calculator.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Calculadora profissional de matemática financeira com interface moderna - FinMath" />
    <meta name="keywords" content="matemática financeira, calculadora, PRICE, SAC, CET, amortização" />
    <meta name="author" content="FinMath Team" />
    
    <!-- Preconnect para performance -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    
    <!-- Inter font (Design System) -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet" />
    
    <title>FinMath - Matemática Financeira Moderna</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

echo "✅ index.html criado com sucesso!"
echo ""

# ========================================
# ARQUIVO 2: src/styles/globals.css
# Estilos globais + Design System tokens
# ========================================

echo "🎨 Criando src/styles/globals.css..."

cat > src/styles/globals.css << 'EOF'
/**
 * FinMath - Global Styles
 * Design System v1.0 - Tema Escuro
 * 
 * Seguindo rigorosamente:
 * - Guia de Excelência UI/UX v1.0
 * - Design System / UI Kit v1.0
 */

@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap');

@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  /* ==========================================
     RESET & BASE STYLES
     ========================================== */
  
  * {
    @apply border-border;
  }
  
  html {
    scroll-behavior: smooth;
  }
  
  body {
    @apply bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900;
    @apply text-slate-100 font-sans antialiased;
    min-height: 100vh;
    font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
  }
  
  /* Números tabulares (WCAG - Design System) */
  .tabular-nums {
    font-variant-numeric: tabular-nums;
    font-feature-settings: 'tnum';
  }
  
  /* Foco visível (Acessibilidade WCAG 2.1 AA) */
  :focus-visible {
    @apply outline-none ring-2 ring-primary-500 ring-offset-2 ring-offset-slate-900;
  }
  
  /* Respeitar preferências do usuário */
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
  /* ==========================================
     GLASSMORPHISM EFFECTS
     ========================================== */
  
  .glass {
    @apply bg-white/5 backdrop-blur-xl border border-white/10;
  }
  
  .glass-hover {
    @apply transition-all duration-200 hover:bg-white/10 hover:border-white/20;
  }
  
  /* ==========================================
     CARD COMPONENTS
     ========================================== */
  
  .card {
    @apply glass rounded-2xl p-6 shadow-2xl;
  }
  
  /* ==========================================
     INPUT COMPONENTS
     ========================================== */
  
  .input-field {
    @apply w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl;
    @apply text-slate-100 placeholder-slate-400;
    @apply focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent;
    @apply transition-all duration-200;
    @apply disabled:opacity-50 disabled:cursor-not-allowed;
  }
  
  .input-field[aria-invalid="true"] {
    @apply border-red-500 focus:ring-red-500;
  }
  
  /* ==========================================
     BUTTON COMPONENTS
     ========================================== */
  
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
  
  .btn-secondary {
    @apply btn bg-gradient-to-r from-secondary-500 to-secondary-600;
    @apply hover:from-secondary-600 hover:to-secondary-700;
    @apply text-white shadow-lg shadow-secondary-500/50;
    @apply focus:ring-secondary-500;
  }
  
  .btn-outline {
    @apply btn border-2 border-slate-700;
    @apply hover:border-primary-500 hover:bg-primary-500/10;
    @apply text-slate-100 focus:ring-primary-500;
  }
  
  .btn-ghost {
    @apply btn hover:bg-slate-800/50 text-slate-100;
  }
  
  /* ==========================================
     METRIC CARD
     ========================================== */
  
  .metric-card {
    @apply glass rounded-xl p-4;
    @apply hover:scale-105 transition-transform duration-200;
  }
  
  /* ==========================================
     TABLE COMPONENTS (Cronogramas)
     ========================================== */
  
  .table-container {
    @apply glass rounded-xl overflow-hidden;
  }
  
  .table-header {
    @apply bg-slate-800/50 text-slate-300;
    @apply font-semibold text-sm uppercase tracking-wider;
  }
  
  .table-row {
    @apply border-b border-slate-700/50;
    @apply hover:bg-slate-800/30 transition-colors duration-150;
  }
  
  /* ==========================================
     SCROLLBAR CUSTOMIZADO
     ========================================== */
  
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
  /* ==========================================
     TEXT UTILITIES
     ========================================== */
  
  .text-gradient {
    @apply bg-clip-text text-transparent;
    @apply bg-gradient-to-r from-primary-400 to-secondary-400;
  }
  
  /* ==========================================
     ANIMATION UTILITIES
     ========================================== */
  
  .animate-glow {
    animation: glow 2s ease-in-out infinite alternate;
  }
  
  @keyframes glow {
    from {
      box-shadow: 0 0 20px rgba(59, 130, 246, 0.5);
    }
    to {
      box-shadow: 0 0 30px rgba(59, 130, 246, 0.8);
    }
  }
  
  /* ==========================================
     ACCESSIBILITY HELPERS
     ========================================== */
  
  .sr-only {
    @apply absolute w-px h-px p-0 -m-px overflow-hidden;
    @apply whitespace-nowrap border-0;
    clip: rect(0, 0, 0, 0);
  }
  
  /* Skip to main content (Acessibilidade) */
  .skip-to-main {
    @apply absolute left-0 top-0 -translate-y-full;
    @apply bg-primary-600 text-white px-4 py-2 rounded-br-lg;
    @apply focus:translate-y-0 transition-transform;
    @apply z-50;
  }
}

/* ==========================================
   PRINT STYLES (Exportações)
   ========================================== */

@media print {
  body {
    @apply bg-white text-black;
  }
  
  .no-print {
    display: none !important;
  }
  
  .table-row {
    break-inside: avoid;
  }
}
EOF

echo "✅ src/styles/globals.css criado com sucesso!"
echo ""

# ========================================
# CRIAR ÍCONE SVG PLACEHOLDER
# ========================================

echo "🎨 Criando ícone calculator.svg..."

cat > public/calculator.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <rect x="4" y="2" width="16" height="20" rx="2"/>
  <line x1="8" y1="6" x2="16" y2="6"/>
  <line x1="16" y1="14" x2="16" y2="18"/>
  <line x1="8" y1="14" x2="8" y2="14.01"/>
  <line x1="12" y1="14" x2="12" y2="14.01"/>
  <line x1="8" y1="18" x2="8" y2="18.01"/>
  <line x1="12" y1="18" x2="12" y2="18.01"/>
</svg>
EOF

echo "✅ calculator.svg criado!"
echo ""

# ========================================
# RESUMO FINAL
# ========================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SETUP COMPLETO - H25 PARTE 3 FINALIZADA!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Arquivos criados:"
echo "  ✓ index.html (entry point)"
echo "  ✓ src/styles/globals.css (Design System completo)"
echo "  ✓ public/calculator.svg (ícone)"
echo ""
echo "📁 Estrutura criada:"
echo "  packages/ui/"
echo "  ├── public/"
echo "  │   └── calculator.svg"
echo "  ├── src/"
echo "  │   └── styles/"
echo "  │       └── globals.css"
echo "  ├── index.html"
echo "  ├── package.json"
echo "  ├── tsconfig.json"
echo "  ├── vite.config.ts"
echo "  └── tailwind.config.js"
echo ""
echo "🎯 Características implementadas (Guia de Excelência):"
echo "  ✅ Tema escuro com glassmorphism"
echo "  ✅ Font-variant-numeric: tabular-nums"
echo "  ✅ Foco visível (WCAG 2.1 AA)"
echo "  ✅ prefers-reduced-motion"
echo "  ✅ Animações 150-250ms"
echo "  ✅ Contraste ≥ 4.5:1"
echo "  ✅ Skip to main content"
echo "  ✅ Print styles"
echo ""
echo "🚀 PRÓXIMOS 2 ARQUIVOS:"
echo "  • src/main.tsx (entry point React)"
echo "  • src/lib/utils.ts (utilities)"
echo ""
echo "💡 Para testar agora:"
echo "  pnpm run dev"
echo ""
