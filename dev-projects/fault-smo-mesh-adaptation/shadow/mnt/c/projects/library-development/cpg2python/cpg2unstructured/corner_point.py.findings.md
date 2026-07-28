# SHADOW: /mnt/c/projects/library-development/cpg2python/cpg2unstructured/corner_point.py
source-path: /mnt/c/projects/library-development/cpg2python/cpg2unstructured/corner_point.py
shadow-created: 2026-07-28
shadow-updated: 2026-07-28
git-hash: 68adff63e79bd7d7e1980587d0f9ebd71edf9bffa7632805d9eba23c71e1cf55
git-branch: main
git-commit: c6202df
caller-program: code-dev-study
caller-project: fault-smo-mesh-adaptation

## Summary
The format-agnostic parsed corner-point grid returned by both the GRDECL text reader and the EGRID binary reader.

## Key Structures
CornerPointGrid (frozen dataclass): cart_dims (NX,NY,NZ); coord (n_pillars,6) = (xt,yt,zt,xb,yb,zb); zcorn (8*NX*NY*NZ,); actnum (NX*NY*NZ,) int8; mapaxes (6,)|None; mapaxes_applied bool; props dict; unrecognized list[str]; source 'grdecl'|'egrid'. Properties n_cells, n_pillars=(NX+1)*(NY+1). Grdecl = TypeAlias back-compat.

## Dependencies
numpy; dataclasses.

## Architecture Role
THE data structure the deformation mutates. coord is the entity D2 moves; zcorn is untouched in stage 1.

## Findings Log
| date | context | finding |
|------|---------|---------|

| 2026-07-28 |  | coord is (n_pillars,6) with BOTH endpoints — so stage 1 (rigid) writes cols 0:2 and 3:5 by the same delta, stage 2 writes them independently. dtype is reader-dependent: float32 for EGRID by default, float64 for GRDECL text — the solver must upcast or the write loses precision. MAPAXES is first-class, NOT in props, and mapaxes_applied records whether coord is already rotated: writing a rotated coord back without un-rotating double-rotates on the next read. |