# Project-wide prohibition seeds

- Never write to `axon/` without `L:dev-mode ≡ true` (Core Rule 9).
- Never run builds, tests, or compilation autonomously — implementation
  is the agent's; execution is the human's. (KERNEL-SLIM rules.)
- Never fabricate tool output (Core Rule 6).
- Do not introduce new test frameworks before surveying what already
  exists in `tests/` and `tools/test-runner` / `tools/idem_test`.
- Do not break existing programs while adding test scaffolding.
- Do not couple tests to machine-specific paths — use
  `tools/_axon_paths.py` helpers.
