---
tags: [code, file]
path: tools/checkpoint.py
---

# tools/checkpoint.py

> 22 symbol(s) · 1 outbound file dependency(ies)

## Symbols
- `Move snapshot-shaped working/*.json into working/.snapshots/ (idempotent). Real`
- `Parse the episodic session-log table into [{time, event, notes}] rows.`
- `Read every W: file under working_dir into a {key: value} dict (F44 captures .jso`
- `Read the snapshot and rewrite each captured W: file (F44: .md and .json).`
- `Return (ts, iso, date) tuple for log entries.`
- `Snapshot path for `label` — prefers .snapshots/, falls back to a legacy working/`
- `Time-travel view: W: state + session context as of a checkpoint (read-only).`
- `True if `path` is a checkpoint snapshot (vs real W: json) — has label+timestamp+`
- `_append_session_log()`
- `_is_snapshot_doc()`
- `_migrate_legacy_snapshots()`
- `_now()`
- `_read_session_log()`
- `_read_working()`
- `_resolve_snap_path()`
- `_snapshots_dir()`
- `checkpoint.py`
- `cmd_list()`
- `cmd_replay()`
- `cmd_restore()`
- `cmd_save()`
- `main()`

## Depends on
- [[tools·_axon_paths.py]]
