import React from "react";
import { Link } from "react-router-dom";
import { Calculator, BarChart3, BookOpen } from "lucide-react";
import { Card } from "../components/base";

/**
 * Página inicial do FinMath
 *
 * Características de acessibilidade:
 * - Heading H1 único e descritivo
 * - Hierarquia lógica de headings (H1 > H2 > H3)
 * - Cards navegáveis por teclado
 * - Links descritivos
 */
export const Home: React.FC = () => {
  const features = [
    {
      title: "Comparador PRICE vs SAC",
      description:
        "Compare os dois sistemas de amortização mais usados no Brasil e descubra qual oferece melhor custo-benefício para seu financiamento.",
      icon: BarChart3,
      link: "/comparador",
      linkText: "Comparar sistemas",
    },
    {
      title: "Calculadora Financeira",
      description:
        "Calcule prestações, juros, CET e outras métricas financeiras com precisão decimal.",
      icon: Calculator,
      link: "/calculadora",
      linkText: "Abrir calculadora",
    },
    {
      title: "Documentação",
      description:
        "Aprenda sobre matemática financeira, sistemas de amortização e como usar nossa biblioteca.",
      icon: BookOpen,
      link: "#docs",
      linkText: "Ver documentação",
    },
  ];

  return (
    <div className="space-y-8">
      <section aria-labelledby="hero-heading">
        <h1 id="hero-heading" className="text-4xl font-bold text-gray-900 mb-4">
          FinMath - Matemática Financeira Acessível
        </h1>
        <p className="text-xl text-gray-600 max-w-3xl">
          Ferramentas de cálculo financeiro com precisão decimal, seguindo
          padrões do mercado brasileiro. Totalmente acessível para todos os
          usuários.
        </p>
      </section>

      <section aria-labelledby="features-heading">
        <h2
          id="features-heading"
          className="text-2xl font-semibold text-gray-900 mb-6"
        >
          Recursos Disponíveis
        </h2>

        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {features.map((feature) => {
            const Icon = feature.icon;

            return (
              <Card key={feature.title} className="flex flex-col h-full">
                <div className="flex items-center mb-4">
                  <div
                    className="p-2 bg-blue-100 rounded-lg"
                    aria-hidden="true"
                  >
                    <Icon className="w-6 h-6 text-blue-600" />
                  </div>
                  <h3 className="ml-3 text-lg font-semibold text-gray-900">
                    {feature.title}
                  </h3>
                </div>

                <p className="text-gray-600 mb-6 flex-grow">
                  {feature.description}
                </p>

                <Link
                  to={feature.link}
                  className="inline-flex items-center justify-center px-4 py-2 text-sm font-medium text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
                >
                  {feature.linkText}
                  <span aria-hidden="true" className="ml-2">
                    →
                  </span>
                </Link>
              </Card>
            );
          })}
        </div>
      </section>

      <section
        aria-labelledby="quality-heading"
        className="bg-blue-50 rounded-lg p-6 border-2 border-blue-200"
      >
        <h2
          id="quality-heading"
          className="text-2xl font-semibold text-gray-900 mb-4"
        >
          Qualidade e Acessibilidade
        </h2>

        <div className="grid gap-4 md:grid-cols-3">
          <div>
            <h3 className="font-medium text-gray-900 mb-2">Precisão Decimal</h3>
            <p className="text-sm text-gray-700">
              Usamos a biblioteca Decimal.js para evitar erros de ponto
              flutuante em cálculos financeiros.
            </p>
          </div>

          <div>
            <h3 className="font-medium text-gray-900 mb-2">
              WCAG 2.1 Nível AA
            </h3>
            <p className="text-sm text-gray-700">
              Toda a interface segue os padrões de acessibilidade WCAG 2.1 AA,
              garantindo uso por todos.
            </p>
          </div>

          <div>
            <h3 className="font-medium text-gray-900 mb-2">
              Testes Automatizados
            </h3>
            <p className="text-sm text-gray-700">
              30 golden files validam os cálculos, testes E2E garantem
              funcionamento, testes A11y previnem regressões.
            </p>
          </div>
        </div>
      </section>
    </div>
  );
};
