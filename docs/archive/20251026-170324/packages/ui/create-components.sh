#!/bin/bash

# ========================================
# SPRINT 5 - COMPONENTES ESSENCIAIS
# DIRETÓRIO: ~/workspace/fin-math/packages/ui/
# ========================================

set -e

cd ~/workspace/fin-math/packages/ui

echo "🚀 Criando componentes React essenciais..."
echo ""

# ========================================
# CRIAR ESTRUTURA COMPLETA
# ========================================

mkdir -p src/components/ui
mkdir -p src/components/layout
mkdir -p src/lib
mkdir -p src/types
mkdir -p src/pages

# ========================================
# 1. src/lib/utils.ts
# ========================================

cat > src/lib/utils.ts << 'EOF'
import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

/**
 * Combina classes CSS com suporte a Tailwind
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

/**
 * Formata número como moeda brasileira
 */
export function formatCurrency(value: number): string {
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  }).format(value)
}

/**
 * Formata número como percentual
 */
export function formatPercent(value: number, decimals: number = 2): string {
  return new Intl.NumberFormat('pt-BR', {
    style: 'percent',
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  }).format(value)
}

/**
 * Formata data no formato brasileiro
 */
export function formatDate(date: Date): string {
  return new Intl.DateTimeFormat('pt-BR').format(date)
}
EOF

echo "✅ utils.ts criado!"

# ========================================
# 2. src/types/index.ts
# ========================================

cat > src/types/index.ts << 'EOF'
/**
 * Tipos TypeScript do FinMath UI
 */

export type AmortizationSystem = 'PRICE' | 'SAC'
export type DayCountConvention = '30/360' | 'ACT/365' | 'ACT/360'

export interface AmortizationScheduleRow {
  period: number
  dueDate: Date
  payment: number
  interest: number
  amortization: number
  balance: number
}
EOF

echo "✅ types/index.ts criado!"

# ========================================
# 3. src/components/layout/Container.tsx
# ========================================

cat > src/components/layout/Container.tsx << 'EOF'
import { HTMLAttributes } from 'react'
import { cn } from '@/lib/utils'

export interface ContainerProps extends HTMLAttributes<HTMLDivElement> {
  maxWidth?: 'sm' | 'md' | 'lg' | 'xl' | '2xl' | 'full'
}

const maxWidthClasses = {
  sm: 'max-w-screen-sm',
  md: 'max-w-screen-md',
  lg: 'max-w-screen-lg',
  xl: 'max-w-screen-xl',
  '2xl': 'max-w-screen-2xl',
  full: 'max-w-full',
}

/**
 * Container responsivo para conteúdo
 */
export function Container({
  children,
  maxWidth = '2xl',
  className,
  ...props
}: ContainerProps) {
  return (
    <div
      className={cn(
        'container mx-auto px-4 sm:px-6 lg:px-8',
        maxWidthClasses[maxWidth],
        className
      )}
      {...props}
    >
      {children}
    </div>
  )
}
EOF

echo "✅ Container.tsx criado!"

# ========================================
# 4. src/components/layout/Header.tsx
# ========================================

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

echo "✅ Header.tsx criado!"

# ========================================
# 5. src/pages/Dashboard.tsx
# ========================================

cat > src/pages/Dashboard.tsx << 'EOF'
import { motion } from 'framer-motion'
import { Calculator, TrendingUp, Percent, DollarSign } from 'lucide-react'
import { Container } from '@/components/layout/Container'

/**
 * Página Dashboard - Landing inicial do FinMath
 */
export function Dashboard() {
  return (
    <Container className="py-12">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mb-12"
      >
        <h1 className="text-5xl md:text-6xl font-bold mb-4">
          <span className="text-gradient">FinMath</span>
        </h1>
        
        <p className="text-xl text-slate-300 max-w-2xl mx-auto">
          Calculadora profissional de matemática financeira com precisão
          e interface moderna
        </p>
      </motion.div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
        <MetricCard
          title="PRICE"
          value="Parcelas Fixas"
          icon={Calculator}
          iconColor="text-blue-500"
        />
        <MetricCard
          title="SAC"
          value="Amortização"
          icon={TrendingUp}
          iconColor="text-purple-500"
        />
        <MetricCard
          title="CET"
          value="Custo Total"
          icon={Percent}
          iconColor="text-yellow-500"
        />
        <MetricCard
          title="Precisão"
          value="Decimal.js"
          icon={DollarSign}
          iconColor="text-green-500"
        />
      </div>

      <div className="glass rounded-2xl p-8 text-center">
        <h2 className="text-2xl font-bold text-slate-100 mb-4">
          🚀 Interface em Desenvolvimento
        </h2>
        <p className="text-slate-300 mb-6">
          Os simuladores PRICE, SAC e CET estão sendo implementados.
          <br />
          Motor financeiro já está integrado e funcionando!
        </p>
        <div className="flex gap-4 justify-center">
          <span className="px-4 py-2 rounded-lg bg-green-500/20 text-green-400 text-sm">
            ✓ Motor @finmath/engine
          </span>
          <span className="px-4 py-2 rounded-lg bg-blue-500/20 text-blue-400 text-sm">
            ✓ Design System
          </span>
          <span className="px-4 py-2 rounded-lg bg-yellow-500/20 text-yellow-400 text-sm">
            ⏳ Componentes UI
          </span>
        </div>
      </div>
    </Container>
  )
}

interface MetricCardProps {
  title: string
  value: string
  icon: React.ComponentType<{ className?: string }>
  iconColor: string
}

function MetricCard({ title, value, icon: Icon, iconColor }: MetricCardProps) {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      whileHover={{ scale: 1.05 }}
      className="metric-card"
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <p className="text-sm text-slate-400 font-medium mb-1">{title}</p>
          <p className="text-xl font-bold text-slate-100">{value}</p>
        </div>
        
        <div className={`p-2 rounded-lg bg-slate-800/50 ${iconColor}`}>
          <Icon className="w-5 h-5" />
        </div>
      </div>
    </motion.div>
  )
}
EOF

echo "✅ Dashboard.tsx criado!"

# ========================================
# 6. src/main.tsx
# ========================================

cat > src/main.tsx << 'EOF'
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import './styles/globals.css'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
EOF

echo "✅ main.tsx criado!"

# ========================================
# 7. src/App.tsx
# ========================================

cat > src/App.tsx << 'EOF'
import { Header } from './components/layout/Header'
import { Dashboard } from './pages/Dashboard'

function App() {
  return (
    <div className="min-h-screen">
      <Header />
      <main>
        <Dashboard />
      </main>
    </div>
  )
}

export default App
EOF

echo "✅ App.tsx criado!"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ TODOS OS COMPONENTES CRIADOS!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Arquivos criados:"
echo "  ✓ src/lib/utils.ts"
echo "  ✓ src/types/index.ts"
echo "  ✓ src/components/layout/Container.tsx"
echo "  ✓ src/components/layout/Header.tsx"
echo "  ✓ src/pages/Dashboard.tsx"
echo "  ✓ src/main.tsx"
echo "  ✓ src/App.tsx"
echo ""
echo "🌐 Volte ao navegador e recarregue: http://localhost:5173"
echo ""
echo "🎯 A interface agora deve aparecer com:"
echo "  • Header com logo FinMath"
echo "  • 4 cards de métricas animados"
echo "  • Status do desenvolvimento"
echo ""
