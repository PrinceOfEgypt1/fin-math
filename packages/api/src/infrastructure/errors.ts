import type { FastifyReply, FastifyRequest } from "fastify";
import { ZodError } from "zod";
import { logger } from "./logger.js";

export enum ErrorCode {
  INVALID_INPUT = "INVALID_INPUT",
  VALIDATION_ERROR = "VALIDATION_ERROR",
  MISSING_REQUIRED_FIELD = "MISSING_REQUIRED_FIELD",
  RESOURCE_NOT_FOUND = "RESOURCE_NOT_FOUND",
  ENDPOINT_NOT_FOUND = "ENDPOINT_NOT_FOUND",
  CALCULATION_ERROR = "CALCULATION_ERROR",
  INVALID_SCHEDULE = "INVALID_SCHEDULE",
  IRR_NO_CONVERGENCE = "IRR_NO_CONVERGENCE",
  IRR_NO_SIGN_CHANGE = "IRR_NO_SIGN_CHANGE",
  IRR_MULTIPLE_ROOTS = "IRR_MULTIPLE_ROOTS",
  INTERNAL_ERROR = "INTERNAL_ERROR",
  CALCULATION_FAILED = "CALCULATION_FAILED",
}

export interface ErrorDetail {
  field?: string;
  message: string;
  code?: string;
  value?: unknown;
}

export interface ErrorEnvelope {
  error: {
    code: string;
    message: string;
    details?: ErrorDetail[];
    correlationId?: string;
  };
}

export class AppError extends Error {
  constructor(
    public code: ErrorCode,
    message: string,
    public statusCode: number = 500,
    public details?: ErrorDetail[],
    public correlationId?: string,
  ) {
    super(message);
    this.name = "AppError";
    Error.captureStackTrace(this, this.constructor);
  }

  toEnvelope(): ErrorEnvelope {
    return {
      error: {
        code: this.code,
        message: this.message,
        details: this.details,
        correlationId: this.correlationId,
      },
    };
  }
}

export class ValidationError extends AppError {
  constructor(
    message: string,
    details?: ErrorDetail[],
    correlationId?: string,
  ) {
    super(ErrorCode.VALIDATION_ERROR, message, 400, details, correlationId);
    this.name = "ValidationError";
  }
}

export class NotFoundError extends AppError {
  constructor(message: string, correlationId?: string) {
    super(ErrorCode.RESOURCE_NOT_FOUND, message, 404, undefined, correlationId);
    this.name = "NotFoundError";
  }
}

export class CalculationError extends AppError {
  constructor(
    message: string,
    code: ErrorCode = ErrorCode.CALCULATION_ERROR,
    details?: ErrorDetail[],
    correlationId?: string,
  ) {
    super(code, message, 422, details, correlationId);
    this.name = "CalculationError";
  }
}

export function formatZodError(
  error: ZodError,
  correlationId?: string,
): ValidationError {
  const details: ErrorDetail[] = error.errors.map((err) => ({
    field: err.path.join("."),
    message: err.message,
    code: err.code,
    value: err.code !== "invalid_type" ? (err as any).input : undefined,
  }));
  return new ValidationError("Validation failed", details, correlationId);
}

export function errorHandler(
  error: Error & { statusCode?: number; validation?: any },
  request: FastifyRequest,
  reply: FastifyReply,
) {
  const correlationId = request.id;
  logger.error(
    { err: error, correlationId, url: request.url, method: request.method },
    "Request error",
  );

  // Handle Fastify validation errors (schema validation)
  if (error.validation) {
    const envelope: ErrorEnvelope = {
      error: {
        code: ErrorCode.VALIDATION_ERROR,
        message: error.message,
        correlationId,
      },
    };
    return reply.status(400).send(envelope);
  }

  // Handle Zod validation errors
  if (error instanceof ZodError) {
    const validationError = formatZodError(error, correlationId);
    return reply
      .status(validationError.statusCode)
      .send(validationError.toEnvelope());
  }

  // Handle custom AppError
  if (error instanceof AppError) {
    return reply.status(error.statusCode).send({
      ...error.toEnvelope(),
      error: { ...error.toEnvelope().error, correlationId },
    });
  }

  // Handle generic errors
  const envelope: ErrorEnvelope = {
    error: {
      code: ErrorCode.INTERNAL_ERROR,
      message:
        process.env.NODE_ENV === "production"
          ? "Internal server error"
          : error.message,
      correlationId,
    },
  };
  return reply.status(500).send(envelope);
}

export function createValidationError(
  field: string,
  message: string,
  correlationId?: string,
): ValidationError {
  return new ValidationError(
    "Validation failed",
    [{ field, message }],
    correlationId,
  );
}

export function createCalculationError(
  message: string,
  type: "price" | "sac" | "cet" | "irr",
  correlationId?: string,
): CalculationError {
  return new CalculationError(
    message,
    ErrorCode.CALCULATION_ERROR,
    [{ message, field: "calculation_type", value: type }],
    correlationId,
  );
}
