import { FastifyInstance } from "fastify";
import Papa from "papaparse";

function toCSV(rows: any[], totals: any, meta: any) {
  const table = rows.map((r: any) => ({
    "#": r.k,
    PMT: r.pmt,
    Juros: r.interest,
    Amortizacao: r.amort,
    Saldo: r.balance,
    Data: r.date ?? "",
  }));
  const csvTable = Papa.unparse(table, { delimiter: ";" });
  const footer = `\n# totals.totalPaid;${totals?.totalPaid ?? ""}\n# totals.totalInterest;${totals?.totalInterest ?? ""}\n# feesT0;${totals?.feesT0 ?? ""}\n# motorVersion;${meta?.motorVersion ?? ""}\n# calculationId;${meta?.calculationId ?? ""}\n`;
  return csvTable + footer;
}

export async function reportsRoutes(app: FastifyInstance) {
  app.post("/reports/price.csv", async (req, reply) => {
    // ✅ Sem /api
    const res = await app.inject({
      method: "POST",
      url: "/api/price",
      payload: req.body as Record<string, unknown>,
    });

    if (res.statusCode >= 400) {
      return reply.status(res.statusCode).send(res.body);
    }

    const data = res.json() as any;
    const csv = toCSV(data.schedule, data.totals, data.meta);

    reply.header("Content-Type", "text/csv; charset=utf-8");
    reply.header("Content-Disposition", "attachment; filename=price.csv");
    return reply.send(csv);
  });

  app.post("/reports/sac.csv", async (req, reply) => {
    // ✅ Sem /api
    const res = await app.inject({
      method: "POST",
      url: "/api/sac",
      payload: req.body as Record<string, unknown>,
    });

    if (res.statusCode >= 400) {
      return reply.status(res.statusCode).send(res.body);
    }

    const data = res.json() as any;
    const csv = toCSV(data.schedule, data.totals, data.meta);

    reply.header("Content-Type", "text/csv; charset=utf-8");
    reply.header("Content-Disposition", "attachment; filename=sac.csv");
    return reply.send(csv);
  });
}
