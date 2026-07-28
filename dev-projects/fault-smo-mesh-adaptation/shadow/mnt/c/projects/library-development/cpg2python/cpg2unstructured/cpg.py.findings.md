# SHADOW: /mnt/c/projects/library-development/cpg2python/cpg2unstructured/cpg.py
source-path: /mnt/c/projects/library-development/cpg2python/cpg2unstructured/cpg.py
shadow-created: 2026-07-28
shadow-updated: 2026-07-28
git-hash: 8d55eff65bd0f024f5cd8949cf4e68e26051035f8abb566ec2a40adf8e9df4a8
git-branch: main
git-commit: c6202df
caller-program: code-dev-study
caller-project: fault-smo-mesh-adaptation

## Summary
CPG geometry assembly: Grdecl -> corner cube -> unique nodes + P map. Interpolates each COORD pillar between top and bottom at the ZCORN depth, NaN-masks inactive corners, then dedups nodes by quantized coordinate.

## Key Structures
CornerCube{nodes (Nn,3), P (2NX,2NY,2NZ) int64 or -1, cart_dims, actnum_3d, pinched_3d}; from_grdecl(g, pinch_tol=0.0); _coord_pillars -> (NX+1,NY+1,6); _zcorn_3d -> (2NX,2NY,2NZ); _assemble_corner_xyz; _pinched_cell_mask; _mask_inactive_corners. _QUANT=1e9.

## Dependencies
numpy; itertools; cpg2unstructured.grdecl_reader.Grdecl. Portions derived from MRST processGRDECL.m (GPL-3.0).

## Architecture Role
Turns deck arrays into mesh nodes. Re-running it after deformation is how the deformed grid is validated.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-28 |  | TWO FEATURE-CRITICAL FACTS. (1) _assemble_corner_xyz interpolates pillar xy LINEARLY in z: xy = top + t*(bot-top), t=(z-z_top)/(z_bot-z_top). A plane is also linear in z, so putting BOTH pillar endpoints in the fault plane puts the ENTIRE pillar in it -> stage 2 achieves distance 0 at EVERY depth, not just top and bottom (study finding F5). (2) Node identity is COORDINATE-DERIVED: nodes are deduped on np.round(xyz*1e9) via np.unique. Two pillars driven to within 1e-9 WELD into one node -> topology change, cells silently merged, and the D13 face-set invariance breaks. This gives a concrete lower bound for a minimum-separation guard. |