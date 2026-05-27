# pr-v2 — Version bump 0.8.0

**Wave**: W2 (close) · **Depends-on**: PR-8..PR-17 merged + PR-9.5/9.6/9.7 merged

## Why
Wave-2 ships study modes, sessions, governance teeth, rename harness, usage logging, routers, plan modes, study index, and three ergonomics PRs. Cut a marker release.

## Spec
- **Files**:
  - modified: `VERSION`, `CHANGELOG.md`.
- **Acceptance**:
  1. `VERSION` = `0.8.0`.
  2. CHANGELOG block `## 0.8.0 — <ISO>` sealed with PR-8..PR-17 + PR-9.5/9.6/9.7 entries.
  3. `## Unreleased` empty, ready for W3.
- **Rollback**: revert.
- **Owner**: AGENT writes; HUMAN reviews CHANGELOG.

## Codebase grounding
- **modify**: [`VERSION`](../../../../VERSION) — `0.7.0` → `0.8.0`.
- **modify**: [`CHANGELOG.md`](../../../../CHANGELOG.md) — seal `## 0.8.0 — <ISO>` block with W2 PR list.

## Cross-refs
- Master plan: `../03-plan.md` § Wave 2 close.
