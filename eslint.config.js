export default [
  {
    files: ["packages/**/*.ts", "packages/**/*.tsx", "apps/**/*.ts"],
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/coverage/**",
      "**/*.config.js",
      "**/*.config.ts",
    ],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      parser: await import("@typescript-eslint/parser").then((m) => m.default),
    },
    plugins: {
      "@typescript-eslint": await import(
        "@typescript-eslint/eslint-plugin"
      ).then((m) => m.default),
    },
    rules: {
      "no-console": "off",
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/no-unused-vars": [
        "warn",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
        },
      ],
    },
  },
];
