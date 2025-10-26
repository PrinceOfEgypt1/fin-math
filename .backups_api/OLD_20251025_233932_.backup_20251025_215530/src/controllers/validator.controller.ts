// packages/api/src/controllers/validator.controller.ts
import { FastifyRequest, FastifyReply } from "fastify";
import { ValidateScheduleRequestSchema } from "../schemas/validator.schema";
import { validatorService } from "../services/validator.service";

/**
 * POST /api/validate/schedule
 */
export async function postValidateSchedule(
  request: FastifyRequest,
  reply: FastifyReply,
) {
  try {
    // Validar body com Zod
    const body = ValidateScheduleRequestSchema.parse(request.body);

    // Executar validação
    const result = validatorService.validate(body);

    // Retornar resultado
    return reply.status(200).send(result);
  } catch (error: unknown) {
    if (error instanceof Error) {
      return reply.status(400).send({
        error: "Validation error",
        message: error.message,
      });
    }
    throw error;
  }
}
