import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { build } from "../../src/server";
import type { FastifyInstance } from "fastify";

describe.skip("POST /api/day-count", () => {
  // Endpoint não implementado ainda - Sprint futura
  let server: FastifyInstance;

  beforeAll(async () => {
    server = await build();
    await server.ready();
  });

  afterAll(async () => {
    await server.close();
  });

  it("should calculate days and year fraction for ACT/365", async () => {
    const response = await server.inject({
      method: "POST",
      url: "/api/day-count",
      payload: {
        startDate: "2024-01-01",
        endDate: "2024-12-31",
        convention: "ACT/365",
      },
    });

    expect(response.statusCode).toBe(200);
    const result = JSON.parse(response.body);
    expect(result.days).toBe(365);
  });

  it("should return 400 for invalid date format", async () => {
    const response = await server.inject({
      method: "POST",
      url: "/api/day-count",
      payload: {
        startDate: "invalid",
        endDate: "2024-12-31",
        convention: "ACT/365",
      },
    });

    expect(response.statusCode).toBe(400);
  });

  it("should return 400 for invalid convention", async () => {
    const response = await server.inject({
      method: "POST",
      url: "/api/day-count",
      payload: {
        startDate: "2024-01-01",
        endDate: "2024-12-31",
        convention: "INVALID",
      },
    });

    expect(response.statusCode).toBe(400);
  });
});
