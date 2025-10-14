import Fastify from "fastify";
import cors from "@fastify/cors";
import swagger from "@fastify/swagger";
import swaggerUI from "@fastify/swagger-ui";
import { requestIdPlugin } from "./infrastructure/request-id";
import { errorHandler } from "./infrastructure/error-handler";
import { dayCountRoutes } from "./routes/day-count.routes";
import { priceRoutes } from "./routes/price.routes";

export async function buildServer() {
  const fastify = Fastify({
    logger: {
      level: process.env.LOG_LEVEL || "info",
    },
    genReqId: () => crypto.randomUUID(),
  });

  await fastify.register(cors, {
    origin: process.env.CORS_ORIGIN || "*",
  });

  await fastify.register(requestIdPlugin);

  await fastify.register(swagger, {
    openapi: {
      info: {
        title: "FinMath API",
        version: "1.0.0",
      },
      servers: [{ url: "http://localhost:3001" }],
    },
  });

  await fastify.register(swaggerUI, {
    routePrefix: "/api-docs",
  });

  fastify.get("/health", async () => ({ status: "ok" }));

  await fastify.register(dayCountRoutes, { prefix: "/api" });
  await fastify.register(priceRoutes, { prefix: "/api" });

  fastify.setErrorHandler(errorHandler);

  return fastify;
}

async function start() {
  const server = await buildServer();
  await server.listen({ port: 3001, host: "0.0.0.0" });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  start();
}
