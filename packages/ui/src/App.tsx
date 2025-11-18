import { Layout } from "./components";
import { Router } from "./Router";

/**
 * Aplicação principal do FinMath.
 * Estrutura acessível seguindo WCAG 2.1 AA.
 */
function App() {
  return (
    <Layout>
      <Router />
    </Layout>
  );
}

export default App;
