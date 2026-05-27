# pr-v1 — Version bump 0.7.0

**Wave**: W1 (close) · **Depends-on**: PR-1..PR-7 merged

## Why
Wave-1 closes the foundation: T1 lints, compile gate, schema migrator, governance schema, secret redaction, cheatsheet, failure-mode catalog. Cut a marker release so the rest of W2-W4 can refer to "post-0.7.0 substrate" unambiguously and so CHANGELOG accumulates per-wave instead of per-PR.

## Spec
- **Files**:
  - modified: `VERSION`, `CHANGELOG.md` (move `## Unreleased` block under `## 0.7.0 — <YYYY-MM-DD>`).
- **Acceptance**:
  1. `VERSION` = `0.7.0`.
  2. `CHANGELOG.md` has `## 0.7.0 — <ISO date>` block with PR-1..PR-7 lines.
  3. `## Unreleased` block exists, empty, ready for W2.
- **Rollback**: revert.
- **Owner**: AGENT writes; HUMAN reviews CHANGELOG text.

## Codebase grounding
- **modify**: [`VERSION`](../../../../VERSION) — single-line file at repo root.
- **modify**: [`CHANGELOG.md`](../../../../CHANGELOG.md) — repo root. Append `## 0.7.0 — <ISO date>` block above the previous version block; clear `## Unreleased` to empty placeholder.

## Cross-refs
- Master plan: `../03-plan.md` § Wave 1 close.
