import React from 'react';
import { Home, Comparator } from './pages';

/**
 * Roteador simples baseado em hash.
 * Mantém a acessibilidade ao mudar de página.
 */
export function Router() {
  const [route, setRoute] = React.useState(window.location.pathname);

  React.useEffect(() => {
    const handleRouteChange = () => {
      setRoute(window.location.pathname);
      // Mover foco para o main ao mudar de rota (melhor para a11y)
      const main = document.getElementById('main-content');
      if (main) {
        main.focus();
      }
    };

    // Interceptar cliques em links internos
    const handleClick = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      const anchor = target.closest('a');

      if (anchor && anchor.href.startsWith(window.location.origin)) {
        e.preventDefault();
        const path = new URL(anchor.href).pathname;
        window.history.pushState({}, '', path);
        handleRouteChange();
      }
    };

    window.addEventListener('popstate', handleRouteChange);
    document.addEventListener('click', handleClick);

    return () => {
      window.removeEventListener('popstate', handleRouteChange);
      document.removeEventListener('click', handleClick);
    };
  }, []);

  // Renderizar componente baseado na rota
  switch (route) {
    case '/':
      return <Home />;
    case '/price':
      return (
        <div>
          <h1 className="text-3xl font-bold mb-6">Calculadora PRICE</h1>
          <p className="text-gray-600">Em desenvolvimento...</p>
        </div>
      );
    case '/sac':
      return (
        <div>
          <h1 className="text-3xl font-bold mb-6">Calculadora SAC</h1>
          <p className="text-gray-600">Em desenvolvimento...</p>
        </div>
      );
    case '/comparator':
      return <Comparator />;
    default:
      return (
        <div>
          <h1 className="text-3xl font-bold mb-6">Página não encontrada</h1>
          <p className="text-gray-600">
            A página que você procura não existe.
          </p>
          <a href="/" className="text-blue-600 hover:underline">
            Voltar para o início
          </a>
        </div>
      );
  }
}
