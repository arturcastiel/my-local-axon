# Project: CPG to Unstructure Grid Python Generator
slug:            cpg-to-unstructure
schema-version:  v4
status:          active
legacy:          false
phase:           2-faults ✓ shipped (v0.2.0) — no next phase created yet
workflow-step:   released
branch:          main
codebase:        /mnt/c/projects/library-development/cpg2python
parent:          (none)
sub-projects:    []
created:         2026-05-21
updated:         2026-10-26 (reconciled to git/GitHub; codebase path corrected)
released:        2026-05-24
released-tag:    v0.2.0
released-commit: 020bfa8
released-url:    https://github.com/arturcastiel/cpg2python/releases/tag/v0.2.0
prev-release:    v0.1.0 (5722cbf, 2026-05-22)

## Current state (reconciled 2026-10-26)
- Repo is PUBLIC (was the pending open-source step). main @ e4637cc, CI green. No tag since v0.2.0.
- Since v0.2.0 (none of it logged at the time — see 04-log.md):
  · #36–#37 (06-18) — `.EGRID` input via resfo + docs. (Was out-of-scope per masterplan.)
  · #38–#46 (07-28..29) — pillar-morphing engine for fault-smo-mesh-adaptation, plus
    #44, which fixes a PRE-EXISTING 2-faults bug: fault faces were the union envelope, not the overlap.
- Project goal NOT fully met: D1 still live on main — `build_topology` calls
  `_i_face_quads`/`_j_face_quads` directly, never the fault-aware finders, so faulted decks
  get merged faces silently. Full analysis: fault-smo-mesh-adaptation/06-study-pr013.md;
  WIP branch `wip/build-topology-stepAB` (NOT FOR MERGE). Candidate next phase / project.
- Open issue #45 (slide boundary on non-axis-aligned rims) — morph code, lives in this repo.

## Working Context (historical)
- Phase 1-design: 13/13 PRs ✓ merged on origin/main.
- v0.1.0 shipped: tag + GH release at
  https://github.com/arturcastiel/cpg2python/releases/tag/v0.1.0
  (annotated tag 1126301 → squash commit 5722cbf).
- Project goal refined 2026-05-22: cpg2python's sole goal is to
  transform any CPG grid (including faulted) into an unstructured
  grid representation. NOT a full reservoir library — transmissibility,
  property algebra, VTK viz, PyPI publish all out of scope.
- Therefore: phase 2-properties (from original masterplan) CANCELLED.
  Only phase 2-faults remains as the next major work.

## ⚠ Sidecar location corrected 2026-05-24 · path re-corrected 2026-10-26
The viz tooling is NOT inside the cpg2python repo (never committed). It
lives in a SEPARATE side folder (not git):
`/mnt/c/projects/library-development/viz-cpg2unstructured/`
(viz/ python pkg + inspect-cpg.ipynb + phase2-validation.ipynb + output/
PNGs). Run via its own launchers — NOT the stale paths in the section
below:
  - interactive (rotate/zoom):  bash /mnt/c/projects/library-development/viz-cpg2unstructured/launch.sh
  - per-deck notebook:          bash .../launch.sh inspect <deck.grdecl>
  - headless PNG (WSL, no X):   bash .../render-demo.sh <deck.grdecl>
The viz predates PR-11..14, so it does NOT yet render NNC bridges /
component colors / pinched-cell drops — basic geometry only.

## Sidecars (in repo, NOT in installed package) — STALE, see note above
- **viz/** — matplotlib-based debug visualisation for CPG and
  UnstructuredGrid. Authored 2026-05-22. Lives at repo root;
  excluded from setuptools install (`include = ["cpg2unstructured*"]`).
  Run: `python -m viz.demo`. Personal use only — never released.
  Files: viz/{__init__,_common,cpg,unstructured,compare,demo}.py
  + README.md. No formal AXON phase tracking; updates land in this
  _meta.md and 04-log.md only.

## Adjacent (sibling) folders, outside the repo
- ⚠ 2026-10-26: `/mnt/c/projects/cpg2python-notebooks/` and
  `/mnt/c/projects/launch-viz-nb.sh` NO LONGER EXIST (not found under
  /mnt/c/projects or library-development). Entry kept for history only.
- **/mnt/c/projects/cpg2python-notebooks/** — interactive Jupyter
  notebook (ipympl backend → rotate/zoom/pan). Imports viz/ and
  cpg2unstructured via sys.path. Single notebook
  inspect-cpg.ipynb with 3 cases: bundled quickstart, synthetic
  6x6x4 deck with scattered inactive cells (checkerboard + 2x2
  hole), and face-edge view. Launcher: /mnt/c/projects/launch-viz-nb.sh
  (installs jupyterlab + ipympl + matplotlib into cpg2python venv,
  then opens JupyterLab).
