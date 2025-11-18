import { useState } from "react";
import { motion } from "framer-motion";
import { Container } from "@/components/layout/Container";
import { TrendingDown } from "lucide-react";
import Decimal from "decimal.js";

export function SacSimulator() {
  const [formData, setFormData] = useState({
    pv: "10000",
    rate: "1",
    n: 12,
  });
  const [result, setResult] = useState<any>(null);

  const calculateSAC = (pv: string, rate: string, n: number) => {
    const PV = new Decimal(pv);
    const i = new Decimal(rate).div(100);
    const amortization = PV.div(n);
    let balance = PV;
    let totalInterest = new Decimal(0);
    let firstPayment = new Decimal(0);
    let lastPayment = new Decimal(0);
    for (let period = 1; period <= n; period++) {
      const interest = balance.times(i);
      const payment = amortization.plus(interest);
      if (period === 1) firstPayment = payment;
      if (period === n) lastPayment = payment;
      totalInterest = totalInterest.plus(interest);
      balance = balance.minus(amortization);
    }
    const totalPaid = PV.plus(totalInterest);
    return {
      firstPayment: firstPayment.toFixed(2),
      lastPayment: lastPayment.toFixed(2),
      amortization: amortization.toFixed(2),
      totalPaid: totalPaid.toFixed(2),
      totalInterest: totalInterest.toFixed(2),
    };
  };

  const handleCalculate = () => {
    try {
      const res = calculateSAC(formData.pv, formData.rate, formData.n);
      setResult(res);
    } catch (error) {
      console.error("Erro ao calcular:", error);
    }
  };

  return (
    <Container className="py-12">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <div className="glass rounded-2xl p-8 max-w-4xl mx-auto">
          <div className="flex items-center gap-3 mb-6">
            <div className="p-3 rounded-xl bg-gradient-to-br from-purple-500 to-purple-600">
              <TrendingDown className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-3xl font-bold text-gradient">
                Simulador SAC
              </h1>
              <p className="text-sm text-slate-400">
                Sistema de Amortização Constante
              </p>
            </div>
          </div>

          <div className="bg-blue-500/10 border border-blue-500/30 rounded-xl p-4 mb-6">
            <p className="text-sm text-blue-300">
              💡 <strong>SAC:</strong> Amortização fixa e juros decrescentes.
              Parcelas diminuem ao longo do tempo.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Valor Principal (R$)
              </label>
              <input
                type="number"
                value={formData.pv}
                onChange={(e) =>
                  setFormData({ ...formData, pv: e.target.value })
                }
                className="input-field"
                placeholder="10000"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Taxa Mensal (%)
              </label>
              <input
                type="number"
                step="0.01"
                value={formData.rate}
                onChange={(e) =>
                  setFormData({ ...formData, rate: e.target.value })
                }
                className="input-field"
                placeholder="1"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Número de Parcelas
              </label>
              <input
                type="number"
                value={formData.n}
                onChange={(e) =>
                  setFormData({ ...formData, n: Number(e.target.value) })
                }
                className="input-field"
                placeholder="12"
              />
            </div>
          </div>

          <button onClick={handleCalculate} className="btn-primary w-full mb-6">
            Calcular SAC
          </button>

          {result && (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
            >
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                <div className="metric-card">
                  <p className="text-sm text-slate-400 mb-1">
                    Primeira Parcela
                  </p>
                  <p className="text-2xl font-bold text-purple-400 tabular-nums">
                    R$ {result.firstPayment}
                  </p>
                </div>
                <div className="metric-card">
                  <p className="text-sm text-slate-400 mb-1">Última Parcela</p>
                  <p className="text-2xl font-bold text-green-400 tabular-nums">
                    R$ {result.lastPayment}
                  </p>
                </div>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="metric-card">
                  <p className="text-sm text-slate-400 mb-1">
                    Amortização Mensal
                  </p>
                  <p className="text-2xl font-bold text-blue-400 tabular-nums">
                    R$ {result.amortization}
                  </p>
                </div>
                <div className="metric-card">
                  <p className="text-sm text-slate-400 mb-1">Total Pago</p>
                  <p className="text-2xl font-bold text-slate-100 tabular-nums">
                    R$ {result.totalPaid}
                  </p>
                </div>
                <div className="metric-card">
                  <p className="text-sm text-slate-400 mb-1">Total de Juros</p>
                  <p className="text-2xl font-bold text-red-400 tabular-nums">
                    R$ {result.totalInterest}
                  </p>
                </div>
              </div>
            </motion.div>
          )}
        </div>
      </motion.div>
    </Container>
  );
}
