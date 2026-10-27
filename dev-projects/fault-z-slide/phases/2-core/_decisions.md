# Decisions (ADRs) — 2-core

- **ADR-201 Scope.** User chose "core slide API (P1–P4) + everything: gaps, errors". In scope:
  P1 `zcorn_ops` (cpg2python), P2–P6 slide + report + deck I/O (fault-projections), upstream
  gallery gaps, D2 (5+ corner fault polygons / intersection nodes), inactive cells and
  pinch-outs beside faults, fieldbook migration, Norne check.
- **ADR-202 Delivery.** Feature branch → push → PR → merge when CI is green, per repo; then
  release tags (cpg2python v0.4.0, fault-projections v0.2.0, fieldbook v0.3.0).
- **ADR-203 Snap default OFF.** Library throws are exact; `Throw(snap=True)` opts in. Tapered
  throws crossing layer boundaries therefore rely on D2 to re-process.
- **ADR-204 Tilted pillars.** Corners move along tilted pillars, so cell volumes change; the
  change is reported per cell (`SlideResult.volume_change`), not compensated.
- **ADR-205 API shape.** `Throw(fault=name|faces, throw=peak|(s,t) table|per-pillar array,
  hanging_side=point|"left"|"right"|None→dip, hanging=1.0, profile="cosine", taper, decay="auto",
  growth, snap=False)`; chain runs from its end pillar with the smaller (I, J). `slide_grid`
  (gate: inversion, overlap, faces outside FAULTS, re-processing; on_invalid raise|bisect|ignore)
  and `slide_deck` (FAULTS names from the deck; INCLUDE + report + optional VTK).
- **ADR-206 Far field.** A fault that separates (alone, with the faults it abuts, or with all
  faults) moves its hanging side rigidly — inner faults ride along. Otherwise the motion fades
  (kernel default, Laplacian option) within the blocks it touches. Fields add linearly.
