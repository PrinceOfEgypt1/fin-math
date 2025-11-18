import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { build } from "../../src/server";
import type { FastifyInstance } from "fastify";

describe("Price API Integration", () => {
  let server: FastifyInstance;

  beforeAll(async () => {
    server = await build();
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
          pv: 100000,
          rate: 0.12, // Taxa anual (12%)
          n: 12,
        },
      });

      expect(response.statusCode).toBe(200);

      const body = JSON.parse(response.body);
      expect(body).toHaveProperty("schedule");
      expect(body).toHaveProperty("snapshotId");
      expect(body.schedule).toHaveLength(12);
      expect(body.schedule[0]).toHaveProperty("period");
      expect(body.schedule[0]).toHaveProperty("pmt");
      expect(body.schedule[0]).toHaveProperty("interest");
      expect(body.schedule[0]).toHaveProperty("amortization");
      expect(body.schedule[0]).toHaveProperty("balance");
    });

    it("should validate required fields", async () => {
      const response = await server.inject({
        method: "POST",
        url: "/api/price",
        payload: {},
      });

      expect(response.statusCode).toBe(400);
    });

    it("should validate positive pv", async () => {
      const response = await server.inject({
        method: "POST",
        url: "/api/price",
        payload: {
          pv: -1000,
          rate: 0.01,
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
          pv: 100000,
          rate: 0.01,
          n: 0,
        },
      });

      expect(response.statusCode).toBe(400);
    });
  });
});
