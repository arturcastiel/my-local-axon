# CD·PLAN·I4·A — final audit

> Last audit. Verify: completeness, coverage, executability, discipline.

## Completeness audit

| Area               | W1 | W2 | W3 | W4+ | Covered? |
|--------------------|:--:|:--:|:--:|:---:|:--------:|
| Schema             | ✔  |    |    |     | ✔        |
| Compiler / tokens  | ✔  |    | ✔  | ✔   | ✔        |
| Governance         | ✔  | ✔  | ✔  |     | ✔        |
| Sessions           |    | ✔  |    | ✔   | ✔        |
| Study mode         |    | ✔  |    | ✔   | ✔        |
| Plan mode          | ✔  | ✔  |    |     | ✔        |
| Testing            | ✔  | ✔  | ✔  | ✔   | ✔        |
| Documentation      | ✔  |    | ✔  | ✔   | ✔        |
| Observability      |    | ✔  | ✔  |     | ✔        |
| Safety             | ✔  |    |    |     | ✔        |
| Umbrella / naming  |    | ✔  |    | ✔   | ✔        |
| Workflows          |    |    |    | ✔   | partial (deferred) |
| Team (deferred)    | —  | —  | —  | —   | non-goal |

All in-scope areas have ≥ 1 PR.

## Goal-tree coverage

Total goals: 93 (91 + 2 added in I1).
- P0 (50): **100%** scheduled within W1-W3.
- P1 (25): ~80% scheduled within W1-W4.
- P2 (12): ~50% scheduled in W4-W5.
- P3 (4, team): all deferred → non-goal.

Unscheduled P1/P2 are explicitly listed as "deferred to W5+" in the plan body.

## DAG final check

Re-running topological sort with all 34 detailed PRs:
```
W1: 1, 2, [3,4 parallel], [5,6,7 parallel]
W2: [8,9,12,13 parallel] → [10,11,14,15,16,17 parallel] (with PR-12 unblocking PR-14)
W3: 18 → 19; [20,21,22 parallel]; [23,24 parallel] → 25
W4: 26 → 27 → 28; [29,30,31,32,33,34 parallel]
```

No cycles. Each PR's deps are within scope.

## Failure-mode final coverage

| Class | Total | W1 | W2 | W3 | W4+ | Already-covered |
|-------|------:|---:|---:|---:|----:|----------------:|
| A     | 3     | 0  | 0  | 0  | 0   | 3 (memory+kernel) |
| B     | 4     | 2  | 2  | 0  | 0   |                 |
| C     | 4     | 2  | 1  | 1  | 0   |                 |
| D     | 3     | 0  | 1  | 1  | 1   |                 |
| E     | 4     | 0  | 2  | 1  | 1   |                 |
| F     | 3     | 3  | 0  | 0  | 0   |                 |
| G     | 3     | 0  | 0  | 0  | 3   |                 |
| H     | 3     | 1  | 0  | 0  | 1   | 1 (memory)       |

Total: 27 modes. 0 orphan.

## Discipline audit

| Discipline                              | In every PR? |
|-----------------------------------------|:------------:|
| Goals row                               | ✔            |
| Files touched (new + modified)          | ✔            |
| Acceptance numbered                     | ✔            |
| Rollback                                | ✔            |
| Owner row                               | ✔            |
| Parallelism note                        | ✔            |
| `lint_paths.py` row (where applicable)  | ✔            |
| Changelog 1-liner                       | added I4     |
| Wave entry/exit gate                    | ✔            |

## Token/scope audit

- W1: 7 PRs ≈ 20-30 turns ≈ 1 focused session (with checkpoints).
- W2: 10 PRs ≈ 30-40 turns ≈ 1-2 sessions.
- W3: 8 PRs ≈ 25-30 turns ≈ 1 session.
- W4+: 9 PRs ≈ 30-40 turns ≈ 1-2 sessions.

Total: ~120 turns to reach end of W4. Realistic across multiple sessions with handoffs.

## Risk register (final consolidated)

| #  | Risk                                                | Wave | Mitigation                       |
|---:|-----------------------------------------------------|-----:|----------------------------------|
| 1  | Migrator breaks live project                        | W1   | dry-run + backup + restore       |
| 2  | Gate too tight                                       | W1   | --override + WARN-first mode     |
| 3  | Wave-1 ALL pre-req for Wave-2                       | W1   | MUST/NICE split (4 MUST only)    |
| 4  | Compile re-compile race                              | W1   | gate ships before recompile      |
| 5  | Renames break dispatch                               | W2-4 | snapshot harness ships first      |
| 6  | Empty rules.md silent-bypass                         | W1   | warn-once + log                  |
| 7  | Cheatsheet bitrot                                    | W3   | docgen auto-section adds in W3   |
| 8  | Sessions overhead                                    | W2   | opt-in initially                 |
| 9  | Compaction loses state mid-PR                        | W1-4 | per-PR checkpoint; resume works  |
| 10 | Strict-mode false-positives                          | W2   | --strict-explain flag            |
| 11 | Idempotence < 80%                                    | W3   | measure first; ratchet           |
| 12 | Provider cache API silent                            | W2-3 | nulls accepted                   |
| 13 | Path-helper drift                                    | all  | lint_paths.py in every PR         |
| 14 | Plan v1 turns out wrong post-execution               | all  | per-wave gate; replan if needed   |

## Non-goals reaffirmed
- multi-actor; library-dev; PR-stack; v5 schema; CI deep; visual UI; sync.

## What this plan does NOT auto-do
- Push to remote (HUMAN consent each time).
- Run pytest (HUMAN runs).
- Run compile (HUMAN runs).
- Modify `axon/`.
- Add features beyond goals listed.

## Verdict
- PLAN v3 + I4 details = **FINAL**.
- No HALT items.
- All P0 scheduled W1-W3.
- All top-10 failure modes mitigated by W3.
- Discipline complete.

→ final plan: `cd-plan-i4-p-final.md`.
