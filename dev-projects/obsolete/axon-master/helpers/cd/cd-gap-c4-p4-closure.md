# CD·GAP·C4·P4 — closure: ready for plan

> R6 (gap-closure) is complete. This file is the signal: the study phase has reached "ready". No new study work needed before the plan.

## Five rounds, 70 helpers

| Round | Theme                          | Helpers | Output                                              |
|------:|--------------------------------|--------:|-----------------------------------------------------|
| R2    | Code-dev baseline              | 10      | 4-cycle deep study (gaps, tokens, improvements, web) |
| R3    | tools/ umbrella reorganization | 4       | inventory, umbrella design, migration, prior art    |
| R4    | Workflows                      | 16      | canonical flows, cookbook, industrial gaps, roadmap |
| R5    | Study + Plan modes              | 16      | modes taxonomy, composition, integration, targets   |
| R6    | Gap-closure (THIS round)        | 16      | coverage audit, deep gaps, cross-cutting, goal tree |
| **Σ** |                                | **62 R2-R6 helpers** (+ R1=8 ⇒ 70 cumulative; some early helpers folded into 01-study.md) |     |

## Final inventory of normalized goals
**91 goals** across 13 areas (A-M). Documented in `cd-gap-c4-p1-goal-tree.md`.

- P0: ~50 (must-have for wave-1)
- P1: ~25
- P2: ~12
- P3 (deferred): 4 (the G.team.* set)

## What we know with high confidence
- Code-dev's surface (57 verbs) is well-mapped.
- File-rename strategy is safe IF rename-safety harness (G.umb.04) ships first.
- Schema migrator (G.inf.02) is the single largest unblocker — gates resume, study folder, and v5 path.
- Compile-gate (G.tok.02) is cheap and prevents an entire class of regressions.
- Governance precedence (U-5) is documentable; rules are simple enough that conflicts are rare.

## What we know with moderate confidence
- Token costs per program — needs measurement.
- Cache-hit rates — depends on provider API & static-prefix discipline.
- Idempotence ratio of `code-dev study` — needs measurement, target ≥ 80%.

## What we deliberately don't know yet
- v5 schema final shape — wait until v4.1 is in production.
- Whether to centralize docs under `docs/` or keep scattered.
- Real failure-rate baseline — no telemetry yet (G.obs.01 will fix).
- Team mode shape — out of scope for this plan.

## Failure modes catalogued
- 8 classes (A-H), ~30 specific modes.
- Top-10 priority list ready.
- 6 of top-10 already mitigated; 4 require this plan.

## Rules captured for the plan
- Kernel rules: non-negotiable.
- User memory rules (operational-safety, post-compaction boot): non-negotiable.
- `safety/rules.md` and `dont-do.md` schemas defined; files not yet populated (plan may proceed with empty).
- AGENT contract: non-negotiable.

## What R6 did NOT do (deliberate)
- Did NOT create the plan.
- Did NOT write any code in `tools/` or `workspace/`.
- Did NOT modify any compiled programs.
- Did NOT push to remotes (this happens at end of round, with consent).
- Did NOT touch `axon/` (dev-mode not enabled this turn).

## Readiness signal

```
study.phase           : 1-study-complete-r6
study.coverage        : 13 areas complete
study.goals           : 91 enumerated, prioritized
study.gaps-remaining  : 0 critical (within scope)
study.deferred        : G.team.* (multi-actor, v5)
plan.ready            : TRUE
plan.recommended-mode : tactical (--wave=1)
plan.suggested-input  : "tactical, wave-1 P0 subset, ~10-15 PRs"
```

## Next step (waiting for user)
The user will issue a command of the form:
```
code-dev plan --mode=tactical --wave=1 [--rule "..."]
```
or equivalent free-text:
```
make the plan
```

When that arrives, the planner will:
1. Load this readiness checklist.
2. Load goal tree + priority matrix.
3. Load `safety/rules.md` + `dont-do.md` (if any).
4. Emit wave-1 plan (~10-15 PRs).
5. Append governance trace.
6. Write to `03-plan.md` + `decisions/` + `pr-1..pr-N` blocks in `_meta.md`.

Until then: **stand by**.

## How to read this folder

```
my-axon/dev-projects/axon-master/
├── _meta.md                      # project state (v1; will migrate)
├── 01-study.md                   # study overview
├── 02-prs.md                     # PR tracker (empty until plan)
├── 03-plan.md                    # plan output (empty)
├── 04-log.md                     # round-by-round journal
├── INDEX.md                      # helpers index by round
├── _actions.log                  # JSONL events
└── helpers/
    ├── cd-c1-*.md … cd-c4-*.md          (R2)
    ├── cd-tools-*.md                     (R3)
    ├── cd-wf-c1-*.md … cd-wf-c4-*.md    (R4)
    ├── cd-study-c1-*.md … cd-study-c4-*.md (R5)
    └── cd-gap-c1-*.md … cd-gap-c4-*.md  (R6, this round)
```

Spine for the plan-reader:
1. `cd-gap-c4-p3-readiness-checklist.md` ← start
2. `cd-gap-c4-p1-goal-tree.md`
3. `cd-gap-c4-p2-priority-matrix.md`
4. R2-R5 helpers as deep references on a per-goal basis.

— end of round 6 —
