import { FastifyError, FastifyReply, FastifyRequest } from "fastify";

export class ValidationError extends Error {
  statusCode = 400;
  code = "VALIDATION_ERROR";

  constructor(
    message: string,
    public details?: unknown,
    public requestId?: string,
  ) {
    super(message);
    this.name = "ValidationError";
  }
}

export function errorHandler(
  error: FastifyError,
  request: FastifyRequest,
  reply: FastifyReply,
) {
  request.log.error({ err: error, requestId: request.id }, "Error occurred");

  if (error instanceof ValidationError) {
    return reply.status(error.statusCode).send({
      error: {
        code: error.code,
        message: error.message,
        details: error.details,
        requestId: error.requestId || request.id,
      },
    });
  }

  return reply.status(error.statusCode || 500).send({
    error: {
      code: error.code || "INTERNAL_SERVER_ERROR",
      message: error.message,
      requestId: request.id,
    },
  });
}
