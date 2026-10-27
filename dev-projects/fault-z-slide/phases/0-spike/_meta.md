# Phase: 0-spike
schema-version: v4
status:         complete
workflow-step:  build
branch:         main
current-pr:     (none)
created:        2026-10-26

## Working Context
- Spike: synthetic closed-block slide end-to-end on branch `spike/z-slide` (NOT FOR MERGE).
- Exit criteria: (1) one side's corners on fault pillars shifted, other side untouched;
  (2) COORD + FAULTS unchanged; (3) INCLUDE written; (4) read-back via fault-aware
  `find_i_faces` shows the expected fault connections; (5) findings feed 2-core design.
- 2026-10-26: SPIKE PASSED — all 5 exit criteria met (A vertical + B tilted). Findings in
  01-study.md: D1 confirmed blocker; new reader gap P0.3 (multi-record keywords).
  Spike committed locally on `spike/z-slide` @ 213e3af (NOT FOR MERGE). Next: 1-prereqs.
- 2026-10-26: re-run on D1 topology → build_topology now matches find_i_faces (12 conns).
