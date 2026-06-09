# Phase 1 — STUDY · axon-registry-consumers

## Goal
Finish F22: migrate the remaining genuine tools/REGISTRY.json consumers to `_axon_registry`, and close
the single-accessor lock's scope hole (it scans tools/*.py only, not tools/rules/).

## Current state (grounded — audit 2026-06-01)
20 tools still reference the REGISTRY.json literal in code (the F22 backlog). They are NOT uniform:
- **Clear genuine consumers (migrate):** anticipate, axon_audit, doc_counts, narrate, synapse_infer,
  synapse_validate, synapse_suggest, rename_snapshot, mcp_server (mcp has a local load_registry to delegate).
- **Need per-file verification:** coherence_lint, programs_registry, freshness, compile_optimizer may load
  a DIFFERENT registry (programs/ not tools/) or only mention the literal; dag_consistency, domain_validate,
  docgen, liveness take an explicit registry-path arg (migrate via the accessor's `path=`).
- **Stay raw BY DESIGN (validators — checking the registry independently):** registry_drift, drift.
- **Special bootstrap (leave):** boot.py (co-located→axon_dir fallback the accessor doesn't model).

## Design
Per-consumer judgement (parallelisable): for each file, confirm it actually loads tools/REGISTRY.json as
a consumer; if so, replace the raw `open/read_text + json.load` with `_axon_registry` (preserve any public
load_registry() name + behaviour; pass `path=` where the file is path-parameterised); self-verify import +
ruff. Leave validators + boot raw, documented. Then extend the lock to scan tools/rules/ and shrink the
ALLOWLIST to only the intentional-raw set.

## Methodology
Workflow fans out one agent per consumer (distinct files → no edit conflicts), each migrates-or-skips with
a reason + self-verifies. Then SERIAL gate→branch→commit→merge-by-number (the established discipline);
batch the migrations into one PR, gate once. PR-2 tightens the lock. Each step branch-first, gate-green.

## Risk
Behaviour change if a file loads a non-default/other registry — mitigated by per-file verification + the
crucible gate (any broken import/test reds it) + keeping validators raw. Lower risk than F21/F30 (these
are additive accessor swaps, not dispatch/storage changes).

## Confidence
8/10 — mechanical, gate-protected; the only judgement is the per-file "genuine consumer?" call.
