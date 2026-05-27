# F-009: PR-review has two implementations with drifting phase semantics

**Severity:** high
**Track:** T-A
**Date:** 2026-05-17
**Linked decisions:** D-013 (FSM model), D-014 (preserve code-dev)
**Linked demands:** D-7 D-13 D-16 D-25

## Evidence

Two implementations of the same FSM coexist:

1. **`code-dev-pr-review.md`** (monolithic master, 140+ lines).
   Phase names: P1 Context load · P2 Study · P3 Conflict analysis ·
   P4 Harmonization plan · P5 Rebase · P6 Execution · P7 Verification ·
   P8 Commit organization · P9 Documentation.

2. **`code-dev-pr-review-p1.md` .. `p9.md`** (9 autogen-stub split scaffolds
   from PR-20.8). Phase names (where read): P1 summary · P2 diff · P5 tests ·
   P9 final verdict.

Both implementations:

- Use `cd_cache` tool to read/write `_reviewer-state.json` (PR-20.5 cache).
- Emit `code-dev.pr.review.phase` event per phase.
- Reference dependencies: PR-2 (compile gate), PR-12 (rename-safety),
  PR-20.5 (`_reviewer-state.json`).

But:

- Phase semantics drift: master P5 = Rebase; stub P5 = tests.
- Master file contains real per-phase logic; stub files call a placeholder
  `review_pN(pr-num)` not implemented anywhere in `workspace/programs/`.
- No declaration of which implementation is canonical.

## Why this matters

The PR-review FSM is the **richest existing example** of a multi-step
synapse chain in AXON today (per F-006). It is also the **most likely
template** for the formal synapse contract spec (F-005). Drift between two
implementations of the same FSM means:

1. Migrating contract metadata risks encoding the wrong phase semantics.
2. The orchestrator picking either `code-dev-pr-review` or
   `code-dev-pr-review-pN` would produce different behavior for the same
   user intent.
3. The PR-20.8 split (per `axon-master` plan history) appears to be a
   *planned refactor* of the master that was never completed. Determining
   ground-truth is necessary before extracting the FSM.

Per D-025 (preserve code-dev hierarchy), we cannot delete either
implementation without verifying which one is in active use. Per D-014,
both stay invocable; the orchestrator must disambiguate.

## Implication for Phase 2 / Phase 3

- **Phase 2.** Designate ONE implementation as canonical. Per evidence
  (master has real logic, stubs are scaffolds) the master is canonical.
  The 9 stubs need a decision: complete them (fill `review_pN` verbs and
  deprecate master) or remove the scaffolds (and complete the master).
- **Phase 2.** Synapse contract schema must explicitly handle "alternative
  implementations" — a meta-program may have multiple back-ends; orchestrator
  picks via a tie-breaker (declared canonical / user preference / project
  context).
- **Phase 3.** PR seed: `pr-review-canonicalize` — fold one impl into the
  other based on Phase-2 decision. Backward compat (D-025) preserved.
- **Phase 3.** Synapse contract for the canonical PR-review FSM, with
  declared transitions:
  ```
  P3 (conflicts == 0) → next: [P9, code-dev-shadow]    confidence: 0.8
  P3 (conflicts > 0)  → next: [P4]                     confidence: 0.95
  P7 (tests_failed > 0) → next: [code-dev-review-tests, P5]
  P9 → next: [code-dev-shadow, code-dev-audit]
  ```

## Risk

If we encode the contract from the master without auditing stub-file usage,
we may break consumers of the stubs (per D-025). If we encode from the stubs,
we lose the master's real logic.

## Suggested action

- **T-A follow-on.** Grep `workspace/programs/`, `my-axon/dev-projects/`, and
  `tools/usage.py` records for invocations of either `code-dev-pr-review`
  (master) or `code-dev-pr-review-pN`. Determine real usage. Produce
  `helpers/pr-review-usage-audit.md`.
- **Phase 2 design Q.** Canonical implementation pick + deprecation path
  for the other.
- **Phase 3 PR seed.** `pr-review-canonicalize` (single PR, dev-mode-gated).
