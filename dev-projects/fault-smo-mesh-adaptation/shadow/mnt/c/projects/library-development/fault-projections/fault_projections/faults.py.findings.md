# SHADOW: /mnt/c/projects/library-development/fault-projections/fault_projections/faults.py
source-path: /mnt/c/projects/library-development/fault-projections/fault_projections/faults.py
shadow-created: 2026-07-28
shadow-updated: 2026-07-28
git-hash: d9aff48a1aeea9eb90a3244a1e996dc93924f1904636b08177f0191b6529ce0b
git-branch: main
git-commit: 8920eee
caller-program: code-dev-study
caller-project: fault-smo-mesh-adaptation

## Summary
Maps a stitched node path to Eclipse FAULTS records and renders the deck text. Each consecutive node pair is one lateral mesh face, looked up in the projected topology for its adjacent cells and axis.

## Key Structures
FaultFace{i,j,face}; path_to_faults(path,topo)->list[FaultFace]; faults_text(groups,nz,names=None)->str; write_faults(...); FaultFace3D; surface_to_fault_faces(...); faults_text_3d(...); write_faults_3d(...). _DIR_FACE={0:'X',1:'Y',2:'Z'}.

## Dependencies
numpy; cpg2unstructured.ProjectedTopology.

## Architecture Role
Terminal stage of the 2.5D pipeline; the D13 regenerated-FAULTS output reuses this verbatim.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-28 |  | Conventions: FACE='X' when cells differ in I, 'Y' when in J; emits the LOWER-index adjacent cell; Eclipse 1-based so +1 on original_ijk; IZ spans the FULL column (IZ1=1, IZ2=nz) — consistent with a vertical stage-1 fault. Boundary faces emit the single in-grid cell. faults_text_3d/surface_to_fault_faces carry real per-layer K for true 3D faults (stage 2). |