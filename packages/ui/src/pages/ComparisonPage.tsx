import { useState } from "react";
import { motion } from "framer-motion";
import { Container } from "@/components/layout/Container";
import { Calculator, TrendingDown, ArrowRight } from "lucide-react";
import Decimal from "decimal.js";

export function ComparisonPage() {
  const [formData, setFormData] = useState({
    pv: "35000",
    rate: "1.65",
    n: 36,
  });
  const [results, setResults] = useState<any>(null);

  const calculatePRICE = (pv: string, rate: string, n: number) => {
    const PV = new Decimal(pv);
    const i = new Decimal(rate).div(100);
    const onePlusI = new Decimal(1).plus(i);
    const numerator = PV.times(i).times(onePlusI.pow(n));
    const denominator = onePlusI.pow(n).minus(1);
    const pmt = numerator.div(denominator);
    const totalPaid = pmt.times(n);
    const totalInterest = totalPaid.minus(PV);
    return {
      pmt: pmt.toFixed(2),
      totalPaid: totalPaid.toFixed(2),
      totalInterest: totalInterest.toFixed(2),
    };
  };

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
      const price = calculatePRICE(formData.pv, formData.rate, formData.n);
      const sac = calculateSAC(formData.pv, formData.rate, formData.n);
      const savings = new Decimal(price.totalInterest).minus(
        new Decimal(sac.totalInterest),
      );
      setResults({ price, sac, savings: savings.toFixed(2) });
    } catch (error) {
      console.error("Erro:", error);
    }
  };

  return (
    <Container className="py-12">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gradient mb-2">
            PRICE vs SAC
          </h1>
          <p className="text-slate-300">
            Compare os dois sistemas de amortização
          </p>
        </div>

        <div className="glass rounded-2xl p-8 max-w-5xl mx-auto mb-6">
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
              />
            </div>
          </div>
          <button onClick={handleCalculate} className="btn-primary w-full">
            Comparar Sistemas
          </button>
        </div>

        {results && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="grid grid-cols-1 lg:grid-cols-2 gap-6 max-w-5xl mx-auto"
          >
            <div className="glass rounded-2xl p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="p-2 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600">
                  <Calculator className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h2 className="text-xl font-bold text-slate-100">PRICE</h2>
                  <p className="text-xs text-slate-400">Parcelas Fixas</p>
                </div>
              </div>
              <div className="space-y-3">
                <div className="bg-slate-800/50 rounded-lg p-3">
                  <p className="text-xs text-slate-400 mb-1">Parcela Mensal</p>
                  <p className="text-2xl font-bold text-blue-400 tabular-nums">
                    R$ {results.price.pmt}
                  </p>
                </div>
                <div className="bg-slate-800/50 rounded-lg p-3">
                  <p className="text-xs text-slate-400 mb-1">Total Pago</p>
                  <p className="text-lg font-bold text-slate-100 tabular-nums">
                    R$ {results.price.totalPaid}
                  </p>
                </div>
                <div className="bg-slate-800/50 rounded-lg p-3">
                  <p className="text-xs text-slate-400 mb-1">Total de Juros</p>
                  <p className="text-lg font-bold text-red-400 tabular-nums">
                    R$ {results.price.totalInterest}
                  </p>
                </div>
              </div>
            </div>
            <div className="glass rounded-2xl p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="p-2 rounded-lg bg-gradient-to-br from-purple-500 to-purple-600">
                  <TrendingDown className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h2 className="text-xl font-bold text-slate-100">SAC</h2>
                  <p className="text-xs text-slate-400">
                    Amortização Constante
                  </p>
                </div>
              </div>
              <div className="space-y-3">
                <div className="bg-slate-800/50 rounded-lg p-3">
                  <p className="text-xs text-slate-400 mb-1">
                    Primeira Parcela
                  </p>
                  <p className="text-xl font-bold text-purple-400 tabular-nums">
                    R$ {results.sac.firstPayment}
                  </p>
                  <p className="text-xs text-green-400 mt-1">
                    Última: R$ {results.sac.lastPayment}
                  </p>
                </div>
                <div className="bg-slate-800/50 rounded-lg p-3">
                  <p className="text-xs text-slate-400 mb-1">Total Pago</p>
                  <p className="text-lg font-bold text-slate-100 tabular-nums">
                    R$ {results.sac.totalPaid}
                  </p>
                </div>
                <div className="bg-slate-800/50 rounded-lg p-3">
                  <p className="text-xs text-slate-400 mb-1">Total de Juros</p>
                  <p className="text-lg font-bold text-red-400 tabular-nums">
                    R$ {results.sac.totalInterest}
                  </p>
                </div>
              </div>
            </div>
            <div className="lg:col-span-2 glass rounded-2xl p-6 bg-gradient-to-r from-green-500/10 to-emerald-500/10 border-green-500/30">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-slate-300 mb-1">
                    💰 Economia escolhendo SAC
                  </p>
                  <p className="text-3xl font-bold text-green-400 tabular-nums">
                    R$ {results.savings}
                  </p>
                  <p className="text-xs text-slate-400 mt-1">
                    Você paga {results.savings} a menos em juros com SAC
                  </p>
                </div>
                <ArrowRight className="w-12 h-12 text-green-400" />
              </div>
            </div>
          </motion.div>
        )}
      </motion.div>
    </Container>
  );
}
