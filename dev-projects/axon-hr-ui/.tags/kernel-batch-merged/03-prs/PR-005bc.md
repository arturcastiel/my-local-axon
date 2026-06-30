# PR-005bc — on-disk precondition scrub + synapse-validate recurrence lint
Status: merged
Phase: pr
Lane: AXON (autonomous, non-kernel)

## Problem
`code-dev.md`'s synapse `precondition:` carries `project ≠ ∅` repeated **11×** on disk (compiled
`code-dev.cmp.md` too). PR-005 added READ-TIME dedup in synapse_infer, so it's functionally neutralized —
but the on-disk source is ugly and nothing catches RECURRENCE at validate time. Scan confirms code-dev.md
is the ONLY program with a ≥3× repeated conjunct.

## Approach
- **005b (scrub):** collapse `project ≠ ∅ (AND project ≠ ∅)+` → single `project ≠ ∅` in `code-dev.md` AND
  `code-dev.cmp.md` (keep source/compiled consistent — surgical edit, no full recompile).
- **005c (recurrence guard):** `synapse_validate.validate()` errors when a precondition conjunct repeats
  ≥3× ("conjunct 'X' repeated N× — dedup it"). Threshold 3 (allows ≤2 legit repeats); only code-dev was
  hit, so no other program newly fails.

## Files
- `workspace/programs/code-dev.md`, `workspace/programs/compiled/code-dev.cmp.md` (scrub)
- `tools/synapse_validate.py` (the lint)
- `tests/` (new: a ≥3× repeat is flagged; a ≤2× repeat is not)

## Acceptance
- code-dev precondition has exactly one `project ≠ ∅`.
- validate() flags a ≥3× repeated conjunct; clean preconditions pass.
- Full crucible green (incl. compiled-staleness + synapse contract tests).

## Notes
Cosmetic source hygiene (005b) + the real value (005c: recurrence can't silently return). Spec-first.
