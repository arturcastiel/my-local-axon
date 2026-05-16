# CD·PLAN·I3·A — audit (iteration 3)

> Verify the I3 risk/sequencing fixes and check the plan against fresh adversarial lenses: "what if the AGENT is the failure mode?"

## Self-failure-mode lens

| Risk to plan execution                          | Mitigation in plan                              |
|-------------------------------------------------|-------------------------------------------------|
| Agent fabricates tool results (F-A3)           | Plan never trusts un-run output; HUMAN runs tests |
| Agent drifts persona post-compaction (F-A1)    | Each PR self-contained; resumable from `_session.md` (PR-9) |
| Agent pushes without consent (F-A2)             | Plan explicitly: do not push; HUMAN gates       |
| Agent loses state at compaction (F-C4)         | Per-PR work is journaled to `_actions.log`; resume picks up at last PR |
| Agent edits `axon/` without dev-mode            | Plan touches `tools/`, `workspace/`, `tests/`, `my-axon/`; NEVER `axon/` |
| Agent misuses path helpers                      | `tools/lint_paths.py` runs over every new tool (acceptance row) |
| Agent over-engineers a PR                       | Each PR scoped to specific goals; "do not add backwards-compat shims" rule |

## Constraint re-cross-check

| Constraint                                            | Pass |
|-------------------------------------------------------|:----:|
| No write to `axon/`                                   | ✔    |
| No agent-run pytest                                   | ✔ — HUMAN runs |
| No agent-run git push                                 | ✔ — HUMAN runs |
| Every tool imports from `_axon_paths.py`              | ✔ — in acceptance |
| All paths absolute or via `_axon_paths`               | ✔ — in acceptance |
| Atomic writes for state files                         | ✔ — PR-3 ships helper |

## DAG re-validation (post I3 ordering)

Edges:
1. PR-1 → PR-3, PR-12.
2. PR-2 → PR-3, all-recompiles.
3. PR-3 → PR-9, PR-17, PR-8.
4. PR-4 → PR-10, PR-11.
5. PR-7 → PR-15.
6. PR-8 → PR-16.
7. PR-9 → PR-15.
8. PR-11 → PR-16.
9. PR-12 → PR-14.
10. PR-13 → PR-21.
11. PR-14 → PR-20.

Topological sort: PR-1, PR-2, [PR-3 ⊥ PR-4], [PR-5 ⊥ PR-6 ⊥ PR-7], then W2 — all consistent.

No cycles. No orphan PRs.

## Wave-1 critical-path latency

If we assume each PR ≈ 1 "implementation unit":
- Sequential MUST: PR-1 → PR-2 → (PR-3 ⊥ PR-4) → boundary = 4 units.
- NICE in parallel: ~1 unit additional.
- W1 total: 4-5 units.

For comparison: W2 = ~6 units, W3 = ~7-8, W4+ = ~15+.

## Test-coverage audit

Every PR has at least one test file or extends one:
- PR-1: writes its own tests (meta).
- PR-2: extends test_compiled_regression.py.
- PR-3: test_migrator.py.
- PR-4: test_governance.py.
- PR-5: test_redact.py.
- PR-6: cheatsheet — manual review (no tests).
- PR-7: catalog — manual review.

Programs-without-test = cheatsheet, catalog. Acceptable (pure docs).

## Documentation audit

Every code PR has documentation:
- PR-1: tests doc comment.
- PR-2: gate documented in AXON-DOCS-COMPILER.md (W3 expansion).
- PR-3: AXON-DOCS-SCHEMA.md (shipped IN PR).
- PR-4: AXON-DOCS-GOVERNANCE.md (shipped IN PR).
- PR-5: redact docstring + allowlist file.
- PR-6: cheatsheet itself.
- PR-7: catalog itself + postmortem template.

W3 expansion fills broader docs.

## Failure-mode coverage map (recheck)

| Class | Mode  | Wave |
|-------|-------|-----:|
| A     | F-A1  | covered |
| A     | F-A2  | covered |
| A     | F-A3  | covered |
| B     | F-B1  | W1 PR-3 |
| B     | F-B2  | W1 PR-3 (atomic) |
| B     | F-B3  | W2 PR-9 (atomic for actions) |
| B     | F-B4  | W2 PR-9 |
| C     | F-C1  | W1 PR-2 |
| C     | F-C2  | W1 PR-2 |
| C     | F-C3  | W3 (per-mode budgets) |
| C     | F-C4  | W2 PR-15 |
| D     | F-D1  | W3 PR-18/19 |
| D     | F-D2  | W2 PR-12 |
| D     | F-D3  | W4 (G.safe.07) |
| E     | F-E1  | W2 PR-11 |
| E     | F-E2  | W3+ (CI integration deferred) |
| E     | F-E3  | W3 PR-22 (rules audit) |
| E     | F-E4  | W2 PR-17 + PR-10 |
| F     | F-F1  | W1 PR-6 (cheatsheet) |
| F     | F-F2  | W1 PR-1 (T1) |
| F     | F-F3  | W1 PR-1 (cross-ref lint) |
| G     | F-G1  | W3+ (lifecycle) |
| G     | F-G2  | W3+ |
| G     | F-G3  | W3+ |
| H     | F-H1  | W1 PR-5 |
| H     | F-H2  | covered (memory) |
| H     | F-H3  | W4+ |

## Audit verdict
- Plan v2 + I3 fixes is execution-ready.
- All major risks have mitigations.
- DAG sound; rollback strategy per PR.
- HUMAN/AGENT split explicit.
- 0 changes to wave assignment.

## Tiny corrections to fold into v3
1. PR-2 gate WARN→BLOCK flip: pick **test-based** (one full audit pass passes) — more reliable than time.
2. `_session.md` "state" field: enum `{active, frozen, tagged, closed, recovered}` — 5 states; richer than single line.
3. Migrator preserves `STUDY DIRECTIVE` (or any unknown section) in a `## CUSTOM` appendix verbatim.

## Items to escalate (none)
All open questions from I3 have defaults; no HALT.

→ plan v3: `cd-plan-i3-p-v3.md`.
