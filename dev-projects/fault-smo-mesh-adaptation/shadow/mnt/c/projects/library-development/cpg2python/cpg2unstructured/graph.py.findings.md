# SHADOW: /mnt/c/projects/library-development/cpg2python/cpg2unstructured/graph.py
source-path: /mnt/c/projects/library-development/cpg2python/cpg2unstructured/graph.py
shadow-created: 2026-07-28
shadow-updated: 2026-07-28
git-hash: 8217110827d117cf1ec6974f76730953d512c4a1c0ba2181faba76eb1d77f902
git-branch: main
git-commit: c6202df
caller-program: code-dev-study
caller-project: fault-smo-mesh-adaptation

## Summary
Cell-cell adjacency and shortest path: a pure-numpy reference implementation plus an optional scipy.sparse fast path.

## Key Structures
cell_adjacency(mesh, weights='unit'|'distance'|'none', cell_centroids=None)->list[list[(id,w)]]; shortest_path(adj,src,dst); cell_adjacency_csgraph(...)->csr_array; shortest_path_fast(csr,src,dst=None). WeightMode literal.

## Dependencies
numpy; heapq; optional scipy.sparse + csgraph; cpg2unstructured.unstructured._TopoMesh.

## Architecture Role
Supplies the Dijkstra used by fault-projections' stitching.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-28 |  | This adjacency is CELL-cell, which the deformation does NOT need. The D6 smoothness term needs PILLAR-pillar adjacency — and pillars form a regular (NX+1)x(NY+1) lattice, so neighbours are (i+-1,j),(i,j+-1) by construction. No graph object is required: the smoothness operator is the standard 5-point Laplacian stencil on that lattice, and the least-squares system is a sparse Poisson-like problem (study finding F4). |