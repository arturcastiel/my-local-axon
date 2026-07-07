<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · project:axon-bugfix01

- schema-version: `v1`
- generated:      `2026-07-03T12:03:32Z`
- generator:      `tools/dag.py`
- nodes:          30
- edges:          15
- critical-path:  PR-003 → PR-004 → PR-008

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-001 | pr | Enforce destructive-git-op gating in the live write path | Enforce destructive-git-op gating in the live write path | pending |
| PR-002 | pr | Consult the AEGIS test-execution policy in test_runner | Consult the AEGIS test-execution policy in test_runner | pending |
| PR-003 | pr | Fix synapse-suggest corpus and confidence math | Fix synapse-suggest corpus and confidence math | pending |
| PR-004 | pr | Make the orchestrator fire step real; conformance covers orchestrator.md | Make the orchestrator fire step real; conformance covers orchestrator.md | pending |
| PR-005 | pr | Reconcile predicate vocabulary; fail loud on undefined predicates | Reconcile predicate vocabulary; fail loud on undefined predicates | pending |
| PR-006 | pr | Populate the predicate eval ctx with real state | Populate the predicate eval ctx with real state | pending |
| PR-007 | pr | Wire check-stale + check-templating into workflow validate | Wire check-stale + check-templating into workflow validate | pending |
| PR-008 | pr | Repair adaptive-free-text.yml | Repair adaptive-free-text.yml | pending |
| PR-009 | pr | Rewrite library-dev.canonical.yml against real library-dev programs | Rewrite library-dev.canonical.yml against real library-dev programs | pending |
| PR-010 | pr | Differentiate fixed/adaptive modes; descope hybrid via ADR | Differentiate fixed/adaptive modes; descope hybrid via ADR | pending |
| PR-011 | pr | Two-token subcommand router for code-dev and library-dev | Two-token subcommand router for code-dev and library-dev | pending |
| PR-012 | pr | Route check-structure to the actual structure checker | Route check-structure to the actual structure checker | pending |
| PR-013 | pr | Router debt cleanup | Router debt cleanup | pending |
| PR-014 | pr | Unify the L: memory scope to a single backend (ADR) | Unify the L: memory scope to a single backend (ADR) | pending |
| PR-015 | pr | Queue integrity: pop, deps, clear semantics | Queue integrity: pop, deps, clear semantics | pending |
| PR-016 | pr | Scheduler-doc honesty: descope preemption claims | Scheduler-doc honesty: descope preemption claims | pending |
| PR-017 | pr | Unstick force-skip | Unstick force-skip | pending |
| PR-018 | pr | Goal system: envelope bug, wire the writer, scoping ADR | Goal system: envelope bug, wire the writer, scoping ADR | pending |
| PR-019 | pr | Make hr-team audit bundles real | Make hr-team audit bundles real | pending |
| PR-020 | pr | Wire hr-team filters and weights | Wire hr-team filters and weights | pending |
| PR-021 | pr | hr-team deliberation flow repairs + LOW sweep | hr-team deliberation flow repairs + LOW sweep | pending |
| PR-022 | pr | Fix simulate .md-CLI contract | Fix simulate .md-CLI contract | pending |
| PR-023 | pr | quickstart dispatcher + run-tests scope fix | quickstart dispatcher + run-tests scope fix | pending |
| PR-024 | pr | library-dev report type, ingest handoff, articles scan | library-dev report type, ingest handoff, articles scan | pending |
| PR-025 | pr | Cron reconciliation | Cron reconciliation | pending |
| PR-026 | pr | dispatch-index status field + synapse fallback honesty | dispatch-index status field + synapse fallback honesty | pending |
| PR-027 | pr | Misc verified breakage sweep | Misc verified breakage sweep | pending |
| PR-028 | pr | Liveness/reachability lint (pattern-7 guard) | Liveness/reachability lint (pattern-7 guard) | pending |
| PR-029 | pr | Inline-EXEC-args lint + pr-ready preflight fix | Inline-EXEC-args lint + pr-ready preflight fix | pending |
| PR-030 | pr | Doc/registry honesty sweep | Doc/registry honesty sweep | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-003 | PR-004 | depends |
| PR-005 | PR-006 | depends |
| PR-003 | PR-008 | depends |
| PR-004 | PR-008 | depends |
| PR-007 | PR-008 | depends |
| PR-005 | PR-009 | depends |
| PR-006 | PR-009 | depends |
| PR-007 | PR-009 | depends |
| PR-006 | PR-010 | depends |
| PR-011 | PR-012 | depends |
| PR-011 | PR-013 | depends |
| PR-015 | PR-016 | depends |
| PR-020 | PR-021 | depends |
| PR-003 | PR-026 | depends |
| PR-016 | PR-030 | depends |
