import pino from "pino";

export const MOTOR_VERSION = "0.2.0";

const loggerConfig: pino.LoggerOptions = {
  level: process.env.LOG_LEVEL || "info",
  formatters: {
    level: (label) => ({ level: label }),
    bindings: (bindings) => ({
      pid: bindings.pid,
      hostname: bindings.hostname,
      motorVersion: MOTOR_VERSION,
      environment: process.env.NODE_ENV || "development",
    }),
  },
  timestamp: pino.stdTimeFunctions.isoTime,
  transport:
    process.env.NODE_ENV === "development"
      ? {
          target: "pino-pretty",
          options: {
            colorize: true,
            translateTime: "HH:MM:ss",
            ignore: "pid,hostname",
          },
        }
      : undefined,
};

export const logger = pino(loggerConfig);

export function createChildLogger(context: Record<string, unknown>) {
  return logger.child(context);
}

export function logCalculationStart(
  calculationId: string,
  type: string,
  params: Record<string, unknown>,
) {
  logger.info(
    {
      calculationId,
      event: "calculation_started",
      type,
      params: sanitizeParams(params),
    },
    `Calculation ${type} started`,
  );
}

export function logCalculationComplete(
  calculationId: string,
  type: string,
  durationMs: number,
  result?: Record<string, unknown>,
) {
  logger.info(
    {
      calculationId,
      event: "calculation_completed",
      type,
      duration_ms: durationMs,
      result: result ? sanitizeResult(result) : undefined,
    },
    `Calculation ${type} completed in ${durationMs}ms`,
  );
}

export function logCalculationError(
  calculationId: string,
  type: string,
  durationMs: number,
  error: Error,
) {
  logger.error(
    {
      calculationId,
      event: "calculation_failed",
      type,
      duration_ms: durationMs,
      error: {
        message: error.message,
        stack: error.stack,
        name: error.name,
      },
    },
    `Calculation ${type} failed after ${durationMs}ms: ${error.message}`,
  );
}

function sanitizeParams(
  params: Record<string, unknown>,
): Record<string, unknown> {
  const sanitized: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(params)) {
    if (typeof value === "number" && key.toLowerCase().includes("pv")) {
      sanitized[key] = "[REDACTED]";
    } else if (
      typeof value === "number" ||
      typeof value === "string" ||
      typeof value === "boolean"
    ) {
      sanitized[key] = value;
    } else if (Array.isArray(value)) {
      sanitized[key] = `[Array(${value.length})]`;
    } else if (value && typeof value === "object") {
      sanitized[key] = "[Object]";
    } else {
      sanitized[key] = value;
    }
  }
  return sanitized;
}

function sanitizeResult(
  result: Record<string, unknown>,
): Record<string, unknown> {
  const sanitized: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(result)) {
    if (key === "schedule" || key === "steps") {
      sanitized[key] = Array.isArray(value)
        ? `[Array(${value.length})]`
        : "[Array]";
    } else if (
      typeof value === "string" ||
      typeof value === "number" ||
      typeof value === "boolean"
    ) {
      sanitized[key] = value;
    } else if (value && typeof value === "object") {
      sanitized[key] = "[Object]";
    } else {
      sanitized[key] = value;
    }
  }
  return sanitized;
}

export default logger;
