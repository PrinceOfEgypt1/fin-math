import type { FastifyInstance } from "fastify";
import { priceController } from "../presentation/controllers/price.controller";
export async function priceRoutes(app: FastifyInstance) {
  app.post(
    "/api/price",
    { schema: { description: "Calcula Price", tags: ["Amortização"] } },
    priceController,
  );
}
