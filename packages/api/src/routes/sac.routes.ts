import { FastifyInstance } from "fastify";
import { postSac } from "../controllers/sac.controller";

export async function sacRoutes(app: FastifyInstance) {
  app.post("/sac", postSac); // ✅ Sem /api
}
