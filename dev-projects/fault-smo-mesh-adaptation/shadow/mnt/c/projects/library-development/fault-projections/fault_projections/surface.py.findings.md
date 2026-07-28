# SHADOW: /mnt/c/projects/library-development/fault-projections/fault_projections/surface.py
source-path: /mnt/c/projects/library-development/fault-projections/fault_projections/surface.py
shadow-created: 2026-07-28
shadow-updated: 2026-07-28
git-hash: 0d6a46b142766ad72f8dcd210b8a5bf660c8cb41654740ce4d82493f846e5ef4
git-branch: main
git-commit: 8920eee
caller-program: code-dev-study
caller-project: fault-smo-mesh-adaptation

## Summary
Ties the 3D fault workflow together: fit the polygon's plane, build its in-plane footprint, call cpg2python's planar minimal-surface selector, and bundle faces + ids + area + boundary loop + plane.

## Key Structures
FaultSurface dataclass {face_ids, cell_ijk, direction, area, boundary_loop, p0, normal, u, v}; project_fault_surface(polygon, grid, graph=None)->FaultSurface.

## Dependencies
numpy; cpg2unstructured.planar_minimal_surface, surface_boundary_loops; fault_projections.polygon.

## Architecture Role
The 3D analogue of projection+stitch. Produces the face set that stage 2 would make geometrically exact.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-28 |  | The boundary is the surface's OWN d2 rim (edges on an odd number of selected faces), so it is always contained in the surface — a deliberate fix over an independent shortest-path outline that could disagree. `graph` is vestigial (back-compat only). |