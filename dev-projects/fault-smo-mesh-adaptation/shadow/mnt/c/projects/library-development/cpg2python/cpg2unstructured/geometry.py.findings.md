# SHADOW: /mnt/c/projects/library-development/cpg2python/cpg2unstructured/geometry.py
source-path: /mnt/c/projects/library-development/cpg2python/cpg2unstructured/geometry.py
shadow-created: 2026-07-28
shadow-updated: 2026-07-28
git-hash: 3accb479b570c24cd48fbbac671c4d2585de7839a841302e379cd7c74ae42773
git-branch: main
git-commit: c6202df
caller-program: code-dev-study
caller-project: fault-smo-mesh-adaptation

## Summary
Face and cell geometry for the unstructured mesh: centroids, areas, oriented normals, and cell volumes via the divergence theorem.

## Key Structures
FaceGeometry{centroids, areas, normals}; CellGeometry{centroids, volumes}; face_geometry(nodes, faces, cell_corners); cell_geometry(nodes, faces, cell_faces, fg). Quad area from the two DIAGONALS (Faces.nodes is sorted by node id, NOT cyclic).

## Dependencies
numpy; cpg2unstructured.unstructured.Faces.

## Architecture Role
The obvious place to look for a validity check — and the wrong one for the solver's inner loop.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-28 |  | PERFORMANCE TRAP: cell_geometry loops over cells in PYTHON (`for c in range(n_cells)`) with an inner loop over faces. Calling it per solver iteration is O(Ncells) interpreted work — prohibitive on a real grid across several iterations. D7 fold detection must instead use the VECTORIZED plan-view signed-area sign test (stage 1), which is exactly equivalent for vertical pillars. Also note areas are computed from diagonals because face node order is id-sorted, not cyclic — do not assume cyclic order anywhere. |