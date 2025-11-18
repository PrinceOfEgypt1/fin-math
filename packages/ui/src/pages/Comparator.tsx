import React, { useState } from 'react';
import { Button, Input } from '../components';

interface ComparatorResult {
  price: {
    firstPayment: string;
    lastPayment: string;
    totalPaid: string;
    totalInterest: string;
  };
  sac: {
    firstPayment: string;
    lastPayment: string;
    totalPaid: string;
    totalInterest: string;
  };
  savings: string;
}

/**
 * Página de comparação entre PRICE e SAC.
 * Completamente acessível via teclado e leitor de tela.
 * Segue WCAG 2.1 AA.
 */
export function Comparator() {
  const [principal, setPrincipal] = useState('');
  const [rate, setRate] = useState('');
  const [periods, setPeriods] = useState('');
  const [result, setResult] = useState<ComparatorResult | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const validateInputs = () => {
    const newErrors: Record<string, string> = {};

    if (!principal || parseFloat(principal) <= 0) {
      newErrors.principal = 'Valor principal deve ser maior que zero';
    }

    if (!rate || parseFloat(rate) <= 0) {
      newErrors.rate = 'Taxa de juros deve ser maior que zero';
    }

    if (!periods || parseInt(periods) <= 0) {
      newErrors.periods = 'Número de parcelas deve ser maior que zero';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const calculateComparison = () => {
    if (!validateInputs()) {
      return;
    }

    const P = parseFloat(principal);
    const i = parseFloat(rate) / 100;
    const n = parseInt(periods);

    // Cálculo PRICE (parcela fixa)
    const pricePayment = P * (i * Math.pow(1 + i, n)) / (Math.pow(1 + i, n) - 1);
    const priceTotalPaid = pricePayment * n;
    const priceTotalInterest = priceTotalPaid - P;

    // Cálculo SAC (parcela decrescente)
    const amortization = P / n;
    const sacFirstPayment = amortization + (P * i);
    const sacLastPayment = amortization + (amortization * i);
    const sacTotalInterest = (P * i * (n + 1)) / 2;
    const sacTotalPaid = P + sacTotalInterest;

    // Economia ao escolher SAC
    const savings = priceTotalPaid - sacTotalPaid;

    setResult({
      price: {
        firstPayment: pricePayment.toFixed(2),
        lastPayment: pricePayment.toFixed(2),
        totalPaid: priceTotalPaid.toFixed(2),
        totalInterest: priceTotalInterest.toFixed(2),
      },
      sac: {
        firstPayment: sacFirstPayment.toFixed(2),
        lastPayment: sacLastPayment.toFixed(2),
        totalPaid: sacTotalPaid.toFixed(2),
        totalInterest: sacTotalInterest.toFixed(2),
      },
      savings: savings.toFixed(2),
    });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    calculateComparison();
  };

  return (
    <div>
      <h1 className="text-3xl font-bold mb-6 text-gray-800">
        Comparador PRICE vs SAC
      </h1>

      <p className="text-gray-600 mb-6">
        Compare os sistemas de amortização PRICE (parcela fixa) e SAC (parcela decrescente)
        para tomar a melhor decisão no seu financiamento.
      </p>

      <form onSubmit={handleSubmit} className="bg-white p-6 rounded-lg shadow-md mb-8">
        <h2 className="text-xl font-semibold mb-4 text-gray-700">
          Dados do Financiamento
        </h2>

        <Input
          label="Valor Principal (R$)"
          type="number"
          value={principal}
          onChange={(e) => setPrincipal(e.target.value)}
          error={errors.principal}
          helperText="Valor total do financiamento"
          required
          step="0.01"
          min="0"
        />

        <Input
          label="Taxa de Juros Mensal (%)"
          type="number"
          value={rate}
          onChange={(e) => setRate(e.target.value)}
          error={errors.rate}
          helperText="Taxa de juros ao mês (ex: 1.5 para 1,5%)"
          required
          step="0.01"
          min="0"
        />

        <Input
          label="Número de Parcelas"
          type="number"
          value={periods}
          onChange={(e) => setPeriods(e.target.value)}
          error={errors.periods}
          helperText="Quantidade de parcelas (meses)"
          required
          step="1"
          min="1"
        />

        <Button type="submit" variant="primary" className="w-full">
          Comparar Sistemas
        </Button>
      </form>

      {result && (
        <div
          role="region"
          aria-live="polite"
          aria-label="Resultados da comparação"
          className="space-y-6"
        >
          <h2 className="text-2xl font-bold mb-4 text-gray-800">
            Resultados da Comparação
          </h2>

          <div className="grid md:grid-cols-2 gap-6">
            {/* PRICE */}
            <div className="bg-blue-50 p-6 rounded-lg border-2 border-blue-200">
              <h3 className="text-xl font-semibold mb-4 text-blue-900">
                Sistema PRICE
              </h3>
              <p className="text-sm text-gray-600 mb-4">
                Parcelas fixas durante todo o período
              </p>

              <dl className="space-y-3">
                <div>
                  <dt className="text-sm font-medium text-gray-600">
                    Parcela (todas iguais):
                  </dt>
                  <dd className="text-2xl font-bold text-blue-900">
                    R$ {result.price.firstPayment}
                  </dd>
                </div>

                <div>
                  <dt className="text-sm font-medium text-gray-600">
                    Total Pago:
                  </dt>
                  <dd className="text-lg font-semibold text-gray-800">
                    R$ {result.price.totalPaid}
                  </dd>
                </div>

                <div>
                  <dt className="text-sm font-medium text-gray-600">
                    Total de Juros:
                  </dt>
                  <dd className="text-lg font-semibold text-gray-800">
                    R$ {result.price.totalInterest}
                  </dd>
                </div>
              </dl>

              <p className="sr-only">
                PRICE: parcela de R$ {result.price.firstPayment},
                total pago R$ {result.price.totalPaid},
                juros totais R$ {result.price.totalInterest}
              </p>
            </div>

            {/* SAC */}
            <div className="bg-green-50 p-6 rounded-lg border-2 border-green-200">
              <h3 className="text-xl font-semibold mb-4 text-green-900">
                Sistema SAC
              </h3>
              <p className="text-sm text-gray-600 mb-4">
                Parcelas decrescentes (amortização constante)
              </p>

              <dl className="space-y-3">
                <div>
                  <dt className="text-sm font-medium text-gray-600">
                    Primeira Parcela:
                  </dt>
                  <dd className="text-2xl font-bold text-green-900">
                    R$ {result.sac.firstPayment}
                  </dd>
                </div>

                <div>
                  <dt className="text-sm font-medium text-gray-600">
                    Última Parcela:
                  </dt>
                  <dd className="text-xl font-semibold text-green-700">
                    R$ {result.sac.lastPayment}
                  </dd>
                </div>

                <div>
                  <dt className="text-sm font-medium text-gray-600">
                    Total Pago:
                  </dt>
                  <dd className="text-lg font-semibold text-gray-800">
                    R$ {result.sac.totalPaid}
                  </dd>
                </div>

                <div>
                  <dt className="text-sm font-medium text-gray-600">
                    Total de Juros:
                  </dt>
                  <dd className="text-lg font-semibold text-gray-800">
                    R$ {result.sac.totalInterest}
                  </dd>
                </div>
              </dl>

              <p className="sr-only">
                SAC: parcela inicial R$ {result.sac.firstPayment},
                parcela final R$ {result.sac.lastPayment},
                total pago R$ {result.sac.totalPaid},
                juros totais R$ {result.sac.totalInterest}
              </p>
            </div>
          </div>

          {/* Economia */}
          <div
            className={`p-6 rounded-lg border-2 ${
              parseFloat(result.savings) > 0
                ? 'bg-green-100 border-green-300'
                : 'bg-red-100 border-red-300'
            }`}
          >
            <h3 className="text-xl font-semibold mb-2">
              {parseFloat(result.savings) > 0 ? '💰 Economia com SAC' : '⚠️ Diferença'}
            </h3>
            <p className="text-3xl font-bold">
              R$ {Math.abs(parseFloat(result.savings)).toFixed(2)}
            </p>
            <p className="mt-2 text-gray-700">
              {parseFloat(result.savings) > 0
                ? 'Ao escolher SAC, você economiza este valor em comparação com PRICE.'
                : 'Neste caso, PRICE resultaria em menor valor total.'}
            </p>
          </div>

          <div className="bg-gray-100 p-4 rounded-lg">
            <h3 className="font-semibold mb-2">💡 Resumo Visual</h3>
            <p className="text-sm text-gray-700">
              <strong>PRICE:</strong> Parcelas constantes de R$ {result.price.firstPayment}.
              Ideal para quem prefere previsibilidade no orçamento.
            </p>
            <p className="text-sm text-gray-700 mt-2">
              <strong>SAC:</strong> Parcelas começam em R$ {result.sac.firstPayment} e
              terminam em R$ {result.sac.lastPayment}.
              Ideal para quem pode pagar mais no início e quer economizar no total.
            </p>
          </div>
        </div>
      )}
    </div>
  );
}
