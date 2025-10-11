import { FastifyPluginAsync } from "fastify";
import * as engine from "@finmath/engine";
import { z } from "zod";

export const routes: FastifyPluginAsync = async (app) => {
  app.get("/health", async () => ({
    ok: true,
    ts: Date.now(),
    motorVersion: "0.1.0",
  }));

  app.post("/price", async (req, reply) => {
    const schema = z.object({
      pv: z.number(),
      rateMonthly: z.number(),
      n: z.number().int().positive(),
    });
    const { pv, rateMonthly, n } = schema.parse(req.body);
    const out = engine.amortization.price(pv, rateMonthly, n);
    return { data: out, meta: { motorVersion: "0.1.0" } };
  });

  app.post("/sac", async (req, reply) => {
    const schema = z.object({
      pv: z.number(),
      rateMonthly: z.number(),
      n: z.number().int().positive(),
    });
    const { pv, rateMonthly, n } = schema.parse(req.body);
    const out = engine.amortization.sac(pv, rateMonthly, n);
    return { data: out, meta: { motorVersion: "0.1.0" } };
  });

  app.post("/npv-irr", async (req, reply) => {
    const schema = z.object({
      cashflows: z.array(z.number()),
      baseAnnual: z.number().default(12),
    });
    const { cashflows, baseAnnual } = schema.parse(req.body);
    const irr = engine.irr.irrBisection(cashflows) ?? 0;
    const cetAnnual = Math.pow(1 + irr, baseAnnual) - 1;
    return {
      data: { irrMonthly: irr, cetAnnual },
      meta: { motorVersion: "0.1.0" },
    };
  });

  app.post("/cet/basic", async (req, reply) => {
    const schema = z.object({
      pv: z.number(),
      pmt: z.number(),
      n: z.number().int().positive(),
      feesT0: z.array(z.number()).optional(),
    });
    const { pv, pmt, n, feesT0 } = schema.parse(req.body);
    const out = engine.cet.cetBasic(pv, pmt, n, feesT0 ?? []);
    return { data: out, meta: { motorVersion: "0.1.0" } };
  });
};
