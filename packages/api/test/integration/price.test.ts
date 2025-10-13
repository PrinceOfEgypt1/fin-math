import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { buildServer } from "../../src/server";
import type { FastifyInstance } from "fastify";

describe("Price API Integration", () => {
  let server: FastifyInstance;

  beforeAll(async () => {
    server = await buildServer();
    await server.ready();
  });

  afterAll(async () => {
    await server.close();
  });

  describe("POST /api/price", () => {
    it("should calculate PRICE schedule for 12 months", async () => {
      const response = await server.inject({
        method: "POST",
        url: "/api/price",
        payload: {
          pv: 10000,
          annualRate: 0.12,
          n: 12,
        },
      });

      expect(response.statusCode).toBe(200);

      const body = JSON.parse(response.body);
      expect(body.calculationId).toBeDefined();
      expect(body.motorVersion).toBe("0.4.0");
      expect(body.result.pmt).toBeCloseTo(888.49, 2);
      expect(body.result.schedule.length).toBe(12);

      const last = body.result.schedule[11];
      expect(last.balance).toBeLessThanOrEqual(0.01);
    });

    it("should validate required fields", async () => {
      const response = await server.inject({
        method: "POST",
        url: "/api/price",
        payload: {
          pv: 10000,
        },
      });

      expect(response.statusCode).toBe(400);

      const body = JSON.parse(response.body);
      expect(body.error.code).toBe("VALIDATION_ERROR");
    });

    it("should validate positive pv", async () => {
      const response = await server.inject({
        method: "POST",
        url: "/api/price",
        payload: {
          pv: -1000,
          annualRate: 0.12,
          n: 12,
        },
      });

      expect(response.statusCode).toBe(400);
    });

    it("should validate n range", async () => {
      const response = await server.inject({
        method: "POST",
        url: "/api/price",
        payload: {
          pv: 10000,
          annualRate: 0.12,
          n: 500,
        },
      });

      expect(response.statusCode).toBe(400);
    });
  });
});
