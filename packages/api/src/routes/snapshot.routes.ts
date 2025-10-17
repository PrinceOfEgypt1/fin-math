// packages/api/src/routes/snapshot.routes.ts
import { FastifyInstance } from "fastify";
import { getSnapshot } from "../controllers/snapshot.controller";

/**
 * Registra rotas de snapshots
 */
export async function snapshotRoutes(fastify: FastifyInstance) {
  fastify.get("/snapshot/:id", getSnapshot);
}
