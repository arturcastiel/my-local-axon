# PR List — AXON Bugfix 01
Updated: 2026-07-03  ·  Total PRs: 30  ·  Waves: A..H (dependency-ordered)

## PR-001 — Enforce destructive-git-op gating in the live write path
- **Status:** merged
- **Complexity:** M
- **Wave:** A
- **Findings:** S1
- **Scope:** tools/shell.py (gate_check), tools/hooks/enforce_pretooluse.py, tools/autonomous_mode.py, tests
- **Depends on:** none
- **Why:** `autonomous_mode.authorized()` has zero production callers; `git push --force` passes the hook today. Wire destructiveness classification + kernel-floor path check into the actual chokepoint.
- **Spec:** 03-prs/PR-001.md (not written yet)

## PR-002 — Consult the AEGIS test-execution policy in test_runner
- **Status:** merged
- **Complexity:** S
- **Wave:** A
- **Findings:** S1
- **Scope:** tools/test_runner.py, tools/aegis_policy.py, tests
- **Depends on:** none
- **Why:** The documented test-execution gate is coded but never consulted by the runner it governs.
- **Spec:** 03-prs/PR-002.md (not written yet)

## PR-003 — Fix synapse-suggest corpus and confidence math
- **Status:** merged
- **Complexity:** M
- **Wave:** A
- **Findings:** S2 (parts a, b)
- **Scope:** tools/synapse_suggest.py; call sites in orchestrator.md, workflow-new.md, workflow-run.md
- **Depends on:** none
- **Why:** Production call sites omit --candidates (ranks tools, not programs); ÷max normalization makes top confidence always exactly 1.0.
- **Spec:** 03-prs/PR-003.md (not written yet)

## PR-004 — Make the orchestrator fire step real; cover orchestrator.md in conformance lint
- **Status:** merged
- **Complexity:** S
- **Wave:** A
- **Findings:** S2 (part c)
- **Scope:** workspace/programs/orchestrator.md, tools/program_tool_conformance.py (glob scope), tests
- **Depends on:** PR-003
- **Why:** Fire step calls a nonexistent `dispatch match --top` flag and never EXECs; the lint built to catch this excludes orchestrator.md from its scope.
- **Spec:** 03-prs/PR-004.md (not written yet)

## PR-005 — Reconcile predicate vocabulary; fail loud on undefined predicates
- **Status:** merged
- **Complexity:** M
- **Wave:** B
- **Findings:** C1 (naming half)
- **Scope:** tools/predicate.py, workspace/domains/code-dev/workflows/*.yml, workspace/domains/library-dev/workflows/*.yml, workflow-run.md break path
- **Depends on:** none
- **Why:** All 4 flagship workflows die silently at their first gate — YAML predicate names don't exist in predicate.py's BUILTINS; undefined_function currently resolves to silent BREAK.
- **Spec:** 03-prs/PR-005.md (not written yet)

## PR-006 — Populate the predicate eval ctx with real state
- **Status:** merged
- **Complexity:** M
- **Wave:** B
- **Findings:** C1 (ctx half), multiple-code-dev gate
- **Scope:** workspace/programs/workflow-run.md, tools/predicate.py ctx contract, tests
- **Depends on:** PR-005
- **Why:** Even with correct names, gates evaluate against `{"state":{...}}` only — review/tests/build/audit/goal/W keys never exist; comparisons silently resolve false.
- **Spec:** 03-prs/PR-006.md (not written yet)

## PR-007 — Wire check-stale + check-templating into workflow validate; teach tool-vs-program detection
- **Status:** merged
- **Complexity:** S
- **Wave:** B
- **Findings:** H5
- **Scope:** workspace/programs/workflow-validate.md, workflow lint tools, tests
- **Depends on:** none
- **Why:** The two lints purpose-built to catch the C1/C4/C8 class exist, are tested, and are never invoked.
- **Spec:** 03-prs/PR-007.md (not written yet)

## PR-008 — Repair adaptive-free-text.yml
- **Status:** merged
- **Complexity:** S
- **Wave:** B
- **Findings:** C4
- **Scope:** workspace/domains/*/workflows/adaptive-free-text.yml
- **Depends on:** PR-003, PR-004, PR-007
- **Why:** First node dispatches a program that doesn't exist (synapse-suggest is a tool); s2 hardcodes code-dev-flow, defeating dynamic dispatch.
- **Spec:** 03-prs/PR-008.md (not written yet)

## PR-009 — Rewrite library-dev.canonical.yml against library-dev's real programs
- **Status:** merged
- **Complexity:** M
- **Wave:** B
- **Findings:** C8
- **Scope:** workspace/domains/library-dev/workflows/library-dev.canonical.yml, _index.md
- **Depends on:** PR-005, PR-006, PR-007
- **Why:** Verbatim code-dev copy — none of library-dev's 8 programs referenced; can silently run a code-PR pipeline under the library-dev label.
- **Spec:** 03-prs/PR-009.md (not written yet)

## PR-010 — Differentiate fixed/adaptive modes; descope hybrid via ADR
- **Status:** merged
- **Complexity:** S
- **Wave:** B
- **Findings:** H4
- **Scope:** workspace/programs/workflow-run.md, 03-decisions/ ADR
- **Depends on:** PR-006
- **Why:** All modes currently walk on-complete rules identically; adaptive ranking is printed and discarded; hybrid has zero implementing logic (decision D1: descope honestly).
- **Spec:** 03-prs/PR-010.md (not written yet)

## PR-011 — Two-token subcommand router for code-dev and library-dev
- **Status:** merged
- **Complexity:** L
- **Wave:** C
- **Findings:** C6, C7, M7, M8, H19
- **Scope:** workspace/programs/code-dev.md, workspace/programs/library-dev.md (router sections)
- **Depends on:** none
- **Why:** Root-cause fix: single-token router vs two-word documented commands. Unlocks pr list/drift/sync/export/suggest-reviewer, 8 umbrella routers, chats, meta cluster; makes the W:_arg1 bridge explicit.
- **Split note:** if review weight demands, splits into C6-suite vs C7-umbrella halves.
- **Spec:** 03-prs/PR-011.md (not written yet)

## PR-012 — Route check-structure to the actual structure checker
- **Status:** merged
- **Complexity:** S
- **Wave:** C
- **Findings:** C5
- **Scope:** workspace/programs/code-dev.md, code-dev-safety-audit.md, code-dev-safety-audit-structure.md
- **Depends on:** PR-011
- **Why:** check-structure currently runs the heavyweight Phase-5 final audit (wrong program) including an unexpected write prompt.
- **Spec:** 03-prs/PR-012.md (not written yet)

## PR-013 — Router debt cleanup
- **Status:** merged
- **Complexity:** M
- **Wave:** C
- **Findings:** H8, H9, H10, H11, H12
- **Scope:** code-dev-whatif.md (mapping table), code-dev-lifecycle.md (init/load dup), ALIAS stubs (preflight/reviewer-track), code-dev-migrate.md, code-dev-finalize.md
- **Depends on:** PR-011
- **Why:** whatif silently mis-executes ~20 subcommands; two expired ALIAS stubs still routed; migrate broken on every axis; finalize permanently dead.
- **Spec:** 03-prs/PR-013.md (not written yet)

## PR-014 — Unify the L: memory scope to a single backend (ADR)
- **Status:** merged
- **Complexity:** M
- **Wave:** D
- **Findings:** C9
- **Scope:** tools/kv_store.py, tools/memory.py, tools/_longterm.py, workspace/programs/config.md, key migration, tests
- **Depends on:** none
- **Why:** config wizard writes via diskcache; kernel gates read .md files — each backend reports the other's keys as not-found. Decision D3: converge on the .md longterm store.
- **Spec:** 03-prs/PR-014.md (not written yet)

## PR-015 — Queue integrity: pop, deps, clear semantics
- **Status:** merged
- **Complexity:** M
- **Wave:** D
- **Findings:** C10 (behavioral core)
- **Scope:** tools/queue_tool.py, workspace/scheduler/QUEUE.md docs, tests
- **Depends on:** none
- **Why:** pop permanently loses tasks; --deps stored but never enforced; clear does the opposite of documented session-end semantics.
- **Spec:** 03-prs/PR-015.md (not written yet)

## PR-016 — Scheduler-doc honesty: descope preemption claims
- **Status:** merged
- **Complexity:** S
- **Wave:** D
- **Findings:** C10 (doc half)
- **Scope:** axon/scheduler/SCHEDULER.md, axon/KERNEL-SLIM.md:498 (KERNEL LINES = OWNER PER-CHANGE CONFIRM)
- **Depends on:** PR-015
- **Why:** PREEMPT/pause/resume/snapshot-restore have zero backing code (decision D2: descope, not implement). Kernel-floor: the KERNEL-SLIM edit ships only with explicit owner sign-off.
- **Spec:** 03-prs/PR-016.md (not written yet)

## PR-017 — Unstick force-skip
- **Status:** merged
- **Complexity:** S
- **Wave:** D
- **Findings:** C11
- **Scope:** workspace/programs/code-dev.md (skip branch), tools/phase_model.py, sandbox regression test
- **Depends on:** none
- **Why:** The designated escape hatch from rigid traversal doesn't call done --force; projects can get permanently stuck at a phase boundary.
- **Spec:** 03-prs/PR-017.md (not written yet)

## PR-018 — Goal system: envelope bug, wire the writer, scoping ADR
- **Status:** merged
- **Complexity:** M
- **Wave:** D
- **Findings:** C12, M14
- **Scope:** code-dev-study.md, code-dev-plan.md, code-dev-journal-log.md, code-dev-safety-audit.md, code-dev-pr-create.md (pg.goals), tools/goal.py, goal-define.md
- **Depends on:** none
- **Why:** All 5 call sites treat the {ok,count,goals} envelope as the goals array; goal set has no callers; phase-entry guidance has never shown a real goal.
- **Spec:** 03-prs/PR-018.md (not written yet)

## PR-019 — Make hr-team audit bundles real
- **Status:** merged
- **Complexity:** M
- **Wave:** E
- **Findings:** C2, M1
- **Scope:** tools/hr_team.py (_HELPER_COMMANDS + vocabulary), workspace/programs/hr-team.md OUTPUT, tests
- **Depends on:** none
- **Why:** write_audit_bundle is fully implemented but unregistered — zero persisted audit trails; persistence vocabulary disagrees three ways.
- **Spec:** 03-prs/PR-019.md (not written yet)

## PR-020 — Wire hr-team filters and weights
- **Status:** merged
- **Complexity:** M
- **Wave:** E
- **Findings:** C3, H2
- **Scope:** workspace/programs/hr-team.md, hr-team-selector.md, hr-team-deliberator.md, tools/hr_team.py (match_roster, deliberation-metrics --weights)
- **Depends on:** none
- **Why:** M2-FILTERED unreachable (W:hr-team-filter never stored); --family/--roles dead; auditor 2× weight computed then discarded.
- **Spec:** 03-prs/PR-020.md (not written yet)

## PR-021 — hr-team deliberation flow repairs + LOW sweep
- **Status:** merged
- **Complexity:** S
- **Wave:** E
- **Findings:** H3, M2, M3 + hr-team LOWs
- **Scope:** hr-team-convener.md (early-exit, GOTO), verdict emission (bpc_passes vars, verdict-status ←/≡), router LOWs
- **Depends on:** PR-020
- **Why:** Re-round-on-dissent unreachable with a malformed GOTO beneath it; undefined verdict variables; assignment-inside-condition fires exactly in the contested case.
- **Spec:** 03-prs/PR-021.md (not written yet)

## PR-022 — Fix simulate .md↔CLI contract
- **Status:** merged
- **Complexity:** S
- **Wave:** F
- **Findings:** C13
- **Scope:** workspace/programs/simulate.md, tools/simulate.py, drift test
- **Depends on:** none
- **Why:** The safety command the menu recommends before anything irreversible fails with a CLI error on every input; output schema read by the .md doesn't exist.
- **Spec:** 03-prs/PR-022.md (not written yet)

## PR-023 — quickstart dispatcher + run-tests scope fix
- **Status:** merged
- **Complexity:** S
- **Wave:** F
- **Findings:** H15, H16
- **Scope:** workspace/programs/quickstart.md (step routing), workspace/programs/run-tests.md (R: → W:)
- **Depends on:** none
- **Why:** Steps 2–7 of the onboarding tour are never displayed; run-tests writes to a memory scope that doesn't exist.
- **Spec:** 03-prs/PR-023.md (not written yet)

## PR-024 — library-dev report type, ingest handoff, articles/ scan
- **Status:** merged
- **Complexity:** S
- **Wave:** F
- **Findings:** H17, H18, M15
- **Scope:** library-dev-report.md (W:_args → real args), library-dev-search.md (persist file path), library-dev-ingest.md + tools/library.py (articles/ default)
- **Depends on:** none
- **Why:** report type silently ignored; approved downloads vanish from the ingest loop; the folder created for drops is never scanned.
- **Spec:** 03-prs/PR-024.md (not written yet)

## PR-025 — Cron reconciliation
- **Status:** merged
- **Complexity:** S
- **Wave:** G
- **Findings:** H6, H7, H13, H14
- **Scope:** tools/cron.py (DEFAULTS), live cron.json (self-care subcommand, lint-code-weekly seed), bidirectional drift test
- **Depends on:** none
- **Why:** self-care cron failing live right now (2 consecutive); seed-defaults drift is bidirectional and unguarded.
- **Spec:** 03-prs/PR-025.md (not written yet)

## PR-026 — dispatch-index status field + synapse fallback honesty
- **Status:** merged
- **Complexity:** S
- **Wave:** G
- **Findings:** H20, H21
- **Scope:** tools/dispatch_index.py (status field, stub filename identity), tools/synapse_suggest.py (docstring + degraded-record handling)
- **Depends on:** PR-003
- **Why:** Fast-path can't distinguish STUB programs; fallback fabricates degraded records zeroing the ranker's own signals.
- **Spec:** 03-prs/PR-026.md (not written yet)

## PR-027 — Misc verified breakage sweep
- **Status:** merged
- **Complexity:** S
- **Wave:** G
- **Findings:** H22, H23, H24, H25, H26, M5
- **Scope:** axon-compare.md, crucible.md (register/status output), handoff.md (timestamps), migrate-workspace.md (STEP 4 status), harness-builder.md ({i} binding), orchestrator.md fixed-branch schema
- **Depends on:** none
- **Why:** Six independent, individually-verified breakages, each a contained fix.
- **Spec:** 03-prs/PR-027.md (not written yet)

## PR-028 — Liveness/reachability lint (pattern-7 guard)
- **Status:** merged
- **Complexity:** M
- **Wave:** H
- **Findings:** cross-cutting pattern 7 (S1, S2, C2, C12, H7 shape)
- **Scope:** tools/rules/R_LIVENESS (new, under existing crucible rule surface), whitelist file, weekly-audit wiring, tests
- **Depends on:** none
- **Why:** "Implemented + unit-tested but zero production callers" is the dominant defect shape; WARN-first rollout with whitelist, per R_NEW_NEEDS_TEST precedent. reduce-surface justification: extends the existing rules/crucible surface.
- **Spec:** 03-prs/PR-028.md (not written yet)

## PR-029 — Inline-EXEC-args lint + pr-ready preflight fix
- **Status:** merged
- **Complexity:** S
- **Wave:** H
- **Findings:** H1, cross-cutting pattern 2
- **Scope:** tools/rules/ (new R_ rule), code-dev-pr-ready.md / code-dev-safety-preflight.md (W:code-dev-preflight-mode handoff), tests
- **Depends on:** none
- **Why:** Inline EXEC args silently don't propagate — fix the instance and add the lint that prevents the class.
- **Spec:** 03-prs/PR-029.md (not written yet)

## PR-030 — Doc/registry honesty sweep
- **Status:** merged
- **Complexity:** S
- **Wave:** H
- **Findings:** M4, M6, M9, M10, M13, S1/C10 doc claims, LOW sweep
- **Scope:** axon/tools/REGISTRY.md mirror + completeness test, KERNEL-SLIM.md local/-scope + governance claims (KERNEL LINES = OWNER PER-CHANGE CONFIRM), workflow-new-questions.yml, PR-119 stubs, QUARANTINE deletions (owner-gated), LOW doc items
- **Depends on:** PR-016
- **Why:** Docs describe behavior with zero backing code; mirrors rot with no completeness test. Kernel-floor carve-out applies.
- **Spec:** 03-prs/PR-030.md (not written yet)
