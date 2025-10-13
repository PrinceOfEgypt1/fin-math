import { describe, it, expect, beforeAll, afterAll } from "vitest";
import type { FastifyInstance } from "fastify";
import { createServer } from "../../src/server.js";

describe("Infrastructure - API Base", () => {
  let server: FastifyInstance;

  beforeAll(async () => {
    server = await createServer();
    await server.ready();
  });

  afterAll(async () => {
    await server.close();
  });

  describe("Health Check", () => {
    it("GET /health deve retornar 200 com status ok", async () => {
      const response = await server.inject({ method: "GET", url: "/health" });
      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.body);
      expect(body.status).toBe("ok");
      expect(body.motorVersion).toBeDefined();
    });
  });

  describe("Swagger UI", () => {
    it("GET /api-docs/json deve retornar spec OpenAPI", async () => {
      const response = await server.inject({
        method: "GET",
        url: "/api-docs/json",
      });
      expect(response.statusCode).toBe(200);
      const spec = JSON.parse(response.body);
      expect(spec.openapi).toBe("3.1.0");
    });
  });

  describe("Error Handling", () => {
    it("404 deve retornar envelope de erro", async () => {
      const response = await server.inject({
        method: "GET",
        url: "/inexistente",
      });
      expect(response.statusCode).toBe(404);
      const body = JSON.parse(response.body);
      expect(body.error.code).toBe("ENDPOINT_NOT_FOUND");
      expect(body.error.correlationId).toBeDefined();
    });
  });
});
