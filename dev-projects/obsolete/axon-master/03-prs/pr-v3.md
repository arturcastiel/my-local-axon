# pr-v3 — Version bump 0.9.0

**Wave**: W3 (close) · **Depends-on**: PR-18..PR-25 + PR-15.5/15.6 + PR-20.5/20.6/20.7/20.8 + PR-25.5 merged

## Why
Wave-3 closes observability + perf + integration + docs.

## Spec
- **Files**: modified `VERSION`, `CHANGELOG.md`.
- **Acceptance**:
  1. `VERSION` = `0.9.0`.
  2. CHANGELOG `## 0.9.0 — <ISO>` block sealed with W3 PR entries.
  3. `## Unreleased` empty, ready for W4.
- **Rollback**: revert.
- **Owner**: AGENT; HUMAN reviews.

## Codebase grounding
- **modify**: [`VERSION`](../../../../VERSION) — `0.8.0` → `0.9.0`.
- **modify**: [`CHANGELOG.md`](../../../../CHANGELOG.md) — seal `## 0.9.0 — <ISO>` block with W3 PR list.

## Cross-refs
- Master plan: `../03-plan.md` § Wave 3 close.
