# Plan — 2-faults · mode: tactical

> Grounded in `01-study.md` (Tier-B LOC dissection across 7 MATLAB
> functions, dispatch story, algorithmic narratives including the
> 8-position J-table + 4 diamond cases, dZ artificial-offset trick).
> Decision: D-2F-1 (widen `find_*_faces` inline, single public entry
> per direction).
> Target: cpg2unstructured handles ANY CPG grid including faulted ones.
> Tier A regression budget: zero behavioural change on matching-Z decks.

## Strategy

**Bottom-up + Tier-A-invariant.** Start with the most isolated pure
pieces (`find_connections` is just 1D segment pairing — no geometry,
no Python code yet to integrate with) and work up to the
integration PRs that widen the existing `find_*_faces` functions.

Every PR after PR-4 produces something visually verifiable via the
`viz/` sidecar — the ghost-overlay shows fault faces correctly
"interlocking" between offset cells when the implementation is right,
or wrong-looking polygons when there's a bug.

The matching-Z fast path stays bit-identical: the widened
`find_*_faces` early-out on `faulted_pillar_mask.any() == False`,
running the same PR-6/PR-7 code as v0.1.0. Tier A regression must be
zero.

Each PR ends in green tests. No PR merges with red.

## Wave structure

| Wave | Theme | PRs | LOC est. |
|------|-------|----:|---:|
| 1 | Foundations: fixture + pure 1D pairing | PR-1, PR-2 | 130 | ✓ done
| 2 | Geometry: line intersection + face polygons | PR-3, PR-4 | 190 | ✓ done
| 3 | i-direction integration | PR-5, PR-6 | 110 | ✓ done
| 4 | j and k integration | PR-7, PR-8 | 70 | ✓ done
| 5 | Polish: regression + CI + larger fixtures | PR-9, PR-10 | 90 | PR-9 ✓ / PR-10 ☐
| 6 | PINCH NNCs (cross-layer non-neighbour conns) | PR-11, PR-12 | ~120 | ☐
| 7 | Disconnected-grid splitting (connected comps) | PR-13, PR-14 | ~90 | ☐
| 8 | v0.2.0 release (tag + GH release) | PR-15 | ~20 | ☐

**~15 PRs total (was 10; +5 for PINCH + disconnected-grid, scope added
2026-05-24). v0.2.0 ships at end of Wave 8 — release HELD until PINCH
and disconnected-grid land (user decision 2026-05-24: one bigger v0.2.0).**

Mean PR size: ~60 LOC (smaller than 1-design's ~165 — Tier B is more
algorithmic than Tier A, smaller blast radius per PR).

## Out of scope (per refined project goal 2026-05-22)

- Properties algebra / transmissibility helpers (NOT cpg2python's job)
- `.EGRID` binary format
- MAPAXES / coordinate transforms
- Visualization (handled by `viz/` sidecar, not as a release feature)

> **Scope change 2026-05-24** — PINCH NNCs and disconnected-grid
> splitting moved INTO scope for v0.2.0 (Waves 6 & 7). Both are pure
> grid topology/connectivity (NNCs = non-neighbour connections;
> splitting = connected components), consistent with the "represent
> ANY CPG grid" goal — not the cancelled properties/sim work.

## Wave gates

- **End of Wave 1** → fixture parses; faulted mask returns expected
  pattern on the 2×2×2 fixture; `find_connections` returns expected
  3 pairs on the worked example.
- **End of Wave 2** → `compute_face_geometry` builds correctly-ordered
  4-corner faces for the worked example; viz/ ghost-overlay used as
  golden eye-check.
- **End of Wave 3** → `find_i_faces` dispatches correctly: matching-Z
  fixtures unchanged, simple_faulted_2x2x2 produces 3 fault faces
  with normals A→B.
- **End of Wave 4** → `build_topology` runs end-to-end on a faulted
  deck without raising `NonMatchingZError`. j and k symmetric to i.
- **End of Wave 5** → larger faulted fixtures pass; viz/ produces
  visually correct side-by-side. (Release NO LONGER here — held.)
- **End of Wave 6** → PINCH deck parses; pinched-out (zero-thickness)
  cells are dropped and a cross-layer NNC connects the cells above and
  below; NNC fixture passes; viz shows the bridged connection.
- **End of Wave 7** → a 2-island deck splits into 2 independent
  UnstructuredGrids (or labelled components); single-component decks
  are unchanged (invariance); fixture passes.
- **End of Wave 8** → full faulted+pinched+multi-component suite green;
  viz golden checks pass; v0.2.0 tagged + GH release published.

## Decisions baked in

- **D-2F-1** (committed in `_decisions.md` + `01-study.md` §5):
  widen `find_*_faces` to dispatch matching vs faulted inline.
  Single public entry per direction. Bit-identical fast path
  preserved.
- Inherited from 1-design: Authoring pattern A (AXON writes source,
  HUMAN runs driver). Scripts default to --pr. viz/ sidecar used
  for visual verification.

## Risk register (from `01-study.md` §10)

- **R-1 (medium)** — `compute_face_geometry`'s 4-diamond-case branching.
  Mitigation: viz/ ghost-overlay verification at every PR from PR-4
  onwards + explicit normal-direction tests.
- **R-2 (low)** — dZ artificial-offset overflow on astronomically
  large decks. Mitigation: runtime assert `dz > z_extent` in PR-5.
- **R-3 (low)** — `intersection` helper fails on heavily-tilted
  pillars (Δz tiny). Mitigation: guard in PR-3, fall back to 3D
  intersection if violated.

## See also

- `01-study.md` — full Tier B dissection, algorithm narratives,
  risk register, port-plan implications table
- `_decisions.md` — D-2F-1 ADR with consequences + cascade
- `03-prs/pr-*.md` — per-PR specs (PR-1 lands first)
- `04-log.md` — phase progression history (project-level log)
