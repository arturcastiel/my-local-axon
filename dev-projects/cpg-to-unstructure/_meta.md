# Project: CPG to Unstructure Grid Python Generator
slug:            cpg-to-unstructure
schema-version:  v4
status:          active
legacy:          false
phase:           2-faults
workflow-step:   released
branch:          main
codebase:        /mnt/c/projects/cpg2python
parent:          (none)
sub-projects:    []
created:         2026-05-21
updated:         2026-05-24
released:        2026-05-24
released-tag:    v0.2.0
released-commit: 020bfa8
released-url:    https://github.com/arturcastiel/cpg2python/releases/tag/v0.2.0
prev-release:    v0.1.0 (5722cbf, 2026-05-22)

## Working Context
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

## ⚠ Sidecar location corrected 2026-05-24
The viz tooling is NOT inside the cpg2python repo (never committed). It
lives in a SEPARATE side folder: `/mnt/c/projects/viz-cpg2unstructured/`
(viz/ python pkg + inspect-cpg.ipynb + phase2-validation.ipynb + output/
PNGs). Run via its own launchers — NOT the stale paths in the section
below:
  - interactive (rotate/zoom):  bash /mnt/c/projects/viz-cpg2unstructured/launch.sh
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
- **/mnt/c/projects/cpg2python-notebooks/** — interactive Jupyter
  notebook (ipympl backend → rotate/zoom/pan). Imports viz/ and
  cpg2unstructured via sys.path. Single notebook
  inspect-cpg.ipynb with 3 cases: bundled quickstart, synthetic
  6x6x4 deck with scattered inactive cells (checkerboard + 2x2
  hole), and face-edge view. Launcher: /mnt/c/projects/launch-viz-nb.sh
  (installs jupyterlab + ipympl + matplotlib into cpg2python venv,
  then opens JupyterLab).
