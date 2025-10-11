import React, { useState } from "react";

export default function App() {
  const [pv, setPv] = useState(10000);
  const [rate, setRate] = useState(0.025);
  const [n, setN] = useState(12);
  const [pmt, setPmt] = useState<number | undefined>();

  function calc() {
    const a = Math.pow(1 + rate, n);
    const p = (pv * (rate * a)) / (a - 1);
    setPmt(Math.round(p * 100) / 100);
  }

  return (
    <div className="max-w-3xl mx-auto p-6">
      <h1 className="text-xl font-semibold">
        FinMath — Simulador Price (stub)
      </h1>
      <div className="grid grid-cols-3 gap-3 mt-4">
        <label className="text-sm">
          PV (R$)
          <input
            className="w-full mt-1 px-2 py-1 bg-slate-800 rounded"
            type="number"
            value={pv}
            onChange={(e) => setPv(Number(e.target.value))}
          />
        </label>
        <label className="text-sm">
          i (% a.m.)
          <input
            className="w-full mt-1 px-2 py-1 bg-slate-800 rounded"
            type="number"
            step="0.0001"
            value={rate * 100}
            onChange={(e) => setRate(Number(e.target.value) / 100)}
          />
        </label>
        <label className="text-sm">
          n (meses)
          <input
            className="w-full mt-1 px-2 py-1 bg-slate-800 rounded"
            type="number"
            value={n}
            onChange={(e) => setN(Number(e.target.value))}
          />
        </label>
      </div>
      <button
        className="mt-4 px-3 py-2 rounded bg-cyan-500 text-slate-900 font-semibold"
        onClick={calc}
      >
        Calcular
      </button>
      <div className="mt-4">
        PMT: <b>{pmt?.toFixed(2) ?? "—"}</b>
      </div>
    </div>
  );
}
