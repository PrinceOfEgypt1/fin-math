// packages/api/src/routes/price.routes.ts
import { FastifyInstance } from "fastify";
import { postPrice } from "../controllers/price.controller";

export async function priceRoutes(fastify: FastifyInstance) {
  fastify.post("/price", postPrice);
}
