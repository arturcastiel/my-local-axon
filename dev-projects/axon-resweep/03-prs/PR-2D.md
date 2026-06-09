# PR-2D — clock time-arithmetic: real offset/today/elapsed/diff-hours/ago subcommands

- **Status:** merged (!138, 8ce3bdb)
- **Phase:** 2-reaudit-fixes  ·  **Complexity:** M  ·  **dev-mode:** no (tools/ + workspace/programs/ + tests/)  ·  **Depends on:** none
- **Source:** re-MEGA F-CLOCK — `clock.py` took NO args, so it ignored every subcommand/flag and returned
  "now". 6 callers computing relative dates/ages/windows silently got "now" → wrong dates, zero ages, dead
  staleness checks.

## Fix
- Rewrote `clock.py` with argparse: the no-arg default is preserved **byte-for-byte** (the ~40 `TOOL(clock)`
  callers reading `.iso`/`.date` are untouched). Added 5 subcommands via literal `add_parser` (so verify.py's
  R_TOOL_CALL_EXISTS sees them — the `choices=` form is what it's blind to):
  - `offset --delta=<[+-]N(d|h|m|s)>` → the timestamp object shifted (`.date` = relative date)
  - `today` → the object for now
  - `elapsed --from <iso>` → `{seconds, hours, human, ...}`
  - `diff-hours --from <iso>` → `{from, hours}`
  - `ago --window <delta>` → `{window, iso, date}` (now − window)
  `_parse_iso` tolerates the episodic-log `+00:00Z` double-tz form; unknown subcommands now fail LOUD (exit 2)
  instead of silently returning "now". The `--delta=-1d` (equals) form dodges argparse's negative-arg gotcha.
- Fixed the 7 caller sites (6 programs) to the real subcommands + the right output field:
  session-summary / turn-log / resume `offset → .date`; resume `elapsed → .human`; code-dev-next
  `diff-hours → .hours` (positional `cached-at` → `--from`); code-dev-meta-usage `ago → .iso`;
  code-dev-meta-dispatch-stats `today → .date`.

## Deferred (PR-2F)
- `session-summary.cmp.md` still carries the old `--offset` form — a stale COMPILED artifact (registered in
  programs/REGISTRY.json but not in any dispatch-index). Regenerated from the now-fixed source by PR-2F (the
  compile-pipeline PR), not hand-edited.

## Acceptance
1. Effect: subcommands return correct relative dates/ages/windows; default shape unchanged; log-tz form parses;
   unknown subcommand fails loud. [test_reaudit_clock.py]
2. Callers use the real subcommands + fields; broken bare-flag/positional forms gone. [test_resweep_program_subcommands.py]
3. Clock-dependent suites (tools_core/tools_kernel/integration/smoke) regress clean.
4. `crucible gate` passed:true.

## Changes
- `tools/clock.py` (rewrite, default preserved) · `workspace/programs/`{session-summary, turn-log, resume,
  code-dev-next, code-dev-meta-usage, code-dev-meta-dispatch-stats}`.md` · `tests/test_reaudit_clock.py` ·
  `tests/test_resweep_program_subcommands.py`
