import { describe, it, expect } from "vitest";
import request from "supertest";
import app from "../../src/server";

describe("POST /api/irr", () => {
  it("deve calcular IRR de fluxo simples", async () => {
    const response = await request(app)
      .post("/api/irr")
      .send({
        cashFlows: [-1000, 300, 400, 500],
      });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.irr).toBeCloseTo(0.124, 3);
    expect(response.body.data.converged).toBe(true);
  });

  it("deve validar entrada", async () => {
    const response = await request(app)
      .post("/api/irr")
      .send({
        cashFlows: [-1000], // Mínimo 2 elementos
      });

    expect(response.status).toBe(400);
  });
});
