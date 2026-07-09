---
tags: [code, file]
path: tools/dag.py
---

# tools/dag.py

> 70 symbol(s) · 1 outbound file dependency(ies)

## Symbols
- `.__init__()`
- `A mutation produced a structurally-invalid DAG (cycle / dangling edge). The`
- `Add a `pr` node per PR (deduped by number) + a `depends` edge per declared depen`
- `All transitive dependents of `node_id` — the downstream nodes that must be     r`
- `Any`
- `ArgumentParser`
- `Backward cascade-invalidation: mark every descendant of `node_id` `stale`     (p`
- `Coerce a legacy node into v1 dict shape.`
- `DagIntegrityError`
- `Integrity-guarded save for the edge-rewiring commands: on a cycle/dangling     v`
- `Kahn's algorithm. Returns a member of a cycle if any, else None.`
- `Longest path by edge count over the depends DAG.`
- `Lossless migration to v1 schema.      Adds schema + schema-version + level (heur`
- `Merge nodes `ids` into a new node `into`. Edges are redirected.`
- `Move every edge touching child_id to `into`, then remove child_id.`
- `Namespace`
- `Path`
- `Regenerate sibling DAG.md and return its text.`
- `Return a list of issues. Each issue: {level, code, detail}.`
- `Shared cascade-invalidation core (PR-001 axon-code-dev-improve): mark every`
- `Split `node_id` into `into_ids`. Incoming and outgoing edges are duplicated.`
- `Tally a DAG's nodes by status and kind.      Status-agnostic: counts whatever ```
- `Verify every DAG.json under root recursively. Returns per-file results.`
- `Write JSON atomically (tmp + rename). Stable key order.      PR-002 (axon-code-d`
- `_atomic_write()`
- `_find_node()`
- `_normalize_edge()`
- `_normalize_node()`
- `_now_iso()`
- `_read_dag()`
- `_save_and_render()`
- `_save_guarded()`
- `add_edge()`
- `add_node()`
- `build_from_prs()`
- `build_parser()`
- `cascade_stale()`
- `cascade_stale_marks()`
- `cmd_add_edge()`
- `cmd_add_node()`
- `cmd_bootstrap()`
- `cmd_build_from_prs()`
- `cmd_fold_in()`
- `cmd_merge()`
- `cmd_migrate()`
- `cmd_remove_edge()`
- `cmd_remove_node()`
- `cmd_render()`
- `cmd_set_status()`
- `cmd_split()`
- `cmd_summary()`
- `cmd_sync()`
- `cmd_verify()`
- `critical_path()`
- `dag.py`
- `descendants()`
- `detect_cycle()`
- `fold_in()`
- `main()`
- `make_empty()`
- `merge_nodes()`
- `migrate_file()`
- `remove_edge()`
- `remove_node()`
- `render_md()`
- `set_status()`
- `split_node()`
- `summarize()`
- `sync_project()`
- `verify()`

## Depends on
- [[_unknown_]]
