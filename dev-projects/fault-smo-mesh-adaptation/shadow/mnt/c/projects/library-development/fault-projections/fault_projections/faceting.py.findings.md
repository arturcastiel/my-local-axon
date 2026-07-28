# SHADOW: /mnt/c/projects/library-development/fault-projections/fault_projections/faceting.py
source-path: /mnt/c/projects/library-development/fault-projections/fault_projections/faceting.py
shadow-created: 2026-07-28
shadow-updated: 2026-07-28
git-hash: 5a82cc958222c7238da829851f4afa3bbc11fa6bf126fad37ab3380e7dd553fb
git-branch: main
git-commit: 8920eee
caller-program: code-dev-study
caller-project: fault-smo-mesh-adaptation

## Summary
Discretizes an arbitrary curved fault surface into PLANAR quad facets and projects each through the planar pipeline, unioning the resulting cell-faces. Source may be a callable z=f(x,y) or a point cloud.

## Key Structures
planarize_quad(quad)->(4,3) via SVD normal; sample_function_grid(f,xlim,ylim,nu,nv); sample_cloud_grid(points,nu,nv,...) uses scipy griddata + nearest fill; facet_surface(source,*,nu,nv,...)->list[(4,3)]; project_faceted_surface(quads,grid)->FaultSurface.

## Dependencies
numpy; scipy.interpolate.griddata (lazy); cpg2unstructured.face_areas, surface_boundary_loops; fault_projections.surface.

## Architecture Role
The curved-fault path. Reduces curvature to a set of planar problems.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-28 |  | Relevant to stage 2 beyond planar: since each facet is planarized, the per-facet exactness property (F5) holds facet-by-facet. A pillar spanning two facets has two competing targets — the D11 multi-residual rule extends naturally. |