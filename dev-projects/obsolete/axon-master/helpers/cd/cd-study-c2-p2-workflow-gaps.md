# CD·STUDY·C2·P2 — workflow gaps (what current `study` can't enable)

> Each workflow above is impossible or painful with today's monolithic `study`. Concrete gaps to close.

## G-S1. No mode flag
Today: every invocation is "overview". WF-S2..S10 are simply unrunnable as authored.
**Close:** add `--mode=` switch to `study`.

## G-S2. No target flag
Today: study walks entire codebase. WF-S5 needs `--target=src/billing`.
**Close:** add `--target=<path-or-glob>`.

## G-S3. No diff mode
Today: every run overwrites. WF-S2, S7 need "what changed since last study".
**Close:** add `--diff [--since=<dur>|--since-last]`.

## G-S4. No input mode
Today: study only consumes source files. WF-S9 needs `--input coverage.json`.
**Close:** add `--input <path>` for mode-specific inputs.

## G-S5. No recipe runner
Today: every step is manual. WF-S1, S3, S5, S6 need a recipe.
**Close:** add `--recipe=<name>` reading `workspace/study-recipes/<name>.md`.

## G-S6. No output budget
Today: study can blow context. WF-S6 (whole-repo) is unsafe today.
**Close:** add per-mode token budget; HALT if exceeded with partial output.

## G-S7. No multi-file output
Today: one `01-study.md`. WF-S1, S3 want `study/security.md` separate from `study/overview.md`.
**Close:** write to `study/<mode>.md` (or `study/subsystems/<target>.md`).

## G-S8. No `_index.md`
Today: no manifest of what's been run.
**Close:** auto-maintained `study/_index.md`.

## G-S9. No suggest-next
Today: user invents follow-up.
**Close:** `--suggest-next` flag and integration with `state next`.

## G-S10. No checkpoint / resume
Today: crash mid-run loses progress.
**Close:** `--checkpoint` writes per-subsystem partials; `--resume` continues.

## G-S11. No staleness check
Today: nothing flags "auth study is 90 days old".
**Close:** `study/_index.md` has timestamps; `pr ready` and `state next` warn.

## G-S12. No plan-mode coupling
Today: `plan` reads 01-study.md only. WF-S2 needs plan to read `study/tests.md --mode=risk-first`.
**Close:** `flow plan --from study/ --mode=<plan-mode>` reads the `_index.md`.

## G-S13. No constraint declaration
Today: plan ranks by gut; WF-S5 needs "no schema changes".
**Close:** `--rule "no schema changes"` injected into plan reasoning.

## G-S14. No budget on plan
Today: plan emits everything; WF-S9 needs "top-5 only".
**Close:** `--budget N`.

## G-S15. No replay
Today: plans regenerated from scratch.
**Close:** `flow plan --replay` re-emits prior plan with annotations of what's still valid.

## G-S16. No `data-flow` query mode
Today: zero support. WF-S4, S8 require it.
**Close:** new mode `dataflow --from --to`.

## G-S17. No churn analysis
Today: zero support for `history` mode.
**Close:** new mode `history` consuming `git log --numstat --since=<dur>` from HUMAN.

## G-S18. No coverage delta
Today: see Round-4 G-I3 — already on roadmap.
**Close:** `study --mode=tests --input coverage.json`.

## G-S19. No subsystem isolation
Today: study walks everything. WF-S5 needs `--target=src/billing`.
**Close:** see G-S2.

## G-S20. No executive output
Today: study is engineering-dense. WF-S6 needs an "executive summary" format.
**Close:** `--output executive|engineering|machine`.

## Priority scoring

| Gap   | Impact | Effort | Score |
|-------|:------:|:------:|:-----:|
| G-S1  | 5 | 1 | 5.0 |
| G-S7  | 5 | 1 | 5.0 |
| G-S8  | 4 | 1 | 4.0 |
| G-S2  | 4 | 1 | 4.0 |
| G-S5  | 5 | 2 | 2.5 |
| G-S3  | 4 | 2 | 2.0 |
| G-S12 | 5 | 3 | 1.7 |
| G-S9  | 4 | 2 | 2.0 |
| G-S6  | 4 | 2 | 2.0 |
| G-S11 | 3 | 1 | 3.0 |
| G-S14 | 3 | 1 | 3.0 |
| G-S13 | 3 | 1 | 3.0 |
| G-S20 | 3 | 1 | 3.0 |
| G-S17 | 4 | 2 | 2.0 |
| G-S16 | 5 | 4 | 1.3 |
| G-S18 | 4 | 3 | 1.3 |
| G-S15 | 3 | 2 | 1.5 |
| G-S10 | 3 | 2 | 1.5 |
| G-S4  | 3 | 1 | 3.0 |
| G-S19 | 4 | 1 | 4.0 |

**Top-10 (by score, ties broken by impact):**
G-S1, G-S7, G-S8, G-S2, G-S19, G-S11, G-S14, G-S13, G-S20, G-S4.

These define the **Wave-1 deliverables** for study modes.

→ plan-side gaps in `cd-study-c2-p3-plan-gaps.md`.
