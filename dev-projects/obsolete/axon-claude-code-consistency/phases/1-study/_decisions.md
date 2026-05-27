# Decisions (ADRs) — 1-study

## D-001 · 2026-05-21 · Sibling project, not extension
Decision: `axon-claude-code-consistency` is a sibling of
`axon-copilot-consistency`, not an expansion of it. Both projects share
the diagnostic framework (T-codes, probe corpus, defense-layer matrix)
but have distinct fix surfaces.

Why:
- The two harnesses have fundamentally different anchoring primitives —
  Copilot's gap was contract text contradictions; Claude Code's gap is
  model drift inside good frames.
- A combined project would mix two unrelated fix surfaces
  (`.github/copilot-instructions.md` vs `~/.claude/*`).
- Keeping them separate makes phase-4 measurement cleaner: the per-PR
  delta is attributable to one harness.

Consequence:
- This project consumes sibling outputs as INPUT (read, not authority).
- The two projects coexist; either can advance without blocking the other.
