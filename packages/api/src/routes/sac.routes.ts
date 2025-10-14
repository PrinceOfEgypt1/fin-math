import { FastifyInstance } from "fastify";
import { postSac } from "../controllers/sac.controller";

export async function sacRoutes(app: FastifyInstance) {
  app.post("/api/sac", postSac);
}
