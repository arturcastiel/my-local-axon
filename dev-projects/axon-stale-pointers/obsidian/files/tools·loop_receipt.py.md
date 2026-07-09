---
tags: [code, file]
path: tools/loop_receipt.py
---

# tools/loop_receipt.py

> 34 symbol(s) · 1 outbound file dependency(ies)

## Symbols
- `Any`
- `Build {id: latest_known_row} from the ledger tail.`
- `Namespace`
- `Path`
- `Recompute post.checksum vs live target value; flag drift.`
- `Return (begin_row, latest_mutation_row_or_None).      Reverse scan + early break`
- `Scan ledger for orphaned BEGUN rows; promote each to a terminal phase.      Stra`
- `Walk the ledger, recomputing each chained row's expected prev-sha from its     p`
- `_append()`
- `_canonical_checksum()`
- `_iter_ledger()`
- `_last_row_sha()`
- `_latest_phase()`
- `_ledger_path()`
- `_mutate()`
- `_new_id()`
- `_now_iso()`
- `_walk_latest()`
- `cmd_abort()`
- `cmd_begin()`
- `cmd_commit()`
- `cmd_gc()`
- `cmd_list()`
- `cmd_recover()`
- `cmd_rollback()`
- `cmd_show()`
- `cmd_verify()`
- `loop_receipt — two-phase commit ledger for AXON side-effects.  Implements spec ``
- `loop_receipt.py`
- `main()`
- `recover()`
- `sha256 of canonical JSON. For file/jsonl-append targets, callers     pass the ra`
- `sha256 of the last ledger row's serialized bytes — the tail of the hash chain.`
- `verify_chain()`

## Depends on
- [[tools·_axon_io.py]]
