// packages/api/src/routes/cet.routes.ts
import { FastifyInstance } from "fastify";
import { postCetBasic } from "../controllers/cet.controller";

export async function cetRoutes(fastify: FastifyInstance) {
  fastify.post("/cet/basic", postCetBasic);
}
