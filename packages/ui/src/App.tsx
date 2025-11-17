import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { Layout } from "./components/Layout";
import { Home, Comparador, Calculadora } from "./pages";

/**
 * Aplicação FinMath com navegação acessível
 *
 * Características de acessibilidade (WCAG 2.1 AA):
 * - React Router para navegação SPA
 * - Layout com landmarks semânticos
 * - Skip links para conteúdo principal
 * - Todas as páginas com H1 único
 * - Navegação completa por teclado
 */
function App() {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/comparador" element={<Comparador />} />
          <Route path="/calculadora" element={<Calculadora />} />
        </Routes>
      </Layout>
    </Router>
  );
}

export default App;
