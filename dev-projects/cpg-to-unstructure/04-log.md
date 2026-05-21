# Implementation Log — CPG to Unstructure Grid Python Generator

## SESSION START — 2026-05-21T09:34:56Z
project:        cpg-to-unstructure
phase:          1-design
workflow-step:  build
branch:         main

## Entries

### 2026-05-21T09:35:52Z · code-dev study (goal-capture)
- Phase: 1-design · Step: study
- Captured user goal: lightweight Python CPG → unstructured grid → graph
  for shortest-path; bidirectional cell-index map required.
- Constraints: stdlib + numpy preferred; no excess libs; modular layout.
- Scope: faulted (matching-Z only) and unfaulted CPG grids.
- Awaiting: MATLAB reference implementation from user.
- Output: phases/1-design/01-study.md

### 2026-05-21T09:38:47Z · code-dev study (analysis)
- Phase: 1-design · Step: study (continued)
- Read MATLAB reference at C:\projects\darsim\darsim-release.
- Identified pipeline: readGRDECL → processGRDECL (1343 LOC, the core)
  → computeGeometry → MeshCore decompress → unstructured_grid.
- MRST's G.cells.indexMap already provides (i,j,k) ↔ active-cell map →
  preserve this contract.
- Drop list captured: edges/sparse-bool matrices/transmissibility/pEDFM
  are reservoir-sim specific, not needed for shortest-path use case.
- Proposed Python layout: 7 modules, numpy-only hard dep, scipy optional.
- Output: phases/1-design/01-study.md (full study).

### 2026-05-21T09:40:38Z · code-dev study (processGRDECL deep-read)
- Read all 1343 LOC of processGRDECL.m.
- Discovered: ~440 LOC (Tier B: findFaults/computeFaceGeometry/
  intersection/findConnections/doIntersect/overlap) is unreachable with
  matching-Z assumption. Guard at entry → NotImplementedError for v2.
- Tier A (~470 LOC MATLAB) maps to ~530 LOC Python (~60% reduction).
- Sketched matching-Z findFaces in numpy (vectorized stride view).
- Optional scipy.sparse decision: extras_require=fast, default deps-free.
- Output: phases/1-design/01-study.md (addendum appended).

### 2026-05-21T09:42:06Z · code-dev study (readGRDECL parser spec)
- Read all 308 LOC of readGRDECL.m.
- Extracted Eclipse keyword spec: SPECGRID/DIMENS, COORD, ZCORN, ACTNUM
  required; PORO/PERM* optional v2 pass-through; ~12 keywords skipped.
- Memory budget for Norne-class case: ~8 MB raw input, trivial.
- Python parser plan: ~120 LOC, stdlib + numpy, dispatch-table based.
- Final pipeline ASCII diagram appended to study.
- Output: phases/1-design/01-study.md (228 → 354 lines)

### 2026-05-21T10:35:32Z · code-dev plan (tactical)
- 13 PRs across 6 waves. Mean ~95 LOC per PR including tests.
- Wave 1 (skeleton+smoke): PR-1, PR-2.
- Wave 2 (parser): PR-3, PR-4.
- Wave 3 (CPG transform): PR-5, PR-6, PR-7.
- Wave 4 (geometry+index): PR-8, PR-9.
- Wave 5 (graph): PR-10, PR-11.
- Wave 6 (polish): PR-12, PR-13.
- 3 deferred decisions captured (D-01..D-03).
- Out-of-scope explicit: non-matching-Z faults (v2 phase 2-faults).
- Output: phases/1-design/02-plan.md, 02-prs.md.

### 2026-05-21T10:54:23Z · code-dev pr 1
- PR-1 specified: repo skeleton + packaging.
- 9 files (pyproject.toml, __init__.py, py.typed, README, LICENSE,
  .gitignore, CHANGELOG, tests/__init__.py, tests/test_smoke.py).
- ~130 LOC total. Acceptance: pip install -e .[dev] + pytest green.
- Decisions baked: Python 3.10+ floor, numpy>=1.24, setuptools backend,
  no ruff/mypy/black in v1, scipy as [fast] extra.
- 3 open questions for user (author name, public repo, PyPI name).
- Output: phases/1-design/03-prs/pr-01.md
