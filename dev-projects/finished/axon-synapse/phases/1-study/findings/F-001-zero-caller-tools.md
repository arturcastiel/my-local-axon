# F-001: 31 of 75 tools have zero program-callers — caller-source classification missing

**Severity:** high
**Track:** T-A
**Date:** 2026-05-17

## Evidence

Regex scan of `workspace/programs/*.md` for `TOOL(<name>,` and `TOOL?(<name>,` patterns
against every name in `/mnt/c/projects/axon/tools/REGISTRY.json` (75 tools) returns
zero hits for 31 tools:

```
boot, log, index, process, benchmark, lint-paths, undo, programs-registry,
compile-write, run, health, audit_compiled, scan_pre_push, rename_snapshot,
plan_dag, study_evals, idem_test, diff, validator, notify, kv-store,
translate, pack, hooks, pattern, compile-suggest, compile-optimizer,
session-save, call_graph, docgen_verify, cheatsheet_gen
```

41 % of registered tools are not invoked from any program file.

## Why this matters for the synapse model

A synapse's value is its **callability** — by other synapses, by the orchestrator,
or by the user. A tool that no program calls is one of:

1. **Kernel-direct.** Invoked by `axon.py` boot/shutdown or by the runtime (e.g.
   `boot`, `log`, `index`, `process`, `health`). Legitimately bypasses the
   program layer.
2. **CLI-only.** Surfaced as a subcommand of `python3 axon.py <name>` and
   intended to be typed by the human. The program layer wraps a subset.
3. **Cron-driven.** Scheduled by `cron.py` rather than EXEC'd by a program (e.g.
   `session-save`, `auto-improve`).
4. **Tool-to-tool only.** Called by another tool's python code, never visible
   to programs (e.g. `compile-suggest` may be called by `compile`).
5. **Dead.** Registered but never invoked from any path. Removal candidate.

Today the REGISTRY does **not** declare the invocation-source — a synapse can't
know whether to suggest it, surface it in menus, or expose it via free-text intent.

## Implication for Phase 2 / Phase 3

- REGISTRY schema needs a `invocation_source:` field: `kernel | cli | cron | tool-to-tool | program`.
- The synapse-suggest engine (D-010) must filter by invocation-source — only
  `program`-callable tools are first-class candidates for "after X → suggest Y".
- Dead-tool classification needs a separate audit pass; today's grep is necessary
  but not sufficient (e.g. python-internal callers).

## Suggested action

- **Phase 2 design Q.** Extend REGISTRY schema with `invocation_source`. Spec
  a verifier that checks declared source matches reality (grep program files,
  inspect cron.py, inspect axon.py CLI registration).
- **Phase 3 PR seed.** `synapse-invocation-audit` program — runs the verifier,
  produces `helpers/tool-invocation-graph.json`, flags dead tools for review.
