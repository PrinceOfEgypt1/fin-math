import { Button } from '../components';

/**
 * Página inicial do FinMath.
 * Acessível via teclado e leitor de tela.
 * Segue WCAG 2.1 AA.
 */
export function Home() {
  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-6 text-gray-800">
        Bem-vindo ao FinMath
      </h1>

      <p className="text-xl text-gray-600 mb-8">
        Calculadora financeira acessível para simulações de financiamento e investimentos.
      </p>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold mb-4 text-gray-700">
          O que você pode fazer aqui?
        </h2>

        <div className="grid md:grid-cols-2 gap-6">
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-xl font-semibold mb-3 text-blue-600">
              Sistema PRICE
            </h3>
            <p className="text-gray-600 mb-4">
              Calcule financiamentos com parcelas fixas. Ideal para quem busca
              previsibilidade no orçamento mensal.
            </p>
            <Button
              onClick={() => window.location.href = '/price'}
              variant="primary"
            >
              Calcular PRICE
            </Button>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-xl font-semibold mb-3 text-green-600">
              Sistema SAC
            </h3>
            <p className="text-gray-600 mb-4">
              Calcule financiamentos com parcelas decrescentes. Economia maior
              no longo prazo.
            </p>
            <Button
              onClick={() => window.location.href = '/sac'}
              variant="primary"
            >
              Calcular SAC
            </Button>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md md:col-span-2">
            <h3 className="text-xl font-semibold mb-3 text-purple-600">
              Comparador PRICE vs SAC
            </h3>
            <p className="text-gray-600 mb-4">
              Compare lado a lado os dois sistemas de amortização e veja
              qual é mais vantajoso para você.
            </p>
            <Button
              onClick={() => window.location.href = '/comparator'}
              variant="primary"
            >
              Comparar Sistemas
            </Button>
          </div>
        </div>
      </section>

      <section className="bg-blue-50 p-6 rounded-lg">
        <h2 className="text-2xl font-semibold mb-4 text-gray-700">
          ♿ Acessibilidade em Primeiro Lugar
        </h2>
        <p className="text-gray-600 mb-4">
          O FinMath foi desenvolvido seguindo as diretrizes WCAG 2.1 Nível AA,
          garantindo que todos possam usar nossa calculadora:
        </p>
        <ul className="list-disc list-inside space-y-2 text-gray-600">
          <li>✅ Navegação completa por teclado</li>
          <li>✅ Compatível com leitores de tela (NVDA, JAWS, VoiceOver)</li>
          <li>✅ Contraste adequado em todos os elementos</li>
          <li>✅ Estrutura semântica clara</li>
          <li>✅ Mensagens de erro descritivas e acessíveis</li>
        </ul>
      </section>
    </div>
  );
}
