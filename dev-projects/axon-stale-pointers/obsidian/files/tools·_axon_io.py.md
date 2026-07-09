---
tags: [code, file]
path: tools/_axon_io.py
---

# tools/_axon_io.py

> 19 symbol(s) · 3 outbound file dependency(ies)

## Symbols
- `.__init__()`
- `Append a single line (newline-terminated) to path with R9 enforcement.      Used`
- `Atomic file I/O helpers for AXON tools.  Why atomic: concurrent writers (cron +`
- `Convenience: serialize obj to JSON and atomic_write.      Inherits R9 enforcemen`
- `Path`
- `R9WriteError`
- `Raised when a write to AXON_ROOT/axon/* is attempted with L:dev-mode != true.`
- `Read L:dev-mode from the workspace longterm via the canonical reader, so the in-`
- `True iff path resolves under this module's AXON_DIR.      arch-audit #11 FIX: de`
- `True while a FRESH dry-run flag file exists (general-bugfix C8). The flag is`
- `Write content to path atomically with R9 enforcement.      Steps:       0. R9 ga`
- `_axon_io.py`
- `_dev_mode_active()`
- `_dry_record()`
- `_dry_run_active()`
- `_is_axon_path()`
- `atomic_append()`
- `atomic_write()`
- `atomic_write_json()`

## Depends on
- [[_unknown_]]
- [[tools·_axon_paths.py]]
- [[tools·_longterm.py]]
