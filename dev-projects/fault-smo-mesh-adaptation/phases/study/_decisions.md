# Decisions (ADRs) — study

## ADR-001 — Feature: fault-driven pillar deformation ("mesh adaptation to fault trace")
**Date:** 2026-07-28 · **Status:** accepted (owner interview, in progress)

### Problem
`fault-projections` today produces a *staircase* fault: the polyline is projected onto the
plan-view mesh, snapped to nearest nodes, stitched via Dijkstra, and exported as a `FAULTS`
deck. The fault faces approximate the true trace but do not lie on it. This feature makes the
grid *adapt* to the trace instead of approximating it.

### Objective (owner intent)
Minimize the distance of the selected projected points to the fault line — **target distance 0**.

### Decisions taken

| # | Decision | Value | Source |
|---|----------|-------|--------|
| D1 | Output | Modified CPG deck (COORD/ZCORN written back) | owner |
| D2 | Entity that moves | Pillar `(x,y)` in COORD | owner |
| D3 | Staging | Stage 1 = rigid pillar (top+bot together, vertical fault); Stage 2 = top/bot independent (dipping fault) | owner |
| D4 | Direction | Closest point on the segment (per-node perpendicular foot) — follows from the min-distance objective | derived |
| D5 | Magnitude | Full move to the line where feasible (distance 0); residual only where a constraint binds | derived |
| D6 | Solver | Global least-squares: `min Σ|x_i − line|² + w·Σ|x_j − mean(nbrs)|²`, sparse SPD solve | owner |
| D7 | Hard constraint | **No cell may break — no crossing edges, no folding/inversion** | owner |
| D8 | Footprint | Global solve over all pillars; on WRITE, any pillar with `\|dx\| < tol` is written at its original COORD value (clean solution, local deck diff). Param: `tol`. | owner |
| D9 | Stage-2 target | Reuse `Polygon3D` (already validated in `polygon.py`). Target = polygon plane ∩ pillar vertical line, evaluated at `z_top` and `z_bot`. **Finite extent** — only pillars inside the polygon footprint are driven; the fault dies at its rim. | owner |
| D10 | Rim rule | Taper the fidelity weight to zero over a band of width `d` inward from the polygon rim. Protects D7 at the fault tip (a hard cut concentrates the full displacement in one cell width) and reproduces real fault-tip displacement decay. Param: `d`. | owner |
| D11 | Kink handling | **No ownership rule.** One fidelity residual per `(pillar, segment)` incidence. A pillar near a vertex acquires two residuals and the solve drives it to the kink vertex — for two non-parallel lines the minimiser of `dist²(p,L₁)+dist²(p,L₂)` IS their intersection. Segments are finite, so each residual uses the *clamped* foot; the vertex property holds in the limit. | owner |
| D13 | FAULTS output | Ship the deformed deck **with a regenerated `FAULTS` block**. Owner note: the fault faces theoretically move along with the projection — but update anyway. | owner |
| D12 | Repo ownership | `cpg2python` gains a **fault-agnostic** engine — `morph_pillars(grid, targets, w, tol)`, `write_grdecl`, signed-area fold detection. `fault-projections` computes per-pillar targets from the trace / `Polygon3D` and calls down. Rationale: pillars, COORD, `P[2NX,2NY,2NZ]` and fold detection are all cpg2python vocabulary; `fault-projections` knows only projected node ids today. Engine is reusable (well paths, boundary conformance). | owner |

### Consequence of D6 × D7 (flagged to owner 2026-07-28)
Linear least-squares is **unconstrained** — it cannot guarantee D7. The solve must be wrapped:
solve → detect folds → escalate `w` (or damp offending pillars) → re-solve, until clean.

**Fold detection, per stage:**
- Stage 1 (vertical pillars): a fold, a crossing edge and an inverted cell are the SAME event —
  a sign flip of each cell's plan-view quad signed area. O(Ncells) numpy, no geometry library.
- Stage 2 (slanted pillars): signed area at the top plane AND the bottom plane, PLUS a
  pillar-pair crossing test over the vertical span — two pillars that do not cross in plan view
  can still cross in depth once they tilt independently.

### Face-set invariance (owner insight, 2026-07-28) — becomes a TEST
The deformation changes pillar POSITIONS, never mesh TOPOLOGY: no cells added or removed, no
faces re-indexed. Therefore the set of cell-faces constituting the fault is INVARIANT under the
deformation — the `(I, J, K, direction)` tuples of a `FAULTS` block computed BEFORE the morph
remain the same faces after, now lying exactly on the trace.

Consequence: regeneration (D13) is cheap insurance, and equality is a free correctness oracle.

> **TEST:** regenerate the FAULTS block on the deformed grid and assert it EQUALS the
> pre-deformation block. A difference means a pillar crossed into a different cell or the
> nearest-node snap flipped — i.e. a solver bug. Catch it in CI, not in a reservoir model.

Keep this test even if D13 were ever reversed — it validates the solver, not the output format.

### Deck round-trip is LOSSY (finding, 2026-07-28) — constrains D1
`grdecl_reader._parse_stream` records unconsumed keywords **by NAME ONLY**
(`state.unrecognized.append(kw)`, line ~180) — never their content. Anything outside
`SPECGRID`/`DIMENS` + `COORD` + `ZCORN` + `ACTNUM` + the known property list
(`PORO PERMX PERMY PERMZ NTG MULT* PRESSURE SWAT SGAS SOIL SATNUM PVTNUM EQLNUM FIPNUM`)
is DROPPED: `EQUALS`, `COPY`, `MULTFLT`, EDIT-section keywords, regions, schedule data.

So a read → deform → write round trip on a real deck silently loses data. Two further traps:
- **MAPAXES**: `apply_mapaxes=True` is the EGRID default, so `coord` may already be rotated into
  the map frame. Writing it back without un-rotating yields a deck rotated TWICE on next read.
- **INCLUDE**: the reader recurses and flattens; a whole-deck writer collapses a deliberate
  multi-file deck into one file.

**Proposed escape (needs owner decision):** do not rewrite the deck. Write ONLY the grid
keywords — deformed `COORD`/`ZCORN` (+ the regenerated `FAULTS` per D13) — into a SEPARATE
`.grdecl` that the master deck `INCLUDE`s. Nothing is round-tripped, so nothing can be lost,
and this matches normal reservoir-workflow practice.

### Consequences / costs already identified
- **No writer exists.** `cpg2unstructured` reads GRDECL + EGRID; nothing writes COORD/ZCORN.
  `fault-projections` writes only the FAULTS keyword. D1 requires a NEW writer (cpg2python).
- **Stage 2 leaves documented scope.** `planview.projected_topology` targets matching-Z /
  vertically-aligned pillars; slanted pillars are marked future work there. Stage 2 either
  extends plan view or reads pillars directly from `coord`.
- **Segment provenance is currently discarded.** `project_polyline` concatenates all segments
  into one node sequence before `stitch_path`. The feature is specified *per segment*, so the
  segment index must be carried through projection → stitching → deformation input.

## ADR-002 — Study refinement: all open questions closed
**Date:** 2026-07-28 · **Status:** accepted · **Basis:** measured on Norne + controlled synthetics

| # | Decision | Value | Basis |
|---|----------|-------|-------|
| D15 | Smoothness term **corrected** | Penalise the CHANGE in differential coordinates: `w·Σ‖L(x)_j − L(x⁰)_j‖²`, NOT `w·Σ‖L(x)_j‖²`. | As originally written, `w→∞` converges to an arbitrary *harmonic* field (the original grid is harmonic only on a perfectly regular lattice) — so no known-good limit exists and bisection could not terminate. It also homogenises deliberate grid grading wherever `w` acts. With the corrected form `w→∞ ⇒ x = x⁰`, which is fold-free by assumption. |
| D16 | Fold repair (Q1) | **Bisection on `w`** between `w₀` (max fidelity, may fold) and `w_max` (≡ original grid, safe). ~20 solves for 1e-6. Optional local damping pass afterwards to recover exactness away from the offender. | D15 makes the upper bracket provably valid, so bisection provably terminates and returns the largest fidelity that is fold-free. |
| D17 | `w` normalisation (Q2) | Solve for **dimensionless displacement** `u = Δx / h_local`; divide each sum by its **term count**. `w` then compares mean residuals and is grid- and fault-length-independent. Default `w₀ = 0.3`. | Fidelity is a displacement² (invariant under refinement); `‖x_j − mean(nbrs)‖ ≈ (h²/4)‖∇²x‖` shrinks as `h²`. Un-normalised, the same `w` smooths less on finer grids, and a long fault outweighs a short one by term count alone. |
| D18 | Minimum pillar separation (Q3) | Hard floor `1e-9` model units (the weld point). Practical default **0.10 × original neighbour spacing**, enforced as a quality guard that triggers `w` escalation — separate from the hard fold rule. | `_QUANT = 1e9` sets the weld point exactly (F6). Below ~10% of original spacing, aspect ratio degrades >10× and transmissibility (`~A/d`) conditioning fails before the geometry does. |
| D19 | Taper width `d` (Q4) | Expressed in **cells, default 3**, converted per pillar via local spacing — never fixed model units. | What matters is how many cells absorb the displacement gradient. Fixed model units behave inconsistently across a graded grid, which is where tips commonly land. |
| D20 | **Bypass plan view** (Q5) | Target selection AND the solve read the `(NX+1)×(NY+1)` pillar lattice from `coord` **directly**. `projected_topology` is NOT used by the deformation, and is NOT extended. | MEASURED: plan view degrades silently at 5 m slant on 100 m cells (projected nodes 245 vs 49 expected — ratio exactly `nz+1`, i.e. nothing collapsed; edges 336 vs 84; no exception raised). Norne is 99.9% slanted (7/5311 vertical, median drift 62.6 m). Bypassing removes the F8 scope limit entirely and unifies stage 1 with stage 2. |
| D21 | Validation decks (Q6) | Primary **Norne** `46×112×22` = 113,344 cells, 64 faults / 984 records, at `opm-tests/norne/`. Unit fixtures: `cpg2python/tests/fixtures/*.grdecl` (12, incl. `simple_faulted_*`, `pinchout_*`, `hole_*`). **Prerequisite:** Norne currently fails `build_topology`. | See F13 — this is a pre-existing library defect, not one the feature introduces. |
| D22 | Performance target (Q7) | Direct sparse `spsolve` is the default; CG + preconditioner only beyond ~200k unknowns. | MEASURED on Norne: unknowns = `2·(NX+1)(NY+1)` = **10,622**, INDEPENDENT of NZ — a 21.3× reduction vs cell count. `read_grdecl` 0.72 s, `from_grdecl` 0.44 s. A direct solve at this size is sub-second. |

## ADR-003 — Boundary handling is a first-class setting
**Date:** 2026-07-28 · **Status:** accepted (owner request)

| # | Decision | Value |
|---|----------|-------|
| D23 | Boundary **mode** | `boundary ∈ {"slide", "pinned", "free"}`, **default `"slide"`**. `slide` = motion TANGENTIAL to the boundary allowed, NORMAL motion blocked (the standard slip condition in mesh morphing): the domain outline is preserved as a polygon while pillars redistribute along it, so a fault meeting the boundary can still reach distance 0 at the intersection. `pinned` = both DOFs fixed. `free` = unconstrained. |
| D24 | Boundary **scope** | `boundary_scope ∈ {"active", "lattice"}`, **default `"active"`**. `active` = the rim of the ACTIVE domain (pillars adjacent to an inactive/absent column). `lattice` = the bounding-box edge (`i ∈ {0,NX}` or `j ∈ {0,NY}`). |

### Why the scope exists (measured on Norne)
Norne's active domain is **44,928 / 113,344 cells (39.6%)**, and only **2,264 / 5,152 columns
(43.9%)** contain any active cell. The reservoir outline is therefore a highly irregular shape well
inside the bounding box. Pinning the *lattice* edge on such a deck constrains pillars far outside the
reservoir — physically meaningless — while leaving the real outline free. Hence `active` as default.

### Implementation
Dirichlet elimination in the least-squares — the system stays symmetric positive definite in all
three modes:
- `pinned` — eliminate both DOFs of each boundary pillar.
- `slide`  — eliminate ONE DOF (the component normal to the local boundary direction); keep the
  tangential DOF free. Corner pillars receive two independent normal constraints and are therefore
  fixed, which is the correct behaviour.
- `free`   — eliminate nothing.

Boundary detection needs no topology: on the pillar lattice it is `i ∈ {0,NX} ∨ j ∈ {0,NY}` for
`lattice`, and "adjacent to an inactive column" for `active` — consistent with D20 (no plan view).
The local boundary direction for `slide` comes from the rim polyline through neighbouring boundary
pillars.

## ADR-001 open items — RESOLVED
- ~~O1 Footprint~~ → D8 (global solve, snap-to-zero on write).
- ~~O2 Stage-2 dip input~~ → D9 (`Polygon3D`, finite extent).
- ~~Q1–Q7~~ → D15–D22 above. **No open questions remain.**

### Resolved
- ~~O3 — "SMO"~~ → an INTERNAL FUNDING-PROGRAMME acronym, not a technical term (owner,
  2026-07-28). It names the project's funding line only. It carries NO algorithmic meaning:
  it does not imply smoothing, and no code, module, or parameter should be named after it.
