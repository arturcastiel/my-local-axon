# PR list — 1-design

> 13 PRs across 6 waves. Each row: `[PR-N] title — files — acceptance one-liner`.
> Detailed specs land via `code-dev pr [N]`.

## Wave 1 — Skeleton + smoke

### PR-1 — Repo skeleton + packaging
- Files: `pyproject.toml`, `cpg2unstructure/__init__.py`, `tests/__init__.py`, `README.md` stub, `.gitignore`, `LICENSE` (MIT)
- Hard deps: `numpy`. Extras: `fast = ["scipy"]`. Dev: `pytest`.
- Acceptance: `pip install -e .[dev]` works; `pytest` runs (zero tests yet, exit 0); `import cpg2unstructure` works.
- LOC budget: ~50

### PR-2 — Toy cartesian smoke pipeline
- Files: `cpg2unstructure/_toy.py`, `tests/test_toy.py`
- Hand-build a 2×2×2 cartesian CPG in numpy (synthetic COORD/ZCORN). Build nodes, faces, cells, neighbours via the simplest possible numpy code (~80 LOC). Assert: 27 nodes, 36 faces (8 inner + 28 boundary), 8 cells, each inner cell has 6 face-neighbours.
- Acceptance: `test_toy.py` passes; serves as integration target for later PRs.
- LOC budget: ~150

## Wave 2 — Real parser

### PR-3 — `grdecl_reader.py` core (DIMENS + COORD + ZCORN + ACTNUM)
- Files: `cpg2unstructure/grdecl_reader.py`, `tests/test_grdecl_reader.py`, `tests/fixtures/simple_2x2x2.grdecl`, `tests/fixtures/simple_3x3x2.grdecl`
- Implements Eclipse keyword tokenizer with `--` comments, `N*VALUE` run-length, `/` terminators. Dispatch table for SPECGRID/DIMENS, COORD, ZCORN, ACTNUM. Returns `Grdecl` dataclass.
- Acceptance: Both fixtures parse to expected shapes; round-trip `cart_dims`, `coord.shape == (n_pillars, 6)`, `zcorn.shape == (8*nx*ny*nz,)`; unrecognized list contains expected skipped keywords.
- LOC budget: ~150

### PR-4 — Parser INCLUDE + property pass-through
- Files: extend `grdecl_reader.py`, add `tests/fixtures/with_include/main.grdecl` + `included.grdecl`
- INCLUDE recursion with relative-path resolution. Pass-through for PORO, PERMX/Y/Z, NTG, SATNUM (just slurp into `props: dict[str, np.ndarray]`).
- Acceptance: INCLUDE fixture parses identically to flat equivalent; PORO array length == nx*ny*nz.
- LOC budget: ~80

## Wave 3 — Real CPG → unstructured

### PR-5 — Corner-cube assembly + node deduplication
- Files: `cpg2unstructure/cpg.py`, `tests/test_cpg.py`
- Build the `(2nx, 2ny, 2nz, 3)` X/Y/Z corner cube from COORD (linearly interpolate along each pillar at the Z given by ZCORN) and ZCORN. `np.unique(stacked_xyz, axis=0, return_inverse=True)` gives unique nodes + back-map `P` of shape `(2nx, 2ny, 2nz)`.
- Acceptance: 2×2×2 cartesian fixture → 27 unique nodes; `P` indexes are right-handed per MRST convention; ACTNUM=0 cells excluded from node generation.
- LOC budget: ~100

### PR-6 — `find_i_faces` + `find_j_faces` (regular, matching-Z)
- Files: `cpg2unstructure/unstructured.py` (start), extend `tests/test_cpg.py`
- Stride-slice corner-quad pairs across the i-direction; assert `np.all(face_a == face_b, axis=-1)` (matching-Z guarantee). On violation → raise `NonMatchingZError("v2 only")`. Same for j.
- Acceptance: 2×2×2 → 4 inner i-faces + 4 inner j-faces; cell pair lists are correct; mismatched-Z fixture raises cleanly.
- LOC budget: ~120

### PR-7 — `find_k_faces` + cell-face inversion
- Files: extend `unstructured.py`, extend tests
- k-direction face deduplication via numpy `np.diff` over `(i,j,:)` stacks (the rlencode equivalent). Build `cells.faces` by inverting `faces.neighbours`. Filter inactive + zero-volume cells; rebuild contiguous cell IDs.
- Acceptance: 2×2×2 → 4 inner k-faces; total inner faces = 12; total faces = 36; cells.faces has 6 entries per inner cell.
- LOC budget: ~140

## Wave 4 — Geometry + index map

### PR-8 — `geometry.py` (centroids, areas, volumes)
- Files: `cpg2unstructure/geometry.py`, `tests/test_geometry.py`
- Face centroid = mean of face nodes (handle 3- or 4-node faces). Face area via cross-product split-into-triangles. Cell volume via divergence theorem `(1/6) Σ x · (n × A)`.
- Acceptance: Unit-cube cell → volume 1.0 ± 1e-12; face area 1.0; centroid (0.5,0.5,0.5).
- LOC budget: ~100

### PR-9 — `index_map.py` (active-id ↔ (i,j,k))
- Files: `cpg2unstructure/index_map.py`, `tests/test_index_map.py`
- `IndexMap` class: `linear_to_cell: np.ndarray (n_active,)` storing `i + j*nx + k*nx*ny` (mirrors MRST's `G.cells.indexMap`); reverse `cell_to_active: dict | sparse` lazily built. Methods: `cell_ijk(active_id) -> (i,j,k)`, `active_id(i,j,k) -> int | None`.
- Acceptance: random ACTNUM round-trip — for every active cell, `active_id(*cell_ijk(a)) == a`; inactive cells return None.
- LOC budget: ~80

## Wave 5 — Graph layer

### PR-10 — `graph.py` adjacency (numpy-only default)
- Files: `cpg2unstructure/graph.py`, `tests/test_graph.py`
- `UnstructuredGrid.graph(weights="unit"|"distance"|None)` returns `dict[int, list[tuple[int, float]]]` adjacency. Inner faces only (both neighbours nonzero). Distance weight = `‖centroid_i − centroid_j‖₂`.
- Acceptance: 2×2×2 graph has 8 nodes, 12 edges (each inner face contributes one edge); Dijkstra from corner-cell to opposite-corner returns shortest path of 3 hops.
- LOC budget: ~80

### PR-11 — Optional `[fast]` scipy CSR + Dijkstra
- Files: extend `graph.py`, `tests/test_graph_fast.py` (skip if scipy absent)
- `grid.csgraph()` returns `scipy.sparse.csr_array` with weights; convenience `grid.shortest_path(src, dst)` uses `scipy.sparse.csgraph.dijkstra` if scipy available, else the dict + heapq fallback. Identical results.
- Acceptance: shortest path on 10×10×5 grid matches between fast and slow paths (numpy_allclose on distance vector).
- LOC budget: ~80

## Wave 6 — Polish

### PR-12 — Property pass-through hook
- Files: extend `unstructured.py`, `tests/test_props.py`
- `UnstructuredGrid.props: dict[str, np.ndarray]` filtered to active cells in correct order via `IndexMap`. Read-only convenience accessor `grid["PORO"] -> ndarray`.
- Acceptance: PORO from fixture round-trips correctly; length == n_active.
- LOC budget: ~50

### PR-13 — README, example, CHANGELOG, version 0.1.0
- Files: `README.md`, `examples/load_norne.py` (or smaller fixture), `CHANGELOG.md`, version bump in `pyproject.toml`.
- README: 30-second quickstart, full API, deps explanation.
- Acceptance: example runs from `examples/`; `pip install cpg2unstructure==0.1.0` from local sdist works.
- LOC budget: ~80

## Total budget

- Core LOC: ~1,260 across PR code + tests (tests are ~40% of that)
- 13 PRs × ~95 LOC mean
- All PRs sized for single-sitting human review

## Gating dependencies

```
PR-1 ──┬─► PR-2 ──┐
       │          │
       │          ├─► PR-5 ─► PR-6 ─► PR-7 ─► PR-8 ─► PR-9 ─┐
       │          │                                          │
       └─► PR-3 ──┴─► PR-4                                   │
                                                             ├─► PR-10 ─► PR-11 ─┐
                                                             │                    │
                                                             └─► PR-12 ───────────┴─► PR-13
```

## Open decisions deferred to PRs

- **D-01** (PR-3): `dataclass` vs plain dict for `Grdecl` → recommend `@dataclass(frozen=True)` for type-checker support.
- **D-02** (PR-9): `cell_to_active` reverse map — eager dict (memory) vs sparse lookup (cpu) → recommend lazy property.
- **D-03** (PR-10): graph as `dict[int, list[tuple]]` vs `list[list[tuple]]` indexed by id → recommend list-of-list (faster, ids are contiguous).
