# Phase: 2-core
schema-version: v4
status:         complete
workflow-step:  build
branch:         main (all repos)
current-pr:     (none) — merged: cpg2python #47 #48 #49, fault-projections #2 #3 #4, fieldbook #1
completed:      2026-10-28
created:        2026-10-27

## Working Context
- DONE: cpg2python v0.4.0 (7d98aeb): `zcorn_ops` (#47), general fault faces D2 — inactive cells,
  pinch-outs, edge-crossing nodes, `Faces.loops`; Norne 0 open cells (#48); release (#49).
- DONE: fault-projections v0.2.0 (353b049): `slide.py` (#2), gallery gaps 1–8 + deterministic
  stitch tie-break (I-step first) + targets weight floor (#3), CHANGELOG + release (#4).
- DONE: fieldbook v0.3.0 (8f5a1ad, PR #1): zslide.py over `slide_grid`; lessons 20/25/26/28 show
  D2 instead of NonMatchingZError; pins bumped; new page docs/functions/fault-slide.md;
  limits/coverage/gallery/z-slide/README updated. 45 tests + all 29 lessons pass locally.
- Fieldbook PR #1 merged with CI red ONLY because secret FAULT_PROJECTIONS_TOKEN is unset (user).
- NOT DONE (candidates for next phase): `adapt_deck(slide=...)`; Norne `slide_deck` check (P7);
  drop lesson guards (interior/close_ring/named_chains/taper_cells=0, custom vtu, INCLUDE in 29);
  rebuild engineers' guide PDF; k-direction faults; skew-pillar volume drift (≤4.4 % Norne);
  L-shaped active region → faces_invariant False.
