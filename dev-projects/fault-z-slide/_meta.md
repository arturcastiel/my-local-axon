# Project: Fault Z-Slide (ZCORN throw)
slug:            fault-z-slide
schema-version:  v4
status:          active
legacy:          false
phase:           2-core
workflow-step:   build
branch:          main
codebase:        /mnt/c/projects/library-development/fault-projections
parent:          (none)
sub-projects:    []
created:         2026-10-26
updated:         2026-10-27

## Working Context
- Goal: slide existing faults by editing ZCORN only — corners move ALONG their pillars
  (vertical pillar ⇒ throw; stage-2 tilted pillar ⇒ true dip-slip). COORD + FAULTS invariant.
- Builds on fault-smo-mesh-adaptation (xy-adapt puts faults on pillar lines) and
  cpg-to-unstructure (faulted-ZCORN topology reader).
- Decisions from 3-round interrogation: phases/0-spike/_decisions.md (ADR-001…ADR-011).
- Skeleton P0–P8: masterplan.md. User chose to start with a SPIKE (phase 0-spike).
- D1 DONE: cpg2python 1eef539 on `fix/d1-fault-aware-topology` (v0.3.0, local, not pushed)
  — build_topology fault-aware + D4 face-area fix. P0.3 reader DONE (2d41127, stacked branch
  `fix/grdecl-multirecord-keywords`). P0.2 fieldbook CI token DONE (ac0ef09).
- Examples DONE: fieldbook branch `docs/z-slide-examples` @ 59c3c57 (lessons 19, 20, wiki page
  learn/z-slide.md). Lesson 21 (oblique fault) WRITTEN, NOT YET COMMITTED — see
  phases/1-prereqs/handoff.md (saved 2026-10-26) for exact resume steps.
- Next after lesson 21: P1 `zcorn_ops` in cpg2python (stack on fix/grdecl-multirecord-keywords),
  then P2 slide in fault-projections (rigid + tapered modes, X/Y faces), D2 as P0.4.
