# Deviations from plan — 1-design

## DEV-01 — Spec drift sweep PR-11..PR-13 vs merged PR-3..PR-10 (2026-05-22)

**Scope.** Read-only audit of `pr-11.md`, `pr-12.md`, `pr-13.md` against
`origin/main` after PR-10 merged. Verified types/exports/fields against:
`cpg2unstructured/{__init__,unstructured,graph,index_map,grdecl_reader}.py`
and `tests/test_graph.py`.

**Result.** 2 LOW drift items in PR-11; 0 in PR-12; 0 in PR-13.

### F-PR11-1 · LOW · Fixture relocation needed

`pr-11.md` references `mesh_2x2x2` as if it were a shared pytest fixture
(`def test_unit_weight_path_identical_2x2x2(mesh_2x2x2)`), but the
fixture is currently defined in `tests/test_graph.py`, not
`tests/conftest.py`. PR-11's new test file `tests/test_graph_fast.py`
cannot consume it as written.

**Resolution chosen:** move `mesh_2x2x2` (and a future `mesh_NxNxN`
helper) to `tests/conftest.py` as part of PR-11. Conftest route preferred
over inline duplication so PR-12's `test_props.py` can also reuse the
fixture without further plumbing.

Recorded as a `## Spec hygiene` block in `pr-11.md` so the PR author
picks up the resolution automatically.

### F-PR11-2 · LOW · `_build_NxNxN_mesh` is `NotImplementedError`

The `_build_NxNxN_mesh(n)` helper in `pr-11.md`'s test sketch is a
deliberate placeholder. Author must implement an adapter from
`cpg2unstructured._toy.build_toy_cpg` → `_TopoMesh` (or whatever the
class is called after PR-12's promotion to `UnstructuredGrid`).

No spec change — already acknowledged in PR-11's "Implementation notes
for the human". Flagged here for tracking.

### PR-12 verified ✓

- `Grdecl.props: dict[str, np.ndarray]` — exists on the public dataclass
  (internal `_State` splits `props_float`/`props_int`, but `Grdecl`
  exposes the merged dict).
- `Grdecl.cart_dims` — present.
- `_TopoMesh` — has `nodes, faces, cell_faces, cell_corners,
  original_ijk, cart_dims`. All assumptions in PR-12's
  `UnstructuredGrid` promotion hold.
- `IndexMap.linear_to_cell` — present with correct semantics.

### PR-13 verified ✓

- Current `__version__ = "0.1.0.dev0"` — clean bump path to `"0.1.0"`.
- All API-map functions in the README skeleton are exported in
  `__init__.py` (modulo additions from PR-11 + PR-12, expected).
- `NonMatchingZError` exists for the "Limitations" section.

**Cascade.** Re-run this audit after PR-11 and PR-12 each merge — only
then is PR-13's README guaranteed accurate.


## DEV-02 — PR-11 spec defect: path equality not guaranteed on 2x2x2 (2026-05-22)

**Scope.** Surfaced by pytest after PR-11's first push.

**Spec claim (pr-11.md, test sketch for `test_unit_weight_path_identical_2x2x2`):**

> "Path equality holds for unit weights with this start/end on 2x2x2"

**Empirical reality.** Both implementations return cost 3.0 (a 3-hop
path) but pick DIFFERENT equal-cost routes:
- heapq-Python (`shortest_path`):  `[0, 1, 3, 7]`
- scipy.csgraph (`shortest_path_fast`): `[0, 1, 5, 7]`

The 2x2x2 all-active cube has **six** equal-cost 3-hop routes from
corner cell 0 to corner cell 7 (3 axis orderings × 2 mirror choices
per axis). Dijkstra picks one based on heap-pop / scan order, which
the two implementations resolve differently.

**This is the exact failure mode Q-PR11-2 warned about**, but the spec
inconsistently applied that warning: distance-weight tests asserted
cost-only, while the unit-weight test asserted path equality. Defect.

**Fix in PR-11.** Renamed the test to
`test_unit_weight_corner_to_corner_2x2x2` and weakened it to:
- cost equality (3.0 == 3.0),
- length equality (4 == 4),
- endpoints match (0 → 7),
- both paths are valid hops in the slow adjacency
  (every consecutive pair is a neighbour with weight 1.0).

Path-list equality is NOT asserted. Test docstring now cites DEV-02
and Q-PR11-2.

**Cascade.** Same trap could lurk in any future test that asserts
exact Dijkstra-path equality when multiple equal-cost routes exist.
Default rule for `cpg2unstructured.graph` tests: assert COST equality
between slow and fast paths; assert path equality only when the route
is provably unique (e.g. a 1-hop neighbour test).
