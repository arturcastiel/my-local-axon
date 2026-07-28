---
tags: [code, file]
path: tools/code_graph.py
---

# tools/code_graph.py

> 36 symbol(s) · 1 outbound file dependency(ies)

## Symbols
- `A human-navigable markdown 'map of AXON' — openable in Obsidian. Deterministic.`
- `ArgumentParser`
- `Deterministic community detection (label propagation).      Sorted node processi`
- `Deterministic liveness signals the `calls` edges cannot see (dead-code only).`
- `In-tree import edges + a name→module map for call resolution.      Returns (impo`
- `Lexicographic walk of *.py under root (deterministic), skipping caches/tests.`
- `Match a node id by exact id, then by `:name` suffix, then by substring (sorted,`
- `Module`
- `Module ids under `root` whose script is registered in tools/REGISTRY.json.`
- `Node ids called or name-referenced from <root>/../tests/*.py (deterministic).`
- `Path`
- `Print the result, or write it to `out` and print a confirmation envelope.`
- `Public functions/methods unreachable by any deterministic liveness signal.`
- `Resolve intra-tree call targets within a function/method body (best-effort, dete`
- `Reverse blast-radius: nodes that (transitively) point INTO the matched node(s).`
- `Top-level functions/classes + (class → its methods), name → node-kind.`
- `_build_parser()`
- `_calls()`
- `_emit()`
- `_imports()`
- `_iter_py()`
- `_liveness_signals()`
- `_module_id()`
- `_registry_modules()`
- `_resolve()`
- `_test_callers()`
- `_top_defs()`
- `affected()`
- `build()`
- `cluster()`
- `code_graph.py`
- `dead_code()`
- `export_markdown()`
- `god_nodes()`
- `main()`
- `tools/rules/registry.py → 'rules.registry'; tools/code_graph.py → 'code_graph'.`

## Depends on
- [[tools·dag.py]]
