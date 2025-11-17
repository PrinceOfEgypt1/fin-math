import React from "react";
import { Card } from "../components/base";

/**
 * Página de Calculadora (placeholder para futuras funcionalidades)
 *
 * Características de acessibilidade:
 * - Heading H1 descritivo
 * - Estrutura semântica
 */
export const Calculadora: React.FC = () => {
  return (
    <div className="space-y-8">
      <section aria-labelledby="page-heading">
        <h1 id="page-heading" className="text-3xl font-bold text-gray-900 mb-2">
          Calculadora Financeira
        </h1>
        <p className="text-lg text-gray-600">
          Ferramentas de cálculo financeiro com precisão decimal.
        </p>
      </section>

      <Card>
        <div className="text-center py-12">
          <p className="text-xl text-gray-600 mb-4">
            Esta funcionalidade estará disponível em breve.
          </p>
          <p className="text-gray-500">
            Por enquanto, use o{" "}
            <a
              href="/comparador"
              className="text-blue-600 hover:text-blue-700 underline focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 rounded"
            >
              Comparador PRICE vs SAC
            </a>{" "}
            para realizar comparações de sistemas de amortização.
          </p>
        </div>
      </Card>
    </div>
  );
};
