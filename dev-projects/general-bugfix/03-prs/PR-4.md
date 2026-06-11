# PR-4 — PR-spec + review contract (T4)

Status: merged
Merged: → main (squash) · crucible green 27 controls · zero warnings
Branch: general-bugfix/pr-4-spec-review-contract → main
Depends-on: (none)
Phase: 3-prs
Covers: T4 (spec/review contract drift) + the C7 residual's advisory floor

## Reality audit first (verify-before-build)
- The review dispatcher (scope/self/tests/diff/all) ALREADY exists — no 7-file collapse
  needed; the gaps were two subs outside it + identity collisions.
- The PR-spec schema was ALREADY coherent writer↔readers — the gap was that nothing
  PINNED it (the dominant root-cause class is exactly this kind of unpinned coherence).
- `W:code-dev-pr-id` overload: not found anywhere — already cleaned by an earlier wave.

## Change
- **Identity collisions fixed (6)**: the review/safety/knowledge implementation files
  stored their ALIAS names as `W:active-program` (rename residue) — each now owns its
  file identity. (Alias-stub deletion itself stays with reduce-surface.)
- **Review surface consolidated**: `coverage` + new `correctness` subs route through the
  `code-dev-review` dispatcher; the parallel direct route removed.
- **NEW `code-dev review correctness`** — the C7 advisory floor: adversarial diff review
  through 6 refutation lenses (inverted-condition, off-by-one, silent-fallback,
  dangling-reference, stale-state, spec-mismatch). WARN-only BY DESIGN — semantic
  correctness is undecidable, so it can never be a deterministic BLOCK. Read-only,
  budget-capped, structure-complete.
- **Schema pinned** (`tests/test_pr_spec_contract.py`, 6 locks): writer heading +
  `Status:` field; every pre-merge lifecycle token reads OPEN and the terminal set
  closes (`_spec_is_open`); dispatcher carries all subs; routes go through it;
  implementations own their identities; the correctness program's contract.

## Guarded-by
- The 6 contract pins + `R_NEW_NEEDS_TEST` (new program ships with its lock).
- Full gate green, ZERO warnings (27 controls).
