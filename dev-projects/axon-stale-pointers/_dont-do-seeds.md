# Project-wide prohibition seeds

These entries seed each new phase's `_dont-do.md` on `code-dev phase start`.
- Do not fix pointer staleness by hand-editing stale records case-by-case — the deliverable
  is the missing stamp/enforcement seam, not one-off repairs.
- Do not add a new state store — the fix must make the EXISTING pointers coherent
  (W:active-phase, _phases.json, _meta.md, last-test-run.json), not introduce a fifth.
