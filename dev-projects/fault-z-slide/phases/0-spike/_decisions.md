# Decisions (ADRs) — 0-spike

Source: 3-round user interrogation, 2026-10-26.

- **ADR-001 Scope.** Slide acts on faults that already exist on pillar lines (after xy-adapt,
  or read from a deck's FAULTS). No fault ⇒ nothing to slide.
- **ADR-002 Mechanism.** Only ZCORN changes; each corner moves ALONG its pillar. Vertical
  pillar ⇒ vertical throw; stage-2 tilted pillar ⇒ true dip-slip. COORD untouched.
- **ADR-003 Input.** Raw per-fault-pillar Δ array (the primitive) + helpers: `constant`,
  `tip_taper`, `table` (distance-along-trace → Δ).
- **ADR-004 Side.** Per-fault parameter; default = hanging wall auto-detected from pillar
  tilt (dip direction). Also `left` / `right` / split ratio (via `FaultCellMap` sides).
- **ADR-005 Far-field.** Parameter, default `auto`: rigid block shift when the moving block is
  closed by faults/model edge; otherwise smooth Laplacian decay (optional radius). Tips pinned
  to Δ=0 so the grid never tears.
- **ADR-006 Layers.** Thickness preserved: Δ constant down each pillar-side by default.
  Depth-varying (growth-fault) Δ is an explicit opt-in that knowingly breaks this.
- **ADR-007 Large throw.** Throw > layer thickness allowed; produce a juxtaposition /
  NNC report (which layers touch which, before vs after).
- **ADR-008 Code split.** Generic ZCORN ops + validity → cpg2python; fault semantics
  (sides, profiles, pipeline) → fault-projections. Mirrors existing D12 split.
- **ADR-009 Entry points.** Standalone `slide_deck` + optional `adapt_deck(slide=…)` step.
  Outputs: INCLUDE (existing writer), report, VTK + PNG.
- **ADR-010 Validation + docs.** Synthetic (closed block, fault with tip), dipping deck,
  Norne. Docs in cpg-fault-fieldbook.
- **ADR-011 Prerequisite.** cpg2python D1 must be fixed before any z-slide merge;
  user delegated "improve the existing repos" where they touch this feature (D1, fieldbook CI,
  duplicate `01_` example numbering).
