# Implementation Log — Fault Z-Slide (ZCORN throw)

## SESSION START — 2026-10-26T10:58:18Z
project:        fault-z-slide
phase:          0-spike
workflow-step:  build
branch:         main

## Entries
- 2026-10-26 — Project scaffolded after 3-round interrogation. Decisions →
  phases/0-spike/_decisions.md. Skeleton P0–P8 → masterplan.md. User chose: start with spike.
- 2026-10-26 — 0-spike: user authorised running the spike. `spike/z-slide` created in
  fault-projections; `spikes/z_slide_spike.py` → SPIKE PASSED (A vertical, B tilted: Δx=10,
  Δz=15 ⇒ dip-slip 18.03 m). find_i_faces juxtaposition correct; build_topology (D1) wrong.
  New gap P0.3: read_grdecl chokes on inline FAULTS. Details: phases/0-spike/01-study.md.
- 2026-10-26 — 1-prereqs: D1 implemented on cpg2python `fix/d1-fault-aware-topology`
  (shared `_fault_stack_faces`, exposed pieces → boundary, padded cell_faces 6+E, triangles).
  Found + fixed D4 (face_geometry diagonal heuristic; pinchout/tilted volumes wrong on main).
  Recorded D5 (mesh3d.face_edges unsupported on faulted grids).
- 2026-10-26 — Joint test with user, all green: cpg2python 492 passed; fault-projections
  214 passed / 1 skipped; smoke: all faulted decks + spike A/B closed, exact volumes;
  unfaulted grids byte-identical to main; spike re-run → build_topology = fault-aware (12).
  Committed 1eef539 (one commit, user choice). Not pushed.
- 2026-10-26 — P0.3 implemented on cpg2python `fix/grdecl-multirecord-keywords` (stacked on
  D1). Also fixed data-less keywords swallowing the next keyword. 3 new tests (fail on old
  reader). Slid spike deck with inline FAULTS + GRID/EDIT reads and builds. cpg2python 495
  passed; fault-projections 214 passed / 1 skipped. Committed 2d41127 (user approved).
- 2026-10-26 — P0.2 on cpg-fault-fieldbook `fix/ci-token-and-example-numbering`: CI failure
  confirmed (anonymous clone of private fault-projections). Token step via step-scoped
  GIT_CONFIG_* rewrite — verified locally (isolated git: fails without, succeeds with);
  actionlint 1.7.12 clean. Examples renumbered 01–18 (guide order). docs --check OK; fieldbook
  34 passed. Commits 9cbf066, ac0ef09 (local). User asked for more autonomy → proceed to 2-core.
- 2026-10-26 — Feature demo figures (out/feature_demos 01–05, incl. interactive 3D HTML).
  User asked "do we have to reprocess the grid after sliding?" → yes: slide = ZCORN edit; the
  derived grid (nodes/faces/fault pairs/areas) is rebuilt with read → from_grdecl →
  build_topology. Timed on Norne (46×112×22, 113,344 active): read 1.3 s, from_grdecl 0.8 s,
  but **build_topology raises NonMatchingZError (D2)** at i=4-5, j=2 — unmodified Norne.
  Impact: P1–P4 (pure ZCORN) unaffected; P5 juxtaposition/NNC report + any re-processing of
  real or tip-tapered slides (throw varying along strike ⇒ layer crossings) need D2 first.
  Candidate P0.4 before 3-pipeline — flagged to user.
- 2026-10-26 — User check "slid blocks must stay on the fault, not move right". Verified on
  spike A/B (corner-by-corner): COORD bit-identical; every corner on its pillar (≤1.4e-14 m);
  west block 0 motion; east corners on fault pillars move ALONG the fault (B: Δx +10, Δz +15,
  18.03 m), interior east pillars move straight down (Δx=Δy=0); east fault face on the fault
  plane (x-gap 0); fault areas conserved per side, W↔E contact 14,422 → 7,211 m² (B);
  thicknesses exact. Side effect of ZCORN-only on a TILTED fault: fault-adjacent east column
  volume −8.6…−9.7 % (column narrows with depth); all other cells 0 %. Vertical fault: 0 %.
  → P4/P5 should report per-cell volume change; P7 invariant: change confined to the
  fault-adjacent columns. 3D figure 05 redrawn at true positions (exploded view was plot-only).
- 2026-10-26 — Example 06: two sequential faults (out/feature_demos/06_*; decks + checks.txt in
  06_two_sequential_faults/). 9×4×3, both fault pillar lines tilted, F1 (i=3) slid 7 m then F2
  (i=6) slid 12 m → blocks W 0 / M 7 / E 19 m. Hanging wall = flood fill cutting only the slid
  fault, so sliding F1 carries F2 along (F2 throw stays 0). 16/16 checks: COORD + FAULTS
  unchanged in all decks; throws exact; F1→F2 == F2→F1 bitwise == one-shot block map
  (slides commute; P2 can compose); thickness exact; re-processed contact pairs == interval
  overlap on both faults at both stages. Volume change confined to columns bounded by a moved
  tilted pillar: i3 −3.0…−3.3 %, i5 +3.8…+4.2 % (widens), i6 −3.0…−3.3 % → −8.1…−8.8 % after F2.
  Implication for P2: a slide's volume footprint includes the *far* side of the moved block
  when another tilted fault bounds it (i5 here), not only the slid fault's adjacent column.
- 2026-10-26 — Fieldbook lessons 19 (sequential faults) and 20 (partial fault) on branch
  docs/z-slide-examples @ 59c3c57 (local, stacked on ac0ef09). New wiki page learn/z-slide.md
  + figures, README/coverage/limits rows. Partial fault (6×6×3, FAULTS on line 3 rows 0–3, tip
  pillar (3,4)): flood fill does not close a block → rigid slide impossible; tapered throw as a
  per-pillar field (8,6,4,2,0) applied east of the line keeps every non-FAULTS face welded;
  re-processed contact areas == analytic (trapezoids/triangles). Taper 15 m crosses DZ=10
  inside a face → NonMatchingZError (D2) — asserted as the current limit. Lessons need D1, so
  fieldbook pin moved to cpg2python 2d41127 / 0.3.0 (lock, pyproject, CI) — CI fails until the
  cpg2python stacked branches are pushed. Fieldbook suite 36 passed at pinned revisions
  (fault-projections main 0837f07). Figures: out/feature_demos/07_partial_fault{.png,_3d.html}.
  P2 design input: slide API needs a "tapered" mode (per-pillar throw field), not only rigid.
- 2026-10-26 — Lesson 21 (oblique fault) written, not committed: 8×6×3 vertical pillars, trace
  (300,0)→(600,600) 26.6° off J → staircase FAULTS 9 faces (6 X, 3 Y). Same FAULTS on (A) regular
  grid L=900 m and (B) adapt_grid pinned/barrier grid L=710.6 m (trace 670.8; faces_invariant).
  7 m rigid slide of the SE block (21 columns): COORD+FAULTS unchanged, opened faces == FAULTS,
  contact area == L×overlap exactly (A 27 % more than B), volumes unchanged. Figure 08 +
  docs/assets/z-slide/oblique-fault.png; wiki section, README/coverage/limits updated.
  Finding: adapt_grid with rim-to-rim traces ≥ ~30° off J regenerates FAULTS with a rim face
  (3,0,'Y') → faces_invariant False (main and spike). State saved → phases/1-prereqs/handoff.md.
- 2026-10-26 — Lesson 21 committed (87a1a06 vertical, then 7ef6ba0 dipping; fieldbook suite 37
  passed at pins before the dip; docs + lesson 21 re-checked after). User asked for dip: the
  staircase pillars keep tops on the trace and lean 40 m east by z=80 → fault dips 65.9° SE.
  B = adapt_grid stage 1 on the leaning grid (keeps lean; faces_invariant). Stage-2 polygon
  rejected: boundary="pinned" keeps the rim pillars (fault ends) vertical. Results: area/m A
  970.8 vs B 775.1 m²/m (A +25 %); contacts == area/m × overlap exactly; corner on fault pillar
  slides 7.83 m (Δx +3.5, Δz +7) — slip follows pillar lean, not pure dip; 27 moving cells
  next to the fault change volume −4.0…−1.6 %, fixed block unchanged. Figure 08 redrawn with
  x-z section. P2 input: rigid slide on leaning pillars = oblique slip along the pillar lean.
- 2026-10-26 17:0x — User: dip not visible, whole hanging wall should go down. Fix (fieldbook
  3223b93): grid 3 x 40 m, every hanging-wall pillar leans 75 m east at the base (footwall
  vertical) → dip 60.8° SE, 25 m slide is a rigid translation (29.5 m along pillars, no volume
  change). A 1007.5 / B 807.9 m²/m. Figure 08 redrawn: solid before/after 3D + south-face
  section. Full fieldbook suite 37 passed at pins. P2 lesson: rigid slide needs moving-block
  pillars parallel to the fault.

## Lesson 22: throw control around a fault tip
- Fieldbook commit (docs/z-slide-examples): lesson 22 `22_z_slide_throw_control` with cases A–F (profile linear/cosine + taper, far field whole-side/decay, hanging-wall share). Rigid slide past the tip refused (opens 4 non-FAULTS faces).
- All cases: COORD/FAULTS unchanged, only FAULTS faces open, volumes kept, contacts = analytic.
- Validated at pins (fault-projections main 0837f07): doctor OK, docs 23 pages, 38 passed.
- Figure 09 (`09_throw_control*.png/html`) in fault-projections/out/feature_demos.
- Open for P2/P3: library defaults (far field auto rigid/decay? kernel vs Laplacian decay? default share/profile?).
- DECISION (user): library defaults for the slide call: far field = auto (rigid if FAULTS close a block, else decay); decay method = both, kernel default + Laplacian option; hanging-wall share = 1.0 (footwall fixed); profile = cosine.

## Gallery: lessons 23–29 (slides × meshing, regridding, adaptation)
- User asked for 30+ cases combining both libraries; chose all 7 themes as lessons 23–29 and a
  fieldbook helper prototyping the planned slide API: `fieldbook/zslide.py` (`slide_blocks`,
  `slide_field`, `Throw` with table/per-horizon throws, kernel or Laplacian decay, cosine
  profile, hanging share, snap; checks `unwelded_faces`, `analytic_contacts`, `process`).
- 38 cases: 23 structural styles (5), 24 fault networks (5), 25 fault data inputs (6), 26 throw
  definitions (6), 27 reservoir questions (6: Allan, SGR→MULTX/Y, connectivity, ensemble,
  well tops), 28 regridding (6), 29 export workflows (4). Each asserts COORD/FAULTS kept, only
  FAULTS faces open, contacts = analytic (or the predicted wedge on tilted pillars).
- Snap generalized: reads both walls at every chain pillar (throw already on the fault counts),
  tol 1e-9·max|zcorn|, pass cap → RuntimeError. 2×20 m == 1×40 m. P2 input: snap is not
  linear in the throw (restoration exact only while inactive).
- Figures 10–16 (`out/feature_demos/1x_*.png/_3d.html`), docs page `learn/gallery.md`, assets
  `docs/assets/gallery/`, README/coverage/limits updated.
- Upstream gaps (candidate library tasks): `faults_after` rim faces / missing ring-closing face
  / merged chains; rim path edge spur in `path_to_faults`; multi-trace `adapt_grid` needs equal
  vertex counts; facet/polygon targets taper at every facet tip; pinned rim pillars on fault;
  `vtk` `%.6g` precision, no .vtu/.pvd, `faults_from_deck` ignores INCLUDE, `adapt_deck` merges
  FAULTS groups; cpg2unstructured: inactive/pinch-out beside a slid fault → NonMatchingZError.

## 2026-10-27 — Everything on main, repos cleaned
- User asked to push everything to main, simplify docs, add the examples, and clean the repos.
- Fieldbook 56bdc24 (v0.2.0): README rewritten (quick start + one table of 29 examples);
  tools/figures/make_figures.py regenerates figures 06-16 from the lessons (extra .[figures]);
  snapshot figures 01-05 in docs/assets/z-slide/background with a "How it started" section.
  45 tests passed locally. Fast-forward of main (lessons 19-29, CI token step).
- cpg2python main 897040d (v0.3.0: D1/D4 + P0.3 + README), fault-projections main 5015aa2
  (v0.1.0, README). Both CI green.
- Clean-up: all branches except main deleted locally and on GitHub (no open PRs); unmerged
  branches kept as archive/* tags; spike/z-slide → tag archive/spike-z-slide.
- Open: fieldbook CI fails until the user sets FAULT_PROJECTIONS_TOKEN (read-only PAT).
