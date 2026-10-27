# Phase: 2-core
schema-version: v4
status:         active
workflow-step:  build
branch:         feat/slide (fault-projections), feat/general-fault-faces + fix/gallery-gaps (worktrees)
current-pr:     fault-projections #2 (slide); cpg2python #47 merged (zcorn_ops)
created:        2026-10-27

## Working Context
- P1 DONE: cpg2python `zcorn_ops` (zcorn_cube, with_zcorn, apply_zcorn_displacement,
  unwelded_faces, zcorn_validity) — PR #47 merged (03b65cc). Also bound 6 unbound `__all__` names.
- P2–P6 DONE on fault-projections `feat/slide` (PR #2): `slide.py` ported from fieldbook
  zslide.py; bit-identical on 8 comparison cases; fixes prototype ring-closing patch. 15 tests.
- Agents: cpg-faces (D2, inactive, pinch-out) in wt-cpg2python-faces; fp-gaps (faults_after,
  path spurs, ragged adapt, taper, pinned rim, vtk precision/.vtu/.pvd, INCLUDE, deck names)
  in wt-fault-projections-gaps.
- Next: merge agents' branches, releases, `adapt_deck(slide=)`, fieldbook migration, Norne.
