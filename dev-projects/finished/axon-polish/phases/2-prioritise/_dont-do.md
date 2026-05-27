# Phase prohibitions — 2-prioritise

_(seeded from `_dont-do-seeds.md`)_

- Never fix a "bug" without confirming it reproduces against a test in `tests/`.
- Never narrate a tool call (Core Rule 6).
- Never bypass the write gate.
- Never let the audit balloon: time-box; carry leftovers to a sub-project.
- Never commit generated files.

## Phase-specific
- **Phase 2 is ranking-only** — no edits to axon/, tools/, workspace/, or tests/ of the dev tree.
  Output is purely planning artifacts in `my-axon/dev-projects/axon-polish/`.
- Never invent a new finding in Phase 2. If something looks like a gap, file it as an addendum to
  `_flaws.md` or `_demands.md` with a `· phase-2-addendum` marker; never inline-rank an unfiled finding.
- Never rank without sizing. Every cluster must have S/M/L/XL before it gets a rank position.
- Never combine findings across ADRs into one cluster — each ADR owns its cluster boundary.
- Never let a cluster grow past ~5 findings without splitting. Tight clusters = sharp PRs.
- Never rank by severity alone — `impact × (1/difficulty)` with prior-work cost reductions factored in.
