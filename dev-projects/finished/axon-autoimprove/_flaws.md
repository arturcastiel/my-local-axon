# Flaws register — axon-autoimprove

> Tracked-known design flaws. A flaw without a row here is a defect.

## Status legend

| Symbol | Meaning |
|--------|---------|
| 🟥 open       | flaw acknowledged, no spec fix yet |
| 🟧 spec-fixed | design fix landed in spec; impl pending |
| 🟨 impl-fixed | code change landed; verification pending |
| 🟩 closed     | verified resolved + tests pass + audit clean |
| ⬛ wontfix    | acknowledged + documented as a known limitation |

## Carried in from axon-synapse audit (2026-05-18)

| ID     | Flaw                                                | Inherited from | Status |
|--------|-----------------------------------------------------|----------------|--------|
| FLA-01 | Auto-improve hooks present but inert (PR-120)       | AUDIT risk #5  | 🟧 spec-fixed — D-A01..D-A20 |
| FLA-02 | No baseline for `usage.py find-program`             | AUDIT R3       | 🟧 spec-fixed — _goal #6 |
| FLA-03 | Ephemeral-promotion counter exists, branch not wired| AUDIT R4       | 🟧 spec-fixed — _goal #3 + D-A14 |
| GAP-07 | Phase-4 ranker tuning labels undefined              | synapse `_flaws.md` | 🟧 spec-fixed — closed-loop replaces labels (D-A13) |
| OP-02  | Linear ranker may be inadequate                     | synapse `_flaws.md` | 🟥 open — measured via D-A13 closed-loop; if reverts > N, revisit in v2 |

## New (seeded — phase-2 will expand)

| ID     | Flaw                                                | Status |
|--------|-----------------------------------------------------|--------|
| FA-01  | Cron-tick after long-idle may apply 30d of archive  | 🟧 spec-fixed — D-A17 idle-gap re-confirm + D-A20 rate limit |
| FA-02  | `L:auto-improve` flip-flop double-fires receipts    | 🟧 spec-fixed — D-A05 idempotent key (date, action, target) |
| FA-03  | Auto-tune chasing noise on low-volume signals       | 🟧 spec-fixed — D-A16 sample-size floor ≥ 20 |
| FA-04  | Archive target collision (already archived this month) | 🟥 open — phase-2 design |

## Newly identified at scaffold review (2026-05-18, post-self-audit)

| ID     | Flaw                                                | Detection | Status |
|--------|-----------------------------------------------------|-----------|--------|
| FA-05  | **Open-loop tuning** — auto-tune applies without re-measuring effect; runaway possible | self-audit "is there a bug" | 🟧 spec-fixed — D-A13 closed-loop discipline + _goal #9 |
| FA-06  | **One-way ratchet** — original spec only raised threshold, never lowered → pin at 0.95 | self-audit | 🟧 spec-fixed — D-A16 bidirectional |
| FA-07  | **Receipt-vs-action atomicity** — crash between receipt write & action apply leaves ledger lying | self-audit | 🟧 spec-fixed — D-A15 two-phase write |
| FA-08  | **Drift-gate read path ambiguous** — workspace program reading kernel `drift.state` without contract | self-audit | 🟧 spec-fixed — D-A19 explicit `TOOL(drift, read)` |
| FA-09  | **No global rollback** — per-action undo exists, but no "undo last N days" command for slow-burn regressions | self-audit | 🟧 spec-fixed — D-A18 global rollback + _goal #10 |
| FA-10  | **"Accept" undefined** for ephemeral promotion — clicked vs invoked vs not-dismissed | self-audit | 🟧 spec-fixed — D-A14 precise definition |
| FA-11  | **Idle-gap cascade** — long-idle laptop archives 30 days in one tick without confirm | self-audit (FA-01 extension) | 🟧 spec-fixed — D-A17 |
| FA-12  | **`kv_store.py` exposes no module-level rollback** — auto-tune needs L:-key undo | phase-1 disk inspection | 🟥 open — phase-2 D-AUTO-001 |

## Newly identified at deep code audit (2026-05-19, phase-1 02-deep-audit.md)

> 21 bug candidates surfaced; 12 not already covered by FA-01..FA-12.
> Confirmed sibling-of bugs (B-05 confirms FA-12, B-06 confirms FA-05/FA-06,
> B-07 confirms FA-07, B-11/B-13/B-14/B-20 confirm FA-01/FA-02/FA-11/FA-12)
> recorded in 02-deep-audit.md §4 — not duplicated here.

| ID    | Flaw                                                                                          | Detection | Status |
|-------|-----------------------------------------------------------------------------------------------|-----------|--------|
| FA-13 | **Cron-failure starves all other overdue jobs** — first failure halts the tick loop (B-01)    | 02-deep-audit §4 B-01 | 🟥 open |
| FA-14 | **Drift gate fails open on missing trace** — no trace ⇒ state="stable" ⇒ actions proceed (B-03) | 02-deep-audit B-03 | 🟥 open |
| FA-15 | **R9 write gate is doc-only at code level** — only 2 of ~50 write sites call enforce.py (B-09) | 02-deep-audit B-09 | 🟥 open |
| FA-16 | **`orchestrator.md` calls non-existent TOOLs** — `dispatch fire`, `usage recent`, `pattern clusters` (B-10) | 02-deep-audit B-10 | 🟥 open |
| FA-17 | **synapse-suggest precondition filter silently drops any contract with `≡` predicate** (B-16) | 02-deep-audit B-16 | 🟥 open |
| FA-18 | **Append logs without fsync** — igap, dispatch feedback, audit, episodic all tearable (B-04)   | 02-deep-audit B-04 | 🟥 open |
| FA-19 | **Second daily ratchet in `dispatch.py` with a different cap** than auto-tune (B-06)          | 02-deep-audit B-06 | 🟥 open |
| FA-20 | **`auto-improve.md` does NOT enforce D-A02 (opt-in HARD) or D-A17 (idle-gap re-confirm)** (B-20) | 02-deep-audit B-20 | 🟥 open |
| FA-21 | **`auto_improve.action_auto_archive` has no D-A20 rate limit** (B-13)                          | 02-deep-audit B-13 | 🟥 open |
| FA-22 | **code-dev pseudo-state-machine transitions are unguarded** — any subcommand from any state    | 02-deep-audit §5.3 | 🟥 open — deferred to sibling project `axon-coherence-v2` |
| FA-23 | **`synapse-validate` does not flag references to unknown neurons** (B-17)                      | 02-deep-audit B-17 | 🟥 open |
| FA-24 | **Boot synchronously runs `cron tick` for up to 140s** — DoS via failing job + cron-auto (B-02+B-21) | 02-deep-audit B-02/B-21 | 🟥 open |

## Newly identified at discoverability audit (2026-05-19, phase-1 04-discoverability.md)

| ID     | Flaw                                                                                                | Status |
|--------|-----------------------------------------------------------------------------------------------------|--------|
| DISC-1 | **Discoverability coverage ≈ 12 %** — only ~22 of 182 programs named directly in menu.md            | 🟥 open — menu PRs A/B/C close ~60 % of gap |
| DISC-2 | **Synapse-era capabilities are menu-invisible** — orchestrator, synapse-suggest, dispatch-stats, board, auto-improve never named as commands | 🟥 open — closed by menu PR-A |
| DISC-3 | **Workflow surface (D-8/D-9/D-14) is menu-invisible** — 6 `workflow-*.md` programs + `adaptive-free-text.yml` exist but none named in menu | 🟥 open — closed by new menu section + glossary entries |
| DISC-4 | **`code-dev-meta-*` programs ship with `desc: (autogen-stub — needs description)`** — board, dispatch-stats, igap, usage, context | 🟥 open — closed by menu PR-E |
| DISC-5 | **`tips ← RAND(tips)` is the only surface for ~17 power features** — per-render visibility ≈ 1/22  | 🟥 open — closed by menu PR-B (DISCOVER section demotes tips to trivia) |

## Phase-1 surfaced decisions (escalated to phase-2)

| ID | Decision | Triggers |
|----|----------|----------|
| D-AUTO-001 | kv_store rollback — extend tool or adopt memory.py pattern? | FA-12 |
| D-AUTO-002 | auto-archive vs `axon-memory-compact` — subsume or guard? | FA-04 |
| D-AUTO-003 | R9 enforcement — at IO chokepoint (`_axon_io.atomic_write`) or per-caller? | FA-15 |
| D-AUTO-004 | `r_tool_call_exists` — new lint rule under `tools/rules/` or extend `verify.py`? | FA-16 |

## Roll-up (2026-05-19 — post 02-deep-audit + 04-discoverability)

| Status        | Count |
|---------------|-------|
| 🟥 open       | 20  (OP-02 + FA-04 + FA-12 + FA-13..FA-24 + DISC-1..DISC-5) |
| 🟧 spec-fixed | 14 |
| 🟨 impl-fixed | 0  |
| 🟩 closed     | 0  |
| ⬛ wontfix    | 0  |
| **Total**     | **34** |

Goal: zero 🟥 rows at phase-4 retro.

## Triage process

- A new flaw lands → row added with 🟥.
- Spec fix lands → status 🟧 + decision link.
- Implementation lands → status 🟨 + PR link.
- Tests + audit pass → status 🟩.
- Cannot/wontfix → status ⬛ with rationale.

Audit (Phase-4): zero 🟥 rows is the goal.
