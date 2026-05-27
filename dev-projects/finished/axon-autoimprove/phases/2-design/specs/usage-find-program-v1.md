# Usage Find-Program Counter Spec (v1)

> glossary: AXON-GLOSSARY v2
> closes:   Synapse AC #10 (manual-program-lookup baseline never captured because the named proxy counter `tools/usage.py find-program` did not exist)
> resolves: G10 deferral inherited from axon-synapse phase-4
> serves:   D-DISC-4 (menu surfaces find-program invocation count as proxy for discoverability gap), D-A09 (warm telemetry baseline)
> sibling:  `loop-receipt-v1.md` (this spec writes only telemetry — no rollback substrate needed; counters are append-only)

## Purpose

Build the literal counter named by synapse acceptance criterion #10. The criterion bound the "did synapse reduce manual program lookup?" question to invocations of `tools/usage.py find-program` — a subcommand that was never written. Two existing tools touch the topic, neither closes the loop:

- `workspace/programs/find-program.md` — the program the *user* invokes to search programs by free-text. Does NOT record its own invocations anywhere.
- `tools/usage.py` — has `record/top/suggest/prune/aggregate`. Knows nothing about find-program semantics; `--kind` is currently restricted to `{program, command, tool}`.

Spec #7 closes the gap by:

1. Adding `find-program` as a valid `--kind` value on `usage record` (so the existing JSONL log captures these events naturally — no schema break).
2. Adding a dedicated `usage find-program` subcommand with three sub-actions (`record`, `count`, `baseline`) — semantic shortcuts so callers don't have to remember the generic-record syntax.
3. Wiring `workspace/programs/find-program.md` to emit a `usage record --kind find-program` call at the end of every invocation (one-line addition).
4. Surfacing the 7-day count on the menu DISCOVER section so it becomes self-monitoring.

## Non-goals

- NOT a search-quality metric. We count *that* the user searched, not whether the search returned useful matches. Quality is a separate metric (could be added later via `--result-rank`).
- NOT a privacy concern: queries are user-typed and stored in plaintext in the same usage-log.jsonl that already holds program/command/tool entries — same scope. No new privacy surface.
- NOT a rate limiter. If the user runs `find-program` 100 times in one minute, all 100 events are recorded. The high count IS the signal.
- NOT a replacement for `top --kind program`. That measures which programs run; this measures which programs the user struggled to find.

## Contract — `tools/usage.py` v1.1

### Schema change

`record` subcommand: `--kind` choices expand from `{program, command, tool}` → `{program, command, tool, find-program}`. Single-line argparse change; no on-disk migration (legacy entries with the old three kinds remain valid; new kind appears only on new entries).

JSONL row shape for the new kind:

```jsonc
{
  "ts":           "2026-05-19T08:11:00Z",
  "kind":         "find-program",
  "name":         "find-program",          // always the program name
  "args":         "auto-improve loop",     // the search query (free text)
  "session":      "axon-2026-05-19-08-00",
  "prompt_label": "",
  "prompt_hash":  "",
  "token_est":    0,
  // existing per-run telemetry fields (in_tokens etc.) — null/unused for this kind
}
```

The `args` field holds the search query. No new column — keeps backward compatibility with every existing `usage` reader.

### New subcommand: `usage find-program`

```
usage find-program record --query <text> [--session S]
usage find-program count  [--window 7d|30d|all]
usage find-program baseline [--rotate]
```

Behaviour:

- **`record --query X`** — shortcut for `usage record --kind find-program --name find-program --args X`. Same JSONL row; same atomic append. Returns `{"recorded": true, "query": X}`.
- **`count [--window 7d]`** — returns `{"count": N, "window": "7d", "uniq_queries": M}` where N is total find-program events in the window and M is the number of distinct `args` strings (case-folded).
- **`baseline [--rotate]`** — snapshot the count for the current calendar month. Writes one file: `MYAXON_ROOT/memory/episodic/baseline-find-program-YYYY-MM.md` (one line: `count: N · uniq_queries: M · window: YYYY-MM-01..YYYY-MM-DD · captured: ISO`). With `--rotate`, the file from the *previous* month is also stamped DONE in its filename (no deletion — episodic is append-only by convention).

### Default-render — `usage find-program` (no sub-action)

Bare `usage find-program` (no positional sub-action) prints the 7-day count + delta vs. prior 7 days:

```
find-program (7d)     N searches · M uniq queries
prior 7d              N' searches · M' uniq queries
delta                 +/- D (+/- ΔM uniq)
```

This is the row the menu DISCOVER section will name.

## `workspace/programs/find-program.md` — one-line addition

Currently the program ends with a `STORE(W:matches, [...])` block and returns the ranked match list. Add one terminal AXON-LANG line:

```
TOOL(usage, "find-program", "record", "--query", query, "--session", session-id)
```

Placement: AFTER the result render (so failed/empty searches still record). The TOOL call is fire-and-forget — its return value is not used. A failure to record MUST NOT prevent the program from returning matches.

This is the only program-side change. Every other find-program invocation path (the menu DISCOVER row, `axon.py run find-program`, the `find-program.md` program called from another workflow) flows through this same program and therefore picks up the recording automatically.

## Menu surface — `workspace/programs/menu.md`

The DISCOVER section landed in PR #17 already names `find-program <text>` as a discoverable verb. This spec adds **one row in the data block + one conditional row in the DISCOVER section** that surfaces the 7-day count:

```
# Data block (near cron-count line)
fp-count-7d ← TOOL(usage, "find-program", "count", "--window", "7d").count | 0
```

```
# DISCOVER section, append to the existing block
→ "     find-program  (last 7d: {fp-count-7d} searches)"   # only when fp-count-7d > 0
```

The conditional rendering follows the existing pattern (`IF fp-count-7d > 0 → → "..."`) — see PR-AUTO-209 for the established template.

## Storage — no new files

All telemetry uses the existing `workspace/memory/longterm/usage-log.jsonl`. Baseline files live under `MYAXON_ROOT/memory/episodic/` which is the canonical home for monthly snapshots (consistent with the auto-improve `baseline-YYYY-MM` convention referenced in `axon-autoimprove/_goal.md:36-37`).

No `axon/state/` writes — keeps R9 surface clean. No new schema. Append-only by construction; cannot corrupt across crashes.

## Test plan — `tests/test_usage_find_program.py`

| Test                              | Setup                                                | Asserts |
|-----------------------------------|------------------------------------------------------|---------|
| `test_record_subcommand_writes_row` | empty workspace                                    | `usage find-program record --query "auto-improve"` appends one JSONL row with `kind=find-program`, `args="auto-improve"` |
| `test_record_via_generic_kind`    | empty workspace                                      | `usage record --kind find-program --name find-program --args X` works identically (schema-level test) |
| `test_count_default_window`       | seed 5 events in last 7d + 3 events older than 7d   | `count --window 7d` returns `count=5`; `--window all` returns 8 |
| `test_count_uniq_queries`         | seed 4 events: queries ["a","a","B","b"]            | `uniq_queries=2` (case-folded) |
| `test_baseline_writes_episodic`   | seed 7 events, no episodic dir                       | `baseline` creates `MYAXON_ROOT/memory/episodic/baseline-find-program-YYYY-MM.md` with `count: 7` line |
| `test_baseline_rotate_keeps_prior`| seed events, prior month's file exists               | `baseline --rotate` leaves prior file in place (renames or stamps; never deletes) |
| `test_default_render_7d_vs_prior` | seed 5 events last 7d + 2 events 7-14d ago           | bare `usage find-program` JSON output has `count=5`, `prior_count=2`, `delta=+3` |
| `test_legacy_record_kinds_still_work` | seed `--kind program` + `--kind command` + `--kind tool` | each succeeds; `--kind find-program` accepted too; `--kind garbage` rejected (argparse choices) |
| `test_kind_filter_isolates_find_program` | mixed log: 3 program + 2 find-program           | `count` reports 2; doesn't bleed into `top --kind program` which still reports 3 |
| `test_atomic_append_under_concurrency` | spawn 10 threads each calling `record --query Xi` | all 10 rows appear; no partial lines (smoke-only; relies on POSIX append atomicity) |

Tests follow the `tools/`-importable pattern from `test_axon_io_r9.py` and `test_cron_breaker.py` — hermetic workspace under `tmp_path`, monkeypatch `MYAXON_ROOT` for episodic test.

## Phase-3 PR mapping

| PR slug          | Scope |
|------------------|-------|
| **PR-AUTO-210**  | This spec, fully implemented: `tools/usage.py` v1.1 (new `find-program` subcommand + extended `--kind` choices) + `tests/test_usage_find_program.py` + one-line edit to `workspace/programs/find-program.md` to record invocations. |
| PR-AUTO-211      | Menu DISCOVER row showing the 7-day count (~3 lines in `menu.md`; same pattern as PR-AUTO-209). |

Both small. PR-AUTO-210 ships dark for one week (no menu surface yet) so the first baseline isn't dominated by AXON's own dogfooding. After 7 days of real usage, PR-AUTO-211 lights up the count.

## Closes / resolves

| Acceptance / demand | Closes via |
|---------------------|------------|
| Synapse AC #10      | Direct: the named subcommand `tools/usage.py find-program` exists and counts manual lookups. |
| G10 deferral        | Same. Baseline becomes capturable via `find-program baseline` once 7 days of data accumulate. |
| D-DISC-4            | Counter surfaces in menu DISCOVER (PR-AUTO-211). Visible discoverability gap signal. |
| D-A09               | Provides one concrete telemetry stream for the warm-baseline criterion. |

## Risks / open questions

| ID  | Concern | Disposition |
|-----|---------|-------------|
| R-1 | If `find-program.md` fails to call `usage record` (network/disk hiccup), the count is silently low | Acceptable: telemetry is best-effort by design. Worst case: under-counted = under-estimated lookup burden = pessimistic-but-safe baseline. |
| R-2 | The user invokes `find-program` via the .md program path vs. some future direct CLI shim that bypasses the .md program | Acceptable in v1: the .md program IS the only documented entrypoint. If a CLI shim appears later, it must also call `usage record` (lint via `r-tool-call-exists` spec #6 once that ships). |
| R-3 | Baseline file in `MYAXON_ROOT` is per-machine; multi-machine users get fragmented data | Out of scope: the user is single-machine for the foreseeable future. v2 can aggregate via `workspace-backup pull` if ever needed. |
| Q-1 | Should `count --window 7d` exclude the current calendar day (rolling 7×24h vs. last 7 calendar days)? | Use rolling 7×24h. Simpler. Matches `read_entries(window=timedelta(days=7))` semantics already used by `top --window 7d`. |
| Q-2 | What does `count` return if `usage-log.jsonl` doesn't exist yet? | `{"count": 0, "window": "7d", "uniq_queries": 0}`. Zero is a valid baseline. |
| Q-3 | Is the 7-day count menu row gated behind dev-mode? | No. It's a passive metric on a discoverable verb — same visibility class as `cron-count` and `q-count`. |

## Hand-off

- Phase-2 work for AC #10 / G10 is complete with this spec.
- Phase-3 PR-AUTO-210 is small: one Python file modified, one Python test file new, one program file +1 line. No R9 surface. No new storage paths. Ship-dark for 7d, then PR-AUTO-211 lights up the menu.
- Independent of `loop-receipt-v1`, `io-chokepoint-v1`, `cron-circuit-breaker-v1`. Can land in any order.

DONE(usage-find-program-v1 · 2026-05-19)
