import { FastifyInstance } from "fastify";
import { postPrice } from "../controllers/price.controller";

export async function priceRoutes(app: FastifyInstance) {
  app.post("/api/price", postPrice);
}
