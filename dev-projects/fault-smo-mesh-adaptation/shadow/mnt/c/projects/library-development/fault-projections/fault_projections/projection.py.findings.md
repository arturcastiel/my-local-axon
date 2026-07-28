# SHADOW: /mnt/c/projects/library-development/fault-projections/fault_projections/projection.py
source-path: /mnt/c/projects/library-development/fault-projections/fault_projections/projection.py
shadow-created: 2026-07-28
shadow-updated: 2026-07-28
git-hash: 0d7eb7d5070de557d65f2b54745515bf9472a493762b4c117d42a051b3e9510b
git-branch: main
git-commit: 8920eee
caller-program: code-dev-study
caller-project: fault-smo-mesh-adaptation

## Summary
Projects a fracture polyline onto the plan-view mesh as an ordered node-id sequence. Computes true segment-vs-edge intersections, orders them along the segment, and snaps each crossing to the NEARER endpoint of the crossed edge. Endpoints snap to the globally nearest node.

## Key Structures
project_polyline(polyline, graph, *, tol=1e-9) -> (M,) int64; project_polylines(...) -> list; _segment_edge_crossings(p1,d1,a,d2,edges,tol) -> list[int]; _append(seq,node) dedups consecutive.

## Dependencies
numpy; fault_projections.graph.ProjectedGraph; fault_projections.polylines.as_polylines.

## Architecture Role
Entry point of the 2.5D fracture pipeline. Consumes ProjectedTopology via ProjectedGraph, produces the node sequence that stitch.py turns into a continuous path.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-28 |  | FEATURE-CRITICAL: the per-segment loop (k over line.shape[0]-1) appends into ONE flat `seq` — SEGMENT PROVENANCE IS DISCARDED. Decision D11 (one residual per (pillar,segment) incidence) requires the segment index to survive; this function must return or carry a parallel segment-id array. Snapping to the NEARER edge endpoint is exactly the approximation the deformation feature removes. |