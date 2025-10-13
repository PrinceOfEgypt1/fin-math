import { describe, it, expect, beforeAll, afterAll } from "vitest";
import Fastify, { FastifyInstance } from "fastify";
import { priceRoutes } from "../../src/routes/price.routes";

describe("POST /api/price", () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    app = Fastify();
    await app.register(priceRoutes);
    await app.ready();
  });

  afterAll(async () => {
    await app.close();
  });

  it("calcula PMT (básico)", async () => {
    const res = await app.inject({
      method: "POST",
      url: "/api/price",
      payload: { pv: 10000, rate: 0.025, n: 12 },
    });

    expect(res.statusCode).toBe(200);

    const j = res.json();
    expect(j.pmt).toBeCloseTo(974.87, 2);
    expect(j.schedule).toHaveLength(12);
    expect(Math.abs(j.schedule[11].balance)).toBeLessThanOrEqual(0.01);
    expect(j.meta?.motorVersion).toBeDefined();
    expect(j.meta?.calculationId).toBeDefined();
  });

  it("valida PV mínimo", async () => {
    const res = await app.inject({
      method: "POST",
      url: "/api/price",
      payload: { pv: 50, rate: 0.025, n: 12 },
    });
    expect(res.statusCode).toBe(400);
  });

  it("inclui tarifas t0 no total pago", async () => {
    const res = await app.inject({
      method: "POST",
      url: "/api/price",
      payload: {
        pv: 10000,
        rate: 0.025,
        n: 12,
        feesT0: [
          { name: "Cadastro", value: 85 },
          { name: "Avaliação", value: 150 },
        ],
      },
    });

    expect(res.statusCode).toBe(200);
    const j = res.json();

    const tarifas = 85 + 150;
    const esperado = j.pmt * 12 + tarifas; // compara com tolerância de 2 casas
    expect(j.totalPaid).toBeCloseTo(esperado, 2);
  });
});
