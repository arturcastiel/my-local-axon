# Project-wide prohibition seeds — axon-ascent

Seed each phase _dont-do.md on `code-dev phase start`.

- Never remove or soften a kernel rule to add a competitor feature (moat-erosion). Apply the turn-1==turn-100 test.
- Never commit generated files.
- Never fix a "bug" without a reproducing test in tests/.
- Never bypass the write gate.
- Phase order matters: do not ship a measurable feature before 1-telemetry makes it measurable.
- Every new tool MUST be registered in tools/REGISTRY.json (REGISTRY drift gate is active).
- New programs must pass the rule pack (R_FAIL_FORMAT, R_PHASE_TRACKED, R_COGNITION_LANGUAGE, ...).
