# SHADOW: /mnt/c/projects/library-development/fault-projections/fault_projections/stitch.py
source-path: /mnt/c/projects/library-development/fault-projections/fault_projections/stitch.py
shadow-created: 2026-07-28
shadow-updated: 2026-07-28
git-hash: e0d6fd4814bba30d0a6c718f43ea4974548e33330639b30ebb1c2b4a0db4a408
git-branch: main
git-commit: 8920eee
caller-program: code-dev-study
caller-project: fault-smo-mesh-adaptation

## Summary
Stitches a projected node sequence into a continuous on-mesh node path by running a shortest path between each consecutive pair and concatenating, without duplicating shared endpoints.

## Key Structures
stitch_path(node_sequence, graph) -> (P,) int64; stitch_paths(seqs, graph) -> list.

## Dependencies
numpy; fault_projections.graph.ProjectedGraph.

## Architecture Role
Bridges projection output to faults.path_to_faults — guarantees consecutive ids are real mesh edges.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-28 |  | Dijkstra weight is edge LENGTH, so the stitched path is the shortest on-mesh route, not the closest route to the true trace. This is the second source of staircase error the deformation removes. Segment provenance is again absent here. |