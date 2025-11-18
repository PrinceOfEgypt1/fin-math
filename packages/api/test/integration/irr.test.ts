// packages/api/test/integration/irr.test.ts
import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { build } from "../../src/server";
import type { FastifyInstance } from "fastify";

describe("POST /api/irr", () => {
  let server: FastifyInstance;

  beforeAll(async () => {
    server = await build();
    await server.ready();
  });

  afterAll(async () => {
    await server.close();
  });

  it("deve calcular IRR de fluxo simples", async () => {
    const response = await server.inject({
      method: "POST",
      url: "/api/irr",
      payload: { cashFlows: [-1000, 300, 400, 500] },
    });

    expect(response.statusCode).toBe(200);
    const body = response.json();
    expect(body.success).toBe(true);
    expect(typeof body.data.irr).toBe("number");
    expect(body.data.converged).toBe(true);
  });

  it("deve validar entrada", async () => {
    const response = await server.inject({
      method: "POST",
      url: "/api/irr",
      payload: { cashFlows: [-1000] },
    });

    expect(response.statusCode).toBe(400);
  });
});
