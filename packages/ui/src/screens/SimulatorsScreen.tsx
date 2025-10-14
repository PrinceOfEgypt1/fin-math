import React, { useMemo, useState } from "react";
import { ExplainPanel } from "../components/ExplainPanel";

function toFixed2(n: number) {
  return Number.isFinite(n) ? n.toFixed(2) : "-";
}

export function SimulatorsScreen() {
  const [pv, setPv] = useState(10000);
  const [i, setI] = useState(2.0); // % a.m.
  const [n, setN] = useState(12);

  // FV/PV simples (UI-only, motor é validado nos GFs; aqui é para valor imediato ao usuário)
  const r = i / 100;
  const fv = useMemo(() => pv * Math.pow(1 + r, n), [pv, r, n]);
  const pmtPost = useMemo(() => {
    if (r === 0) return pv / n;
    return (pv * r * Math.pow(1 + r, n)) / (Math.pow(1 + r, n) - 1);
  }, [pv, r, n]);

  return (
    <>
      <section className="card" aria-label="Formulário">
        <h2 className="text-lg font-medium mb-3">Simuladores base</h2>
        <div className="grid grid-cols-3 gap-3">
          <label className="flex flex-col">
            PV
            <input
              className="card"
              type="number"
              value={pv}
              min={0}
              onChange={(e) => setPv(Number(e.target.value))}
            />
          </label>
          <label className="flex flex-col">
            % a.m.
            <input
              className="card"
              type="number"
              value={i}
              step="0.01"
              onChange={(e) => setI(Number(e.target.value))}
            />
          </label>
          <label className="flex flex-col">
            n (meses)
            <input
              className="card"
              type="number"
              value={n}
              min={1}
              onChange={(e) => setN(Number(e.target.value))}
            />
          </label>
        </div>
        <div className="mt-4 grid grid-cols-3 gap-3">
          <div className="card">
            <div className="text-sm text-slate-400">FV (composto)</div>
            <div className="text-2xl">{toFixed2(fv)}</div>
          </div>
          <div className="card">
            <div className="text-sm text-slate-400">PMT (postecipado)</div>
            <div className="text-2xl">{toFixed2(pmtPost)}</div>
          </div>
          <div className="card">
            <div className="text-sm text-slate-400">Total pago (n·PMT)</div>
            <div className="text-2xl">{toFixed2(n * pmtPost)}</div>
          </div>
        </div>
      </section>

      <section aria-label="Explain">
        <ExplainPanel
          title="Fundamentos (S1/H7-H8)"
          formulae={[
            "FV = PV · (1 + i)^n",
            "PMT = PV · i · (1+i)^n / ((1+i)^n - 1)",
          ]}
          variables={{ PV: pv, i: `${i}% a.m.`, n }}
          notes={[
            "Valores exibidos com arredondamento visual (2 casas).",
            "Precisão oficial do motor garantida pelos Golden Files.",
          ]}
        />
      </section>
    </>
  );
}
