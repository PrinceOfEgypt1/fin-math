// packages/api/src/routes/perfis.routes.ts
import type { FastifyInstance, FastifyPluginOptions } from "fastify";
import { listarPerfis, buscarPerfil } from "../services/perfis.service";

export async function perfisRoutes(
  app: FastifyInstance,
  _opts: FastifyPluginOptions,
) {
  app.get("/perfis", async (_req, reply) => {
    try {
      const perfis = await listarPerfis();
      return reply.send({
        success: true,
        version: "2025-01",
        data: perfis.map((p) => ({
          id: p.id,
          instituicao: p.instituicao,
          vigencia: p.vigencia,
        })),
      });
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      return reply.status(500).send({ success: false, error: message });
    }
  });

  app.get("/perfis/:id", async (req, reply) => {
    try {
      const id = (req.params as { id?: string })?.id;
      if (!id) {
        return reply
          .status(400)
          .send({ success: false, error: "Parâmetro id ausente" });
      }
      const perfil = await buscarPerfil(id);
      if (!perfil) {
        return reply
          .status(404)
          .send({ success: false, error: "Perfil não encontrado" });
      }
      return reply.send({ success: true, data: perfil });
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      return reply.status(500).send({ success: false, error: message });
    }
  });
}

export default perfisRoutes;
