# Phase: 2-faults
schema-version: v4
status:         active
workflow-step:  merged
branch:         main
current-pr:     PR-15
predecessors:   [1-design]
created:        2026-05-22
updated:        2026-05-24

## Goal
Port Tier B of `processGRDECL.m` so cpg2unstructured handles
**non-matching-Z (faulted) CPG grids**. Closes the gap between the
v0.1.0 alpha (matching-Z only) and "transforms any CPG grid into an
unstructured grid representation" — the stated project goal.

## Source material
- DARSim-vendored MRST snapshot:
  `/mnt/c/projects/darsim/darsim-release/src/darsim_legacy/CornerPointGridGenerator/MRST_Functions/processGRDECL.m`
  (1293 LOC — same copy used in 1-design's Tier A study, so no
  version drift risk against the existing matching-Z code path)
- Upstream-MRST cross-check (read-only reference) at
  `/mnt/c/projects/prototype/mrst/MRST/core/gridprocessing/processGRDECL.m`

## Tier B section map (preliminary — refine during study)

| Lines (MATLAB) | Function | Role |
|---:|---|---|
| 502-648 | `findFaces` | Matching-Z + handover to fault path; partial port (Tier A side) exists |
| 687-825 | `findFaults` | Discover faulted pillar pairs (where ZCORN doesn't match across a face) |
| 826-852 | (in `findFaults`) — orchestrates `findConnections` calls per fault stack | |
| 853-1163 | `computeFaceGeometry` | Build the actual fault-face polygons from a/b corner-z lists + connection table |
| 1164-1193 | `intersection` | Line/segment intersection helper |
| 1194-1250 | `findConnections` | Pair up overlapping a- and b-segments along a faulted pillar pair |
| 1251-1284 | `doIntersect` / `overlap` | Segment-overlap predicates |

## Goal scope (in)
- Non-matching-Z fault geometry on i-faces and j-faces
- Faulted-cell neighbour table (pairs connected by an offset face)
- Visual verification via viz/ sidecar (ghost-overlay catches
  mis-aligned cells across faults)
- PINCH NNCs — cross-layer non-neighbour connections (Wave 6, added 2026-05-24)
- Disconnected-grid splitting — connected-component split (Wave 7, added 2026-05-24)

## Out of scope (deferred or cancelled)
- Properties algebra / transmissibility helpers (project goal
  refined — see user-side memory project_cpg2python_goal.md)
- `.EGRID` binary format
- MAPAXES / coordinate transforms

## Working Context  (v0.2.0 ready 2026-05-24)
- ALL 15 PRs merged on main (@ 5746265, version 0.2.0). Phase 2-faults
  code-complete: faulted (non-matching-Z) grids, PINCH NNCs, and
  disconnected-grid split() all land. PR-10..15 done via autonomous run.
- REMAINING = human gates only: (1) viz golden eye-check; (2) v0.2.0
  tag + GH release. After that the project goal is met.
- (historical reconciliation note below kept for the record.)

## Working Context  (reconciled to git 2026-05-24)
- Wave 5 of 5 — "Polish + v0.2.0 release". PR-1…PR-8 MERGED on
  origin/main (HEAD 5a0503d). build_topology now runs end-to-end on
  faulted decks; find_i_faces (PR-6) + find_j_faces (PR-7) dispatch
  matching vs faulted; PR-8 dropped the top-level fault guard.
- PR-9 MERGED (#23, squash 8d54282) on 2026-05-24: 3×3×2
  multi-column i-fault regression + first CI workflow. 198 tests
  green on py3.10/3.11/3.12. 9/10 PRs done.
- PR-10 (final Wave-5 PR — v0.2.0 release) not started → current-pr.
- Note: this _meta.md had frozen at "study / no PRs" while the work
  ran to PR-8+; reconciled to git on 2026-05-24 (see 04-log.md).

## Decisions baked in (from 1-design that this phase honours)
- Authoring pattern A — AXON writes source files; user runs driver
  scripts (`pr*-build.sh`).
- Scripts default to --pr (full commit + push + open PR).
- Same codebase: `/mnt/c/projects/cpg2python`.
- v0.1.0 already released — this phase builds toward v0.2.0.
- Viz sidecar (`viz/`) used for visual verification of every PR.

## Next
- ✓ Full deep read of Tier B (lines 502-1293) — all 7 functions
  understood. See `01-study.md` §§4-6.7.
- ✓ Port plan refined to 10 PRs in 5 waves with LOC estimates.
  See `01-study.md` §8.
- ✓ Risks identified (R-1 diamond-case branching, R-2 dZ overflow,
  R-3 pillar-tilt limit). See `01-study.md` §10.
- ✓ `02-plan.md` written — lifted §8 wave structure into plan-of-record
  with wave gates + risk register + decisions cross-ref.
- ✓ `03-prs/pr-01.md` drafted — first PR spec (faulted fixture +
  `_faulted_pillar_mask_*` rename, behaviour-preserving).
- ✓ PR-1…PR-8 implemented + merged (Waves 1–4). See 04-log.md.
- ⌛ PR-9 authored, awaiting commit/push — run
  `./pr-fault-09-build.sh`, then `code-dev log`.
- ☐ PR-10 — final Wave-5 PR: v0.2.0 release (larger fixtures,
  viz verification, tag). Not yet specced.

## Decisions made so far
- D-2F-1 — widen `find_*_faces` to dispatch matching vs faulted
  inline; do NOT introduce parallel `find_faulted_*` functions.
  See `_decisions.md`.
