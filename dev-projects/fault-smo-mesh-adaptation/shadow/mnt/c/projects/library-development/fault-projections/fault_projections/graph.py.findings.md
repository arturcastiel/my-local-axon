# SHADOW: /mnt/c/projects/library-development/fault-projections/fault_projections/graph.py
source-path: /mnt/c/projects/library-development/fault-projections/fault_projections/graph.py
shadow-created: 2026-07-28
shadow-updated: 2026-07-28
git-hash: f9df058c79d22524596ed5ce0fe511a362b100f3b26bddbf42605358d397978d
git-branch: main
git-commit: 8920eee
caller-program: code-dev-study
caller-project: fault-smo-mesh-adaptation

## Summary
Thin instantiation layer over cpg2python's ProjectedTopology: builds a weighted node-edge CSR graph (weight = in-plane edge length) plus a cKDTree for nearest-node snapping. Dijkstra is reused from cpg2python, not reimplemented.

## Key Structures
ProjectedGraph dataclass {topo, csr, kdtree}; .n_nodes; .nearest_node(points)->int64[]; .shortest_path(src,dst)->(len,[ids]); build_projected_graph(topo)->ProjectedGraph.

## Dependencies
numpy; scipy.sparse; scipy.spatial.cKDTree; cpg2unstructured.ProjectedTopology, shortest_path_fast.

## Architecture Role
The query surface for projection + stitching. Holds no geometry of its own — topo.nodes2d is the coordinate source.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-28 |  | NOTE for the deformation: nodes2d is a SNAPSHOT. After pillars move, csr edge weights and the KD-tree are stale. Any re-projection on the deformed grid (the D13 FAULTS-invariance test) must REBUILD this object, not reuse it. |