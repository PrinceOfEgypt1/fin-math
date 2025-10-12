import type { FastifyRequest, FastifyReply } from "fastify";
import { ZodError } from "zod";
import { PriceService } from "../../application/services/price.service";
import { PriceRequestSchema } from "../validators/price.schema";
import { logger } from "../../infrastructure/logger";

export async function priceController(
  req: FastifyRequest,
  reply: FastifyReply,
) {
  try {
    const validated = PriceRequestSchema.parse(req.body);
    const service = new PriceService();
    const result = await service.calculate(validated);
    reply.status(200).send(result);
  } catch (error) {
    if (error instanceof ZodError) {
      logger.warn({ errors: error.errors }, "Validação falhou");
      reply
        .status(400)
        .send({
          error: {
            code: "VALIDATION_ERROR",
            message: "Parâmetros inválidos",
            details: error.errors.map((e) => ({
              field: e.path.join("."),
              message: e.message,
            })),
          },
        });
      return;
    }
    logger.error({ error: (error as Error).message }, "Erro no controller");
    reply
      .status(500)
      .send({
        error: { code: "INTERNAL_ERROR", message: "Erro ao calcular Price" },
      });
  }
}
