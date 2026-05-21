# Study — 1-design

## Goal (verbatim)

Lightweight Python — minimum libraries — that:

1. Reads CPG (Corner-Point Geometry) grids: `COORD` + `ZCORN`, faulted
   or unfaulted, with **matching Z-coords on fault sides** (no pillar-side
   mismatch).
2. Transforms to a fully unstructured mesh (explicit nodes, faces, cells).
3. Builds a graph representation for downstream shortest-path algorithms.
4. Maintains a bidirectional **(i,j,k) ↔ unstructured-cell-id** map.
5. Modular, organized, light.

## MATLAB reference — the existing pipeline

Located in `C:\projects\darsim\darsim-release`. Three layers, top to bottom:

### Layer 1 — `unstructured_grid.m` (DARSim discretization)
- 98 LOC. Wraps `MeshCore`. Builds `Neighbours = [upstream downstream]`
  from `mesh.face.inner` and a sparse `ConnectivityMatrix`.
- **This is the graph the user wants** — inner-face cell-pair list.
  Everything else (transmissibilities, pEDFM, heat conductivity) is
  reservoir-simulation noise we drop.

### Layer 2 — `MeshCore.m` (DARSim mesh wrapper, 240 LOC)
- Constructs from either an MRST `G` struct or a `.grdecl` path.
- Calls `readGRDECL → convertInputUnits → processGRDECL → grdecl2Rock`.
- Calls `computeGeometry(G)` for areas/volumes/centroids/normals.
- Decompresses MRST's compressed-row storage into explicit:
  - `cells.element_faces_bool`, `element_nodes_bool`
  - `faces.face_nodes`, `face_neigh`, `normals`, `areas`, `centroid`,
    `bound_faces`
  - `nodes.coords`
  - `edges.edges_node`, `faces.faces_edges` (3D only)
  - `cells.indexMap` ← **the (i,j,k)→cell map already exists in MRST**

### Layer 3 — MRST routines (the heavy lift)
- `readGRDECL.m` — parses Eclipse `.grdecl` into a struct.
- `processGRDECL.m` — **1343 LOC.** Pillar-walking, ZCORN unique-node
  generation, fault face detection, neighbour assembly. **This is the
  algorithm we must port faithfully (or replace with a leaner equivalent).**
- `computeCpGeometry.m` — 190 LOC. Geometry only — drop or replace with
  a 30-line numpy version (centroids = mean of face nodes, areas =
  cross-product half-sum, volumes = divergence theorem).

## What MRST already gives us

The hard problem of producing the map is **already solved in MRST** as
`G.cells.indexMap`: a vector mapping active unstructured cell-id → linear
`sub2ind(cartDims, i, j, k)`. The reverse is a one-liner with `ind2sub`.
So our Python port preserves this contract: a `numpy.ndarray` of length
`n_active` storing `i + j*nx + k*nx*ny`. Reverse lookup builds a dict on
demand.

## Lightweight Python target (proposed module map)

```
cpg2unstructure/
├── __init__.py            # public API: load_cpg, UnstructuredGrid
├── grdecl_reader.py       # parse .grdecl → {COORD, ZCORN, ACTNUM, DIMENS, props}
├── cpg.py                 # CornerPointGrid: structured CPG state
├── unstructured.py        # UnstructuredGrid: nodes, faces, cells, neighbours
├── geometry.py            # centroids, areas, volumes (numpy only)
├── index_map.py           # (i,j,k) ↔ active-cell-id, bidirectional
├── graph.py               # adjacency list / CSR from inner-face neighbours
└── tests/                 # round-trip, fault, index-map tests
```

**Hard dependency: `numpy` only.**
**Conditional: `scipy.sparse` only if user wants CSR graph; else dict-of-list.**
No `xtgeo`, no `meshio`, no `pyvista`, no `opm-grid`, no `ecl`. Each was
considered and rejected: each pulls 50–500 MB of transitive deps.

## Pipeline (lean equivalent of MeshCore + processGRDECL)

```
load_cpg(path) →
  1. parse_grdecl(path)         → COORD[6*nx*ny], ZCORN[8*nx*ny*nz], ACTNUM
  2. build_pillar_nodes()       → unique 3D points along each pillar
                                  (matching-Z assumption → cheap dedup
                                   per pillar by sorted-Z + tolerance)
  3. build_cells()              → 8 corner-node ids per cell (active only)
  4. build_faces()              → 6 candidate quads per cell, dedup by
                                  sorted-node-tuple → inner faces emerge
                                  with neighbour pairs naturally
  5. build_index_map()          → active_id ↔ (i,j,k)
  6. compute_geometry()         → centroids, areas, volumes (numpy)
  7. wrap UnstructuredGrid object
```

`grid.graph()` → adjacency from `faces.neighbours` rows where both sides
nonzero (= inner faces). Optional weights = `‖c_i − c_j‖₂`.

## What we are NOT porting (drop list)

- `MeshCore.edges` — generate-edges machinery only used for plotting / FEM.
- `pEDFM_alpha_T`, `condTrans` — reservoir transmissibility, irrelevant.
- `processing_input` MATLAB inputParser — replace with simple kwargs.
- `convertInputUnits` — input is assumed already in metric; trivial scalar mul if needed.
- `grdecl2Rock` — only needed if user wants PORO/PERM passed through. Optional add-on, gated by user.
- `face_nodes_bool` / `element_faces_bool` sparse boolean cell↔face↔node
  matrices — cute but redundant when we already store explicit
  `cell_faces[cell_id]` and `face_nodes[face_id]` Python lists.

## Open questions resolved

- **Q1 input format** → `.grdecl` (Eclipse keyword text). `.EGRID` not in
  this phase.
- **Q2 MATLAB structure** → studied above; `processGRDECL` is the only
  algorithmic body that needs careful porting.
- **Q3 graph semantics** → cell-to-cell adjacency over inner faces;
  optional centroid-distance weights. Active cells only (ACTNUM=1).
  Restrict-set support deferred.
- **Q4 properties** → out-of-scope for v1; add a thin pass-through later.
- **Q5 output sink** → in-memory Python objects; serialization deferred.

## Risk register

| Risk | Mitigation |
|------|------------|
| `processGRDECL.m` has edge cases for degenerate cells (pinch-outs, zero-thickness layers) | Mirror its `tagCollapsedColumns`/pinch logic; add tests with `pinchedLayersGrdecl.m` testgrid |
| Faulted-but-matching-Z still produces split nodes when X/Y differ across pillars | Dedup nodes globally by (x,y,z) tuple with tolerance, not per-pillar |
| Floating-point comparison for "matching Z" | Use `np.isclose` with documented `rtol/atol`; expose as kwarg |
| MRST orientation conventions (face normal direction, cell-face sign) | Replicate MRST's swap-rule when neighbour[0]==0 (already in `retrieve_face_neigh_normal`) |

## Status
Study complete. Ready to graduate to `code-dev plan`.

---

## Addendum — `processGRDECL.m` LOC dissection

After reading the full 1343 LOC, the algorithm decomposes into **two tiers**:

### Tier A — always required (~470 LOC of MATLAB)

| Lines | Function | What it does | Port effort |
|------:|----------|--------------|-------------|
| 1–330 | `processGRDECL` (main) | Orchestration: build coords → process i-faces → process j-faces → process k-faces → build cell-faces → cleanup | ~80 lines numpy |
| 338–420 | `build_coordinates` | Reshape ZCORN/COORD into (X,Y,Z) corner arrays of shape `(2nx, 2ny, 2nz)`; add 1-cell auxiliary top/bottom layer; right-handed check | ~50 lines numpy |
| 441–469 | `create_initial_grid` | `unique([Z Y X])` to dedupe corner points → `nodes.coords` + back-mapping `P` (point indices for each cell corner) | ~15 lines numpy (`np.unique(..., axis=0, return_inverse=True)`) |
| 524–548 | `buildCellFaces` | From `faces.neighbors`, build `cells.facePos` + `cells.faces` via sort | ~20 lines numpy |
| 552–695 | `findFaces` | **The core regular-face routine.** For each pillar-pair, check if 4-point face on side A == side B → if yes, emit one face shared between two cells; collect boundary faces; filter degenerate/pinched | ~80 lines numpy |
| 699–733 | `findVerticalFaces` | k-direction faces via `rlencode` on stacks of corner points (collapses pinch-outs to NNCs) | ~30 lines numpy |

### Tier B — only fires on **non-matching-Z faults** (~440 LOC, NOT NEEDED for v1)

| Lines | Function | What it does |
|------:|----------|--------------|
| 737–899 | `findFaults` | Detects fault-stacks where `all(a==b)` fails; calls `findConnections` to compute geometric overlap between mismatched face stacks; appends synthesized cell-cell pairs |
| 903–1212 | `computeFaceGeometry` | Computes new node coordinates at fault-face intersection points (line-line intersections in 3D) |
| 1214–1241 | `intersection` | Ray-pillar intersection helper |
| 1244–1297 | `findConnections` | Z-overlap detector for two stacks of fault-face Z-coords |
| 1301–1336 | `doIntersect` / `overlap` | 1-D Z-interval overlap predicates |

**This is the entire matching-Z payoff.** Because with matching Z:
- In `findFaults`, the test `all(a==b, 2)` succeeds for every cell pair on the pillar-pair (since corner indices match → all node IDs match too).
- The "kept" set `~h(:)` becomes empty → all subsequent code (lines 836–898) operates on empty arrays → no-op.
- The regular `findFaces` path handles everything.

**Hard implication:** our Python port of Tier A handles the user's case
end-to-end. Tier B is a `# v2` placeholder — a clearly-marked
`raise NotImplementedError("non-matching-Z faults: deferred to v2")`
guard at the entry of fault detection.

## Total LOC budget (revised)

| Module | Est. LOC | Purpose |
|--------|---------:|---------|
| `grdecl_reader.py` | ~120 | Tokenize Eclipse keywords; parse SPECGRID, COORD, ZCORN, ACTNUM |
| `cpg.py` | ~80 | Hold raw CPG arrays; build `(X,Y,Z)` corner cube and node-dedup `P` |
| `unstructured.py` | ~150 | i-faces + j-faces + k-faces builders; cell-face assembly; matching-Z fault guard |
| `geometry.py` | ~60 | Centroids, areas (cross-product), volumes (divergence) |
| `index_map.py` | ~40 | active-id ↔ (i,j,k) bidirectional |
| `graph.py` | ~50 | Adjacency from inner-face neighbours; optional weights |
| `__init__.py` | ~30 | Public API |
| **Total core** | **~530** | vs. 1343 LOC MATLAB — **~60% reduction** |
| `tests/` | ~300 | Cartesian round-trip, single-fault matching-Z, pinch-out, index-map invariants |

The 60% shrink comes from: (a) dropping Tier B, (b) numpy vectorization
replaces MATLAB sparse-matrix tricks, (c) no MATLAB-specific input
handling (inputParser, varargin), (d) no MRST-isms (rlencode/rldecode
become a 5-line helper), (e) no auxiliary-layer hack (we filter inactive
cells directly without padding).

## Algorithmic skeleton — the matching-Z `findFaces` in numpy (sketch)

```python
def find_i_faces(P, B, actnum, nx, ny, nz):
    # P shape: (2nx, 2ny, 2nz), corner-point indices into nodes.coords
    # B shape: (nx, ny, nz), linear cell numbers
    #
    # face quad on the "east" side of cell (i,j,k) uses P at:
    #   (2i, 2j-1, 2k-1), (2i, 2j, 2k-1), (2i, 2j, 2k), (2i, 2j-1, 2k)
    # face quad on the "west" side of cell (i+1,j,k) uses P at:
    #   (2(i+1)-1, 2j-1, 2k-1) == (2i+1, 2j-1, 2k-1), etc.
    f_east = np.stack([P[2:2*nx:2, 0:2*ny:2, 0:2*nz:2],   # n1
                       P[2:2*nx:2, 1:2*ny:2, 0:2*nz:2],   # n2
                       P[2:2*nx:2, 1:2*ny:2, 1:2*nz:2],   # n3
                       P[2:2*nx:2, 0:2*ny:2, 1:2*nz:2]],  # n4
                      axis=-1)
    f_west = np.stack([P[3:2*nx+1:2, 0:2*ny:2, 0:2*nz:2],
                       ...], axis=-1)
    match = np.all(f_east == f_west, axis=-1)  # shape (nx-1, ny, nz)
    # all_match=True means a single shared face → emit (c1,c2)
    # all_match=False means faulted stack → matching-Z guarantees
    #     it actually IS True; if not → raise NotImplementedError
    if not match.all():
        raise NotImplementedError("non-matching-Z fault detected; v2 only")
    c1 = B[:nx-1, :, :][match]
    c2 = B[1:nx, :, :][match]
    quads = f_east[match]  # (n_inner_faces, 4) node-id arrays
    return quads, c1, c2
```

Same pattern for j-faces (transpose) and k-faces (rlencode-equivalent).

## Decision: scipy.sparse — yes or no?

For the **graph** layer:
- dict-of-list adjacency: 0 deps, fine for ≤ 10⁶ cells, slow Dijkstra in pure Python.
- `scipy.sparse.csgraph` (Dijkstra in C, milliseconds on 10⁷ edges): adds scipy (~30 MB).

**Recommendation:** make scipy optional. Default graph is dict-of-list +
stdlib `heapq` Dijkstra. Add `grid.csgraph()` returning a CSR if scipy
is installed. User picks at install time: `pip install cpg2unstructure`
vs. `pip install cpg2unstructure[fast]`.

---

## Addendum 2 — `readGRDECL.m` parser spec (308 LOC)

The MRST parser is small and clean; the **format spec** drives what we
need to reproduce. Copying it verbatim from the MATLAB source:

### Eclipse `.grdecl` syntax (subset relevant to CPG)

- File is **line-oriented**, keyword-driven.
- A **keyword** matches regex `^[A-Z][A-Z0-9]{0,7}` (1–8 uppercase chars).
- After the keyword, **values follow on subsequent lines** until `/`
  terminator.
- **Comments**: `--` to end of line (MRST regex doesn't show this
  explicitly but Eclipse standard; verify with test files).
- **Run-length encoding**: `N*VALUE` means N copies of VALUE
  (e.g. `12000*1.0`). Handled by `readVector` helper.

### Keywords we MUST handle for CPG

| Keyword | Count | Type | Field |
|---------|-------|------|-------|
| `SPECGRID` or `DIMENS` | 3 ints (+trash) | dims | `cartDims = [NX, NY, NZ]` |
| `COORD` | `6 * (NX+1) * (NY+1)` floats | pillar lines | top (x,y,z) + bottom (x,y,z) per pillar |
| `ZCORN` | `8 * NX * NY * NZ` floats | corner depths | 8 corners per cell, k-fastest |
| `ACTNUM` | `NX * NY * NZ` ints | active flags | 0=inactive, 1=active |
| `INCLUDE` | filename | recurse | resolve relative to current file |

### Keywords we OPTIONALLY pass through (v2 properties)

`PORO`, `PERMX`, `PERMY`, `PERMZ`, `PERMXY`, `PERMXZ`, `PERMYZ`,
`PERMYX`, `PERMZX`, `PERMZY`, `PERMH`, `NTG`, `SATNUM`, `ROCKTYPE`,
`MULTX[-]`, `MULTY[-]`, `MULTZ[-]`. All are `NX*NY*NZ`-sized arrays;
trivial to read with the same `readVector`.

### Keywords we SKIP for v1

`MAPAXES`, `MAPUNITS`, `GRIDUNIT`, `GDORIENT`, `FAULTS`, `MULTFLT`,
`DXV/DYV/DZV` (alternate cartesian spec — not CPG), `DEPTHZ`,
`ADD/COPY/EQUALS/MAXVALUE/MINVALUE/MULTIPLY` (post-processing operators).
Collect names in `unrecognized: list[str]` for diagnostics.

### Memory cost (real reservoir scales)

For Norne (~46 × 112 × 22 ≈ 113 k cells):
- COORD: `6 * 47 * 113 * 8 bytes = 255 KB`
- ZCORN: `8 * 113344 * 8 = 7.1 MB`
- ACTNUM: `113344 * 4 = 442 KB`

Total raw input: ~8 MB. Decoded grid (nodes, faces, cells): a few × that.
Trivial for any modern machine — no streaming required, mmap not needed.

### Python parser plan (`grdecl_reader.py`, target ~120 LOC)

```python
def read_grdecl(path: str | Path) -> Grdecl:
    """
    Returns a dataclass with:
        cart_dims: tuple[int, int, int]
        coord:     np.ndarray  # shape (n_pillars, 6) float64
        zcorn:     np.ndarray  # shape (8 * nx * ny * nz,) float64
        actnum:    np.ndarray | None  # shape (nx*ny*nz,) int8
        props:     dict[str, np.ndarray]  # PORO/PERM*/etc. if present
        unrecognized: list[str]
    """
```

Key implementation details:
- Hand-rolled tokenizer: `for line in file: strip comments; split tokens`.
- One keyword dispatch table: `dict[str, Callable]`.
- `_read_vector(tokens_iter, expected_n)` handles `N*VALUE` expansion.
- `INCLUDE` recursion: resolve relative path, parse same way, merge into
  parent grdecl.
- Validation: assert lengths match `cart_dims`-derived expected counts.
- **No regex except for the keyword-pattern check.** Everything else is
  string `.startswith()` / `.split()`.

## Final algorithmic complete picture

```
.grdecl file
    │
    ▼
[read_grdecl]  ──────  ~120 LOC ── stdlib + numpy
    │ Grdecl(cart_dims, coord, zcorn, actnum, props)
    ▼
[build_corner_cube]  ──── ~30 LOC ── ZCORN reshaped to (2nx, 2ny, 2nz);
    │                                COORD interpolated along Z to give
    │                                X,Y at each corner depth
    ▼
[unique_nodes]  ──────── ~10 LOC ── np.unique(stacked, axis=0,
    │ nodes.coords, P                  return_inverse=True)
    ▼
[find_i_faces]  ──────── ~40 LOC ── stride-slice the 8-corner quads;
[find_j_faces]                       np.all(face_a == face_b, axis=-1);
[find_k_faces]                       guard: NotImplementedError if
    │ face_nodes, neighbours          matching-Z assumption violated
    ▼
[build_cell_faces]  ──── ~25 LOC ── invert neighbours → cells.faces
    │
    ▼
[remove_inactive_pinched]  ~30 LOC ── filter ACTNUM==0 + zero-volume
    │                                  cells; rebuild index_map
    ▼
[geometry]  ──────────── ~60 LOC ── centroids, areas, volumes (numpy)
    │
    ▼
UnstructuredGrid object
    │ .graph()  → adjacency dict (or scipy CSR via .csgraph())
    │ .cell_ijk(new_id) / .cell_id(i,j,k)
    └─────────────────────────────────────
```

## Status
Study complete with full Tier-A LOC breakdown and parser spec.
**Ready to graduate to `code-dev plan`.**
