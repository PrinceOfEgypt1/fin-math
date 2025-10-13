import Fastify from "fastify";
import cors from "@fastify/cors";
import helmet from "@fastify/helmet";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";
import { logger, MOTOR_VERSION } from "./infrastructure/logger.js";
import { errorHandler } from "./infrastructure/errors.js";

export async function createServer() {
  const server = Fastify({
    logger: logger as any,
    requestIdLogLabel: "correlationId",
    disableRequestLogging: false,
    genReqId: () => crypto.randomUUID(),
  });

  await server.register(cors, {
    origin: process.env.CORS_ORIGIN || "*",
    credentials: true,
  });

  await server.register(helmet, {
    contentSecurityPolicy: false,
  });

  await server.register(swagger, {
    openapi: {
      openapi: "3.1.0",
      info: {
        title: "FinMath API",
        description: "API REST para cálculos de matemática financeira",
        version: MOTOR_VERSION,
        contact: {
          name: "FinMath Team",
          url: "https://github.com/PrinceOfEgypt1/fin-math",
        },
      },
      tags: [
        { name: "health", description: "Health check" },
        { name: "price", description: "Price calculations" },
        { name: "sac", description: "SAC calculations" },
        { name: "cet", description: "CET calculations" },
      ],
    },
  });

  await server.register(swaggerUi, {
    routePrefix: "/api-docs",
    uiConfig: { docExpansion: "list", deepLinking: true },
  });

  server.setErrorHandler(errorHandler);

  server.addHook("onSend", async (request, reply, payload) => {
    if (reply.statusCode >= 200 && reply.statusCode < 300) {
      const contentType = reply.getHeader("content-type");
      if (contentType && contentType.toString().includes("application/json")) {
        try {
          const json = JSON.parse(payload as string);
          if (!json.meta) json.meta = {};
          json.meta.motorVersion = MOTOR_VERSION;
          json.meta.calculationId = json.meta.calculationId || request.id;
          json.meta.timestamp = new Date().toISOString();
          return JSON.stringify(json);
        } catch {
          return payload;
        }
      }
    }
    return payload;
  });

  server.get(
    "/health",
    {
      schema: {
        description: "Health check",
        tags: ["health"],
        response: {
          200: {
            type: "object",
            properties: {
              status: { type: "string" },
              timestamp: { type: "string" },
              motorVersion: { type: "string" },
              uptime: { type: "number" },
            },
          },
        },
      },
    },
    async () => ({
      status: "ok",
      timestamp: new Date().toISOString(),
      motorVersion: MOTOR_VERSION,
      uptime: process.uptime(),
    }),
  );

  server.get("/", async (request, reply) => reply.redirect("/api-docs"));

  server.setNotFoundHandler((request, reply) => {
    reply.status(404).send({
      error: {
        code: "ENDPOINT_NOT_FOUND",
        message: `Route ${request.method}:${request.url} not found`,
        correlationId: request.id,
      },
    });
  });

  return server;
}

export async function startServer() {
  const server = await createServer();
  const port = parseInt(process.env.PORT || "3001", 10);
  const host = process.env.HOST || "0.0.0.0";

  try {
    await server.listen({ port, host });
    logger.info(
      { port, host, motorVersion: MOTOR_VERSION },
      `🚀 Server running on http://${host}:${port}`,
    );
    logger.info(`📚 API Docs: http://${host}:${port}/api-docs`);
  } catch (err) {
    logger.error(err, "Failed to start server");
    process.exit(1);
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  startServer();
}
