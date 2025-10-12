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
    const j = JSON.parse(res.payload);
    expect(j.pmt).toBeCloseTo(974.87, 2);
    expect(j.schedule).toHaveLength(12);
  });

  it("valida PV mínimo", async () => {
    const res = await app.inject({
      method: "POST",
      url: "/api/price",
      payload: { pv: 50, rate: 0.025, n: 12 },
    });
    expect(res.statusCode).toBe(400);
  });
});
