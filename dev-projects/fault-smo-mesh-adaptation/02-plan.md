# High-Level Plan — Fault SMO Mesh Adaptation
Updated: 2026-07-28 · Iterations: 1 · AXON: 9/10 · User: pending
Mode: tactical · PRs: 15 · Basis: 01-study.md (16 findings) + ADR-001/002/003 (23 decisions)

## Context (from Phase 1)

**Goal.** Make the corner-point grid adapt to the true fault trace instead of approximating it with
a staircase of cell faces. For each polyline segment, the pillars in that segment's projected set
are driven toward the segment line — minimising distance, target 0 — subject to the mesh remaining
valid. Output is an Eclipse `INCLUDE` deck plus a regenerated `FAULTS` block.

**Two stages.** Stage 1 moves a pillar's top and bottom `(x,y)` by the same delta (any pre-existing
slant preserved). Stage 2 moves them independently, so the pillar tilts and the fault dips.

## Architecture Overview

Two GPL-3.0 Python libraries, sibling checkouts, `fault-projections` depending on `cpg2python`:

```
cpg2python (cpg2unstructured)              fault-projections
────────────────────────────               ─────────────────
 deck I/O    grdecl_reader, egrid_reader    inputs    polylines, polygon (Polygon3D)
 geometry    corner_point, cpg, geometry    projection projection, stitch, graph
 topology    unstructured, mesh3d, planview surfaces  surface, quad_surface, faceting
 queries     graph, minimal_surface         output    faults (FAULTS deck), vtk, viz
```

The feature adds a **deformation stage** between projection and output, split by D12 so that the
numerics are fault-agnostic and reusable:

```
NEW in cpg2python (fault-agnostic)          NEW in fault-projections (fault semantics)
──────────────────────────────────          ─────────────────────────────────────────
 pillars.py   lattice accessors,             targets.py   targets_from_polyline  (stage 1)
              boundary masks                              targets_from_polygon   (stage 2)
 validity.py  fold detection, separation                  rim taper weighting
 morph.py     least-squares solve,           projection.py  (EDIT) carry segment ids
              bisection repair
 grdecl_writer.py  INCLUDE-deck writer
```

## Implementation Approach

### The solve (D6 as corrected by D15, D17)

Unknowns are pillar displacements on the `(NX+1)×(NY+1)` lattice read **directly from `coord`** —
never through `projected_topology`, which F12 proves is silently wrong on slanted pillars, and
Norne is 99.9% slanted. This is what lets stage 1 and stage 2 share one mechanism.

Solving in dimensionless displacement `u = Δx / h_local`, with each sum divided by its term count
so `w` compares mean residuals and transfers between decks:

```
min_u   (1/N_f) Σ_(p,s) ‖u_p − û_(p,s)‖²   +   w · (1/N_p) Σ_j ‖L(u)_j − L(u⁰)_j‖²
        └── one term per (pillar, segment) ──┘   └── CHANGE in differential coords ──┘
                    incidence (D11)                        (D15 — not ‖L(u)‖²)
```

`L` is the 5-point Laplacian on the pillar lattice — no adjacency structure is built (F4). The
system is sparse, symmetric positive definite, and small: Norne is 10,622 unknowns, independent of
NZ (F15), so `spsolve` is sub-second and CG is unnecessary below ~200k (D22).

Penalising the *change* in differential coordinates rather than their magnitude is what makes
`w → ∞ ⇒ u = 0` exactly — giving bisection a provably valid upper bracket — and it preserves
deliberate grid grading instead of homogenising it (F14).

### Validity (D7, D16, D18)

The hard constraint is that no cell may break. Least-squares cannot enforce it, so the solve is
wrapped: solve → detect → repair → re-solve, by **bisection on `w`** between `w₀` (max fidelity, may
fold) and `w_max` (≡ the original grid, fold-free by assumption). ~20 solves reach 1e-6.

Detection is the vectorised plan-view **signed-area sign flip** — for stage 1 a fold, a crossing edge
and an inverted cell are the same event. `cell_geometry` must not be used: it loops over cells in
Python (F7). Stage 2 adds the same test at both top and bottom planes plus a pillar-pair crossing
check over the vertical span.

Separately, a **minimum-separation guard** at 0.10 × original spacing. This is not defensive
programming: F13 shows welded corners already occur on Norne (9.6% of cells have <8 distinct corner
nodes), and `_QUANT = 1e9` sets the exact weld point at 1e-9.

### Boundary (D23, D24)

`boundary ∈ {slide, pinned, free}` (default `slide`) × `boundary_scope ∈ {active, lattice}`
(default `active`). All three are Dirichlet elimination and keep the system SPD — `pinned` removes
both DOFs, `slide` removes only the component normal to the rim, `free` removes none. The `active`
default matters because Norne's reservoir occupies 39.6% of its bounding box (F16).

### Output (D1, D13, D14)

Only the grid keywords are written, to a **separate `.grdecl` that the master deck `INCLUDE`s** —
never a whole-deck rewrite, because the reader keeps unparsed keywords by name only and would
silently drop them (F2). `mapaxes_applied` must be honoured or the deck double-rotates.

The `FAULTS` block is regenerated and, per F10, **asserted equal** to the pre-deformation block:
the morph changes positions, not topology, so the face set is invariant. Any difference is a solver
bug caught in CI. The `ProjectedGraph` must be rebuilt for that check, never reused (F11).

## Scope boundaries

**In scope.** The deformation engine, the writer, stage-1 and stage-2 targets, curved faults via the
existing faceting path, and the boundary settings.

**Out of scope, but surfaced.** Two pre-existing upstream defects (P1, P2) that the engine does not
depend on — it reads `coord` directly — but which block end-to-end Norne validation and the
`FAULTS`-regeneration path. Planned as PR-013 and PR-014, independently mergeable, and the only PRs
here that fix behaviour predating this feature.

## Risks

| Risk | Mitigation |
|------|-----------|
| Bisection converges to heavy smoothing on a stubborn deck, i.e. little fault fidelity gained | Report achieved distance distribution per run; if `w` lands near `w_max`, surface it rather than silently shipping a barely-moved grid |
| Welded corners (F13) reappear post-morph even with the separation guard | The invariance test (F10) catches it — face set changes ⇒ fail |
| Stage-2 slant interacts with pinch-outs in ways the 2-plane check misses | PR-011 tests explicitly against `pinchout_*.grdecl` and `pinched_1x1x3.grdecl` fixtures |
| P1/P2 turn out deeper than estimated | They are isolated in phase 5 and block only Norne validation, not delivery of stages 1–2 |
