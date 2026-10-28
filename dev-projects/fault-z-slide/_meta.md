# Project: Fault Z-Slide (ZCORN throw)
slug:            fault-z-slide
schema-version:  v4
status:          active
legacy:          false
phase:           4-limits
workflow-step:   done (4-limits complete; next phase not chosen)
branch:          main
codebase:        /mnt/c/projects/library-development/fault-projections
parent:          (none)
sub-projects:    []
created:         2026-10-26
updated:         2026-10-28

## Working Context
- Goal: slide existing faults by editing ZCORN only — corners move ALONG their pillars
  (vertical pillar ⇒ throw; stage-2 tilted pillar ⇒ true dip-slip). COORD + FAULTS invariant.
- Phases 0-spike, 1-prereqs, 2-core COMPLETE (2026-10-28). Released: cpg2python v0.4.0 (7d98aeb),
  fault-projections v0.2.0 (353b049), cpg-fault-fieldbook v0.3.0 (8f5a1ad). All repos main-only,
  no open PRs, no worktrees.
- Library API: `fault_projections.slide_grid/slide_deck/Throw` on `cpg2unstructured.zcorn_ops`.
- User action pending: set fieldbook secret FAULT_PROJECTIONS_TOKEN (read-only PAT) — CI red until then.
- Phase 3-pipeline COMPLETE (2026-10-28): fault-projections v0.3.0 (7222fc4, adapt_deck(slide=),
  validation incl. Norne, guide PDF), fieldbook v0.4.0 (4b09559, lesson 30, guards dropped).
- Phase 4-limits COMPLETE (2026-10-28): fault-projections v0.4.0 (247507e: top_trace two-stage,
  surface_top_trace, live_faces L-shape fix, slide PNG), fieldbook v0.5.0 (8b04e9d: lesson 30 C).
- Next candidates: see phases/4-limits/_meta.md "STILL OPEN".
