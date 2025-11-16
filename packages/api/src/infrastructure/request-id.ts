import { FastifyPluginAsync } from "fastify";

export const requestIdPlugin: FastifyPluginAsync = async (fastify) => {
  fastify.addHook("onRequest", async (request) => {
    request.log.info({ requestId: request.id }, "Request received");
  });
};
