import React from 'react';

interface LayoutProps {
  children: React.ReactNode;
}

/**
 * Layout principal com estrutura semântica acessível.
 * Inclui header, nav, main e footer.
 * Segue WCAG 2.1 AA.
 */
export function Layout({ children }: LayoutProps) {
  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 bg-blue-600 text-white px-4 py-2 rounded"
      >
        Pular para o conteúdo principal
      </a>

      <header className="bg-blue-600 text-white shadow-md">
        <div className="container mx-auto px-4 py-4">
          <h1 className="text-2xl font-bold">
            FinMath - Calculadora Financeira
          </h1>
        </div>
      </header>

      <nav aria-label="Navegação principal" className="bg-white shadow-sm">
        <div className="container mx-auto px-4">
          <ul className="flex space-x-6 py-3">
            <li>
              <a
                href="/"
                className="text-gray-700 hover:text-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 rounded px-2 py-1"
              >
                Início
              </a>
            </li>
            <li>
              <a
                href="/price"
                className="text-gray-700 hover:text-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 rounded px-2 py-1"
              >
                PRICE
              </a>
            </li>
            <li>
              <a
                href="/sac"
                className="text-gray-700 hover:text-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 rounded px-2 py-1"
              >
                SAC
              </a>
            </li>
            <li>
              <a
                href="/comparator"
                className="text-gray-700 hover:text-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 rounded px-2 py-1"
              >
                Comparador
              </a>
            </li>
          </ul>
        </div>
      </nav>

      <main id="main-content" className="flex-1 container mx-auto px-4 py-8">
        {children}
      </main>

      <footer className="bg-gray-800 text-white mt-auto">
        <div className="container mx-auto px-4 py-6">
          <p className="text-center text-sm">
            © {new Date().getFullYear()} FinMath. Desenvolvido com acessibilidade em mente.
          </p>
        </div>
      </footer>
    </div>
  );
}
