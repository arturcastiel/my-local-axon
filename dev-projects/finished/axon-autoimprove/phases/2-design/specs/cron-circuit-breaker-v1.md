# Cron Circuit Breaker Spec (v1)

> glossary: AXON-GLOSSARY v2
> closes:   FA-13 (cron failure starves overdue jobs), FA-24 (boot synchronously runs cron tick for up to 140s — DoS via failing job + cron-auto)
> resolves: (none new)
> serves:   D-A22 (per-job circuit breaker on cron)
> sibling:  `loop-receipt-v1.md` (auto-disable events log through receipts)

## Purpose

Bound the blast radius of a buggy cron job. Today, `tools/cron.py:283 tick`
attempts at most one job per tick (good) but has **no memory of past
failures** — a job that has failed every run for a week still gets retried
on every tick, and at boot the tick runs synchronously with a 140 s
ceiling (FA-24). One pathological job can:

- Stall boot for the full timeout window every session.
- Hold the cron lock long enough to delay every other overdue job.
- Spam `last_status: error` rows with no escalation.

The circuit breaker auto-disables a job after **N consecutive failures**
(default 3), records the reason, and surfaces the disabled list on the
next menu render under SELF-OBSERVE. A user re-enables explicitly:
`cron enable <id>`.

## Non-goals

- NOT a retry policy with backoff. A failed job's `next_run` advances by
  its normal schedule; the breaker only cares about *consecutive*
  failures, not their timing.
- NOT a kill-switch for the entire cron subsystem. Other jobs continue to
  run normally; only the failing job is disabled.
- NOT a health monitor across reboots. State lives in the existing cron
  job record (`tools/cron.py:_read`); no new ledger.
- NOT replacing the boot timeout. The boot path keeps its existing
  ceiling; the breaker just reduces the cases that reach the ceiling.

## Contract — `tools/cron.py` v1.1

### New job-record fields

```jsonc
{
  "id":            "axon-auto-improve",
  "label":         "Daily auto-improve",
  "schedule":      "daily 03:00",
  "command":       "auto-improve --dry-run",
  "enabled":       true,
  "last_run":      "2026-05-19T03:00:01Z",
  "last_status":   "error",
  "last_detail":   "...",
  "run_count":     12,
  "next_run":      "2026-05-20T03:00:00Z",

  // NEW — circuit breaker fields (all optional, default-zero on legacy rows)
  "consecutive_failures":   3,
  "disabled_at":            "2026-05-19T03:00:01Z",
  "disabled_reason":        "circuit-breaker: 3 consecutive failures (last: timeout after 60s)",
  "breaker_threshold":      3       // per-job override of the global default
}
```

### Breaker logic — tick path

```python
# Inside tick loop, after _run_job(j, ws) returns (ok, detail):

threshold = int(j.get("breaker_threshold") or BREAKER_DEFAULT_N)   # 3

if ok:
    j["consecutive_failures"] = 0
    # disabled_at / disabled_reason are NOT cleared here — only on
    # explicit `cron enable <id>`. Auto-clear would re-open the breaker
    # if the job somehow runs while disabled, which should never happen.
else:
    j["consecutive_failures"] = int(j.get("consecutive_failures") or 0) + 1
    if j["consecutive_failures"] >= threshold and j.get("enabled", True):
        j["enabled"]         = False
        j["disabled_at"]     = now_str()
        j["disabled_reason"] = f"circuit-breaker: {j['consecutive_failures']} consecutive failures (last: {detail[:120]})"
        # Emit an audit event so the next menu render can surface it.
        _emit_event(ws, "axon.cron.breaker-tripped", {
            "job_id":  j["id"],
            "failures": j["consecutive_failures"],
            "last_detail": detail,
        })
```

### Breaker logic — enable / disable / status

- `cron enable <id>` (existing subcommand) — clears `consecutive_failures = 0`,
  removes `disabled_at`, removes `disabled_reason`, sets `enabled = true`.
  Idempotent.
- `cron disable <id>` (existing) — sets `enabled = false`, but does NOT
  set `disabled_at`/`disabled_reason` (those are reserved for breaker
  trips; user-disable is intent, not a fault). User-disable can be
  reversed at any time without breaker state interference.
- `cron status` — extend output to surface tripped jobs:
  ```
  axon-auto-improve   schedule=daily 03:00   ✗ DISABLED (breaker)
    failures=3  last error: "timeout after 60s"
    disabled_at=2026-05-19T03:00:01Z
    re-enable: cron enable axon-auto-improve
  ```
- New verb: `cron breaker-status` (read-only) — lists only tripped jobs.
  Used by menu render to count `breaker-tripped` count for SELF-OBSERVE.

### Global tuning knobs

```python
BREAKER_DEFAULT_N = 3                # default consecutive-failure threshold
BREAKER_DISABLE_AT_BOOT_MAX = 5     # max breaker trips per boot before
                                    # halting tick (defence vs. mass failure)
```

Both are module-level constants in v1 (not L:/W: settings). v1.1 may move
them to `L:cron-breaker-threshold` once a user requests per-installation
override.

## Boot path interaction (FA-24)

`tools/boot.py` calls `cron tick` synchronously. Today's failure mode
(per the deep-audit, B-02 + B-21): a failing job with `cron-auto=true`
gets attempted on every boot, eats ~5–60s of timeout per boot. The
breaker shortcuts this — after the third boot in a row the job is
auto-disabled and subsequent boots skip it entirely (no attempt, no
timeout exposure).

Additional defence: `cron tick` MUST also enforce an outer wall-clock
ceiling on the whole tick:

```python
TICK_WALL_CLOCK_BUDGET_S = 30        # tighten from current 140s

# Inside tick():
tick_start = time.monotonic()
for j in overdue_now:
    if time.monotonic() - tick_start > TICK_WALL_CLOCK_BUDGET_S:
        # Hand remaining jobs to next tick.
        pending.append({"id": j["id"], "label": j.get("label",""),
                        "schedule": j.get("schedule",""),
                        "reason": "tick-wall-clock-budget-exceeded"})
        continue
    ...
```

The rate-limit-of-1-attempt rule (`tools/cron.py:300-302`) stays — the
budget is the second layer.

## Migration

Legacy job rows do not have the new fields. `_read(ws)` MUST default-fill:

```python
for j in data.get("jobs", []):
    j.setdefault("consecutive_failures", 0)
    # Do NOT setdefault disabled_at / disabled_reason — absence is meaningful.
    # Do NOT default breaker_threshold — code falls back to BREAKER_DEFAULT_N.
```

No on-disk migration step is required: the first write after upgrade
persists the new field automatically.

## Test plan — `tests/test_cron_breaker.py`

| Test                              | Setup                                    | Asserts |
|-----------------------------------|------------------------------------------|---------|
| `test_success_resets_counter`     | job with `consecutive_failures=2`, command that succeeds | counter → 0, job stays enabled |
| `test_failure_increments_counter` | job with `consecutive_failures=1`, command that fails    | counter → 2, job still enabled (below threshold) |
| `test_third_failure_trips_breaker`| job with `consecutive_failures=2`, command that fails    | counter → 3, `enabled=false`, `disabled_reason` contains "circuit-breaker", `disabled_at` is ISO-8601 |
| `test_disabled_job_skipped`       | job with `enabled=false` (any reason)    | tick does NOT call `_run_job` for it |
| `test_per_job_threshold_override` | job with `breaker_threshold=5`, 4 prior failures | next failure: counter=5, breaker trips at 5 not 3 |
| `test_explicit_enable_clears_state`| job with `disabled_reason` set         | `cron enable <id>` removes both fields AND zeroes counter |
| `test_user_disable_doesnt_set_reason`| job enabled, user runs `cron disable`| `disabled_reason` remains absent |
| `test_wall_clock_budget_skips_remaining`| 3 overdue jobs; force `time.monotonic` to advance 31s after job 1 | jobs 2 and 3 land in `pending` with `reason="tick-wall-clock-budget-exceeded"` |
| `test_breaker_status_subcommand`  | 2 tripped + 1 normal job                 | `cron breaker-status` JSON lists only the 2 tripped, includes `disabled_reason` |
| `test_legacy_row_default_fills`   | jobs.json missing `consecutive_failures` | tick runs without KeyError; field written back to disk |

Tests follow the same `conftest.py` patterns as `test_cron_*` (if any
exist) or `test_axon_io_r9.py` (hermetic, monkeypatched paths).

## Menu surface (companion change, NOT in this PR)

Once the breaker subcommand exists, a follow-up menu edit adds a
SELF-OBSERVE row:

```
Cron breaker   {N} tripped — run: cron breaker-status
```

Renders only when `N > 0`. Lands as a small Menu PR-A.2 after the cron
PR ships.

## Phase-3 PR mapping

| PR slug          | Scope |
|------------------|-------|
| **PR-AUTO-208**  | This spec, fully implemented: `cron.py` v1.1 + `tests/test_cron_breaker.py` + `cron breaker-status` subcommand. Adds `TICK_WALL_CLOCK_BUDGET_S = 30` ceiling. |
| PR-AUTO-209      | Menu PR-A.2 — SELF-OBSERVE row for cron breaker. |

## Closes / resolves

| Bug / demand | Closes via |
|--------------|------------|
| FA-13 | Breaker auto-disables the offending job after N=3 failures; the per-tick wall-clock budget (30 s) caps cascade damage even for short failure cycles. |
| FA-24 | `cron tick` at boot now bounded by 30 s instead of the current ~140 s. After 3 boots of one failing job, that job is skipped entirely on subsequent boots. |
| D-A22 | Direct delivery: "After 3 consecutive failures, a cron job auto-disables and surfaces a one-line note at next boot." |

## Risks / open questions

| ID  | Concern | Disposition |
|-----|---------|-------------|
| R-1 | A job that's failing because of a transient network issue gets auto-disabled and stays so until user re-enables | Acceptable in v1: surfacing failures to the user is the desired behaviour. v1.1 may add a half-open / probe state after 24 h. |
| R-2 | `_emit_event` doesn't exist yet on cron's side | Adopt the same event-sink helper used by `tools/auto_audit.py` — append a JSONL row to `axon/state/cron-events.jsonl` via `_axon_io.atomic_write` (which now enforces R9 — but `axon/state/` write requires dev-mode, so v1 emits events under `my-axon/memory/local/` instead). Resolved in PR-AUTO-208 by writing to `MYAXON_ROOT/memory/local/cron-events.jsonl`. |
| Q-1 | Should the breaker reset counter on `cron disable` then `cron enable`? | Yes — explicit re-enable is a clean slate. Captured in test `test_explicit_enable_clears_state`. |
| Q-2 | What if `TICK_WALL_CLOCK_BUDGET_S` is too tight for a legitimate long job (e.g. `library-dev ingest`)? | Long-running ingest jobs should NOT be cron jobs in v1; they should be queue jobs. If a legitimate use-case appears, expose `tick_budget_s` as a per-job override (parallel to `breaker_threshold`). |

## Hand-off

- Phase-2 work for FA-13/FA-24 is now complete with this spec.
- Phase-3 PR-AUTO-208 implements both the breaker and the wall-clock
  budget in one PR; small surface (one file + one test file), no R9
  surface (writes go to `my-axon/`).
- Independent of `loop-receipt-v1` and `io-chokepoint-v1` — can land in
  any order.

DONE(cron-circuit-breaker-v1 · 2026-05-19)
