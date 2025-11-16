// packages/api/src/routes/comparador.routes.ts
import type { FastifyInstance, FastifyPluginOptions } from "fastify";
import { z } from "zod";
import { compararCenarios } from "../services/comparador.service";

export async function comparadorRoutes(
  app: FastifyInstance,
  _opts: FastifyPluginOptions,
) {
  app.post("/comparar", async (request, reply) => {
    const Schema = z.object({
      cenarios: z
        .array(
          z.object({
            id: z.string(),
            nome: z.string(),
            pv: z.number().positive(),
            i: z.number().positive(),
            n: z.number().int().positive(),
          }),
        )
        .min(2),
    });

    try {
      const { cenarios } = Schema.parse(request.body);
      const resultado = await compararCenarios(cenarios);
      return reply.send({ success: true, data: resultado });
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      return reply.status(400).send({ success: false, error: message });
    }
  });
}

export default comparadorRoutes;
