// packages/api/src/server.ts
import Fastify, { FastifyInstance } from "fastify";
import cors from "@fastify/cors";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";
import { priceRoutes } from "./routes/price.routes";
import { sacRoutes } from "./routes/sac.routes";
import { cetRoutes } from "./routes/cet.routes";
import { snapshotRoutes } from "./routes/snapshot.routes";
import { validatorRoutes } from "./routes/validator.routes";
import { reportsRoutes } from "./routes/reports.routes";
import irrRoutes from "./routes/irr.routes";
import perfisRoutes from "./routes/perfis.routes";
import comparadorRoutes from "./routes/comparador.routes";

export async function build(): Promise<FastifyInstance> {
  const fastify = Fastify({
    logger: {
      level: process.env.LOG_LEVEL || "info",
    },
  });

  // CORS
  await fastify.register(cors, {
    origin: true,
  });

  // Swagger com configuração detalhada
  await fastify.register(swagger, {
    openapi: {
      info: {
        title: "FinMath API",
        description: "API de Matemática Financeira - Sprint 3",
        version: "0.3.0",
      },
      servers: [
        {
          url: "http://localhost:3001",
          description: "Servidor de desenvolvimento",
        },
      ],
      components: {
        schemas: {
          PriceRequest: {
            type: "object",
            required: ["pv", "rate", "n"],
            properties: {
              pv: {
                type: "number",
                description: "Valor presente (principal)",
                example: 100000,
              },
              rate: {
                type: "number",
                description: "Taxa de juros por período (decimal)",
                example: 0.01,
              },
              n: {
                type: "integer",
                description: "Número de períodos",
                example: 12,
              },
            },
          },
          SacRequest: {
            type: "object",
            required: ["pv", "rate", "n"],
            properties: {
              pv: {
                type: "number",
                description: "Valor presente (principal)",
                example: 100000,
              },
              rate: {
                type: "number",
                description: "Taxa de juros por período (decimal)",
                example: 0.01,
              },
              n: {
                type: "integer",
                description: "Número de períodos",
                example: 12,
              },
            },
          },
          CetBasicRequest: {
            type: "object",
            required: ["pv", "rate", "n"],
            properties: {
              pv: {
                type: "number",
                description: "Valor financiado",
                example: 100000,
              },
              rate: {
                type: "number",
                description: "Taxa de juros mensal (decimal)",
                example: 0.01,
              },
              n: {
                type: "integer",
                description: "Número de parcelas",
                example: 12,
              },
              iof: {
                type: "number",
                description: "IOF (opcional)",
                example: 150,
              },
              tac: {
                type: "number",
                description: "TAC (opcional)",
                example: 50,
              },
            },
          },
        },
      },
    },
  });

  await fastify.register(swaggerUi, {
    routePrefix: "/api-docs",
    uiConfig: {
      docExpansion: "list",
      deepLinking: true,
      defaultModelsExpandDepth: 3,
      defaultModelExpandDepth: 3,
    },
    staticCSP: true,
  });

  // Rotas
  await fastify.register(priceRoutes, { prefix: "/api" });
  await fastify.register(sacRoutes, { prefix: "/api" });
  await fastify.register(cetRoutes, { prefix: "/api" });
  await fastify.register(snapshotRoutes, { prefix: "/api" });
  await fastify.register(validatorRoutes, { prefix: "/api" });
  await fastify.register(reportsRoutes, { prefix: "/api" });
  await fastify.register(irrRoutes, { prefix: "/api" });
  await fastify.register(perfisRoutes, { prefix: "/api" });
  await fastify.register(comparadorRoutes, { prefix: "/api" });

  return fastify;
}
