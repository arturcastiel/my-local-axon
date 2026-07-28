# SHADOW: /mnt/c/projects/library-development/cpg2python/cpg2unstructured/planview.py
source-path: /mnt/c/projects/library-development/cpg2python/cpg2unstructured/planview.py
shadow-created: 2026-07-28
shadow-updated: 2026-07-28
git-hash: 2e1b2108543dcfdb2ce739bb40af4d307b71a6f5a678d1463a1f4a8453fb80a2
git-branch: main
git-commit: c6202df
caller-program: code-dev-study
caller-project: fault-smo-mesh-adaptation

## Summary
Collapses a 3D UnstructuredGrid onto a coordinate plane and returns the in-plane topology: unique projected nodes, lateral faces as node-pair edges, per-edge adjacent cell indices and axis labels.

## Key Structures
ProjectedTopology{plane, nodes2d (Np,2), edges (Ne,2), edge_len, edge_uv (Ne,2,2), edge_dir (Ne,) int8, node_of_grid_node (Nnodes,)}; projected_topology(grid, plane='xy', *, decimals=None); PLANE_AXES.

## Dependencies
numpy; cpg2unstructured.unstructured.UnstructuredGrid.

## Architecture Role
The 2.5D bridge: everything fault-projections consumes comes from here.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-28 |  | SCOPE LIMIT (documented in the module docstring): targets matching-Z / vertically-aligned pillars where a column's 3D nodes share in-plane coords and collapse exactly; slanted/faulted pillars are 'future work'. STAGE 1 stays inside this; STAGE 2 (independent top/bottom, slanted pillars) LEAVES it — so stage 2 must either extend planview or read pillars straight from coord. `decimals` exists precisely to absorb float drift in vertical pillars. node_of_grid_node is the 3D-node -> projected-node map (the back-map direction the deformation needs is its inverse). |