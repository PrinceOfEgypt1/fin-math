import { randomUUID } from "node:crypto";
import { createHash } from "node:crypto";

export function generateCalculationId(): string {
  return randomUUID();
}

export function generateHash(data: string): string {
  return createHash("sha256").update(data).digest("hex");
}

export function formatTimestamp(date: Date = new Date()): string {
  return date.toISOString();
}
