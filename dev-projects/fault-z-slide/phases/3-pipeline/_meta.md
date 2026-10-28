# Phase: 3-pipeline
schema-version: v4
status:         complete
workflow-step:  build
branch:         main (all repos)
current-pr:     (none) — merged: fault-projections #5 #6, fieldbook #2
completed:      2026-10-28
created:        2026-10-28

## Working Context
- Goal: masterplan P6 (adapt_deck slide hook), P7 (validation incl. Norne), P8 (docs), lesson
  clean-up, guide PDF. User: "continue until the end, work freely".
- DONE: fault-projections v0.3.0 (7222fc4):
  - #5 `adapt_deck(slide=, slide_options=)`: morph → slide_grid on regenerated faults (deck FAULTS
    merged, regenerated names win) → write. `AdaptResult.slide`, `.slide_report_path`;
    `.grid` = adapted+slid, `.slide.before` = adapted. SlideError raises before any write;
    no regenerated faults → ValueError. 5 tests.
  - P7 tests: tilted pillars (rigid + tip): COORD/ACTNUM equal, every k-slot shifted alike
    (thickness kept), zero throw identity, ±6 m round trip 1e-9; slide_deck leaves deck + FAULTS;
    Norne E_01 5 m + BC 3 m via a wrapper deck (env CPG_NORNE_GRDECL or opm-tests path; skips).
  - Engineer's guide: J.1 slide API + adapt_deck(slide=); PDF rebuilt (69 pages, build.py, pandoc
    + pdflatex; `$\pm 5$` not `$\pm$5` — pandoc rejects a closing $ before a digit).
  - #6 release: CHANGELOG [0.3.0], tag + GitHub release.
- DONE: fieldbook v0.4.0 (4b09559, PR #2): lesson 30 deck_slide_workflows (A adapt_deck(slide=)
  == adapt_deck + slide_grid bit for bit; B Norne slide_deck: 8 faces open, round trip 4.5e-13,
  volume ≤ 2.37 %, 17,972 connections; --deck/--throw for user decks; skips without Norne).
  Lessons 23–29 drop interior/close_ring (verified no-ops by making them raise). Pins → 0.3.0.
  46 tests + 30 lessons pass locally; CI red only for missing FAULT_PROJECTIONS_TOKEN.
- Norne facts: 46x112x22, 44,927 active, 61 named faults all simple chains; 8 faults probed
  (m_west, m_east, C_01, E_01, G_01, DI, BC, C_26) slide ok, 0 unexpected, 0.1–0.4 s each.
- STILL OPEN: k-direction faults; skew-pillar volume drift (≤ 4.4 % Norne); L-shaped active
  region → faces_invariant False; stage 2 alone no chain; optional docs learn/throw.md,
  cases/relay-ramp.md; user must set FAULT_PROJECTIONS_TOKEN.
