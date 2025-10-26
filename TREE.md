.
├── .editorconfig
├── .fenix
│   ├── 03*fenix_ci_patch.sh
│   ├── 04_fenix_local_tests.sh
│   ├── 05_fenix_status.sh
│   ├── README.md
│   ├── adapters
│   │   ├── github
│   │   │   └── pr_template.md
│   │   └── logging
│   │   └── schema.json
│   ├── artifacts
│   │   ├── .gitkeep
│   │   ├── branch-protection.backup.main.json
│   │   ├── kpis.daily.json
│   │   ├── kpis.local.json
│   │   ├── plan.daily.md
│   │   ├── plan.local.md
│   │   ├── sanitize_after_20251026-135826.txt
│   │   └── sanitize_before_20251026-135826.txt
│   ├── checks
│   │   ├── fenix-checks.config.json
│   │   ├── reports
│   │   │   └── .gitkeep
│   │   └── validators
│   │   ├── forbidden_paths.cjs
│   │   ├── forbidden_paths.ts
│   │   ├── golden_guard.cjs
│   │   ├── golden_guard.ts
│   │   ├── openapi_check.cjs
│   │   ├── openapi_check.ts
│   │   ├── precision_scorer.cjs
│   │   └── precision_scorer.ts
│   ├── limits.yaml
│   ├── playbooks
│   │   ├── durante-sprint.yml
│   │   ├── finalizar-sprint.yml
│   │   └── inicio-sprint.yml
│   ├── policy
│   │   ├── finmath.policy.v2.yaml
│   │   └── rulesets
│   │   └── forbidden-paths.yaml
│   ├── prompts
│   │   └── system.md
│   ├── rag
│   │   ├── cache
│   │   │   └── finmath-docs-md
│   │   ├── collections.yaml
│   │   └── sources
│   │   ├── backlog-hu.sot.json
│   │   ├── finmath-docs-md.sot.json
│   │   ├── finmath-docs.sot.json
│   │   ├── guia-cet.sot.json
│   │   └── regras-criticas.sot.json
│   └── scripts
│   ├── fenix-dry-run.sh
│   └── fenix-report.sh
├── .github
│   ├── CODEOWNERS
│   └── workflows
│   ├── ci.yml
│   ├── fenix-ci-ext.yml
│   └── fenix-guard.yml
├── .gitignore
├── .husky
│   ├── *
│   │   ├── .gitignore
│   │   ├── applypatch-msg
│   │   ├── commit-msg
│   │   ├── h
│   │   ├── husky.sh
│   │   ├── post-applypatch
│   │   ├── post-checkout
│   │   ├── post-commit
│   │   ├── post-merge
│   │   ├── post-rewrite
│   │   ├── pre-applypatch
│   │   ├── pre-auto-gc
│   │   ├── pre-commit
│   │   ├── pre-merge-commit
│   │   ├── pre-push
│   │   ├── pre-rebase
│   │   └── prepare-commit-msg
│   └── pre-commit
├── .npmrc
├── .scripts-backup
│   ├── 01_inicio_sprint4.sh
│   ├── 02_h15_npv_implementation.sh
│   ├── 03_h15_irr_brent_solver.sh
│   ├── 04_h15_fix_brent_test.sh
│   ├── 05_h15_fix_exports.sh
│   ├── 06_h15_recreate_brent.sh
│   ├── 07_h15_fix_final_tests.sh
│   ├── 08_h15_fix_irr_final.sh
│   ├── 09_h15_fix_irr_algorithm.sh
│   ├── 10_h15_brent_correto_final.sh
│   ├── 11_fix_typescript_strict.sh
│   ├── 12_validacao_completa_h15.sh
│   └── 13_limpeza_repositorio.sh
├── 00_executar_sprint3.sh
├── 00_validacao_completa.sh
├── 01_bootstrap_fenix.sh
├── 01_limpar_ambiente.sh
├── 02_corrigir_branch.sh
├── 02_seed_fenix_files.sh
├── 03_adicionar_rotas_server.sh
├── 04_validar_antes_commit.sh
├── 06_fenix_patch_forbidden_guard_v2.sh
├── 07_fenix_infra_pr_local_test.sh
├── 08_fenix_mark_pr_infra.sh
├── 09_fenix_combo_infra.sh
├── 10_fenix_open_and_label_pr.sh
├── 11_fenix_branch_protection_main.sh
├── 12_fenix_watch_ci.sh
├── 13_fenix_merge_current_pr.sh
├── 14_fenix_pr_approve_and_merge.sh
├── 15_fenix_enable_repo_auto_merge.sh
├── 16_fenix_show_branch_protection.sh
├── 18_relax_protection_for_bootstrap.sh
├── 19_merge_or_auto_current_pr.sh
├── 21_git_safe_checkout_main.sh
├── 23_watch_auto_merge.sh
├── 24_watch_pr_by_number.sh
├── 25_finalize_after_merge.sh
├── 26_unstash_last.sh
├── 27_inspect_pr_blockers.sh
├── 28_enable_dispatch_and_trigger_fenix_ci.sh
├── 28_temp_require_only_guard.sh
├── 29_resolve_stash_conflicts_keep_main.sh
├── 31_checkout_pr_branch_clean.sh
├── 32_trigger_fenix_ext_on_branch.sh
├── 33_reduce_checks_wait_merge_restore.sh
├── 34_remove_embedded_repo.sh
├── 35_fenix_automerge_now.sh
├── 38_fenix_ci_green_bootstrap.sh
├── 39_fenix_smoke.sh
├── 40_fenix_assert_install.sh
├── 41_merge_now_or_diagnose.sh
├── 44_debug_merge_blockers.sh
├── 45_guard_dispatch_and_merge.sh
├── 46_guard_merge_compat.sh
├── 47_force_merge_with_protection_roundtrip.sh
├── 48_sync_main_via_pr.sh
├── 50_stop_tracking_artifacts_via_pr.sh
├── 51_show_divergence.sh
├── 51_wait_and_merge_37.sh
├── 52_main_reset_to_remote.sh
├── 54_post_sync_housekeeping.sh
├── 56_verify_fenix_local.sh
├── 57_finish_gitignore_pr_and_sync.sh
├── 57_push_gitignore_via_pr.sh
├── 60_ingest_docs_to_rag.sh
├── 61_enable_policies_and_checks.sh
├── 61_verify_policy_patch.sh
├── 62_patch_system_playbooks.sh
├── 63_fenix_smoke_local.sh
├── 64_commit_pr_playbooks.sh
├── 66_finish_pr41_and_cleanup.sh
├── 70_wire_docs_to_fenix.sh
├── 71_push_rag_docs_via_pr.sh
├── 72_extract_docx_to_md.sh
├── 96_desfazer_merge_local.sh
├── 97_push_via_pr_sprint3.sh
├── 98_finalizar_push_sprint3.sh
├── 99_validacao_final_corrigida.sh
├── 99_validacao_final_sprint3.sh
├── ANALISE-E-PROXIMOS-PASSOS-20251025-012327.md
├── ANALISE-E-PROXIMOS-PASSOS-20251025-013416.md
├── ANALISE-PROGRESSO-20251025-014527.md
├── CHANGELOG.md
├── CHANGELOG.md.old
├── CHECKLIST_FINAL_SPRINT3.md
├── LICENSE
├── README.md
├── README.md.old
├── SPRINT3_RESUMO_EXECUTIVO.md
├── TREE.md
├── UPDATE-SPRINTS.sh
├── VALIDATION-REPORT-FINAL.md
├── \_snapshot_reports
│   ├── dirs.all.txt
│   ├── ext.count.txt
│   ├── files.csv.txt
│   ├── files.json.txt
│   ├── files.pdf.txt
│   ├── lines_per_file.tsv
│   ├── paths.all.txt
│   ├── sha256.txt
│   ├── todos.sample.txt
│   ├── tree.txt
│   └── wc.txt
├── analise-finmath-v2.sh
├── analise-progresso-finmath.sh
├── api
│   └── openapi.yaml
├── apply_finmath_patches_v4.sh
├── apps
│   └── demo
│   └── index.html
├── audit-hu24.sh
├── audit-project-complete.sh
├── configurar-status-field-v2.sh
├── configurar-status-field-v3.sh
├── configurar-status-field.sh
├── converter-para-board.sh
├── copiar_arquivos.sh
├── criar-board-view.sh
├── criar-project-board.sh
├── diagnose-lint.sh
├── docs
│   ├── ARCHITECTURE.md
│   ├── CONTRIBUTING.md
│   ├── PROJECT-BOARD.md
│   ├── README.md
│   ├── SPRINT4B-SUMMARY.md
│   ├── SPRINTS_AND_HUS.md
│   ├── TESTING.md
│   ├── adr
│   │   ├── ADR-001-decimal-js.md
│   │   └── README.md
│   ├── api
│   │   ├── .nojekyll
│   │   ├── assets
│   │   │   ├── hierarchy.js
│   │   │   ├── highlight.css
│   │   │   ├── icons.js
│   │   │   ├── icons.svg
│   │   │   ├── main.js
│   │   │   ├── navigation.js
│   │   │   ├── search.js
│   │   │   └── style.css
│   │   ├── functions
│   │   │   ├── calculatePMT.html
│   │   │   ├── calculateProRataInterest.html
│   │   │   ├── cetBasic.html
│   │   │   ├── d.html
│   │   │   ├── daysBetween.html
│   │   │   ├── generatePriceSchedule.html
│   │   │   ├── generateSacSchedule.html
│   │   │   ├── round2.html
│   │   │   └── yearFraction.html
│   │   ├── hierarchy.html
│   │   ├── index.html
│   │   ├── interfaces
│   │   │   ├── PriceInput.html
│   │   │   ├── PriceResult.html
│   │   │   ├── PriceScheduleRow.html
│   │   │   ├── ProRataInput.html
│   │   │   ├── ProRataResult.html
│   │   │   ├── SacInput.html
│   │   │   ├── SacResult.html
│   │   │   └── SacScheduleRow.html
│   │   ├── types
│   │   │   └── DayCountConvention.html
│   │   └── variables
│   │   ├── ENGINE_VERSION.html
│   │   ├── amortization.html
│   │   ├── cet.html
│   │   ├── interest.html
│   │   ├── irr.html
│   │   ├── rate.html
│   │   └── series.html
│   ├── archive
│   │   ├── 2025-10-17-sprint2-docs-detalhados
│   │   │   ├── ARQUITETURA.md
│   │   │   ├── EXEMPLOS_API.md
│   │   │   ├── README.md
│   │   │   └── RESUMO_EXECUTIVO.md
│   │   ├── 2025-10-17-sprint2-historico
│   │   │   └── README.md
│   │   ├── 2025-10-17-sprint3-completed
│   │   │   ├── DEPENDENCIAS-E-REPLANEJAMENTO.md
│   │   │   └── README.md
│   │   └── CHECKLIST-ONDA.md
│   ├── cet-sot
│   │   └── evidences
│   │   └── v1
│   ├── h15-irr-tir-com-brent.md
│   ├── historias-usuario
│   │   ├── COMO-USAR-TEMPLATE.md
│   │   ├── HU-24-comparacao-price-sac.md
│   │   ├── HU-25-simulador-cet-completo.md
│   │   ├── HU-template.md
│   │   ├── README.md
│   │   ├── create-hu.sh
│   │   └── screenshots
│   │   └── README.md
│   ├── issues
│   │   ├── ISSUE-001-testes-unitarios-comparison.md
│   │   ├── ISSUE-002-acessibilidade-comparison.md
│   │   └── README.md
│   ├── source-docs
│   │   ├── CATALOGO_24HUs_ULTRA_DETALHADO_FINAL.docx
│   │   ├── CATALOGO_24HUs_ULTRA_DETALHADO_FINAL.docx:Zone.Identifier
│   │   ├── Como Descrever uma Sprint v2.0.docx
│   │   ├── FINMATH - GUIA RÁPIDO (CHEAT SHEET).docx
│   │   ├── REGRAS_CRITICAS_FINMATH_24_SPRINTS_COMPLETO.docx
│   │   ├── REGRAS_CRITICAS_FINMATH_24_SPRINTS_COMPLETO.docx:Zone.Identifier
│   │   ├── REGRAS_CRITICAS_FINMATH_v2_0_COMPLETO.docx
│   │   ├── REGRAS_CRITICAS_FINMATH_v2_0_COMPLETO.docx:Zone.Identifier
│   │   ├── Readme Workflow.docx
│   │   └── WORKFLOW COMPLETO E REGRAS CRÍTICAS v1.1.docx
│   ├── sprint-planning
│   │   ├── sprint-retrospective.md
│   │   └── sprint5-checklist.md
│   ├── sprint2
│   │   └── validate-docs.sh
│   └── troubleshooting-guide.md
├── eslint.config.js
├── export_debug.sh
├── fin-math
├── fin-math.sh
├── fix-eslint-config.sh
├── fix-package-name.sh
├── fix-validation-routes.sh
├── fix-workspace.sh
├── fix_single_file.sh
├── fix_typescript_errors.sh
├── install_dependencies.sh
├── package.json
├── packages
│   ├── api
│   │   ├── .gitignore
│   │   ├── README.md
│   │   ├── eslint.config.cjs
│   │   ├── package.json
│   │   ├── src
│   │   │   ├── controllers
│   │   │   ├── index.ts
│   │   │   ├── infrastructure
│   │   │   ├── routes
│   │   │   ├── schemas
│   │   │   ├── server.ts
│   │   │   ├── services
│   │   │   ├── utils
│   │   │   └── validation
│   │   ├── test
│   │   │   └── integration
│   │   ├── tsconfig.json
│   │   └── vitest.config.ts
│   ├── engine
│   │   ├── .eslintrc.json
│   │   ├── .npmignore
│   │   ├── README.md
│   │   ├── examples
│   │   │   ├── 01-price-basico.ts
│   │   │   ├── 02-cet-completo.ts
│   │   │   ├── 03-irr-investimento.ts
│   │   │   └── README.md
│   │   ├── finmath-engine-0.4.1.tgz
│   │   ├── golden
│   │   │   └── starter
│   │   ├── package.json
│   │   ├── profiles
│   │   │   ├── banco_a@2025-01.json
│   │   │   └── banco_b@2025-02.json
│   │   ├── src
│   │   │   ├── amortization
│   │   │   ├── cet
│   │   │   ├── day-count
│   │   │   ├── index.ts
│   │   │   ├── irr
│   │   │   ├── modules
│   │   │   ├── smoke.test.ts
│   │   │   └── util
│   │   ├── test
│   │   │   ├── golden
│   │   │   ├── golden.spec.ts
│   │   │   ├── property
│   │   │   ├── smoke.spec.ts
│   │   │   └── unit
│   │   ├── tsc
│   │   ├── tsconfig.json
│   │   └── typedoc.json
│   └── ui
│   ├── .vscode
│   │   └── settings.json
│   ├── create-components.sh
│   ├── fix-errors.sh
│   ├── index.html
│   ├── package.json
│   ├── pnpm-lock.yaml
│   ├── postcss.config.js
│   ├── public
│   │   └── calculator.svg
│   ├── setup-parte1.sh
│   ├── setup-parte2.sh
│   ├── setup-parte3.sh
│   ├── src
│   │   ├── App.tsx
│   │   ├── components
│   │   ├── lib
│   │   ├── main.tsx
│   │   ├── pages
│   │   ├── screens
│   │   ├── styles
│   │   ├── styles.css
│   │   └── types
│   ├── tailwind.config.js
│   ├── test
│   │   └── e2e
│   ├── tsconfig.json
│   ├── tsconfig.node.json
│   └── vite.config.ts
├── plano-desenvolvimento-sprint3-v2.sh
├── plano-sprint3-20251025-024610
│   ├── README.md
│   ├── docs
│   │   └── PLANO-SPRINT-3.md
│   ├── golden-files
│   ├── scripts
│   │   ├── 01-inicio-sprint3.sh
│   │   ├── 02-implementar-h15-irr-brent.sh
│   │   ├── 03-implementar-h16-seguros-cet.sh
│   │   ├── 04-implementar-h17-perfis-cet.sh
│   │   ├── 05-implementar-h18-comparador.sh
│   │   ├── 06-implementar-h19-export-xlsx.sh
│   │   └── 99-validacao-final-sprint3.sh
│   └── tests
├── plano-sprint3-20251025-025322
│   ├── README.md
│   ├── docs
│   │   └── PLANO-SPRINT-3.md
│   ├── golden-files
│   ├── scripts
│   │   ├── 01-inicio-sprint3.sh
│   │   ├── 02-implementar-h15-irr-brent.sh
│   │   ├── 03-implementar-h16-seguros-cet.sh
│   │   ├── 04-implementar-h17-perfis-cet.sh
│   │   ├── 05-implementar-h18-comparador.sh
│   │   ├── 06-implementar-h19-export-xlsx.sh
│   │   └── 99-validacao-final-sprint3.sh
│   └── tests
├── pnpm-lock.yaml
├── pnpm-workspace.yaml
├── price_output.pdf
├── rollback_finmath_patches.sh
├── sac_output.csv
├── sac_output.pdf
├── sac_output_v2.csv
├── scripts
│   ├── 95_pos_merge_github.sh
│   └── sprint2-dev
│   ├── corrigir-cet-completo.sh
│   ├── corrigir-cet-export.sh
│   ├── corrigir-cet-routes.sh
│   ├── corrigir-erros-build.sh
│   ├── corrigir-swagger-schemas.sh
│   ├── criar-arquivos-faltantes.sh
│   ├── criar-codigo-h21-h22.sh
│   ├── executar-sprint2-completo-v2.sh
│   ├── finalizar-sprint-2.sh
│   ├── fix-validator-service.sh
│   ├── implementar-h12-cet-api.sh
│   ├── implementar-h21-h22.sh
│   ├── investigar-estado-atual.sh
│   ├── modificar-controllers.sh
│   ├── reset-e-corrigir-tudo.sh
│   ├── testar-h21-h22.sh
│   ├── teste-completo-sprint2-v2.sh
│   ├── teste-completo-sprint2.sh
│   ├── validar-antes-commit.sh
│   ├── verificar-cet-api.sh
│   └── verificar-pre-requisitos.sh
├── snapshot-amostra.txt
├── snapshot_00.part
├── snapshot_01.part
├── snapshot_02.part
├── snapshot_03.part
├── snapshot_04.part
├── snapshot_05.part
├── snapshot_06.part
├── teste-geral-completo-v2.sh
├── teste-geral-completo.sh
├── teste-geral-final-v2.sh
├── teste-geral-final.sh
├── tools
│   ├── board-management
│   │   ├── .finmath_duplicates_20251015_200124.txt
│   │   ├── .finmath_issues_map.txt
│   │   ├── .finmath_project.env
│   │   ├── BOARD.md
│   │   ├── RELATORIO-SPRINT-1.md
│   │   ├── RELATORIO-SPRINT-2.md
│   │   ├── close-sprint2-issues.sh
│   │   ├── close_duplicates.sh
│   │   ├── create_issues_and_populate_project.sh
│   │   ├── debug_full_output.txt
│   │   ├── demo-gestor.sh
│   │   ├── diagnose_field_configuration.sh
│   │   ├── diagnose_schema.sh
│   │   ├── diagnostic_results.txt
│   │   ├── final_test.txt
│   │   ├── finmath_duplicates.txt
│   │   ├── fix-h12-status.sh
│   │   ├── fix_project_create_v2.sh
│   │   ├── fix_project_statuses.sh
│   │   ├── fix_project_statuses_FINAL.sh
│   │   ├── fix_project_statuses_FINAL_V2.sh
│   │   ├── fix_project_statuses_TMPFILE.sh
│   │   ├── fix_project_statuses_WORKING.sh
│   │   ├── get_item_id.sh
│   │   ├── inicio-sprint-2-fix.sh
│   │   ├── inicio-sprint-2.sh
│   │   ├── populate_board.sh
│   │   ├── populate_project_with_issues.sh
│   │   ├── remove_from_board.sh
│   │   ├── setup-phase-1-1.sh
│   │   ├── setup_finmath_project.sh
│   │   ├── sync_project_status.sh
│   │   ├── test_fix.sh
│   │   ├── test_lines_290-300.sh
│   │   ├── test_while_loop.sh
│   │   └── teste-completo.sh
│   └── scripts
│   ├── analyze-daycount.sh
│   ├── close-sprint3-issues.sh
│   ├── inspect_price.js
│   ├── patch_price_gf.js
│   └── seed_artifacts.sh
├── tsconfig.base.json
├── validate-sprint4.sh
├── validate_errors.sh
└── verify_out.log

104 directories, 421 files
