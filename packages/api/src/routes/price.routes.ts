import { FastifyInstance } from "fastify";
import { postPrice } from "../controllers/price.controller";

export async function priceRoutes(app: FastifyInstance) {
  app.post("/price", postPrice); // ✅ Sem /api (já vem do prefix)
}
