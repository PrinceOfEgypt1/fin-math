import React, { useEffect, useMemo, useState } from "react";
import { ExplainPanel } from "../components/ExplainPanel";

type Row = {
  k: number;
  pmt: number;
  interest: number;
  amort: number;
  balance: number;
};
function fmt(n: number) {
  return Number.isFinite(n) ? n.toFixed(2) : "-";
}

export function SacScreen() {
  const [pv, setPv] = useState(10000);
  const [i, setI] = useState(2.0);
  const [n, setN] = useState(12);
  const [feesT0, setFeesT0] = useState(85);
  const [schedule, setSchedule] = useState<Row[]>([]);
  const [meta, setMeta] = useState<{
    motorVersion?: string;
    calculationId?: string;
  }>({});

  const rowH = 40,
    headH = 44,
    pagerH = 44,
    pad = 24;
  const viewportRows = Math.max(
    1,
    Math.floor((window.innerHeight - 64 - pad * 2 - headH - pagerH) / rowH),
  );
  const [page, setPage] = useState(1);
  const pages = Math.max(1, Math.ceil(schedule.length / viewportRows));
  const rowsPage = useMemo(
    () => schedule.slice((page - 1) * viewportRows, page * viewportRows),
    [schedule, page, viewportRows],
  );

  async function run() {
    const res = await fetch("/api/sac", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ pv, rateMonthly: i / 100, n, feesT0 }),
    });
    const data = await res.json();
    setSchedule(data.schedule ?? []);
    setMeta({
      motorVersion: data?.meta?.motorVersion,
      calculationId: data?.meta?.calculationId,
    });
    setPage(1);
  }

  useEffect(() => {
    run(); /* eslint-disable-next-line */
  }, []);

  return (
    <>
      <section className="card" aria-label="Formulário SAC">
        <h2 className="text-lg font-medium mb-3">SAC</h2>
        <div className="grid grid-cols-6 gap-3">
          <label className="flex flex-col">
            PV{" "}
            <input
              className="card"
              type="number"
              value={pv}
              onChange={(e) => setPv(Number(e.target.value))}
            />
          </label>
          <label className="flex flex-col">
            % a.m.{" "}
            <input
              className="card"
              type="number"
              step="0.01"
              value={i}
              onChange={(e) => setI(Number(e.target.value))}
            />
          </label>
          <label className="flex flex-col">
            n{" "}
            <input
              className="card"
              type="number"
              value={n}
              onChange={(e) => setN(Number(e.target.value))}
            />
          </label>
          <label className="flex flex-col">
            fees t0{" "}
            <input
              className="card"
              type="number"
              value={feesT0}
              onChange={(e) => setFeesT0(Number(e.target.value))}
            />
          </label>
        </div>
        <div className="mt-3">
          <button className="btn btn-primary" onClick={run}>
            Calcular
          </button>
        </div>
      </section>

      <section className="card schedule" aria-label="Cronograma SAC">
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>PMT</th>
              <th>Juros</th>
              <th>Amortização</th>
              <th>Saldo</th>
            </tr>
          </thead>
          <tbody>
            {rowsPage.map((r) => (
              <tr key={r.k}>
                <td>{r.k}</td>
                <td>{fmt(r.pmt)}</td>
                <td>{fmt(r.interest)}</td>
                <td>{fmt(r.amort)}</td>
                <td>{fmt(r.balance)}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <div className="pager">
          <button
            className="btn"
            disabled={page <= 1}
            onClick={() => setPage((p) => Math.max(1, p - 1))}
          >
            Anterior
          </button>
          <div>
            Página {page}/{pages} · linhas/viewport: {viewportRows}
          </div>
          <button
            className="btn"
            disabled={page >= pages}
            onClick={() => setPage((p) => Math.min(pages, p + 1))}
          >
            Próxima
          </button>
        </div>
      </section>

      <section aria-label="Explain">
        <ExplainPanel
          title="SAC"
          formulae={[
            "Amortização_k = PV / n",
            "Juros_k = Saldo_{k-1} · i; PMT_k = Amort + Juros_k",
            "Ajuste final apenas na última parcela",
          ]}
          variables={{ PV: pv, i: `${i}% a.m.`, n, feesT0 }}
          meta={meta}
        />
      </section>
    </>
  );
}
