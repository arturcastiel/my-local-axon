---
tags: [code, file]
path: tests/test_cron_breaker.py
---

# tests/test_cron_breaker.py

> 28 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `A failed job must advance next_run (out of overdue) — not re-attempt every tick`
- `Build a job record that is already overdue.`
- `Force cron-auto so tick will attempt overdue jobs.`
- `Hermetic workspace + my-axon root so events don't leak.      Layout:         tmp`
- `In a tick, the attempted (failing) front job must advance out of overdue so a la`
- `Run cron.main() with the given argv. Returns parsed JSON output.`
- `Tests for the cron circuit breaker (PR-AUTO-208).  Spec: my-axon/dev-projects/ax`
- `Write cron.json with the given job records.`
- `_enable_auto()`
- `_invoke()`
- `_overdue_job()`
- `_read_cron()`
- `_stub_run_job()`
- `_write_cron()`
- `fake_ws()`
- `test_breaker_status_subcommand()`
- `test_cron_breaker.py`
- `test_disabled_job_skipped()`
- `test_explicit_enable_clears_state()`
- `test_failed_front_job_does_not_starve_followers_in_tick()`
- `test_failed_job_advances_next_run()`
- `test_failure_increments_counter()`
- `test_legacy_row_default_fills()`
- `test_per_job_threshold_override()`
- `test_success_resets_counter()`
- `test_third_failure_trips_breaker()`
- `test_user_disable_doesnt_set_reason()`
- `test_wall_clock_budget_skips_remaining()`

## Depends on
- (none)
