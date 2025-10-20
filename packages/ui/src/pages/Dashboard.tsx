import { motion } from "framer-motion";
import { Calculator, TrendingUp, Percent, DollarSign } from "lucide-react";
import { Container } from "@/components/layout/Container";

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
          Calculadora profissional de matemática financeira com precisão e
          interface moderna
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
  );
}

interface MetricCardProps {
  title: string;
  value: string;
  icon: React.ComponentType<{ className?: string }>;
  iconColor: string;
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
  );
}
