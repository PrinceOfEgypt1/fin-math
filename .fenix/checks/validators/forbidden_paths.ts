#!/usr/bin/env -S node --loader ts-node/esm
/**
 * Reprova se paths proibidos foram alterados. Recebe lista via stdin (um arquivo por linha).
 */
import { readFileSync } from "node:fs";

const forbidden = [/^(?:\.github\/|infra\/|scripts\/)/];

const changed = readFileSync(0, "utf8").split("\n").filter(Boolean);
const hit = changed.filter((f) => forbidden.some((rx) => rx.test(f)));

if (hit.length) {
  console.error(
    "❌ Paths proibidos alterados:\n" + hit.map((x) => " - " + x).join("\n"),
  );
  process.exit(1);
}
console.log("✅ Forbidden paths: ok");
