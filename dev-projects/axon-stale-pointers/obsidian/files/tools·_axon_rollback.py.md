---
tags: [code, file]
path: tools/_axon_rollback.py
---

# tools/_axon_rollback.py

> 16 symbol(s) · 1 outbound file dependency(ies)

## Symbols
- `AXON rollback helpers — generalized 3-version snapshot pattern.  Lifts the algor`
- `Map W:<key> → <workspace>/memory/working/<key>.md.`
- `Path`
- `Restore `target` from its Nth-most-recent snapshot.      version=1 is the latest`
- `Return <target_dir>/.rollback/ for a given target file path.`
- `Return existing snapshots for `target`, newest first.`
- `Stash current contents of `target` to its .rollback/ dir.      No-op when target`
- `_axon_rollback.py`
- `_now_compact()`
- `_snapshot_filename()`
- ``<basename>-<ts>.<ext>` (ext kept so the snapshot looks like the original).`
- `list_snapshots()`
- `restore()`
- `rollback_dir()`
- `snapshot()`
- `w_key_path()`

## Depends on
- [[tools·_axon_io.py]]
