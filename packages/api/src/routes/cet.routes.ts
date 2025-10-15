import type { FastifyInstance } from "fastify";
import { cetController } from "../controllers/cet.controller";
import { CETBasicRequestSchema } from "../schemas/cet.schema";

export async function cetRoutes(app: FastifyInstance) {
  app.post(
    "/cet/basic",
    {
      schema: {
        description: "Calcula CET Básico (tarifas t=0)",
        tags: ["CET"],
        body: CETBasicRequestSchema,
      },
    },
    cetController.calculateBasic.bind(cetController),
  );
}
