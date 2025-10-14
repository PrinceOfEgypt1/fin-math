import { FastifyRequest, FastifyReply } from "fastify";
import { PriceRequestSchema } from "../schemas/price.schema";
import { calculatePrice } from "../services/price.service";

export async function postPrice(req: FastifyRequest, reply: FastifyReply) {
  const parsed = PriceRequestSchema.safeParse(req.body);
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
  const result = await calculatePrice(parsed.data);
  return reply.send(result);
}
