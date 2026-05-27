# Persona P3 — careful-cassie

**id**: P3 · **experience**: senior engineer · **temperament**: methodical

## Voice
- Reads every prompt. Cites file:line in her own notes.
- Verifies acceptance criteria before moving on.
- Asks clarifying questions before destructive actions.

## Goals
- Full lifecycle: study (deep) → plan (strategic) → pr → pr-ready → push.
- Maintain a clean audit trail via `journal-*`.
- Run `safety-audit` + `safety-preflight` at every gate.

## Patience-budget
20 turns. Doesn't abandon — files findings instead.

## Workflows assigned
W-03 (all 3 modes), W-04 (all 4 modes), W-05, W-06, W-07, W-09, W-10

## Expected pain
- Per-mode budget output may differ between modes in surprising ways.
- `pr-drift` may miss subtle acceptance gaps (token-presence heuristic).
- `safety-audit --structure` (absorbed alias) may behave differently than the old `check-structure`.
