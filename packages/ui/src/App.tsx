import { useEffect, useState } from "react";
import { Header } from "./components/layout/Header";
import { Dashboard } from "./pages/Dashboard";
import { PriceSimulator } from "./pages/simulators/PriceSimulator";
import { SacSimulator } from "./pages/simulators/SacSimulator";
import { ComparisonPage } from "./pages/ComparisonPage";

function App() {
  const [currentPage, setCurrentPage] = useState("dashboard");
  useEffect(() => {
    const handleHashChange = () => {
      const hash = window.location.hash.slice(1);
      setCurrentPage(hash || "dashboard");
    };
    window.addEventListener("hashchange", handleHashChange);
    handleHashChange();
    return () => window.removeEventListener("hashchange", handleHashChange);
  }, []);
  const renderPage = () => {
    switch (currentPage) {
      case "price":
        return <PriceSimulator />;
      case "sac":
        return <SacSimulator />;
      case "comparison":
        return <ComparisonPage />;
      case "cet":
        return <Dashboard />;
      default:
        return <Dashboard />;
    }
  };
  return (
    <div className="min-h-screen">
      <Header />
      <main>{renderPage()}</main>
    </div>
  );
}
export default App;
