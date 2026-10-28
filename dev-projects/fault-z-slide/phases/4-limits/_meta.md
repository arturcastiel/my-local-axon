# Phase: 4-limits
schema-version: v4
status:         complete
workflow-step:  build
branch:         main (all repos)
current-pr:     (none) — merged: fault-projections #7, fieldbook #3
completed:      2026-10-28
created:        2026-10-28

## Working Context
- Goal: close the STILL OPEN items of 3-pipeline that can be fixed upstream. User: "go ahead,
  work freely".
- DONE: fault-projections v0.4.0 (247507e, PR #7):
  - L-shape fix: `live_faces(grid, faces)` (both side cells active in some layer);
    `AdaptResult.faces_invariant` compares live faces only. Before/after differed only on
    faces with an inactive side (projection walks round the hole, the chain runs through it).
  - Two-stage in one call: `adapt_grid(..., top_trace=None|"auto"|(N,2))` for polygon/facets:
    stage 1 = 2-D trace (gives FAULTS), stage 2 = tilt pillars on r1.grid; `.stage1`,
    `.top_trace`. `surface_top_trace(grid, surface)`: untapered stage-2 targets → xy_top ordered
    by PCA, binned at 0.5·median h, ends extended by h at the lattice rim. `adapt_deck` accepts
    one surface with top_trace (names from fault_names, default FAULT_1).
  - PNG: `viz.plot_slide(res)`, `write_slide_png(res, path)`, `slide_deck(png=True)`
    → `<prefix>_slide.png`, `SlideResult.png_path`. Figure API, no pyplot.
  - 283 passed / 1 skipped; ruff + mypy clean; CI green on 3.10–3.12.
- DONE: fieldbook v0.5.0 (8b04e9d, PR #3): lesson 30 C (65° rim-to-rim polygon, boundary="slide",
  top_trace="auto", Throw 15 m: chain gap 43 → max 4.6 m, volume −1.2 % vs wedge); B writes PNG
  if matplotlib; lesson 25 two_stage uses top_trace (output byte-identical). Docs: adapt-grid,
  fault-slide, limits, z-slide, README; pins 0.4.0 / 247507e; inventory maps new names.
- STILL OPEN (documented, not fixed): k-direction faults; skew-pillar volume drift (by design);
  sj_min ~2e-4 without barrier polish; surface_top_trace untested for faults curving > ~180°;
  user must set FAULT_PROJECTIONS_TOKEN.
