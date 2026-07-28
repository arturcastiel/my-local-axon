# PR List — Fault SMO Mesh Adaptation
Updated: 2026-07-28 · Total PRs: 17 · Mode: tactical
Autonomy: see AUTONOMY.md (ADR-004) — two sequential grants, cpg2python first.

Ordering rule holds: no PR depends on a later-numbered PR.
Repo key: **[cp]** = cpg2python · **[fp]** = fault-projections

---

## Phase 0 — Gate setup  (required before ANY autonomous PR — ADR-004 A6)

## PR-000a — Gate setup: cpg2python
- **Status:** not-started
- **Repo:** [cp] · **Complexity:** S
- **Scope:** `pyproject.toml`, `.github/workflows/ci.yml`, dev env
- **Depends on:** none
- **Why:** The A3 gate (pytest + ruff + mypy local AND CI green) does not exist yet. Verified: no
  `[tool.ruff]` or `[tool.mypy]` in pyproject, CI runs pytest only, `mypy` and `resfo` not installed
  — `import cpg2unstructured` fails outright, so pytest dies at collection (P3).
- **Detail:** install `resfo` + `mypy` (+ scipy `[fast]` extra); add `[tool.ruff.lint]` and
  `[tool.mypy]`; extend `ci.yml` to run ruff and mypy alongside pytest so local matches CI.
- **Acceptance:** `pytest`, `ruff check`, `mypy` all run clean locally and in CI on untouched main.

## PR-000b — Gate setup: fault-projections
- **Status:** not-started
- **Repo:** [fp] · **Complexity:** S
- **Scope:** `pyproject.toml`, `.github/workflows/ci.yml`
- **Depends on:** none
- **Why:** Same gap as PR-000a — no ruff or mypy config, CI runs pytest only.
- **Detail:** as PR-000a, minus `resfo` (not a dependency of this repo).
- **Acceptance:** `pytest`, `ruff check`, `mypy` all run clean locally and in CI on untouched main.

---

## Phase 1 — Foundations  (PR-001 … PR-003, parallel after phase 0)

## PR-001 — Write CPG grid keywords to an INCLUDE deck
- **Status:** not-started
- **Repo:** [cp] · **Complexity:** M
- **Scope:** `cpg2unstructured/grdecl_writer.py` (new); `tests/test_grdecl_writer.py` (new)
- **Depends on:** PR-000a
- **Why:** D1 needs an output path and F1 found none — the library is read-only today.
- **Detail:** `write_grid_include(grid, path)` emits `SPECGRID` + `COORD` + `ZCORN` + `ACTNUM` with
  `N*VALUE` run-length encoding and `/` terminators. Never rewrites the master deck (D14, F2).
  Honours `mapaxes_applied`: un-rotate before writing, or refuse with a clear error — writing a
  rotated `coord` verbatim double-rotates on the next read.
- **Acceptance:** read → write → read round-trip is array-identical on all 12
  `tests/fixtures/*.grdecl`; a deck with `unrecognized` keywords is never rewritten in place.

## PR-002 — Pillar lattice accessors and validity primitives
- **Status:** not-started
- **Repo:** [cp] · **Complexity:** M
- **Scope:** `cpg2unstructured/pillars.py`, `cpg2unstructured/validity.py` (new); tests
- **Depends on:** PR-000a
- **Why:** Every later PR needs the pillar lattice and the fold test; D20 requires reading `coord`
  directly rather than via `projected_topology` (F12).
- **Detail:** `pillar_xy(grid)` → `(NX+1, NY+1, 2)` at top and bottom, straight from `coord`.
  Boundary masks for `scope ∈ {active, lattice}` — `active` = adjacent to an inactive column (F16).
  Vectorised plan-view **signed-area** fold detection (F7 — `cell_geometry` is a Python loop and
  must not be used). Minimum-separation guard, default 0.10 × original spacing, hard floor 1e-9
  (D18, F6).
- **Acceptance:** fold detector flags a hand-folded quad and passes the unmodified fixtures;
  separation guard fires at 1e-9; boundary masks verified on `hole_1x1x3` and `islands_5x1x1`.

## PR-003 — Carry segment provenance through projection
- **Status:** not-started
- **Repo:** [fp] · **Complexity:** S
- **Scope:** `fault_projections/projection.py`, `stitch.py`; `tests/test_projection.py`
- **Depends on:** PR-000b
- **Why:** D11 assigns one fidelity residual per `(pillar, segment)` incidence, and F3 found the
  segment index is discarded — `project_polyline` flattens all segments into one sequence.
- **Detail:** return a parallel segment-id array alongside the node ids; `stitch_path` preserves the
  association across the Dijkstra fill-in. Back-compatible: the existing return shape stays the
  default, provenance is opt-in.
- **Acceptance:** a 3-segment polyline yields ids whose segment labels partition the path in order;
  existing projection tests unchanged.

---

## Phase 2 — Engine  (the numerics)

## PR-004 — `morph_pillars` least-squares core
- **Status:** not-started
- **Repo:** [cp] · **Complexity:** L
- **Scope:** `cpg2unstructured/morph.py` (new); `tests/test_morph.py`
- **Depends on:** PR-002
- **Why:** The solver at the centre of the feature (D6 as corrected by D15).
- **Detail:** dimensionless `u = Δx / h_local`, each sum divided by its term count (D17).
  Fidelity `Σ‖u_p − û_(p,s)‖²` over incidences; smoothness `w·Σ‖L(u)_j − L(u⁰)_j‖²` on the change in
  differential coordinates — **not** `‖L(u)‖²`, which has no valid `w→∞` limit and destroys grid
  grading (F14). `L` is the 5-point stencil on the pillar lattice (F4). Boundary via Dirichlet
  elimination: `pinned` removes both DOFs, `slide` the normal DOF only, `free` none (D23, D24).
  `scipy.sparse.linalg.spsolve`; CG only past ~200k unknowns (D22).
- **Acceptance:** on a uniform grid with one pillar targeted, the solution is symmetric and decays
  monotonically; `w → ∞` reproduces the input grid to machine precision (the D15 property);
  `slide` leaves the boundary polygon unchanged while permitting tangential motion.

## PR-005 — Validity-guaranteed solve: bisection on `w`, snap-to-zero on write
- **Status:** not-started
- **Repo:** [cp] · **Complexity:** M
- **Scope:** `cpg2unstructured/morph.py`; `tests/test_morph_validity.py`
- **Depends on:** PR-004, PR-002
- **Why:** D7 is the one hard constraint and least-squares cannot enforce it (F14).
- **Detail:** outer loop — solve → detect folds → bisect `w` between `w₀` and `w_max` → re-solve,
  returning the largest fidelity that is fold-free (D16). `w_max` is valid *because* of D15.
  On write, any pillar with `‖Δx‖ < tol` is emitted at its original `coord` value, keeping the deck
  diff local (D8). Report achieved distance distribution and the final `w`.
- **Acceptance:** a target set that provably folds at `w₀` returns a fold-free grid; the reported
  `w` is within one bisection step of the fold threshold; zero folds on every fixture.

---

## Phase 3 — Stage 1: rigid pillar translation

## PR-006 — `targets_from_polyline` (stage 1)
- **Status:** not-started
- **Repo:** [fp] · **Complexity:** M
- **Scope:** `fault_projections/targets.py` (new); `tests/test_targets.py`
- **Depends on:** PR-003, PR-002
- **Why:** Turns a fault trace into the target rows the engine consumes (D2–D5, D11).
- **Detail:** one row per `(pillar, segment)` incidence — no ownership rule, so a pillar near a kink
  acquires two residuals and the solve drives it to the vertex (D11). Target is the **clamped foot**
  on the segment. Stage 1 applies the same delta to top and bottom, preserving any existing slant.
- **Acceptance:** a pillar equidistant from two segments of a right-angle kink lands on the vertex;
  targets are identical whether the polyline is given forwards or reversed.

## PR-007 — Stage-1 end to end: deck in, deformed INCLUDE out
- **Status:** not-started
- **Repo:** [fp] · **Complexity:** M
- **Scope:** `fault_projections/adapt.py` (new); `examples/adapt_stage1.py`; integration tests
- **Depends on:** PR-001, PR-005, PR-006
- **Why:** The first user-visible deliverable — the whole D1 → D14 path in one call.
- **Detail:** read deck → build targets → `morph_pillars` → `write_grid_include`. Surfaces the
  achieved distance distribution, final `w`, fold count and moved-pillar count.
- **Acceptance:** on `simple_faulted_3x3x2.grdecl` the mean distance to the trace drops by >90%
  versus the undeformed grid, with zero folds and a byte-identical master deck.

## PR-008 — Regenerate FAULTS and assert face-set invariance
- **Status:** not-started
- **Repo:** [fp] · **Complexity:** S
- **Scope:** `fault_projections/adapt.py`; `tests/test_fault_invariance.py`
- **Depends on:** PR-007
- **Why:** D13 ships the block; F10 makes it a free correctness oracle.
- **Detail:** re-project on the deformed grid and emit the block. **Rebuild** `ProjectedGraph` — its
  CSR and KD-tree are snapshots and go stale once pillars move (F11). Assert the regenerated
  `(I, J, K, direction)` set equals the pre-deformation set; a difference means a pillar crossed
  cells or a snap flipped.
- **Acceptance:** invariance holds on every fixture; a deliberately over-driven target set fails the
  assertion rather than shipping a wrong barrier.

---

## Phase 4 — Stage 2: independent top/bottom, dipping faults

## PR-009 — `targets_from_polygon` (stage 2)
- **Status:** not-started
- **Repo:** [fp] · **Complexity:** M
- **Scope:** `fault_projections/targets.py`; `tests/test_targets_3d.py`
- **Depends on:** PR-006
- **Why:** D9 — the fault is a `Polygon3D`, already coplanarity-validated by `as_polygon`.
- **Detail:** target = polygon plane ∩ the pillar's vertical line, evaluated at `z_top` and `z_bot`
  separately. Finite extent: only pillars inside the polygon footprint are driven. Asserts the F5
  property — with both endpoints in the plane, the whole pillar lies in it, so distance is 0 at
  **every** depth, not just at the two ends.
- **Acceptance:** for a dipping planar fault, max corner distance over all layers is ≤1e-9 (F5);
  pillars outside the footprint receive no target.

## PR-010 — Rim taper
- **Status:** not-started
- **Repo:** [fp] · **Complexity:** S
- **Scope:** `fault_projections/targets.py`; `tests/test_taper.py`
- **Depends on:** PR-009
- **Why:** D10 — a hard cut at the polygon rim concentrates the full displacement in one cell width,
  which is precisely where D7 breaks.
- **Detail:** fidelity weight ramps from full to zero over a band of width `d`, expressed in **cells**
  (default 3) and converted per pillar via local spacing (D19). Reproduces fault-tip displacement
  decay.
- **Acceptance:** no fold at the rim on a fault terminating mid-grid; displacement decays
  monotonically toward the tip.

## PR-011 — Stage-2 validity: slanted-pillar fold detection
- **Status:** not-started
- **Repo:** [cp] · **Complexity:** M
- **Scope:** `cpg2unstructured/validity.py`; `tests/test_validity_3d.py`
- **Depends on:** PR-005  *(relaxed from PR-005+PR-009 — ADR-004 A2: its acceptance criteria are
  purely synthetic slanted geometry and need no fault targets. Dropping the PR-009 edge collapses
  the grant schedule from 4 windows to 2.)*
- **Why:** D7 for tilted pillars — the stage-1 single-plane test is no longer sufficient.
- **Detail:** signed area at the top plane **and** the bottom plane, plus a pillar-pair crossing test
  over the vertical span: two pillars that do not cross in plan view can still cross in depth once
  they tilt independently.
- **Acceptance:** detects a synthetic depth-crossing pair that the plan-view test alone misses;
  passes `pinchout_2x2x2.grdecl` and `pinched_1x1x3.grdecl` unchanged.

## PR-012 — Stage-2 end to end, including curved faults
- **Status:** not-started
- **Repo:** [fp] · **Complexity:** S
- **Scope:** `fault_projections/adapt.py`; `examples/adapt_stage2.py`
- **Depends on:** PR-007, PR-009, PR-011
- **Why:** Completes D3 and extends to curved faults at no extra cost.
- **Detail:** routes each planarised facet from `faceting.facet_surface` through the PR-009 target
  builder — the F5 exactness property holds facet by facet. A pillar spanning two facets acquires
  two residuals, exactly as D11 handles kinks.
- **Acceptance:** a listric fault sampled into facets deforms without folds; per-facet max distance
  matches the single-plane case.

---

## Phase 5 — Validation and upstream prerequisites

> PR-013 and PR-014 fix behaviour that predates this feature. The engine depends on **neither**
> (it reads `coord` directly), but they block end-to-end Norne validation and the FAULTS path.

## PR-013 — P1: `build_topology` must survive welded corners
- **Status:** not-started
- **Repo:** [cp] · **Complexity:** L
- **Scope:** `cpg2unstructured/unstructured.py`; `tests/test_build_topology_welded.py`
- **Depends on:** PR-000a
- **Why:** Norne raises `face … has more than 2 neighbours` and cannot be ingested at all (F13).
- **Detail:** measured cause — 10,912 of 113,344 cells (9.6%) have fewer than 8 distinct corner node
  ids (1,137 with 7, 1,115 with 6, 286 with 5) plus 8,374 pinched cells. Faces are deduped by their
  sorted node-id set, so welded corners collapse two distinct faces onto one entry and it acquires a
  third neighbour. Fix: disambiguate faces by `(cell, direction)` provenance rather than node-id set
  alone, or drop degenerate faces explicitly.
- **Acceptance:** Norne loads end to end; fixture behaviour unchanged; the degenerate-face count is
  reported rather than silently absorbed.

## PR-014 — P2: `projected_topology` on slanted pillars
- **Status:** not-started
- **Repo:** [cp] · **Complexity:** L
- **Scope:** `cpg2unstructured/planview.py`; `tests/test_planview_slanted.py`
- **Depends on:** PR-000a
- **Why:** F12 — plan view degrades **silently** at 5 m of tilt on a 100 m cell (projected nodes
  245 vs 49 expected, ratio exactly `nz+1`; edges 336 vs 84), and Norne has 7 vertical pillars out
  of 5,311. Every consumer of the 2.5D chain is affected, this feature's FAULTS path included.
- **Detail:** collapse by **pillar identity** (`P` index) rather than by coordinate equality — the
  correct fix. If deferred, at minimum raise instead of returning a plausible-looking wrong
  topology.
- **Acceptance:** the F12 synthetic returns 49 projected nodes at every slant; Norne yields
  5,311 projected nodes.

## PR-015 — Norne validation harness and benchmark
- **Status:** not-started
- **Repo:** [fp] · **Complexity:** M
- **Scope:** `benchmarks/norne_adapt.py`; docs
- **Depends on:** PR-008, PR-013, PR-014
- **Why:** D21 — the reference deck, 46×112×22, 64 faults, 984 records. Needs **both** upstream
  fixes: PR-013 to ingest Norne at all, PR-014 because PR-008's FAULTS regeneration runs through
  `projected_topology`, which is silently wrong on Norne's slanted pillars (F12).
- **Detail:** end-to-end run reporting distance-to-line before/after, fold count, welded-pillar
  count, final `w`, and wall-clock against the F15 baseline (`read_grdecl` 0.72 s,
  `from_grdecl` 0.44 s, 10,622 unknowns).
- **Acceptance:** zero folds, distance reduced by an order of magnitude on the driven set, total
  runtime under a minute.
