# Project: Fault SMO Mesh Adaptation
slug:            fault-smo-mesh-adaptation
schema-version:  v4
status:          complete
legacy:          false
phase:           complete (manifest-backed: all 5 phases done)
workflow-step:   build
branch:          main
codebase:        /mnt/c/projects/library-development/fault-projections
workflow:        _workflow.yml
parent:          (none)
sub-projects:    []
created:         2026-07-28
updated:         2026-10-26 (reconciled to git/GitHub — post-completion work logged; see 04-log.md)

## Current state (reconciled 2026-10-26)
- COMPLETE stands. All owner-gated merges done: cpg2python #38, #39 · fault-projections #1.
- Post-completion work (07-28 → 07-29) shipped but was never logged until 2026-10-26:
  cpg2python #40–#46 merged; fault-projections bench + engineer's guide (main @ 0837f07).
- Open follow-ups (outside this project's scope):
  · cpg2python issue #45 — `boundary='slide'` moves rim pillars off non-axis-aligned outlines.
  · PR-013 (Norne via `build_topology`) — study in 06-study-pr013.md; WIP evidence on
    cpg2python branch `wip/build-topology-stepAB` (NOT FOR MERGE). Run as its own project.
  · cpg-fault-fieldbook CI red — fault-projections is still PRIVATE.

## Working Context (historical — project scaffold, 2026-07-28)
- New project. Run: code-dev study  to begin first phase.
- Codebase selected 2026-07-28 after a repo-provenance sweep. Three DISTINCT GitHub repos
  exist with confusingly similar names — recorded here so the wrong one is never picked again:
    · fault-projections (PLURAL, github.com/arturcastiel/fault-projections) — THIS project's
      codebase. 42 commits, last 2026-05-29, clean. A rewrite: shares ZERO history with the
      singular repo. Package `fault_projections/` (quad_surface, surface, skeleton, faceting,
      stitch, polygon, projection, faults, vtk).
    · fault-projection (SINGULAR, github.com/arturcastiel/fault-projection) — the SUPERSEDED
      generation. Two checkouts: /mnt/c/projects/smo-faults (8 commits, 2026-05-16, 3 unpushed,
      the newer of the pair) and /mnt/c/projects/faults/fault-projection (4 commits, stale
      duplicate — its HEAD a4a75fe is an ancestor of smo-faults).
    · cpg2python (github.com/arturcastiel/cpg2python) — HARD DEPENDENCY of this codebase, not
      a duplicate. 56 commits, last 2026-06-18 (most recently touched of all). Provides
      `cpg2unstructured`: CPG .grdecl/.EGRID → unstructured mesh + adjacency graph.
- Cross-repo sibling registered in _profile.md. fault-projections' README installs
  cpg2unstructured from ../cpg2python — changes there can break this codebase.
