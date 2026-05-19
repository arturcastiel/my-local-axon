# Phase 1 — Closure (axon-autoimprove)

slug:            1-study
status:          CLOSED
opened:          2026-05-18
closed:          2026-05-19
duration:        2 days (1 active session)
phase-2-entry:   ready

## Scorecard vs `_meta.md` exit criteria

| Exit criterion                                                       | Status | Evidence |
|----------------------------------------------------------------------|--------|----------|
| All 9 flaws either confirmed or downgraded                           | ✓ MET  | 17 → 34 (12 new FA-13..FA-24 + 5 DISC). All triaged in `_flaws.md` roll-up. Sole open OP-02 deferred to spinout. |
| Each acceptance criterion in `_goal.md` has phase-3 PR placeholder   | ✓ MET  | 10 acceptance items mapped in `03-synapse-retro.md` §4. AC #10 (baseline counter) escalated to `tools/usage.py find-program` build-out. |
| `code-dev plan` ready to fire (phase-2 will populate)                | ✓ MET  | 7 specs queued (see "Phase-2 entry brief" below). |

## Deliverables landed

| # | Deliverable                            | File                                              | Lines |
|---|----------------------------------------|---------------------------------------------------|-------|
| 1 | Findings index                         | `01-study.md`                                     | (existing) |
| 2 | Deep code audit (kernel↔code, bugs, synapse/DAG/state coverage, new-tool rec) | `02-deep-audit.md` | 868 |
| 3 | Synapse retrospective (original goals vs shipped) | `03-synapse-retro.md`                  | 455 |
| 4 | Discoverability audit (infrastructure-vs-menu gap) | `04-discoverability.md`              | 400 |
| 5 | Flaws ledger update (12 FA + 5 DISC + 4 ADR)      | `../../_flaws.md`                     | +50 rows |
| 6 | Demands ledger update (7 D-A + 5 D-DISC)          | `../../_demands.md`                   | +12 rows |
| 7 | Closure (this file)                                | `_closure.md`                          | — |

## Key findings — one-line each

- **Bug-class headline**: R9 enforcement is doc-only at code level (only 2 of ~50 writers call `enforce.py`). [FA-15 / B-09 / D-A21]
- **Synapse-coverage headline**: orchestrator calls 3 non-existent tools (`dispatch fire`, `usage recent`, `pattern clusters`). [FA-16 / B-10 / D-A27]
- **Reversibility headline**: `kv_store` has no rollback substrate. `loop-receipt` (new tool, PR-AUTO-201) is the chosen substrate; resolves D-AUTO-001 + provides D-A25. [FA-12 / D-AUTO-001]
- **Discoverability headline**: ~12% of programs are named in menu.md; the entire workflow surface (D-8/D-9/D-14) was menu-invisible. [DISC-3]
- **Workflow demand status**: D-8/D-9/D-14/D-25 all shipped on disk (`workspace/programs/workflow-*.md` + `workspace/workflows/adaptive-free-text.yml`). Phase-1 Menu PR-A surfaces them.

## Decisions surfaced (escalated to phase-2)

| ID         | Decision                                                                    | Owner   |
|------------|-----------------------------------------------------------------------------|---------|
| D-AUTO-001 | kv_store rollback — extend tool or adopt memory.py pattern?                 | resolved: `loop-receipt` (D-A25) |
| D-AUTO-002 | auto-archive vs `axon-memory-compact` — subsume or guard?                   | open    |
| D-AUTO-003 | R9 enforcement — IO chokepoint (`_axon_io.atomic_write`) or per-caller?     | open    |
| D-AUTO-004 | `r_tool_call_exists` — new rule under `tools/rules/` or extend `verify.py`? | open    |

## Phase-2 entry brief — specs to author

| # | Spec                                                | Closes                                           | Priority |
|---|-----------------------------------------------------|--------------------------------------------------|----------|
| 1 | `loop-receipt-v1.md`                                | B-04, B-06, B-07, B-14, B-20, FA-12, D-A25       | **first** |
| 2 | `io-chokepoint-v1.md`                               | FA-15, D-A21, D-AUTO-003                         | high |
| 3 | `cron-circuit-breaker-v1.md`                        | FA-13, FA-24, D-A22                              | high |
| 4 | `drift-fail-closed-v1.md`                           | FA-14, D-A23                                     | med |
| 5 | `predicate-evaluator-wiring-v1.md`                  | FA-17, D-A26                                     | med |
| 6 | `r-tool-call-exists-v1.md` (lint rule)              | FA-16, D-A27, D-AUTO-004                         | med |
| 7 | `usage-find-program-v1.md` (baseline counter)       | Synapse AC #10, D-DISC-4                         | high |

## Spinout projects (sibling) — proposed

| Slug                  | Scope                                                  | Triggers      |
|-----------------------|--------------------------------------------------------|---------------|
| `axon-coherence-v2`   | Real FSM for code-dev (replace pseudo-state-machine)   | FA-22         |
| `axon-ranker-v2`      | Predicate evaluator + feedback signal capture          | FA-17, OP-02  |
| `axon-io-chokepoint`  | Centralise R9 enforcement at the IO layer              | FA-15         |

## Hand-off to Phase 2

- `STATUS.md` (project root) → bump `phase: 1-study` → `phase: 2-design`.
- `code-dev plan` should be fired against this `_closure.md` next, with spec #1 (`loop-receipt-v1.md`) as the first plan row.
- All session studies (`02-deep-audit.md`, `03-synapse-retro.md`, `04-discoverability.md`) remain authoritative inputs for phase-2 — phase-2 specs CITE these files, do not re-derive.

DONE(phase-1-closure · axon-autoimprove · 2026-05-19)
