import type { FastifyRequest, FastifyReply } from "fastify";
import { cetService } from "../services/cet.service";
import type { CETBasicRequest } from "../schemas/cet.schema";

export class CETController {
  async calculateBasic(
    request: FastifyRequest<{ Body: CETBasicRequest }>,
    reply: FastifyReply,
  ) {
    try {
      const result = cetService.calculateBasic(request.body);
      return reply.status(200).send(result);
    } catch (error) {
      request.log.error(error, "Erro ao calcular CET básico");
      return reply.status(500).send({
        error: "Internal Server Error",
        message: error instanceof Error ? error.message : "Erro desconhecido",
      });
    }
  }
}

export const cetController = new CETController();
