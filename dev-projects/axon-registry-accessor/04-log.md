# Implementation Log — axon-registry-accessor (F22)

> Goal: end "every tool re-derives the REGISTRY.json path + re-parses its schema" (20+ independent
> parsers). Deliver ONE accessor, migrate the clear duplicates, and lock the boundary so the drift
> can't return. Each PR gate-verified green (`crucible gate`, 22 controls/0 fail), branch-first.

## Merged — 2026-05-30
| PR | MR | What |
|----|----|------|
| PR-1 | !87 | `tools/_axon_registry.py` — the single accessor (load_registry / tools / iter_tools / tool_script / active_tools / by_category) + `tests/test_axon_registry.py` (parity vs raw json.load). `_`-prefixed so registry_drift treats it as a lib, not an orphan. |
| PR-2 | !88 | verify.py / health.py / run.py drop their local "open REGISTRY.json + json.load" duplicates and delegate to the accessor. verify.py keeps its public `load_registry()` name (re-sourced). Behaviour-identical — same co-located path; smoke-verified 146 tools / 134 active scripts. |
| PR-3 | !89 | `tests/test_registry_single_accessor.py` — AST lock: only `_axon_registry.py` may carry the `REGISTRY.json` literal in code; the 20 current raw consumers are an ALLOWLIST that can only shrink. A NEW raw consumer now reds the gate. |

**main b12871b · gate 22/0 green on each merge.**

## Scope decision — what migrated vs what stayed raw (deliberate)
F22's value is **one home for the path+schema** + **no new re-derivers**, not "rewrite 20 working files."
- **Migrated (PR-2):** the 3 files whose raw load was a pure duplicate of the accessor (verify/health/run) — zero behaviour change, maximal clarity. Proof-of-pattern.
- **Stayed raw, by design:** the registry's own validators — `registry_drift`, `drift`, `dag_consistency`, `coherence_lint`, `domain_validate`, `freshness`. Their job is to check the registry *independently*; delegating to the accessor would make the check partly circular.
- **Stayed raw, special-path:** `boot.py` (co-located→axon_dir fallback the accessor doesn't model), `liveness.py` / `docgen.py` (take an explicit repo_root/path — the accessor's `path=` arg covers them, a clean future migration).
- **Legacy backlog (still raw, no special reason):** anticipate, axon_audit, doc_counts, narrate, programs_registry, synapse_{infer,suggest,validate}, compile_optimizer, mcp_server, rename_snapshot. These work today; migrating them is pure cleanup with no functional benefit, so it's incremental — each drops itself from the ALLOWLIST.

## Why lock-then-cleanup (not migrate-all-then-lock)
Migrating 20 working files en masse is high churn / high fatigue-risk for zero functional gain, and a
semantic slip in a rarely-tested path can pass the gate. The **boundary lock** is the high-value,
low-risk piece: it stops the #1 way the drift returns (a new tool hand-rolling the path). The existing
20 are stable; the ALLOWLIST is the honest, ratcheting backlog. This is the same pattern as
liveness-allow.txt.
- 2026-07-09: pointer-repair (axon-stale-pointers): _meta.phase advanced to 'audit' (was behind a done phase)
- 2026-07-09: pointer-repair (axon-stale-pointers): status active->complete — MANIFEST-BACKED closeout (every phase done); the project was finished but never closed out (the inverse of the unbacked-claim class).
