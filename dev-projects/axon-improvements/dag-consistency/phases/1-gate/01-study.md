# Study — 1-gate (DAG consistency, universal)

## Goal
The DAG is AXON's single source of structural truth — synapse neurons, code-dev
phases/PRs, workflows — UNIVERSAL (whole workspace) and INFINITELY NESTABLE
(node → child-dag → … any depth). Consistency must be enforced mechanically.

## Deep-search: where it fails (substrate exists, cascade missing)
- Substrate: tools/dag.py (DAG.json/DAG.md, 5 levels, verify w/ cycle+dangling+
  orphan+child-dag), plan_dag.py (PR-DAG emit), workflow_dag.py (analyze), synapse graph.
- GAP: mutation programs write PROSE, not DAG ops — no cascade:
  divide (PR/phase split) · combine (merge) · pr-create (add) · pr-link (edge) ·
  phase-new (add) · plan-master (deps). DAG authored once at `code-dev plan`, drifts after.
- No DAG-integrity gate runs after mutations; synapse-validate only soft-warns.
- Edges live in 3 unreconciled stores: Depends-on (specs) · _pr-links.md · _meta predecessors.
- Phase-graph has NO DAG.json (prose+Mermaid only).
- Smoking gun: project `firing-dag-missing` seeded 2026-05-19 for this exact concern, never run.

## Live evidence (this foundation's first run, 18 dangling synapse edges)
- workspace x10 (10 programs next-suggest a non-existent `workspace` neuron — likely `menu`)
- send-report x2 · TOOL x1 · reservoir-dca x1 · list-programs x1 · new-chat x1 · plan-new x1 · program x1
- No existing gate caught these. tools/dag_consistency.py now does (universal, fail-closed).

## Contract (DAG-as-core)
1. DAG.json canonical per level; _pr-links.md / _meta predecessors / Mermaid are RENDERS.
2. Mutations cascade via dag.py ops (not prose). Nested: project ⊃ phase ⊃ PR ⊃ … any depth.
3. R_DAG_CONSISTENT gate (verifier rule + crucible control) asserts DAG ↔ reality everywhere.
4. Neuron contract gains a `dag:` obligation for structure-mutating programs.

## Phases
- 1-gate (THIS): universal checker tool + crucible control (WARN) — DETECT drift. ✓ foundation built.
- 1b: repoint the 18 dangling edges → promote control to BLOCK.
- 2-cascade: wire the 7 mutation programs to call dag.py ops.
- 3-nest: phase-graph DAG.json + neuron `dag:` field + infinite-nesting reconciliation.
