# Implementation Log — axon-state-singlewriter (F43/F44)

> Two findings: F43 (divergent L: writers) + F44 (checkpoint loses JSON W: state + conflates snapshots).
> Each PR gate-verified green, branch-first (one branch-first slip on PR-2, caught + recovered — see below).

## Merged — 2026-05-30
| PR | MR | What |
|----|----|------|
| PR-1 (F43) | !92 | Single L: writer `_longterm.write_from_workspace` — atomic os.replace via _axon_io, trailing newline, capped indented-JSON rollback. memory.py's set-L: branch + session_save's summary/snapshot writes both delegate. session_save's old `write_longterm` was **dead code** — deleted. Byte-identical parity test vs memory.py CLI. |
| PR-2 (F44) | !93 | checkpoint captures `.json` W: state (keyed with extension → restored to `<key>.json`); snapshots relocated to `working/.snapshots/`; save/restore/list/replay all use it; legacy snapshot-shaped `working/*.json` auto-migrate; real W: json left in place; old bare-key snapshots still restore as `.md` (back-compat). |
| PR-3 (lock) | !94 | Lock the single-writer invariant: memory.py + session_save must keep delegating to _longterm; writer API must persist. |

**main f0ce399 · gate 22/0 on each.**

## Verified complete (not just "the two we knew about")
Scanned all of tools/ for L: writers: **memory.py and session_save.py are the only two**, and both now
delegate. No stragglers — F43's "single writer" is genuinely achieved, not approximated.

## Incident (caught + recovered)
PR-2 (F44) was committed on local `main` before branching (the recurring branch-first trap). Caught
immediately via `git rev-list origin/main..HEAD` = 1; recovered by `git branch fix/f44-checkpoint-json`
(preserve the commit) → `git reset --hard origin/main` → push the branch → merge via !93. origin/main
was never polluted. Lesson reinforced: **branch BEFORE the first edit, every time.**

## Scope note
A broad static "no raw longterm write anywhere" scanner was considered for PR-3 and rejected as fragile
(L: paths are constructed too many ways to match robustly). The behavioural parity test (format) + the
targeted delegation lock (the two known writers) are the regression net.
- 2026-07-09: pointer-repair (axon-stale-pointers): _meta.phase advanced to 'audit' (was behind a done phase)
- 2026-07-09: pointer-repair (axon-stale-pointers): status active->complete — MANIFEST-BACKED closeout (every phase done); the project was finished but never closed out (the inverse of the unbacked-claim class).
