# Phase 1 — STUDY · axon-registry-accessor

## Goal
One shared REGISTRY accessor; migrate the 22 independent parsers off it (F22).

## Current state (the finding, grounded)
F22 — 22 tools open + json.load tools/REGISTRY.json independently, each re-deriving the path + schema; a schema change forces touching all 22, and handling already diverges.

## Design
Add tools/_axon_registry.py: load_registry(), tool_script(name), iter_tools(), active_tools(), by_category(). It owns the path + schema. Migrate the 22 consumers to it.

## Methodology
1) PR: accessor + unit tests (matches direct parsing). 2) PRs: migrate consumers in batches grouped by usage pattern (load-all / lookup-script / iterate-active), gate each. 3) PR: lock-test forbidding raw json.load of REGISTRY.json outside the accessor. Python, gate-protected.

## Risk
Per-consumer parsing differences (some need the path, some the dict, some specific fields) — accessor must cover all shapes; gate (pytest) catches mismatches.

## Confidence
8/10 — additive accessor first, incremental migration, gate-caught.

## Gate to PLAN
Owner confirms STUDY (or adds requirements). Per the discipline, PLAN numbers the PRs before any code.
