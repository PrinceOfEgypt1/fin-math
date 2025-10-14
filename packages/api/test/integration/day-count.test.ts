import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { buildServer } from "../../src/server";
import { FastifyInstance } from "fastify";

describe("Day Count API Integration", () => {
  let server: FastifyInstance;

  beforeAll(async () => {
    server = await buildServer();
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
      expect(body.motorVersion).toBeDefined();
      expect(body.result.interest).toBeCloseTo(986.3, 1);
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
        },
      });

      expect(response.statusCode).toBe(400);

      const body = JSON.parse(response.body);
      expect(body.code).toBe("FST_ERR_VALIDATION"); // ✅ Formato Fastify
      expect(body.message).toContain("annualRate");
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
      expect(body.code).toBe("FST_ERR_VALIDATION"); // ✅ Formato Fastify
      expect(body.message).toContain("convention");
    });
  });
});
