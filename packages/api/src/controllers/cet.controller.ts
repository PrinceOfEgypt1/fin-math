import { FastifyRequest, FastifyReply } from "fastify";
import { CETBasicRequestSchema } from "../schemas/cet.schema";
import { cetService } from "../services/cet.service";

export async function postCETBasic(req: FastifyRequest, reply: FastifyReply) {
  const parsed = CETBasicRequestSchema.safeParse(req.body);

  if (!parsed.success) {
    return reply.status(400).send({
      error: {
        code: "VALIDATION_ERROR",
        message: "Validation failed",
        details: parsed.error.errors.map((e) => ({
          path: e.path,
          message: e.message,
        })),
      },
    });
  }

  const result = cetService.calculateBasic(parsed.data);
  return reply.send(result);
}
