import { FastifyInstance } from "fastify";
import Papa from "papaparse";
import PDFDocument from "pdfkit";

function toCSV(rows: any[], totals: any, meta: any) {
  const table = rows.map((r: any) => ({
    "#": r.period || r.k || "",
    PMT: r.pmt || "",
    Juros: r.interest || "",
    Amortizacao: r.amortization || r.amort || "",
    Saldo: r.balance || "",
    Data: r.date || "",
  }));

  const csvTable = Papa.unparse(table, { delimiter: ";" });

  const footer = `\n# totals.totalPaid;${totals?.totalPaid || ""}\n# totals.totalInterest;${totals?.totalInterest || ""}\n# feesT0;${totals?.feesT0 || ""}\n# motorVersion;${meta?.motorVersion || ""}\n# calculationId;${meta?.calculationId || ""}\n`;

  return csvTable + footer;
}

function generatePDF(
  rows: any[],
  systemType: string,
  amortConst?: string,
): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({ margin: 50 });
      const chunks: Buffer[] = [];

      doc.on("data", (chunk) => chunks.push(chunk));
      doc.on("end", () => resolve(Buffer.concat(chunks)));
      doc.on("error", reject);

      // Header
      doc
        .fontSize(20)
        .text(`Cronograma de Amortização - ${systemType}`, { align: "center" });
      doc.moveDown();
      doc.fontSize(10).text(`Data: ${new Date().toLocaleDateString("pt-BR")}`, {
        align: "right",
      });
      doc.moveDown();

      if (amortConst) {
        doc
          .fontSize(12)
          .text(`Amortização Constante: R$ ${amortConst}`, { align: "left" });
        doc.moveDown();
      }

      // Table Header
      const tableTop = doc.y;
      const colWidths: number[] = [40, 80, 80, 100, 100];
      const headers = ["#", "PMT", "Juros", "Amortização", "Saldo"];

      doc.fontSize(10).font("Helvetica-Bold");
      let x = 50;
      headers.forEach((header, i) => {
        const width = colWidths[i] || 80; // Fallback para 80
        doc.text(header, x, tableTop, { width, align: "center" });
        x += width;
      });

      doc.moveDown();
      doc.moveTo(50, doc.y).lineTo(550, doc.y).stroke();
      doc.moveDown(0.5);

      // Table Rows
      doc.font("Helvetica").fontSize(9);
      rows.forEach((row: any) => {
        const y = doc.y;

        // Check if we need a new page
        if (y > 700) {
          doc.addPage();
          doc.fontSize(9);
        }

        const period = row.period || row.k || "";
        const pmt = row.pmt || "";
        const interest = row.interest || "";
        const amortization = row.amortization || row.amort || "";
        const balance = row.balance || "";

        doc.text(String(period), 50, doc.y, { width: 40, align: "center" });
        doc.text(String(pmt), 90, y, { width: 80, align: "right" });
        doc.text(String(interest), 170, y, { width: 80, align: "right" });
        doc.text(String(amortization), 250, y, { width: 100, align: "right" });
        doc.text(String(balance), 350, y, { width: 100, align: "right" });

        doc.moveDown(0.8);
      });

      // Footer
      doc.moveDown();
      doc.moveTo(50, doc.y).lineTo(550, doc.y).stroke();
      doc.moveDown();
      doc
        .fontSize(8)
        .text("Gerado por FinMath API v0.3.0", { align: "center" });

      doc.end();
    } catch (error: unknown) {
      reject(error);
    }
  });
}

export async function reportsRoutes(app: FastifyInstance) {
  // CSV Routes
  app.post("/reports/price.csv", async (req, reply) => {
    const res = await app.inject({
      method: "POST",
      url: "/api/price",
      payload: req.body as Record<string, unknown>,
    });

    if (res.statusCode >= 400) {
      return reply.status(res.statusCode).send(res.body);
    }

    const data = res.json() as any;
    const csv = toCSV(data.schedule || [], data.totals || {}, data.meta || {});

    reply.header("Content-Type", "text/csv; charset=utf-8");
    reply.header("Content-Disposition", "attachment; filename=price.csv");
    return reply.send(csv);
  });

  app.post("/reports/sac.csv", async (req, reply) => {
    const res = await app.inject({
      method: "POST",
      url: "/api/sac",
      payload: req.body as Record<string, unknown>,
    });

    if (res.statusCode >= 400) {
      return reply.status(res.statusCode).send(res.body);
    }

    const data = res.json() as any;
    const csv = toCSV(data.schedule || [], data.totals || {}, data.meta || {});

    reply.header("Content-Type", "text/csv; charset=utf-8");
    reply.header("Content-Disposition", "attachment; filename=sac.csv");
    return reply.send(csv);
  });

  // PDF Routes
  app.post("/reports/price.pdf", async (req, reply) => {
    const res = await app.inject({
      method: "POST",
      url: "/api/price",
      payload: req.body as Record<string, unknown>,
    });

    if (res.statusCode >= 400) {
      return reply.status(res.statusCode).send(res.body);
    }

    const data = res.json() as any;
    const pdf = await generatePDF(data.schedule || [], "PRICE");

    reply.header("Content-Type", "application/pdf");
    reply.header("Content-Disposition", "attachment; filename=price.pdf");
    return reply.send(pdf);
  });

  app.post("/reports/sac.pdf", async (req, reply) => {
    const res = await app.inject({
      method: "POST",
      url: "/api/sac",
      payload: req.body as Record<string, unknown>,
    });

    if (res.statusCode >= 400) {
      return reply.status(res.statusCode).send(res.body);
    }

    const data = res.json() as any;
    const pdf = await generatePDF(data.schedule || [], "SAC", data.amortConst);

    reply.header("Content-Type", "application/pdf");
    reply.header("Content-Disposition", "attachment; filename=sac.pdf");
    return reply.send(pdf);
  });
}
