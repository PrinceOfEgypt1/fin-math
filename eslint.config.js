import js from "@eslint/js";
import tseslint from "typescript-eslint";
import love from "eslint-config-love";
export default [
  ...love,
  js.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  {
    files: ["**/*.{ts,tsx}"],
    languageOptions: {
      parserOptions: { project: ["./tsconfig.json"] },
    },
    rules: {
      // suas regras aqui (opcional)
    },
  },
];
