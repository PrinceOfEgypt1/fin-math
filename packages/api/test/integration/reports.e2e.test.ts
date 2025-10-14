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

describe("POST /api/reports/price.csv", () => {
  it("gera CSV a partir do cálculo de PRICE", async () => {
    const res = await request(app.server)
      .post("/api/reports/price.csv")
      .send({ pv: 10000, rateMonthly: 0.02, n: 12, feesT0: 85 })
      .expect(200);
    expect(res.headers["content-type"]).toContain("text/csv");
    expect(res.text).toContain("# totals.totalPaid;");
  });
});
