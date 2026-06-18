# Project-wide prohibition seeds

- NEVER edit axon/ kernel files (esp. KERNEL-SLIM.md DONE shorthand) — inviolable floor, human-only.
  The generalized DONE guard lands as a TOOL + verifier RULE in workspace/tools, not a kernel edit.
- NEVER bypass a gate to make progress (no phase_model --force, no skip-guard force) — "gates cannot be broken".
- Test-execution ONLY when the full crucible gate is green (AEGIS green-only). No autonomous build.
- New tool/program ships ACTIVE with tests in the SAME change (Core Rule 13).
- The gate must read the program's OWN declared `# outputs:` (single source of truth) — do not
  reintroduce a second hardcoded map that can drift (that is the very residual we are fixing).
