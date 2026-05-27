# Project: AXON Polish — comprehensive audit + heavy-workflow readiness
slug:            axon-polish
schema-version:  v4
status:        finished
legacy:          false
phase:           5-validate
workflow-step:   complete
# Phase drift note (2026-05-23): this field sat at 2-prioritise/ranked
# through the entire implement+validate effort because nothing enforced
# phase-state honesty — the exact failure ADR-004 addresses. Corrected
# on ADR-004 acceptance. All ranked clusters (C-01..C-16 in-scope) shipped;
# 16 Phase-5 e2e scenarios green; heavy-workflow-ready substantiated.
branch:          main
codebase:        /home/arturcastiel/projects/axon-development/axon
parent:          (none)
sub-projects:    []
created:         2026-05-21
updated:         2026-05-21
phase-1-audit-completed: 2026-05-21
phase-2-prioritise-started: 2026-05-21
adrs-accepted: 3 (ADR-001 shell.py sandbox · ADR-002 fail_render.py · ADR-003 30-day hybrid deprecate)
clusters-ranked: 15
clusters-routed-out: 3
phase-3-design-blockers: ADR-004 (phase-transition gate) — only ADR still PROPOSED awaiting accept
adrs-accepted-total: 6 (ADR-001/002/003/005-split/006-sequenced/007)
adrs-proposed: 1 (ADR-004)
adrs-deferred: 1 (ADR-005b — registered builtins; deferred until 005a closes F-D4-003)

## Iteration 2 (Phase 2.5-verify) — 2026-05-21
meta-finding: dev tree ≡ prod tree at HEAD 97c29c3 (same code, same commit, byte-identical kernel)
new-blockers-added: 2 (F-D6-005a write-attribution sentinel, F-D6-005b EXEC silent simulation)
new-majors-added: 1 (F-D4-016 DAG-skip)
new-minors-added: 1 (F-D5-009 drift-log schema)
new-demands-added: 3 (D-D8-021 silence-window, D-D8-022 EXEC verification, D-D6-005a sentinel)
new-adrs-proposed: 1 (ADR-004 phase-transition invariant gate)
findings-retracted-or-reframed: 1 (F-D3-003 version drift → MINOR ambiguous banner)
major-trace-confirm-rate: 91% (10/11 stood as MAJOR; 1 PARTIAL with caveat)
pytest-actual-tests: 3606 (audit's "86" was test-file count, not collected tests)
ci-status: lint-paths + tests-full + coverage gates active
flaws-cataloged: 137
demands-cataloged: 48
demands-retired-by-prior-work: 6
findings-routed-elsewhere: 5
active-conflicts-needing-user-decision: 3
plan-readiness-grade: A+
prior-work-surveyed: 14 projects

## Working Context
- Vision: take the dev tree (v3.7.0, axon-synapse) from "feature-complete" to
  "heavy-workflow ready" by a thorough multi-angle audit and a bug-census-driven
  polish pass. Audit-first → priorities derived from synthesis → spec → fix → validate.
- Phase graph:
    1-audit       (study/inventory — current)
    2-prioritise  (rank findings by impact × difficulty)
    3-design      (spec fixes per finding cluster)
    4-implement   (PR specs + code)
    5-validate    (heavy-workflow stress test)
- dev-mode is ON for this project — kernel writes are permitted but always
  routed through PR specs, never ad-hoc.
- Run: code-dev study  to begin Phase 1.

---
> **CONSOLIDATED 2026-05-27** — moved to `finished/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.
