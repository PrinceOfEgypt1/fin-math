// packages/api/src/routes/validator.routes.ts
import { FastifyInstance } from "fastify";
import { postValidateSchedule } from "../controllers/validator.controller";

/**
 * Registra rotas de validação
 */
export async function validatorRoutes(fastify: FastifyInstance) {
  fastify.post("/validate/schedule", postValidateSchedule);
}
