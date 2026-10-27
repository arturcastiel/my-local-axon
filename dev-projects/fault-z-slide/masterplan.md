# Masterplan — Fault Z-Slide (ZCORN throw)

## Phase graph (directed)

- **0-spike** → 1-prereqs → 2-core → 3-pipeline → 4-validation → 5-docs
  (1-prereqs may run in parallel with the spike; 2-core needs both)

| Phase | Skeleton | Repo(s) | Content |
|-------|----------|---------|---------|
| 0-spike (complete) | — | fault-projections (`spike/z-slide`, NOT FOR MERGE) | Synthetic closed-block deck: fault faces → side split → rigid Δz on one side → INCLUDE → read back with fault-aware faces. Proves corner addressing + split-pillar idea. Throwaway. |
| **1-prereqs** (active) | P0 | cpg2python, fieldbook | ✅ P0.1 D1 (+D4 face-area fix; cpg2python 1eef539, v0.3.0): `build_topology` → fault-aware `find_i_faces`/`find_j_faces` (spike: confirmed same-k pairing across a 15 m throw). ✅ P0.2 fieldbook CI access to private fault-projections (user chose token secret `FAULT_PROJECTIONS_TOKEN`); renumber duplicate `01_` examples (→ 01–18 sequential). ✅ P0.3 `read_grdecl`: skip multi-record keywords (FAULTS, MULTFLT, …) to their empty `/` (spike finding). |
| 2-core | P1–P4 | cpg2python + fault-projections | P1 `zcorn_ops` (corner addressing, `apply_zcorn_displacement`, `zcorn_validity`). P2 `slide.py` (`SlideSpec`, constant/tip_taper/table, side resolution via `FaultCellMap`, auto hanging wall, split lattice). P3 far-field (closed-block flood-fill; rigid / Laplacian decay via `morph.laplacian_matrix`; auto). P4 validity gate + scale bisection → `SlideResult`. |
| 3-pipeline | P5–P6 | fault-projections | P5 juxtaposition / throw / NNC report. P6 `slide_grid`, `slide_deck`, `adapt_deck(slide=…)`, INCLUDE + FAULTS-invariant + VTK/PNG. |
| 4-validation | P7 | both libs | Synthetic closed block, fault-with-tip, dipping deck (stage-2), Norne. Invariants: Δ=0 identity, +Δ/−Δ round-trip, COORD & FAULTS unchanged, thickness preserved. |
| 5-docs | P8 | cpg-fault-fieldbook | examples 19 (slide) / 20 (dip-slip) (renumbered: 01–18 taken after P0.2); `functions/slide-faults.md`, `learn/throw.md`, `cases/relay-ramp.md`; api-inventory; `upstream-lock.toml` bump. |

Phases are added by: code-dev phase new
