# Masterplan — Dont-Do Enforcement (soft → HARD, fail-closed)

> Promote project `_dont-do` prohibitions from advisory/opt-in to a mechanical,
> fail-closed gate that BLOCKS. **Owner priority (2026-05-27).**
>
> **STUDY DONE (2026-05-27 → `01-study.md`):** feasibility is GREEN — no prerequisite
> plumbing PR; `R_DONT_DO` mirrors `R_NEW_NEEDS_TEST`. The authoritative plan is now the
> **PR-0 … PR-6** sequence in `01-study.md` (adds PR-0 capture + tripwire tests), which
> supersedes the Phase 1–4 sketch below.

## The gap (diagnosed 2026-05-27, in opm-development/axon)
- **Tier 1 — AXON kernel rules:** HARD. `verify.py` predicates + `crucible` gate, fail-closed, block merge.
- **Tier 2 — project `_dont-do` / specs:** SOFT. `code-dev-review-diff` §3 greps the diff against
  prohibition phrases; `code-dev-log`/`audit` do drift detection. **None BLOCK; all opt-in; only as
  good as the tokens recorded.**
- **Failure mode:** a design constraint (prose, not tokenized) + no forced review step → slipped
  through twice; the human reviewer was the only backstop.

## Design — make it Tier-1-class
### Phase 1 — design (here)
- **`_dont-do` SCHEMA:** every prohibition carries a mechanically-checkable `match:` (literal
  token(s) or regex), not just prose — e.g. `match: "SummaryConfig(... const EclipseGrid&"`.
- **Gate semantics (FAIL-CLOSED / most conservative):**
  - token matches the diff → **BLOCK**.
  - prohibition has NO checkable token (prose-only) while the diff is non-empty → **BLOCK**
    (force tokenization) — never silently skip.
  - empty / unparseable `_dont-do` while changes exist → flag → BLOCK per policy.
### Phase 2 — control
- **`R_DONT_DO` crucible control (BLOCK severity):** on diff vs merge-base, evaluate every active
  prohibition's `match` against the diff. Register in `tools/crucible.json`. Tests (R_NEW_NEEDS_TEST).
### Phase 3 — always-on wiring
- Run `R_DONT_DO` INSIDE the crucible gate (pre-merge/pre-push), so it ALWAYS fires — not opt-in
  via `code-dev-review-diff`. Keep review-diff §3 as the human-facing view.
### Phase 4 — backfill
- Migrate existing prose prohibitions to tokenized `match:` form; lint that every `_dont-do` entry has one.

## Relationships
- Generalizes the `artifact-guard` static-lint pattern; sibling to `dag-consistency` (mechanical truth).
- **Cross-tree:** the gate must land in the CANONICAL axon tree and propagate — note there are now
  **4 axon trees** (mnt/c, new-axon, axon-development, opm-development). See axon-improvements **F0**.

## Discipline
New control + schema ⇒ tests in the same change; fail-closed; you run the gate; you commit.
