import { FastifyInstance } from "fastify";
import { postCETBasic } from "../controllers/cet.controller";

export async function cetRoutes(app: FastifyInstance) {
  app.post("/cet/basic", postCETBasic);
}
