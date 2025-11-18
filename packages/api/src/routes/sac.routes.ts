// packages/api/src/routes/sac.routes.ts
import { FastifyInstance } from "fastify";
import { postSac } from "../controllers/sac.controller";

export async function sacRoutes(fastify: FastifyInstance) {
  fastify.post("/sac", postSac);
}
