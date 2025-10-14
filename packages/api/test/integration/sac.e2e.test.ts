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

describe("POST /api/sac", () => {
  it("gera cronograma SAC (amortização constante) com ajuste final", async () => {
    const res = await request(app.server)
      .post("/api/sac")
      .send({ pv: 10000, rateMonthly: 0.02, n: 12, feesT0: 85 })
      .expect(200);
    expect(res.body.schedule).toHaveLength(12);
    const first = res.body.schedule[0],
      last = res.body.schedule[11];
    expect(first.amort).toBeGreaterThan(0);
    expect(last.balance).toBe(0);
  });
});
