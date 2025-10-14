import React, { useState } from "react";
import { PriceScreen } from "./PriceScreen";
import { SacScreen } from "./SacScreen";
import { SimulatorsScreen } from "./SimulatorsScreen";

export default function App() {
  const [route, setRoute] = useState<"sim" | "price" | "sac">("sim");
  return (
    <div id="app-root">
      <header className="app-header">
        <div className="flex gap-3">
          <button
            className={`btn ${route === "sim" ? "btn-primary" : ""}`}
            onClick={() => setRoute("sim")}
          >
            Simuladores (S1/H7)
          </button>
          <button
            className={`btn ${route === "price" ? "btn-primary" : ""}`}
            onClick={() => setRoute("price")}
          >
            PRICE (S2/H9-H10)
          </button>
          <button
            className={`btn ${route === "sac" ? "btn-primary" : ""}`}
            onClick={() => setRoute("sac")}
          >
            SAC (S2/H11)
          </button>
        </div>
      </header>
      <main className="page">
        {route === "sim" && <SimulatorsScreen />}
        {route === "price" && <PriceScreen />}
        {route === "sac" && <SacScreen />}
      </main>
    </div>
  );
}
