import React, { useState } from "react";

type ExplainProps = {
  title: string;
  formulae?: string[];
  variables?: Record<string, string | number>;
  notes?: string[];
  meta?: { motorVersion?: string; calculationId?: string };
};

export function ExplainPanel({
  title,
  formulae = [],
  variables = {},
  notes = [],
  meta,
}: ExplainProps) {
  const [tab, setTab] = useState<"formula" | "vars" | "notes">("formula");
  return (
    <div className="card" role="region" aria-label={`Explain: ${title}`}>
      <div className="flex items-center justify-between mb-2">
        <h2 className="text-lg font-medium">{title} — Explain</h2>
        <div className="flex gap-2">
          <button
            className="btn"
            onClick={() => window.print()}
            aria-label="Exportar PDF"
          >
            Exportar PDF
          </button>
        </div>
      </div>
      <div className="tabs" role="tablist" aria-label="Explain tabs">
        <button
          className={`tab ${tab === "formula" ? "tab--active" : ""}`}
          role="tab"
          aria-selected={tab === "formula"}
          onClick={() => setTab("formula")}
        >
          Fórmulas
        </button>
        <button
          className={`tab ${tab === "vars" ? "tab--active" : ""}`}
          role="tab"
          aria-selected={tab === "vars"}
          onClick={() => setTab("vars")}
        >
          Variáveis
        </button>
        <button
          className={`tab ${tab === "notes" ? "tab--active" : ""}`}
          role="tab"
          aria-selected={tab === "notes"}
          onClick={() => setTab("notes")}
        >
          Notas
        </button>
      </div>
      {tab === "formula" && (
        <ul className="list-disc pl-6">
          {formulae.map((f, i) => (
            <li key={i} className="mb-1">
              {f}
            </li>
          ))}
        </ul>
      )}
      {tab === "vars" && (
        <table className="w-full">
          <thead>
            <tr>
              <th className="text-left">Variável</th>
              <th className="text-left">Valor</th>
            </tr>
          </thead>
          <tbody>
            {Object.entries(variables).map(([k, v]) => (
              <tr key={k}>
                <td className="py-1">{k}</td>
                <td className="py-1">{String(v)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
      {tab === "notes" && (
        <ul className="list-disc pl-6">
          {notes.map((n, i) => (
            <li key={i} className="mb-1">
              {n}
            </li>
          ))}
        </ul>
      )}
      <div className="text-xs text-slate-400 mt-3">
        {meta?.motorVersion && (
          <>
            motorVersion: <code>{meta.motorVersion}</code> ·{" "}
          </>
        )}
        {meta?.calculationId && (
          <>
            calculationId: <code>{meta.calculationId}</code>
          </>
        )}
      </div>
    </div>
  );
}
