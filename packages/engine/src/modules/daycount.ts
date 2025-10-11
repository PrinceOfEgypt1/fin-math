export type DayCount = "30360" | "ACT365";
export function prorataFactor(date0: Date, date1: Date, dc: DayCount) {
  const ms = date1.getTime() - date0.getTime();
  const days = Math.max(0, Math.round(ms / 86400000));
  return dc === "30360" ? Math.min(30, days) / 30 : days / 365;
}
