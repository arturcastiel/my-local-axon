# SHADOW: /mnt/c/projects/library-development/fault-projections/fault_projections/polygon.py
source-path: /mnt/c/projects/library-development/fault-projections/fault_projections/polygon.py
shadow-created: 2026-07-28
shadow-updated: 2026-07-28
git-hash: e786066ab2c74e179148022247ab41259bdbf696a9ecd8aa0bf428c9aecac18b
git-branch: main
git-commit: 8920eee
caller-program: code-dev-study
caller-project: fault-smo-mesh-adaptation

## Summary
Validates a closed PLANAR 3D fault polygon, fits its plane, and projects its boundary onto the mesh as a closed node loop. Also exposes the single-segment projector reused by the quad-mesh skeleton.

## Key Structures
Polygon3D{vertices (N,3)}; as_polygon(points, tol=1e-6); polygon_plane(poly)->(p0,normal,u,v); project_segment(p1,p2,grid_lines,graph,tol); project_polygon_boundary(poly,graph,tol); to_plane_2d(points,p0,u,v); _edge_node_sequence densifies at mesh-grid-plane crossings.

## Dependencies
numpy; cpg2unstructured.fit_plane, project_to_plane.

## Architecture Role
The 3D fault input format. Decision D9 adopts Polygon3D as the stage-2 target definition.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-28 |  | as_polygon ENFORCES coplanarity against the best-fit plane (tol scaled by polygon extent) — so a Polygon3D is guaranteed planar, which is what makes the stage-2 exactness property hold (see 01-study.md finding F5). Curved faults must go through faceting.py instead. |