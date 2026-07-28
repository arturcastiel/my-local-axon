# Study — Fault SMO Mesh Adaptation
Updated: 2026-07-28 · Iterations: 3 (interview + measured refinement + boundary mode) · AXON: 10/10 · User: pending
**Open questions: 0** — all closed by measurement, see ADR-002.

Codebases studied:
- `/mnt/c/projects/library-development/fault-projections` @ `8920eee` (main) — 422 graph nodes
- `/mnt/c/projects/library-development/cpg2python`        @ `c6202df` (main) — 808 graph nodes

Shadow index: 12 files (12 fresh). Graphs: `graph/graph.json`, `graph/cpg2python.json`.

---

## Goal

Make the corner-point grid **adapt to the true fault trace** instead of approximating it with a
staircase of cell faces.

Today `fault-projections` projects a fault polyline onto the plan-view mesh, snaps each crossing
to the *nearer* endpoint of the crossed edge, stitches the snapped nodes with Dijkstra, and emits
an Eclipse `FAULTS` deck. The resulting faces bracket the trace but do not lie on it.

The feature adds a deformation step: **for each segment of the polyline, the pillars in that
segment's projected set are moved toward the segment line — minimising their distance to it,
target distance 0** — subject to the mesh remaining valid. The deformed grid is written out as an
Eclipse `INCLUDE` file together with a regenerated `FAULTS` block.

Delivered in two stages:
- **Stage 1** — rigid pillar translation: a pillar's top and bottom `(x,y)` move by the same delta.
  Any pre-existing slant is preserved; the fault is vertical *relative to the deck's own geometry*.
- **Stage 2** — independent top/bottom offsets: the pillar tilts, the fault dips.

Both stages read the pillar lattice from `coord` directly and never touch `projected_topology`
(**D20**, grounded in F12) — so neither is constrained by plan view's matching-Z scope, and the two
stages share one mechanism rather than forking.

Boundary pillars are governed by a setting: `boundary ∈ {slide, pinned, free}` (default `slide`)
over `boundary_scope ∈ {active, lattice}` (default `active`) — **D23/D24**, see F16.

## Priorities

1. **Correctness of the mesh before exactness of the fault.** A grid with a folded cell is worthless
   regardless of how well the fault is placed (D7 is the one hard constraint).
2. **Distance 0 wherever it is reachable.** The objective is minimisation, not a fixed damping rule.
3. **Non-destructive output.** Nothing in the user's deck may be lost or silently altered (D14).
4. **Reuse over reinvention.** `Polygon3D`, `planar_minimal_surface`, `path_to_faults`, `faceting`
   already exist and are validated — the feature composes them.
5. **The engine stays fault-agnostic.** `cpg2python` gains "move pillars to targets, keep cells
   valid, write the deck"; fault semantics stay in `fault-projections` (D12).

## Constraints

- **HARD — no broken cells.** No crossing edges, no folded or inverted cells. Non-negotiable (D7).
- Output must not rewrite the master deck (D14 — see F2 for why).
- Stage 1 must not touch `ZCORN`; layering is preserved.
- Kernel-file / build / test execution rules of the host project are unchanged — this is a library
  feature in two external repos.
- Both libraries are GPL-3.0 (`fault-projections` inherits it from `cpg2unstructured`).

## Tech Stack

Python ≥ 3.10 · NumPy (core) · SciPy (`sparse`, `spatial.cKDTree`, `csgraph`, `interpolate`) ·
pytest · ruff. Optional: `pyshp` (shapefile input), `matplotlib` (plots), VTK export is hand-rolled.
No MRST, no resdata, no GPL imports at module import time in `fault-projections`.

## Key Concepts — the pipeline as it exists

```
read_grdecl / read_egrid          cpg2python   deck  → CornerPointGrid{coord,zcorn,actnum,...}
  → from_grdecl                                      → CornerCube{nodes, P[2NX,2NY,2NZ]}
  → build_topology                                   → UnstructuredGrid{faces, cell_corners,
                                                                        original_ijk}
  → projected_topology                               → ProjectedTopology{nodes2d, edges,
                                                          edge_uv, edge_dir, node_of_grid_node}
  → build_projected_graph      fault-projections     → ProjectedGraph{csr, cKDTree}
  → project_polyline                                 → ordered node-id sequence
  → stitch_path                                      → continuous on-mesh node path
  → path_to_faults → faults_text                     → Eclipse FAULTS deck
```

The 3D branch replaces the middle with `as_polygon → project_fault_surface →
planar_minimal_surface`, and curved faults go through `faceting.facet_surface` first.

**Where the feature inserts:** a new stage between `project_*` and the writer, operating on
`coord` — not on `UnstructuredGrid.nodes`, which are derived and have no back-map to the deck.

---

## Findings

### F1 — There is no writer. At all.
`cpg2unstructured` reads GRDECL and EGRID; nothing writes `COORD`/`ZCORN`. `fault-projections`
writes only the `FAULTS` keyword block. `write_grdecl` is net-new work, and it is the *only* way
D1 can be satisfied.

### F2 — A whole-deck round trip is lossy, so do not attempt one
`grdecl_reader._parse_stream` records unconsumed keywords **by name only**
(`state.unrecognized.append(kw)`), never their content. Everything outside
`SPECGRID`/`DIMENS` + `COORD` + `ZCORN` + `ACTNUM` + the known property list is **dropped**:
`EQUALS`, `COPY`, `MULTFLT`, EDIT-section keywords, regions, schedule data.

Two further traps on the same path:
- **MAPAXES double-rotation.** `apply_mapaxes=True` is the EGRID reader's default, so `coord` may
  already be rotated into the map frame; writing it back un-corrected rotates it *again* on the
  next read. `mapaxes_applied` is the flag that must be honoured.
- **INCLUDE flattening.** The reader recurses into includes; a whole-deck writer would collapse a
  deliberately multi-file deck into one file.

→ Resolved by **D14**: write only the grid keywords to a separate `.grdecl` that the master deck
`INCLUDE`s. Nothing is round-tripped, so nothing can be lost.

### F3 — Segment provenance is discarded, and D11 needs it
`project_polyline` loops `for k in range(line.shape[0]-1)` over segments but appends every result
into one flat `seq`. By the time `stitch_path` runs, which segment produced which node is gone.
D11 (one fidelity residual per `(pillar, segment)` incidence) requires that association. The
projector must carry a parallel segment-id array — a small but load-bearing change.

### F4 — The smoothness term needs no graph: pillars are a regular lattice
`cell_adjacency` is **cell**-to-cell and is the wrong structure here. Pillars form a regular
`(NX+1) × (NY+1)` lattice by construction, so a pillar's neighbours are `(i±1, j)` and `(i, j±1)`
with no adjacency object to build. The D6 smoothness operator is therefore the standard **5-point
Laplacian stencil**, and the least-squares system is a sparse Poisson-like problem — well
conditioned, symmetric positive definite, and solvable with `scipy.sparse.linalg.spsolve` or a CG.

### F5 — For a planar fault, stage 2 is *exact at every depth* (not just top and bottom)
`_assemble_corner_xyz` interpolates pillar `xy` **linearly in z**:
`xy = top + t·(bot − top)`, `t = (z − z_top)/(z_bot − z_top)`.

A plane is also linear in `z`. A straight line with two points in a plane lies **entirely** in that
plane. Therefore, if stage 2 places a pillar's top endpoint on the fault plane at `z_top` and its
bottom endpoint on the plane at `z_bot`, the **whole pillar lies in the fault plane** and every
corner it carries — at every layer — has distance exactly 0.

This is why D9's choice of `Polygon3D` matters beyond convenience: `as_polygon` *enforces*
coplanarity, so the exactness property is guaranteed by the input type rather than hoped for. For
curved faults via `faceting`, each quad is `planarize_quad`'d, so the property holds facet-by-facet.

### F6 — Node identity is coordinate-derived: pillars can silently WELD
`from_grdecl` dedups nodes on `np.round(xyz * 1e9)` via `np.unique` (`_QUANT = 1e9`). Node identity
is a function of position, not of pillar index. Two pillars driven to within `1e-9` therefore
**merge into one node**, which changes topology, silently welds cells, and breaks the D13 face-set
invariance.

D7 forbids crossing; this shows that *touching* is equally fatal, and gives a concrete numeric floor
for a minimum-separation guard rather than an arbitrary tolerance.

### F7 — Do not use `cell_geometry` for fold detection
`cell_geometry` computes volumes by the divergence theorem inside a **Python `for` loop over cells**,
with an inner loop over faces. Calling it once per solver iteration is interpreted-Python work
proportional to cell count — prohibitive on a real grid across several iterations.

Use instead the **vectorised plan-view signed-area sign test**: for stage 1 (vertical pillars) a
fold, a crossing edge and an inverted cell are the *same event* — a sign flip of a cell's plan-view
quad signed area — computable as one O(Ncells) NumPy expression. Stage 2 needs the test at both the
top and bottom planes, plus a pillar-pair crossing check over the vertical span.

Incidental: `face_geometry` computes quad area from the two **diagonals**, because `Faces.nodes` is
sorted by node id and is *not* in cyclic order. Nothing downstream may assume cyclic vertex order.

### F8 — `planview` is documented as matching-Z only
Its docstring scopes it to "matching-Z / vertically-aligned pillars, where the 3D nodes of a column
share identical in-plane coordinates and collapse exactly", and calls slanted/faulted pillars future
work. Stage 1 is inside this. **Stage 2 is not** — it must either extend `projected_topology` or
read pillars directly from `coord`, bypassing plan view. The `decimals=` parameter exists to absorb
float drift in nominally vertical pillars and will matter after deformation.

### F9 — `FAULTS` emission conventions are already fixed
`FACE = 'X'` when the adjacent cells differ in I, `'Y'` when in J; the **lower-index** adjacent cell
is emitted; Eclipse is 1-based so `original_ijk + 1`; and the 2.5D path spans the **full column**
(`IZ1=1, IZ2=nz`) — consistent with a vertical stage-1 fault. Boundary faces emit the single in-grid
cell. For stage 2, `surface_to_fault_faces` / `faults_text_3d` already carry real per-layer `K`.

### F10 — Face-set invariance is a free correctness oracle
The deformation changes pillar *positions*, never mesh *topology*: no cells added or removed, no
faces re-indexed. So the fault's `(I, J, K, direction)` face set is invariant under the morph.

> **Test:** regenerate the `FAULTS` block on the deformed grid and assert it equals the
> pre-deformation block. Any difference means a pillar crossed into a different cell or a
> nearest-node snap flipped — a solver bug, caught in CI.

Keep this test regardless of whether the block is shipped; it validates the solver, not the format.

### F11 — `ProjectedGraph` is a snapshot and goes stale
Its `csr` edge weights and `cKDTree` are built from `topo.nodes2d` at construction time. After
pillars move, both are wrong. The F10 re-projection test must **rebuild** the graph, not reuse it.

---

## Architecture Snapshot — where the new code lands

```
cpg2python  (fault-agnostic engine — D12)
  morph.py          NEW  morph_pillars(grid, targets, *, w, tol, max_iter) -> CornerPointGrid
                         · 5-point Laplacian on the (NX+1)x(NY+1) pillar lattice, read from
                           coord DIRECTLY — no plan view, no ProjectedTopology (D20, F12)
                         · dimensionless u = dx/h_local, per-term-count normalisation (D17)
                         · Σ|u−target|² + w·Σ|L(u)_j − L(u⁰)_j|²   (D6 as corrected by D15)
                         · bisection on w between w0 and w_max ≡ original grid (D16)
                         · boundary=slide|pinned|free x scope=active|lattice, Dirichlet
                           elimination; slide removes the NORMAL DOF only (D23/D24, F16)
  validity.py       NEW  signed-area fold detection, vectorised (F7); min-separation guard (D18)
  grdecl_writer.py  NEW  write_grid_include(grid, path)  — SPECGRID/COORD/ZCORN/ACTNUM (D14, F1, F2)
                         · honours mapaxes_applied; never rewrites the master deck

fault-projections  (fault semantics)
  targets.py        NEW  targets_from_polyline(polyline, topo)  -> (pillar, segment, target) rows
                         targets_from_polygon(Polygon3D, grid)  -> top/bottom targets (D9, F5)
                         · rim taper weighting (D10)
                         · one row per (pillar, segment) incidence — no ownership rule (D11)
  projection.py     EDIT carry the segment index through (F3)
```

## Findings — round 2 (measured, 2026-07-28)

### F12 — `projected_topology` degrades SILENTLY on slanted pillars — and real decks are slanted
Controlled synthetic, 6×6×4 grid of 100 m cells, every pillar tilted by `slant` in +x:

| slant | mesh nodes | projected nodes | expected | ratio | edges | verdict |
|-------|-----------|-----------------|----------|-------|-------|---------|
| 0 m   | 245 | 49  | 49 | 1.0× | 84  | OK |
| 5 m   | 245 | 245 | 49 | 5.0× | 336 | **DEGRADED** |
| 50 m  | 245 | 245 | 49 | 5.0× | 336 | **DEGRADED** |

At 5 m of tilt on a 100 m cell, *nothing collapses*: the ratio is exactly `nz+1`, i.e. every node
in every layer becomes its own projected node, and the edge count quadruples. **No exception is
raised** — the caller receives a plausible-looking `ProjectedTopology` that is not a plan view.

Norne measured: **7 of 5,311 pillars are vertical (0.1%)**; median lateral drift 62.6 m, mean 84.4 m,
max 675.1 m; 5,294 pillars drift more than 1 m.

Consequence: the whole existing 2.5D chain (`projected_topology → ProjectedGraph → project_polyline
→ stitch_path → path_to_faults`) is silently wrong on essentially every real deck. This is a
**pre-existing defect**, independent of this feature.

→ **D20**: the deformation bypasses plan view entirely and reads the pillar lattice from `coord`.
This removes the F8 scope limit rather than working around it, and unifies stage 1 with stage 2.
Note honestly: D13's regenerated `FAULTS` block still goes through `path_to_faults`, so it inherits
this pre-existing limitation until F12 is fixed upstream.

### F13 — Norne cannot currently be ingested, and the cause is F6 in the wild
`build_topology` raises `RuntimeError: face 40459 has more than 2 neighbours`.

Measured cause on the same deck: **10,912 of 113,344 cells (9.6%) have fewer than 8 distinct corner
node ids** — 1,137 with 7, 1,115 with 6, 286 with 5 — plus 8,374 pinched cells. Faces are deduped by
their sorted 4-node-id set, so once coordinate dedup (`np.round(xyz·1e9)`) welds coincident corners,
two geometrically distinct faces collapse onto one node set and that face acquires a third neighbour.

So F6's weld hazard is not a theoretical risk introduced by deformation — it **already occurs** on
the reference deck. This raises the priority of the D18 separation guard from "nice" to "load-bearing".

### F14 — the smoothness term as first specified had no valid limit (D6 corrected → D15)
`w·Σ‖L(x)‖²` alone is minimised by *any* harmonic field; the original grid is harmonic only on a
perfectly regular lattice. So `w→∞` does not return the original grid, no known-good bracket exists
for bisection, and — worse — the term actively homogenises deliberate grid grading wherever it acts.

Corrected to penalise the **change** in differential coordinates, `w·Σ‖L(x)_j − L(x⁰)_j‖²`. Now
`w→∞ ⇒ x = x⁰` exactly, which is fold-free by assumption, grading is preserved, and D16's bisection
provably terminates.

### F16 — "the boundary of the domain" is ambiguous on real decks, and the useful one is irregular
Norne measured: **44,928 / 113,344 active cells (39.6%)**; only **2,264 / 5,152 columns (43.9%)**
contain any active cell. The reservoir outline is a highly irregular shape well inside the
bounding box.

So the bounding-box edge (`i ∈ {0,NX}`, `j ∈ {0,NY}`) and the active-domain rim are different
objects, and only the latter is physically meaningful. Constraining the lattice edge on such a deck
pins pillars far outside the reservoir while leaving the real outline free.

→ **D23/D24**: `boundary ∈ {slide, pinned, free}` (default `slide`) × `boundary_scope ∈
{active, lattice}` (default `active`). `slide` blocks motion NORMAL to the rim while allowing
motion ALONG it — the outline is preserved as a polygon, yet a fault meeting the boundary can still
reach distance 0 at the intersection. Without it, a boundary-terminating fault reproduces the D10
rim problem at the domain edge, where D7 pays for it.

Detection needs no topology (consistent with D20): lattice is an index test; active is
"adjacent to an inactive column". All three modes are Dirichlet elimination and keep the system SPD
— `pinned` removes both DOFs, `slide` removes the normal DOF only, `free` removes none.

### F15 — the system is far smaller than the grid, and independent of NZ
Norne: 113,344 cells but only `47 × 113 = 5,311` pillars → **10,622 unknowns** (x, y per pillar), a
21.3× reduction. Crucially the count does **not** depend on NZ, because a pillar spans all layers.
Timings: `read_grdecl` 0.72 s, `from_grdecl` 0.44 s. A direct sparse solve at this size is sub-second.

---

## Open Questions

**None.** All seven questions from round 1 are closed by D15–D22 (see `phases/study/_decisions.md`,
ADR-002). Summary of resolutions:

| # | Question | Resolution |
|---|----------|-----------|
| Q1 | Fold-repair strategy | **D16** — bisection on `w`, bracketed by the corrected smoothness term (D15); optional local damping pass after. Provably terminating. |
| Q2 | Scale-invariance of `w` | **D17** — solve in dimensionless displacement `u = Δx/h_local`; divide each sum by term count. Default `w₀ = 0.3`. |
| Q3 | Minimum pillar separation | **D18** — hard floor `1e-9` (weld point, F6); practical default 0.10 × original spacing as a quality guard. |
| Q4 | Taper width `d` | **D19** — in cells, default 3, converted per pillar via local spacing. |
| Q5 | Stage-2 route | **D20** — bypass plan view; read the pillar lattice from `coord`. Grounded in F12. |
| Q6 | Test decks | **D21** — Norne primary (`opm-tests/norne`, 46×112×22, 64 faults / 984 records) + 12 `cpg2python/tests/fixtures/*.grdecl`. Prerequisite: F13. |
| Q7 | Performance target | **D22** — `spsolve` by default; CG only beyond ~200k unknowns. Norne is 10,622. |

## Prerequisites surfaced by this study (not part of the feature, but blocking full validation)

| # | Item | Effect if unfixed |
|---|------|-------------------|
| P1 | `build_topology` fails on decks with welded corners (F13) | Norne cannot be used end-to-end; validation limited to fixtures + synthetics |
| P2 | `projected_topology` silently wrong on slanted pillars (F12) | D13's regenerated `FAULTS` inherits the defect on real decks |
| P3 | `resfo` not installed in this environment | `import cpg2unstructured` fails outright (declared hard dep, not a library defect) |

The deformation engine itself (D20) depends on **neither** P1 nor P2 — it reads `coord` directly.
Both prerequisites bite only the FAULTS-regeneration path and end-to-end Norne validation.

## Sources

- Source read, shadow-indexed (12 files): `fault-projections` — `projection.py`, `graph.py`,
  `stitch.py`, `polygon.py`, `faceting.py`, `faults.py`, `surface.py`; `cpg2python` —
  `planview.py`, `corner_point.py`, `cpg.py`, `geometry.py`, `graph.py`.
- Read for context, not shadow-indexed: `grdecl_reader.py`, `egrid_reader.py` (MAPAXES),
  `unstructured.py` (structure), `mesh3d.py` (signatures), `index_map.py`, `polylines.py`,
  both `__init__.py`, both `README.md`.
- Owner interview, 2026-07-28 → 14 decisions, recorded in `phases/study/_decisions.md` (ADR-001).
- Code graphs: `graph/graph.json` (422 nodes / 834 links), `graph/cpg2python.json` (808 / 1923).
