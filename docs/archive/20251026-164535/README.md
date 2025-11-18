# Arquivo de Documentação/Script — Archive

Este diretório armazena **documentos e scripts legados** removidos na rotina de sanitização “ultra slim”.
Nada foi descartado sem registro: o histórico está aqui e no Git.

Critérios adotados:

- Manter somente: README.md, LICENSE, CHANGELOG.md, docs/README.md, docs/ARCHITECTURE.md, docs/TESTING.md, docs/CONTRIBUTING.md e api/openapi.yaml
- **Todos os .sh** fora de `.fenix/` e `.husky/` foram arquivados (ou deletados se a flag DELETE_SCRIPTS=1 foi usada)
- Toda documentação auxiliar (ADR, issues, sprints, DOCX, typedoc estático, etc.) veio para cá

Para recuperar algo, faça cherry-pick ou copie a partir deste diretório.
