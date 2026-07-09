---
tags: [code, file]
path: tools/cron.py
---

# tools/cron.py

> 29 symbol(s) · 3 outbound file dependency(ies)

## Symbols
- `Accept full or 3-letter day names; return weekday index 0..6.`
- `Append a JSONL audit event under MYAXON_ROOT/memory/local/cron-events.jsonl.`
- `Assemble the subprocess argv for a cron job's `program` field.        • path for`
- `Compute next scheduled datetime from a given reference point.`
- `Execute a single cron job in-process via subprocess.      Returns (ok: bool, det`
- `Read an L: kv-store value (workspace/memory/kv-store/<key>.md).`
- `Strip machine-specific absolute paths from a job's detail before it is persisted`
- `Update breaker state on a job record after a run attempt.      Returns True iff`
- `_apply_breaker()`
- `_build_job_cmd()`
- `_emit_event()`
- `_lock()`
- `_read()`
- `_read_kv()`
- `_resolve_day()`
- `_run_job()`
- `_sanitize_detail()`
- `_unlock()`
- `_write()`
- `cron.py`
- `cron_path()`
- `datetime`
- `is_overdue()`
- `lock_path()`
- `main()`
- `new_id()`
- `next_run()`
- `now_str()`
- `now_utc()`

## Depends on
- [[_unknown_]]
- [[tools·_axon_paths.py]]
- [[tools·usage.py]]
