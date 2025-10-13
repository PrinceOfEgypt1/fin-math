import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { buildServer } from "../../src/server";
import type { FastifyInstance } from "fastify";

describe("Day Count API Integration", () => {
  let server: FastifyInstance;

  beforeAll(async () => {
    server = await buildServer();
    await server.ready();
  });

  afterAll(async () => {
    await server.close();
  });

  describe("POST /api/day-count", () => {
    it("should calculate pro-rata interest with 30/360", async () => {
      const response = await server.inject({
        method: "POST",
        url: "/api/day-count",
        payload: {
          principal: 100000,
          annualRate: 0.12,
          startDate: "2025-01-01",
          endDate: "2025-02-01",
          convention: "30/360",
        },
      });

      expect(response.statusCode).toBe(200);

      const body = JSON.parse(response.body);
      expect(body.calculationId).toBeDefined();
      expect(body.motorVersion).toBe("0.4.0");
      expect(body.result.interest).toBeCloseTo(986.3, 2);
      expect(body.result.days).toBe(31);
      expect(body.result.convention).toBe("30/360");
    });

    it("should calculate pro-rata interest with ACT/365", async () => {
      const response = await server.inject({
        method: "POST",
        url: "/api/day-count",
        payload: {
          principal: 100000,
          annualRate: 0.12,
          startDate: "2025-01-01",
          endDate: "2025-02-01",
          convention: "ACT/365",
        },
      });

      expect(response.statusCode).toBe(200);

      const body = JSON.parse(response.body);
      expect(body.result.interest).toBeCloseTo(1019.18, 2);
      expect(body.result.convention).toBe("ACT/365");
    });

    it("should validate required fields", async () => {
      const response = await server.inject({
        method: "POST",
        url: "/api/day-count",
        payload: {
          principal: 100000,
          // Missing fields
        },
      });

      expect(response.statusCode).toBe(400);

      const body = JSON.parse(response.body);
      expect(body.error.code).toBe("VALIDATION_ERROR");
    });

    it("should validate convention enum", async () => {
      const response = await server.inject({
        method: "POST",
        url: "/api/day-count",
        payload: {
          principal: 100000,
          annualRate: 0.12,
          startDate: "2025-01-01",
          endDate: "2025-02-01",
          convention: "INVALID",
        },
      });

      expect(response.statusCode).toBe(400);

      const body = JSON.parse(response.body);
      expect(body.error.code).toBe("VALIDATION_ERROR");
    });
  });
});
