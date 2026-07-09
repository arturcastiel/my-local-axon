---
tags: [code, file]
path: tools/dag_consistency.py
---

# tools/dag_consistency.py

> 19 symbol(s) · 0 outbound file dependency(ies)

## Symbols
- `(source, target) edges from every program's next-suggests list.`
- `Dangling synapse edges: a next-suggests target with no existing neuron.`
- `Every DAG.json under root, at any nesting depth (infinite nesting).`
- `For a DAG.json inside a 03-prs/ dir, reconcile node IDs against sibling PR-*.md`
- `Normalize a PR filename to its canonical node ID (e.g. 'pr-01.md' → 'PR-01').`
- `Set of existing neuron names: program file stems + registered tool names.`
- `Verify every DAG.json (recursively). Returns error/warn issues with path.`
- `_pr_id_from_filename()`
- `build_parser()`
- `check()`
- `check_dag_files()`
- `check_pr_file_sync()`
- `check_synapse_graph()`
- `cmd_check()`
- `dag_consistency.py`
- `discover_dags()`
- `main()`
- `synapse_edges()`
- `valid_neurons()`

## Depends on
- (none)
