import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { build } from "../../src/server.js";
import type { FastifyInstance } from "fastify";

describe("POST /api/day-count", () => {
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
    expect(result.yearFraction).toBe(1);
    expect(result.convention).toBe("ACT/365");
  });

  it("should return 400 for invalid date format", async () => {
    const response = await server.inject({
      method: "POST",
      url: "/api/day-count",
      payload: {
        startDate: "invalid-date",
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
