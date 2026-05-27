# Phase: 1-design
schema-version: v4
status:         complete
workflow-step:  released
branch:         main
current-pr:     PR-13 (merged · 5722cbf · GH #12)
created:        2026-05-21
updated:        2026-05-22

## Working Context
- 13/13 PRs merged. Phase 1-design complete on 2026-05-22.
- PR-1  ✓ merged (665544d)        — repo skeleton + packaging
- PR-2  ✓ merged (c6f1a76, GH #1) — toy 2x2x2 cartesian smoke
- PR-3  ✓ merged (6d9aeac, GH #2) — grdecl_reader (DIMENS/SPECGRID/COORD/ZCORN/ACTNUM)
- PR-4  ✓ merged (3b26263, GH #3) — INCLUDE recursion + property pass-through
- PR-5  ✓ merged (470d0e4, GH #4) — corner-cube assembly + node dedup
- PR-6  ✓ merged (1d959ae, GH #5) — find_i_faces + find_j_faces (matching-Z)
- PR-7  ✓ merged (2d7bb3d, GH #6) — find_k_faces + build_topology + active-cell rebuild
- PR-8  ✓ merged (281a50e, GH #7) — face + cell geometry
- PR-9  ✓ merged (6c07ad7, GH #8) — IndexMap (active-id ↔ Eclipse ijk)
- PR-10 ✓ merged (7912711, GH #9) — graph.py (numpy adjacency + Dijkstra)
- PR-11 ✓ merged (9595eac, GH #10) — graph fast path (scipy.sparse CSR + dijkstra)
        · fixup commit e404785 → squash: weakened path-equality test (DEV-02)
- PR-12 ✓ merged (394a50e, GH #11) — UnstructuredGrid + attach_props
- PR-13 ✓ merged (5722cbf, GH #12) — README + examples + v0.1.0 stamp

## Decisions baked in (1-design)
- D-04 — package name `cpg2unstructured` (trailing `d`)
- D-05 — author identity Dr. Artur Castiel Reis de Souza (full form)
- D-06 — private use first; no PyPI for v0.1.0
- D-07 — PR-2 wave-spec arithmetic correction
- D-PR4-1, D-PR4-2, D-PR4-3 — see PR-4 spec
- D-PR7-* — see PR-7 spec
- D-PR9-1 — IndexMap reverse-map lazy + cached
- D-PR10-1..4 — see PR-10 spec
- D-PR12-1..4 — see PR-12 spec

## Deviations
- DEV-01 — spec drift sweep PR-11..PR-13 (F-PR11-1 + F-PR11-2)
- DEV-02 — PR-11 path-equality assumption invalid on 2x2x2; weakened test

## Released
- v0.1.0 tagged + released on 2026-05-22T05:42:47Z.
- Annotated tag 1126301 → squash commit 5722cbf.
- https://github.com/arturcastiel/cpg2python/releases/tag/v0.1.0

## Next
- Phase 2-faults or 2-properties per masterplan (both deferred).
