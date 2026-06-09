# PR-2E — liveness orphan-gate self-blinding + reclassify the surfaced orphans OPTIONAL

- **Status:** merged (!139, 39ff302)
- **Phase:** 2-reaudit-fixes  ·  **Complexity:** M  ·  **dev-mode:** no (tools/ + tests/)  ·  **Depends on:** none
- **Source:** re-MEGA F-LIVE — liveness.py's orphan gate (a BLOCK crucible control) was self-blind: `_surfaces`
  built the program/import/dispatch corpus with `exclude_basenames=set()`, so each tool was checked against a
  corpus containing ITS OWN file → a docstring/argparse saying `tools/X.py` or `Tool: X` self-matched →
  reached == total (139/139), orphans == []. The BLOCK gate could never fire.

## Fix
- `liveness.py`: replaced the single shared corpus with a PER-FILE corpus (`_corpus_files` → `[(rel, text)]`);
  `reached_by` now searches every corpus file EXCEPT the tool's own (`rel == script`), mirroring
  `r_no_orphan_tools`'s `exclude_rel`. Self-references no longer count (reached 139/139 → 129/139; surfaced 10).
- The 10 surfaced orphans are all entry / CLI / installer / analyzer tools with no program-caller BY DESIGN:
  apply-host-wiring, apply-memory-slot, onboarding (installer/setup); project-graph, workflow-dag,
  dual-agent-eval (viz/analyzer/benchmark CLI); deprecation-log (ledger/cron); lint-code, domain_validate,
  axon-trace. Per the DOCUMENTED policy (`liveness-allow.txt`: the backlog "was triaged → reclassified OPTIONAL
  in REGISTRY; … the allowlist is [for] a genuinely-pending tool"): **8** genuinely-optional entry/CLI/installer
  tools → reclassified ACTIVE→OPTIONAL (liveness checks only ACTIVE); **2** (domain_validate, deprecation-log)
  are each deliberately pinned ACTIVE by a test (test_domain_manifest / test_deprecation_log — registered tools
  pending their wiring) → kept ACTIVE and grandfathered in liveness-allow.txt (the designed pending-tool path).

## OPTIONAL-safety (verified before reclassifying)
- Invokability: `axon.py` gates only `PLANNED` (not OPTIONAL) — `rtk`/`axon-eval` (already OPTIONAL) run fine,
  so all 10 stay invokable.
- `health` ACTIVE-count invariant (test_tools_kernel) holds: it probes the ACTIVE set, so both the probe count
  and `active_in_reg` drop by the same 10.
- `CONTEXT.md` count test uses `len(tools)` (total, unchanged); domain/onboarding tests are functional, not
  status-pinned.
- Future-wiring candidates (noted, not blocking): lint-code → .pre-commit / a crucible control;
  domain_validate → a gate once domains are in active use; axon-trace → the autonomy cadence. Bump back to
  ACTIVE if/when wired.

## Acceptance
1. Unit: `reached_by` excludes a tool's own file (self-only → orphan; external ref → reached). [test_reaudit_liveness.py]
2. `liveness check` green (0 non-allowlisted orphans); 8 are OPTIONAL; domain_validate + deprecation-log ACTIVE-and-grandfathered.
3. health ACTIVE-count invariant + registry/onboarding/domain suites regress clean.
4. `crucible gate` passed:true.

## Changes
- `tools/liveness.py` (`_corpus`→`_corpus_files`; `reached_by` per-file self-exclusion) ·
  `tools/REGISTRY.json` (8 ACTIVE→OPTIONAL) · `tools/liveness-allow.txt` (grandfather domain_validate +
  deprecation-log) · `tests/test_reaudit_liveness.py`
