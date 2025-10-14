import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { buildServer } from "../../src/server";
import request from "supertest";

let app: any;
beforeAll(async () => {
  app = await buildServer();
});
afterAll(async () => {
  await app.close();
});

describe("POST /api/price", () => {
  it("calcula cronograma e aplica ajuste final", async () => {
    const res = await request(app.server)
      .post("/api/price")
      .send({
        pv: 10000,
        rateMonthly: 0.02,
        n: 12,
        feesT0: 85,
        daycount: "30/360",
        proRata: true,
      })
      .expect(200);
    expect(res.body.pmt).toBeDefined();
    expect(res.body.schedule).toHaveLength(12);
    const last = res.body.schedule[11];
    expect(last.balance).toBe(0); // saldo final zerado (ajuste aplicado)
    expect(res.body.meta.calculationId).toBeDefined();
    expect(res.body.meta.motorVersion).toBeDefined();
  });
});
