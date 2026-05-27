# PR execution DAG — AXON Polish Phase 3-design

> Companion to `01-master-plan.md` and `02-prs.md`.
> Maps the 5 execution waves + dependencies + parallelism opportunities.

## Wave overview

| Wave | Scope | Effort | PRs | BLOCKERs closed | Parallelism |
|---|---|---|---|---|---|
| A | Tier-1 BLOCKER closers | 3-5 days | 8 | 9 | all 8 independent |
| B | Tier-2 BLOCKER closers (gate evasion, write-attr, phase ledger) | 1 week | 5 | 6 | mostly parallel; PR-1.1 unblocks PR-1.2 test4 + PR-16.1 |
| C | Tier-2 follow-on (FAIL migration, workflow bridge) | 1 week | 5 | 0 | parallel within wave; depends on Wave A foundations |
| Decision | ADR-004 accept · ADR-005b PR-design | 1 day | — | — | user input |
| D | Tier-3 (enforcers + predicate vocab + doc pipeline) | 2-3 weeks | ~13 | 7+ | parallel across 3 clusters |
| E | Cross-project handoffs + Phase 5-validate | 1-2 weeks | — | (route) | parallel handoffs |

**Total**: ~6-8 weeks calendar; most work parallelizable.

## Wave A DAG (Tier-1, all parallel)

```
     ┌───────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────┐
     ▼           ▼           ▼           ▼           ▼           ▼           ▼           ▼
   PR-9.1     PR-9.2     PR-12.1     PR-1.2      PR-7.1      PR-2.1      PR-5.1      PR-6.1
   dedupe     dead-      enforce.    R9          context     fail_       workflow    session
   menu/      code       py user:   realpath    L:host-     render       -run         recover
   QS/help    removal    bypass     + tests     model       .py tool    step-count  wire-up

   F-D1-001  F-D6-011  F-D7-007a  F-D8-001    F-D9-001    F-D2-001    F-D4-003    F-D9-022
   F-D1-002             F-D7-007   vec 1-3     F-D9-005    F-D2-007    F-D4-018    F-D9-004
   F-D1-003                                    F-D9-015    +foundation              F-D9-011p
```

No inter-PR dependencies. Any PR can ship first; any PR can be delayed without blocking others.

## Wave B DAG (Tier-2 BLOCKER closers)

```
              ┌──────────────┐
              │   PR-1.1     │  ← ship first in Wave B (unblocks others)
              │ shell.py     │
              │ sandbox      │
              │ + allowlist  │
              └──────┬───────┘
                     │
       ┌─────────────┼─────────────┐
       ▼             ▼             ▼
   PR-16.1      [PR-1.2 test4   PR-6.2
   write-attr   becomes         R_PHASE_TRACKED
   sentinel +   runnable]       + program audit
   pre-commit
   hook
       │                            │
       ▼                            ▼
   F-D6-005a                   F-D9-002 (full)
                               F-D9-011 (full)


              ┌──────────────┐       ┌──────────────┐
              │  PR-3.1      │       │  PR-4.1      │
              │  deprecation │       │  workflow-   │
              │  log + cron  │       │  run light   │
              │  + sweep     │       │  bridge      │
              └──────────────┘       └──────────────┘
              ↑ independent of PR-1.1    ↑ independent of PR-1.1

              F-D2-005                F-D4-002
              F-D5-003                F-D4-014
              D-D5-001                F-D4-015
```

**Critical edge**: PR-1.1 must land before PR-1.2 test 4 (the shell-tool bypass test) can run. PR-1.1 also enables PR-16.1's pre-commit hook to leverage the sandboxed allowlist.

## Wave C DAG (Tier-2 follow-on)

```
   Wave A PR-2.1 (fail_render.py)
                │
       ┌────────┼────────┐
       ▼        ▼        ▼
    PR-2.2  PR-2.3   PR-2.4
    LANG    migrate  lint rule +
    short-  5        extend cleanup
    hand    programs autopatch
              │
              ▼
       (closes F-D2-001/007 fully
        as migration completes)


   Wave A PR-6.1 (recover wire-up)
                │
                ▼
            PR-6.2  ← R_PHASE_TRACKED  (Wave B sibling; can also fit Wave C)


   Wave B PR-4.1 (workflow bridge)
                │
       ┌────────┴────────┐
       ▼                 ▼
    PR-4.2            PR-4.3
    orchestrator      CLEAR(W:orch-last-tick)
    bridge guard      at workflow DONE
```

## Decision-point: between Wave C and Wave D

```
   ┌──────────────────────────────────────────────────────────────┐
   │  USER DECISIONS NEEDED                                       │
   │                                                              │
   │  1. ADR-004 (phase-transition invariant gate)                │
   │     → accept as-is, refine, or reject                        │
   │     → drives PR-4.x phase-gate work in Wave D                │
   │                                                              │
   │  2. ADR-005b (full predicate-vocab BUILTINS)                 │
   │     → already ACCEPTED; needs PR-design pass to convert      │
   │       into PR-5b.1..PR-5b.4                                  │
   │                                                              │
   │  3. C-08 enforcement strategy                                │
   │     → 5 separate ADRs (per-rule) or 1 batch ADR-008          │
   │     → recommend batch — they share output-text-scan strategy │
   └──────────────────────────────────────────────────────────────┘
```

## Wave D DAG (Tier-3 — architectural BLOCKERs)

```
     ┌──────────────┬──────────────┬──────────────┐
     ▼              ▼              ▼              ▼
   C-08          C-05b         C-14           (ADR-004
   5 missing    register      doc-drift /     phase-gate
   enforcers    full          live-count      work — only
                predicate     pipeline        if ADR-004
   PR-8.1..8.5  vocab                         accepted)

   F-D6-001     PR-5b.1..    PR-14.1..3
   F-D6-007     5b.4
   F-D8-002                  F-D3-002
   F-D8-003     F-D4-017     F-D3-009
   F-D8-004     F-D4-017a    F-D3-016
   F-D8-010     F-D4-018     F-D3-017
   F-D8-011-016 (full)       F-D3-002
```

All 3 sub-clusters parallel within Wave D.

## Wave E DAG (handoffs + validation)

```
   ┌────────────┬────────────┬────────────┬────────────┬────────────┐
   ▼            ▼            ▼            ▼            ▼            ▼
 axon-       axon-        axon-         axon-         firing-      5-validate
 cleanup     wiring-      ranker-       copilot-      dag-          stress test
            gaps         v2           anchor        missing
 C-11        C-10         C-13          F-D6-005b    F-D4-016      heavy-workflow
 catalog     explain/     ranker        EXEC drift   DAG-skip      200-turn drill
 grooming    simulate     correctness   F-D5-009     paths
 (cleanup    wiring                     F-D6-016
 owns it)                                drift-log
```

All handoffs parallel.

## Critical-path analysis

The longest dependency chain is:

```
PR-2.1 (Wave A)  →  PR-2.2 (Wave C)  →  PR-2.4 (Wave C; extends cleanup autopatch)
   3 days            3 days               2 days
   ────────         ────────             ────────
   Total: ~8 days for the C-02 FAIL-render lineage to complete
```

The longest BLOCKER-closing chain is:

```
PR-1.1 (Wave B)  →  PR-16.1 (Wave B; depends on sandbox allowlist)
   5 days            3 days
   ─────            ─────
   Total: ~8 days for write-attribution sentinel to be enforceable
```

**Parallelism opportunity**: with 2-3 people working in parallel, Wave A + start of Wave B can fit in ~1 calendar week. Solo dev hits the same waves sequentially, ~3-5 weeks for Waves A+B+C combined.

## Risk-ordered recommendation (1-person sequential)

If only one PR can ship at a time and we want maximum BLOCKER count closed earliest:

| Order | PR | Closes | Rationale |
|---|---|---|---|
| 1 | PR-9.1 | 3 BLOCKERs | Highest BLOCKER-per-effort ratio (mechanical cleanup) |
| 2 | PR-12.1 | 2 BLOCKERs | Security gate; small surface |
| 3 | PR-1.2 | 1 BLOCKER (3 vectors) | Test gap → enforced |
| 4 | PR-6.1 | 2 BLOCKERs | Connects orphaned recover() |
| 5 | PR-5.1 | 1 BLOCKER | Workflow termination |
| 6 | PR-7.1 | 1 BLOCKER | Context limit (Claude 4.x) |
| 7 | PR-2.1 | 0 BLOCKER (foundation) | Unblocks Wave C |
| 8 | PR-9.2 | 0 BLOCKER (MAJOR) | Cleanup |
| ── End of Wave A ── | | | **Cumulative: 9 BLOCKERs closed in ~5-8 days** |
| 9 | PR-1.1 | 3 BLOCKERs | Biggest single BLOCKER closer in entire plan |
| 10 | PR-16.1 | 1 BLOCKER | Closes heredoc bypass |
| 11 | PR-6.2 | 1 BLOCKER (full) | G-02 full coverage |
| ── End of Wave B ── | | | **Cumulative: 14 BLOCKERs closed in ~2-3 weeks** |

**Bottom line for solo sequential**: PR-9.1 first (3 BLOCKERs in half a day), PR-1.1 ninth (biggest single impact). Wave A in 1 week; Wave B in 2 more weeks; 14 of ~24 BLOCKERs closed in 3 weeks.

## File map

This DAG file lives at `phases/3-design/03-dag.md`. Companion files:
- `01-master-plan.md` — strategic ranking of all 16 clusters
- `02-prs.md` — flat PR list with status
- `03-prs/PR-*.md` — individual PR specs (8 drafted to date)
