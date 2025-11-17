import React from "react";
import { Link, useLocation } from "react-router-dom";
import { Calculator, BarChart3, Home } from "lucide-react";

export interface LayoutProps {
  children: React.ReactNode;
}

/**
 * Layout principal da aplicação com navegação acessível
 *
 * Características de acessibilidade:
 * - Landmarks semânticos (<header>, <nav>, <main>, <footer>)
 * - Skip link para pular navegação
 * - Navegação por teclado completa
 * - Indicador visual da página ativa
 * - aria-current para link ativo
 */
export const Layout: React.FC<LayoutProps> = ({ children }) => {
  const location = useLocation();

  const navigation = [
    { name: "Início", href: "/", icon: Home },
    { name: "Comparador PRICE vs SAC", href: "/comparador", icon: BarChart3 },
    { name: "Calculadora", href: "/calculadora", icon: Calculator },
  ];

  const isActive = (path: string) => location.pathname === path;

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Skip Link para acessibilidade */}
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-blue-600 focus:text-white focus:rounded-lg focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
      >
        Pular para o conteúdo principal
      </a>

      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-gray-900">
                <Link
                  to="/"
                  className="focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 rounded-lg px-2 py-1"
                >
                  FinMath
                </Link>
              </h1>
            </div>

            <nav aria-label="Navegação principal">
              <ul className="flex space-x-4">
                {navigation.map((item) => {
                  const Icon = item.icon;
                  const active = isActive(item.href);

                  return (
                    <li key={item.name}>
                      <Link
                        to={item.href}
                        aria-current={active ? "page" : undefined}
                        className={`
                          inline-flex items-center px-3 py-2 text-sm font-medium rounded-lg
                          transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500
                          ${
                            active
                              ? "bg-blue-100 text-blue-700"
                              : "text-gray-700 hover:bg-gray-100 hover:text-gray-900"
                          }
                        `}
                      >
                        <Icon
                          className="w-4 h-4 mr-2"
                          aria-hidden="true"
                          focusable="false"
                        />
                        {item.name}
                      </Link>
                    </li>
                  );
                })}
              </ul>
            </nav>
          </div>
        </div>
      </header>

      <main
        id="main-content"
        className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8"
      >
        {children}
      </main>

      <footer className="bg-white border-t border-gray-200 mt-auto">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <p className="text-center text-sm text-gray-600">
            © 2025 FinMath - Matemática Financeira Acessível
          </p>
        </div>
      </footer>
    </div>
  );
};
