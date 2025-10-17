# 📚 Índice da Documentação - FinMath

**Owner:** @PrinceOfEgypt1  
**Última revisão:** 2025-10-17

Este diretório centraliza toda a documentação técnica e de gestão do projeto.

---

## 📋 Gestão de Projeto

| Documento                                  | Descrição                                                  |
| ------------------------------------------ | ---------------------------------------------------------- |
| [SPRINTS_AND_HUS.md](./SPRINTS_AND_HUS.md) | Sprints, HUs, status e dependências (fonte: Project Board) |
| [PROJECT-BOARD.md](./PROJECT-BOARD.md)     | Como usar o GitHub Project v2 (colunas, labels, workflow)  |

## 🏗️ Arquitetura & Desenvolvimento

| Documento                            | Descrição                                          |
| ------------------------------------ | -------------------------------------------------- |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Visão macro (monorepo, pacotes, decisões-chave)    |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Workflow Git, padrões de PR/commits, convenções    |
| [TESTING.md](./TESTING.md)           | Estratégia de testes (unit/integration/golden/e2e) |

## 📖 Decisões & Contratos

| Documento      | Descrição                                             |
| -------------- | ----------------------------------------------------- |
| [adr/](./adr/) | Architecture Decision Records (ADR-001, ADR-002, ...) |
| [api/](./api/) | Contratos de API (OpenAPI, endpoints, exemplos)       |

## 🆘 Troubleshooting

| Documento                                              | Descrição                                         |
| ------------------------------------------------------ | ------------------------------------------------- |
| [troubleshooting-guide.md](./troubleshooting-guide.md) | Problemas comuns e soluções (on-call, onboarding) |

## 🗄️ Arquivo

| Pasta                  | Descrição                                                |
| ---------------------- | -------------------------------------------------------- |
| [archive/](./archive/) | Documentos históricos (sprints passadas, docs obsoletos) |

---

## 📝 Boas Práticas

1. **Fonte de verdade:** Status de HUs vivem no Project Board
2. **Owners:** Todo doc tem `Owner: @username` no topo
3. **Última revisão:** Data de última atualização no topo
4. **Curto e versionado:** Docs longos/obsoletos vão para `archive/`
5. **ADRs disciplinados:** 1 decisão por ADR, <1 página

---

**Para editar esta documentação:** Ver [CONTRIBUTING.md](./CONTRIBUTING.md)
