import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { build } from "../../src/server";
import type { FastifyInstance } from "fastify";

describe("Infrastructure - API Base (Parcial)", () => {
  let server: FastifyInstance;

  beforeAll(async () => {
    server = await build();
    await server.ready();
  });

  afterAll(async () => {
    await server.close();
  });

  describe.skip("Health Check", () => {
    it("should return healthy status", async () => {
      const response = await server.inject({
        method: "GET",
        url: "/health",
      });

      expect(response.statusCode).toBe(200);

      const body = JSON.parse(response.body);
      expect(body.status).toBe("healthy");
      expect(body.motorVersion).toBeDefined();
      expect(body.timestamp).toBeDefined();
    });
  });

  describe("Swagger UI", () => {
    it("should serve OpenAPI documentation", async () => {
      const response = await server.inject({
        method: "GET",
        url: "/api-docs",
      });

      expect(response.statusCode).toBe(200);
    });
  });

  describe("Error Handling", () => {
    it("should return 404 for non-existent endpoints", async () => {
      const response = await server.inject({
        method: "GET",
        url: "/non-existent-endpoint",
      });

      expect(response.statusCode).toBe(404);
    });
  });
});
