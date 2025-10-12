import type { FastifyInstance } from "fastify";
import { priceController } from "../presentation/controllers/price.controller";

export async function priceRoutes(app: FastifyInstance): Promise<void> {
  app.post("/api/price", priceController);
}
