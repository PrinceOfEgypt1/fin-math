import { useState } from "react";

function App() {
  const [count, setCount] = useState(0);

  return (
    <div
      style={{
        minHeight: "100vh",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: "system-ui, sans-serif",
        background: "#1a1a1a",
        color: "#fff",
      }}
    >
      <h1 style={{ fontSize: "3rem", marginBottom: "2rem" }}>
        FinMath Calculator
      </h1>

      <div
        style={{
          padding: "2rem",
          background: "#2a2a2a",
          borderRadius: "8px",
          textAlign: "center",
        }}
      >
        <button
          onClick={() => setCount(count + 1)}
          style={{
            padding: "1rem 2rem",
            fontSize: "1.5rem",
            background: "#646cff",
            color: "white",
            border: "none",
            borderRadius: "4px",
            cursor: "pointer",
          }}
        >
          Count is {count}
        </button>
        <p style={{ marginTop: "1rem", color: "#888" }}>
          ✅ Vite + React funcionando!
        </p>
      </div>

      <p style={{ marginTop: "2rem", color: "#888" }}>
        Sprint 4 - E2E Tests Ready
      </p>
    </div>
  );
}

export default App;
