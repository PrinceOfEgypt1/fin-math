import { FastifyRequest, FastifyReply } from "fastify";
import { SacRequestSchema } from "../schemas/sac.schema";
import { calculateSac } from "../services/sac.service";

export async function postSac(req: FastifyRequest, reply: FastifyReply) {
  const parsed = SacRequestSchema.safeParse(req.body);
  if (!parsed.success) {
    return reply
      .status(422)
      .send({
        errors: parsed.error.errors.map((e) => ({
          path: e.path,
          message: e.message,
        })),
      });
  }
  const result = await calculateSac(parsed.data);
  return reply.send(result);
}
