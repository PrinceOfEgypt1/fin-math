import { useState } from "react";
import { motion } from "framer-motion";
import { Container } from "@/components/layout/Container";
import { Calculator } from "lucide-react";
import Decimal from "decimal.js";

export function PriceSimulator() {
  const [formData, setFormData] = useState({
    pv: "10000",
    rate: "1",
    n: 12,
  });
  const [result, setResult] = useState<any>(null);

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

  const handleCalculate = () => {
    try {
      const res = calculatePRICE(formData.pv, formData.rate, formData.n);
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
            <div className="p-3 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600">
              <Calculator className="w-6 h-6 text-white" />
            </div>
            <h1 className="text-3xl font-bold text-gradient">
              Simulador PRICE
            </h1>
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
            Calcular
          </button>

          {result && (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="grid grid-cols-1 md:grid-cols-3 gap-4"
            >
              <div className="metric-card">
                <p className="text-sm text-slate-400 mb-1">Valor da Parcela</p>
                <p className="text-2xl font-bold text-primary-400 tabular-nums">
                  R$ {result.pmt}
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
            </motion.div>
          )}
        </div>
      </motion.div>
    </Container>
  );
}
