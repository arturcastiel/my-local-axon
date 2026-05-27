# F-006: Workflow-completion programs already exist — orchestrator is the missing piece

**Severity:** high (high information value, reframes Phase 3 scope)
**Track:** T-A (overlaps T-B + T-F)
**Date:** 2026-05-17

## Evidence

`workspace/programs/` contains 174 programs total. 117 are `code-dev-*`.
Filtering by workflow-completion keywords (`review`, `test`, `audit`, `shadow`,
`impact`, `finalize`, `safety`, `simulate`, `self`):

| Program | Likely role in chain |
|---------|---------------------|
| `code-dev-self-review.md`         | self-review entry |
| `code-dev-review-self.md`         | self-review (alt name — redundant?) |
| `code-dev-review.md`              | review entry |
| `code-dev-pr-review.md`           | PR-level review entry |
| `code-dev-pr-review-p1.md` .. `p9.md` | PR review phases (9-step sub-FSM) |
| `code-dev-pr-suggest-reviewer.md` | suggest reviewer |
| `code-dev-explain-reviewer.md`    | explain to reviewer |
| `code-dev-reviewer-track.md`      | track reviewer state |
| `code-dev-knowledge-reviewer-track.md` | indexer variant |
| `code-dev-review-coverage.md`     | coverage report |
| `code-dev-review-diff.md`         | diff renderer for review |
| `code-dev-review-scope.md`        | scope reasoning |
| `code-dev-review-tests.md`        | review the tests |
| `code-dev-suggest-tests.md`       | suggest tests for change |
| `code-dev-test-map.md`            | test → file mapping |
| `run-tests.md`                    | (system) test runner wrapper |
| `code-dev-impact.md`              | impact analysis |
| `code-dev-knowledge-impact.md`    | impact indexer variant |
| `code-dev-shadow.md`              | shadow capture (mandatory per D-011) |
| `code-dev-knowledge-shadow.md`    | shadow indexer variant |
| `code-dev-audit.md`               | post-PR audit |
| `code-dev-rules-audit.md`         | rules audit |
| `code-dev-safety-audit.md`        | safety audit |
| `code-dev-safety-audit-structure.md` | structure audit |
| `code-dev-finalize.md`            | finalize / close PR |
| `axon-audit.md`                   | (meta) AXON-level audit |
| `simulate.md`                     | (system) dry-run |
| `harness-builder.md`              | (system) harness scaffolder |

That is 28 workflow-completion programs in core families + several more in the
`code-dev-pr-review-p*` series, for a total of ≥ 36 chain-related entries.

## Why this matters for the project

The user's vision asks for "after developing → build → test → self-review →
reviewer-altering" suggestions. **The programs to fire already exist.** What
is missing:

1. **Declared transitions between them** — none of these declare
   `precondition` / `post-state` / `next-conditional` (cf F-005).
2. **An orchestrator that walks the chain** — no program reads "user just ran
   `code-dev pr 7` → next state requires `code-dev-suggest-tests`."
3. **A canonical chain definition** — the FSM (D-013) needs an entry-point
   declaration: "the post-implementation chain is [review-self, suggest-tests,
   run-tests, review-tests, review-coverage, impact, safety-audit, audit,
   shadow, finalize]" or a workflow-author's preferred ordering.

This means **Phase 3 scope is smaller than expected**:
- Author the synapse contract for ~30 workflow-chain programs (not 174).
- Wire the orchestrator to a small set of canonical chains first.
- Bulk-migration of remaining 144 programs is a Phase 3 follow-up.

## Implication for Phase 2 / Phase 3

- The canonical "post-impl chain" is a Phase 2 design artifact, not a Phase 3
  implementation. Author it as a YAML / JSON workflow file once contract
  schema is set.
- The 9-phase `code-dev-pr-review-p1`..`p9` series is already a sub-FSM —
  inspecting it in T-A batch 2 is the highest-value learning before designing
  the synapse contract.
- Redundancy patterns (e.g. `code-dev-self-review` vs `code-dev-review-self`,
  `code-dev-X` vs `code-dev-knowledge-X`) need resolution — captured in F-007.

## Suggested action

- **T-A batch 2 (next slice).** Read `code-dev-pr-review.md` + the 9 phase
  files. Extract the de-facto FSM: state transitions, conditional next steps,
  rollback paths. Document as `helpers/pr-review-sub-fsm.md`.
- **Phase 2 design Q.** Codify the "post-impl canonical workflow" as the first
  authored chain. Use it to validate the synapse-contract schema.
- **Phase 3 PR seed.** `workflow-canonical-postimpl` — single workflow file
  + orchestrator entry-point that fires the chain end-to-end (with QUERY at
  each phase boundary while `L:inference-mode ≤ 5`).
