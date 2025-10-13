import Fastify from "fastify";
import cors from "@fastify/cors";
import helmet from "@fastify/helmet";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";
import { randomUUID } from "crypto";
import { errorHandler } from "./infrastructure/errors";
import { dayCountRoutes } from "./routes/day-count.routes";
import { ENGINE_VERSION } from "@finmath/engine";

const PORT = process.env.PORT ? parseInt(process.env.PORT) : 3001;

async function buildServer() {
  const fastify = Fastify({
    logger: true,
    genReqId: () => randomUUID(),
  });

  await fastify.register(helmet);
  await fastify.register(cors);

  await fastify.register(swagger, {
    openapi: {
      info: {
        title: "FinMath API",
        version: ENGINE_VERSION,
        description: "Financial mathematics calculation API",
      },
      tags: [
        { name: "health", description: "Health check" },
        { name: "day-count", description: "Day count conventions" },
      ],
    },
  });

  await fastify.register(swaggerUi, {
    routePrefix: "/api-docs",
  });

  fastify.setErrorHandler(errorHandler as any);

  fastify.get("/health", {
    schema: {
      description: "Health check endpoint",
      tags: ["health"],
      response: {
        200: {
          type: "object",
          properties: {
            status: { type: "string" },
            motorVersion: { type: "string" },
            timestamp: { type: "string" },
          },
        },
      },
    },
    handler: async (request, reply) => {
      return reply.status(200).send({
        status: "healthy",
        motorVersion: ENGINE_VERSION,
        timestamp: new Date().toISOString(),
      });
    },
  });

  await fastify.register(dayCountRoutes, { prefix: "/api" });

  return fastify;
}

async function start() {
  const server = await buildServer();

  try {
    await server.listen({ port: PORT, host: "0.0.0.0" });
    server.log.info(`Server listening on port ${PORT}`);
    server.log.info(`Swagger UI: http://localhost:${PORT}/api-docs`);
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
}

if (require.main === module) {
  start();
}

export { buildServer };
