# Decisions (ADRs) — 2-faults

## D-2F-1 — Widen find_*_faces to dispatch matching vs faulted inline (2026-05-22)

**Context.** Two designs considered for handling non-matching-Z grids:
A) widen existing `find_i_faces / find_j_faces / find_k_faces` so each
   detects faulted pillar pairs internally and falls through to a new
   fault-face code path; or B) keep matching-Z functions unchanged and
   add parallel `find_faulted_*_faces` functions called by the
   orchestrator.

**Decision.** Choose A — widen inline.

**Consequences.**
- `_verify_matching_z_i/_j/_k` stop raising `NonMatchingZError`.
  They become `_faulted_pillar_mask_i/_j/_k` returning a per-pillar-pair
  boolean array.
- `find_i_faces`, `find_j_faces`, `find_k_faces` keep their public
  signature (`cube -> Faces`) but internally dispatch: all-matching
  case → existing PR-6/PR-7 fast path (bit-identical); any faulted
  → new fault code path concatenated with matching output.
- `NonMatchingZError` reserved for genuinely unsupported cases inside
  the fault path (degenerate geometry we don't handle yet).
- Tier A regression budget: all 1-design tests must pass identically
  when no faults are present.

**Justification.**
1. MRST's `processGRDECL.m` has a single `findFaces` that does both;
   mirroring its design lowers drift risk against the reference.
2. Matching-Z fast path stays bit-identical via early-out on
   `np.any(faulted_mask) == False`.
3. Single public entry per direction → simpler orchestrator,
   no API surface churn for users.

**Cascade.** Phase 2-faults PR specs PR-3..PR-7 (integration waves)
all assume this dispatch model. PR-1 + PR-2 (foundations) are
unaffected — they introduce pure helpers used by both designs.



## ADR-2F-2 — Pattern A relaxed to scoped autonomous-mode (2026-05-24)
For THIS project only, the inherited "Pattern A — HUMAN runs driver"
is superseded by a scoped, audited `autonomous-mode` grant (pulled
from axon #94). AXON runs the commit → push → PR → merge git loop for
`arturcastiel/cpg2python`; tests run in CI (GitHub Actions), never
locally. Started gated (no merge, 2026-05-24 08:22Z), upgraded to full
on user instruction (08:29Z) — green PRs self-merge. Kernel-file +
destructive git (force-push/reset-hard/branch-delete) remain human-only
even under the grant. Grant state is private in
`my-axon/memory/local/autonomous-grant.json` (gitignored). Revoke:
`autonomous-mode off`. First run: PR-9 (#23). The driver scripts
(`pr-fault-*.sh`) are retired for this project.

## ADR-2F-3 — PINCH NNCs as a separate `nnc` array (2026-05-24)
NNCs are represented as a dedicated `nnc: np.ndarray (M, 2)` int64 field
of cell-id pairs on `UnstructuredGrid` (mirrors MRST's top-level `nnc`).
NOT encoded inside `Faces` — `Faces.nodes` is (N,4) geometric polygons
and an NNC has no polygon, so mixing them would break that invariant.
Pinched-out (zero-thickness) cells are dropped; an NNC bridges the cells
above and below. Default empty `(0,2)` when no PINCH. (Wave 6.)

## ADR-2F-4 — Disconnected split via `component` labels + `split()` (2026-05-24)
`build_topology` keeps returning ONE `UnstructuredGrid` (non-breaking);
add `component: np.ndarray (Ncells,)` int64 labels (0 for single-component
decks — invariance) plus a `split() -> list[UnstructuredGrid]` method that
materialises independent grids on demand. Chosen over MRST's default of
returning a list, to avoid a breaking return-type change. (Wave 7.)

## Inherited from 1-design (still binding)
- D-04 — package name `cpg2unstructured` (trailing `d`)
- D-05 — author identity Dr. Artur Castiel Reis de Souza
- D-06 — private use first; no PyPI publish for v0.1.0 (revisit at
  end of 2-faults if real decks now work)
- Authoring pattern A — AXON writes source files; HUMAN runs driver
- Scripts default to --pr (full commit + push + open-PR cycle)
- Viz sidecar (`viz/`) is the visual verification mechanism — every
  PR in this phase MUST include a fixture + viz check
