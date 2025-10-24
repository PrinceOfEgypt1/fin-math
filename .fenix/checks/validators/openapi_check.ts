#!/usr/bin/env -S node --loader ts-node/esm
/**
 * Verificador simples do OpenAPI: garante que o arquivo existe e tem "openapi:".
 * Ajuste o caminho conforme seu projeto (ex.: openapi-3.1_finmath-v1.0.yaml.yaml).
 */
import { readFileSync } from "node:fs";

const PATHS = [
  "openapi-3.1_finmath-v1.0.yaml.yaml",
  "api/openapi.yaml",
  "api/openapi.yml",
];

let found = false;
for (const p of PATHS) {
  try {
    const txt = readFileSync(p, "utf8");
    if (/^openapi:\s*3\./m.test(txt)) {
      console.log(`✅ OpenAPI OK em: ${p}`);
      found = true;
      break;
    }
  } catch {}
}

if (!found) {
  console.error(
    "❌ OpenAPI não encontrado ou inválido. Ajuste PATHS no validador.",
  );
  process.exit(1);
}
