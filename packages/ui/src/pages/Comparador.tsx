import React, { useState } from "react";
import Decimal from "decimal.js";
import { Button, Input, Card } from "../components/base";
import {
  generatePriceSchedule,
  generateSacSchedule,
  formatCurrency,
  type PriceResult,
  type SacResult,
} from "../utils/calculations";

/**
 * Página Comparador PRICE vs SAC
 *
 * Características de acessibilidade (WCAG 2.1 AA):
 * - Formulário com labels associados
 * - Campos com validação e feedback acessível
 * - Resultados anunciados por leitores de tela (aria-live)
 * - Navegação completa por teclado
 * - Contraste adequado
 * - Tabelas com cabeçalhos e escopo corretos
 */
export const Comparador: React.FC = () => {
  const [valor, setValor] = useState("");
  const [taxa, setTaxa] = useState("");
  const [prazo, setPrazo] = useState("");

  const [priceResult, setPriceResult] = useState<PriceResult | null>(null);
  const [sacResult, setSacResult] = useState<SacResult | null>(null);
  const [error, setError] = useState("");

  const [isCalculating, setIsCalculating] = useState(false);

  const handleCalculate = (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setIsCalculating(true);

    try {
      const pv = new Decimal(valor);
      const taxaMensal = new Decimal(taxa).div(100);
      const n = parseInt(prazo, 10);

      if (pv.lessThanOrEqualTo(0)) {
        setError("O valor do empréstimo deve ser maior que zero");
        setIsCalculating(false);
        return;
      }

      if (taxaMensal.lessThan(0)) {
        setError("A taxa de juros não pode ser negativa");
        setIsCalculating(false);
        return;
      }

      if (n <= 0 || !Number.isInteger(n)) {
        setError("O prazo deve ser um número inteiro positivo");
        setIsCalculating(false);
        return;
      }

      const price = generatePriceSchedule(pv, taxaMensal, n);
      const sac = generateSacSchedule(pv, taxaMensal, n);

      setPriceResult(price);
      setSacResult(sac);
    } catch {
      setError("Erro ao calcular. Verifique os valores informados.");
    } finally {
      setIsCalculating(false);
    }
  };

  const economia =
    priceResult && sacResult
      ? priceResult.totalPago.minus(sacResult.totalPago)
      : null;

  return (
    <div className="space-y-8">
      <section aria-labelledby="page-heading">
        <h1 id="page-heading" className="text-3xl font-bold text-gray-900 mb-2">
          Comparador PRICE vs SAC
        </h1>
        <p className="text-lg text-gray-600">
          Compare os sistemas de amortização e descubra qual oferece menor custo
          total para seu financiamento.
        </p>
      </section>

      <Card
        role="form"
        ariaLabel="Formulário de entrada de dados do financiamento"
      >
        <form onSubmit={handleCalculate} className="space-y-6">
          <h2 className="text-xl font-semibold text-gray-900">
            Dados do Financiamento
          </h2>

          <div className="grid gap-6 md:grid-cols-3">
            <Input
              label="Valor do Empréstimo (R$)"
              type="number"
              step="0.01"
              min="0"
              value={valor}
              onChange={(e) => setValor(e.target.value)}
              required
              hint="Valor total a ser financiado"
              placeholder="Ex: 100000.00"
            />

            <Input
              label="Taxa de Juros Mensal (%)"
              type="number"
              step="0.01"
              min="0"
              value={taxa}
              onChange={(e) => setTaxa(e.target.value)}
              required
              hint="Taxa mensal em percentual"
              placeholder="Ex: 1.5"
            />

            <Input
              label="Prazo (meses)"
              type="number"
              step="1"
              min="1"
              value={prazo}
              onChange={(e) => setPrazo(e.target.value)}
              required
              hint="Número de parcelas"
              placeholder="Ex: 360"
            />
          </div>

          {error && (
            <div
              role="alert"
              className="p-4 bg-red-50 border-2 border-red-200 rounded-lg"
            >
              <p className="text-red-800 font-medium">{error}</p>
            </div>
          )}

          <Button
            type="submit"
            variant="primary"
            size="lg"
            disabled={isCalculating}
            aria-busy={isCalculating}
          >
            {isCalculating ? "Calculando..." : "Comparar Sistemas"}
          </Button>
        </form>
      </Card>

      {priceResult && sacResult && (
        <div
          role="region"
          aria-live="polite"
          aria-label="Resultados da comparação"
          className="space-y-6"
        >
          <h2 className="text-2xl font-semibold text-gray-900">
            Resultados da Comparação
          </h2>

          <div className="grid gap-6 md:grid-cols-2">
            {/* Resultado PRICE */}
            <Card
              title="Sistema PRICE"
              role="article"
              ariaLabel="Resultado do sistema PRICE"
            >
              <div className="space-y-4">
                <div>
                  <h3 className="text-sm font-medium text-gray-600 mb-1">
                    Parcela Fixa
                  </h3>
                  <p className="text-2xl font-bold text-gray-900">
                    R$ {formatCurrency(priceResult.parcela)}
                  </p>
                  <span className="sr-only">
                    PRICE: parcela fixa de R${" "}
                    {formatCurrency(priceResult.parcela)}
                  </span>
                </div>

                <div>
                  <h3 className="text-sm font-medium text-gray-600 mb-1">
                    Total Pago
                  </h3>
                  <p className="text-xl font-semibold text-gray-900">
                    R$ {formatCurrency(priceResult.totalPago)}
                  </p>
                  <span className="sr-only">
                    PRICE: total pago R$ {formatCurrency(priceResult.totalPago)}
                  </span>
                </div>

                <div>
                  <h3 className="text-sm font-medium text-gray-600 mb-1">
                    Total de Juros
                  </h3>
                  <p className="text-xl font-semibold text-red-600">
                    R$ {formatCurrency(priceResult.totalJuros)}
                  </p>
                  <span className="sr-only">
                    PRICE: total de juros R${" "}
                    {formatCurrency(priceResult.totalJuros)}
                  </span>
                </div>

                <div className="pt-4 border-t border-gray-200">
                  <p className="text-sm text-gray-600">
                    <strong>Característica:</strong> Parcelas fixas durante todo
                    o período
                  </p>
                </div>
              </div>
            </Card>

            {/* Resultado SAC */}
            <Card
              title="Sistema SAC"
              role="article"
              ariaLabel="Resultado do sistema SAC"
            >
              <div className="space-y-4">
                <div>
                  <h3 className="text-sm font-medium text-gray-600 mb-1">
                    Parcela Inicial
                  </h3>
                  <p className="text-2xl font-bold text-gray-900">
                    R$ {formatCurrency(sacResult.parcelaInicial)}
                  </p>
                  <span className="sr-only">
                    SAC: parcela inicial de R${" "}
                    {formatCurrency(sacResult.parcelaInicial)}
                  </span>
                </div>

                <div>
                  <h3 className="text-sm font-medium text-gray-600 mb-1">
                    Total Pago
                  </h3>
                  <p className="text-xl font-semibold text-gray-900">
                    R$ {formatCurrency(sacResult.totalPago)}
                  </p>
                  <span className="sr-only">
                    SAC: total pago R$ {formatCurrency(sacResult.totalPago)}
                  </span>
                </div>

                <div>
                  <h3 className="text-sm font-medium text-gray-600 mb-1">
                    Total de Juros
                  </h3>
                  <p className="text-xl font-semibold text-red-600">
                    R$ {formatCurrency(sacResult.totalJuros)}
                  </p>
                  <span className="sr-only">
                    SAC: total de juros R${" "}
                    {formatCurrency(sacResult.totalJuros)}
                  </span>
                </div>

                <div className="pt-4 border-t border-gray-200">
                  <p className="text-sm text-gray-600">
                    <strong>Característica:</strong> Parcelas decrescentes, da
                    R$ {formatCurrency(sacResult.parcelaInicial)} até R${" "}
                    {formatCurrency(sacResult.parcelaFinal)}
                  </p>
                </div>
              </div>
            </Card>
          </div>

          {/* Economia */}
          {economia && economia.greaterThan(0) && (
            <Card
              className="bg-green-50 border-green-200"
              role="complementary"
              ariaLabel="Economia ao escolher SAC"
            >
              <div className="text-center">
                <h2 className="text-lg font-semibold text-gray-900 mb-2">
                  💰 Economia ao escolher SAC
                </h2>
                <p className="text-3xl font-bold text-green-700">
                  R$ {formatCurrency(economia)}
                </p>
                <span className="sr-only">
                  Você economiza R$ {formatCurrency(economia)} ao escolher o
                  sistema SAC em vez do PRICE
                </span>
                <p className="mt-2 text-sm text-gray-700">
                  Escolhendo o sistema SAC, você pagará{" "}
                  <strong>R$ {formatCurrency(economia)} a menos</strong> em
                  juros comparado ao sistema PRICE.
                </p>
              </div>
            </Card>
          )}

          {/* Resumo textual para leitores de tela */}
          <div className="sr-only" role="status" aria-live="polite">
            Comparação calculada com sucesso. Sistema PRICE: parcela fixa de R${" "}
            {formatCurrency(priceResult.parcela)}, total pago R${" "}
            {formatCurrency(priceResult.totalPago)}, total de juros R${" "}
            {formatCurrency(priceResult.totalJuros)}. Sistema SAC: parcela
            inicial de R$ {formatCurrency(sacResult.parcelaInicial)}, total pago
            R$ {formatCurrency(sacResult.totalPago)}, total de juros R${" "}
            {formatCurrency(sacResult.totalJuros)}. Economia escolhendo SAC: R${" "}
            {economia ? formatCurrency(economia) : "0"}.
          </div>
        </div>
      )}
    </div>
  );
};
