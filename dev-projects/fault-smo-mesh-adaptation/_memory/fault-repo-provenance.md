---
id: fault-repo-provenance
tier: project
scope-ref: fault-smo-mesh-adaptation
bindings: project:fault-smo-mesh-adaptation,fault-projections,cpg2python,provenance
source: repo sweep 2026-07-28
date: 2026-07-28
confidence: high
privacy: private
supersedes: 
---
FAULT/CPG REPO PROVENANCE (resolved 2026-07-28, owner did not know which checkout was current). THREE distinct GitHub repos with confusingly similar names, four checkouts on disk. CANONICAL/LIVE: (1) /mnt/c/projects/library-development/fault-projections -> github.com/arturcastiel/fault-projections (PLURAL) -- 42 commits, last 2026-05-29, clean; package fault_projections/ (quad_surface, surface, skeleton, faceting, stitch, polygon, projection, faults, vtk); a REWRITE sharing ZERO history with the singular repo (first commit 'Initial fault-projections pipeline'). (2) /mnt/c/projects/library-development/cpg2python -> github.com/arturcastiel/cpg2python -- 56 commits, last 2026-06-18 (most recently touched of all); package cpg2unstructured (CPG .grdecl/.EGRID -> unstructured mesh + adjacency graph, _fault_geometry, _fault_connections, minimal_surface, PINCH NNCs). fault-projections declares cpg2unstructured a HARD DEPENDENCY installed from the sibling ../cpg2python checkout -- designed as siblings, not duplicates. SUPERSEDED: github.com/arturcastiel/fault-projection (SINGULAR) -- /mnt/c/projects/smo-faults (8 commits, 2026-05-16, 3 unpushed, untracked generated/) is the NEWER of its two checkouts and strictly contains /mnt/c/projects/faults/fault-projection (4 commits, HEAD a4a75fe is an ancestor). Do NOT edit the singular repos expecting the fix to reach the plural one. HOW TO APPLY: fault work -> fault-projections; grid/mesh topology work -> cpg2python. ALSO FOUND: dev-project cpg-to-unstructure/_meta.md has codebase /mnt/c/projects/cpg2python which NO LONGER EXISTS (repo moved under library-development/) -- stale pointer, repair separately.
