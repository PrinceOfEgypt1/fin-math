# Plano (dry-run)

- scope: changed
- enforce: 0

## Checks mapeados

- lint: npm run -w engine lint && npm run -w api lint && npm run -w ui lint
- typecheck: npm run -w engine typecheck && npm run -w api typecheck && npm run -w ui typecheck
- unit: npm run -w engine test
- property: npm run -w engine test:property
- integration: npm run -w api test:integration
- golden: npm run -w engine test:golden
- build: npm run -w engine build && npm run -w api build && npm run -w ui build
- e2e: npm run -w ui test:e2e
- openapi: node .fenix/checks/validators/openapi_check.cjs
