export function recordCalculationDuration(kind: string, ms: number) {
  console.log(`[METRIC] ${kind}_duration_ms: ${ms}`);
  if (ms > 150) console.warn(`[SLO_BREACH] ${kind} ${ms}ms`);
}
export function recordCalculationResult(kind: string, ok: boolean) {
  console.log(
    `[METRIC] ${kind}_total{status="${ok ? "success" : "error"}"}: 1`,
  );
}
