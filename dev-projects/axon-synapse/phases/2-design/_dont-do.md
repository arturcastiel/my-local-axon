# Phase prohibitions — 2-design

_(seeded from _dont-do-seeds.md on phase start)_

## Hard rules (inherited)
- Do not write to `axon/` unless `L:dev-mode ≡ true` AND a per-PR dev-mode toggle was logged.
- Do not invoke builds or test runs autonomously.
- Do not commit/push outside the `my-axon/` workspace-backup path.
- Do not fabricate tool output.
- Do not deprecate / delete a tool or program without a documented replacement path.

## Design-phase specific
- Do not implement code in 2-design. Specs only.
- Do not change any existing program file (D-014/D-025).
- Do not encode code-specific concepts at kernel-schema level (D-015).
- Do not assume what the orchestrator does — design it from declared
  signal sources (F-014) and goal predicates (F-017).
- Do not specify a synapse schema that cannot be inferred from existing
  program headers (D-005 hybrid; F-013).
- Do not author a workflow file format that can't represent both Fixed
  and Adaptive modes (D-017) or hybrid.
