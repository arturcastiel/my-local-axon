# Audit — State-Surface Integrity
Date: 2026-07-10 · Status: shipped (2 PRs merged to origin/main: f79dad6, b178af5)

## Outcome vs. council-approved plan (v9, hr-team 5/5)
Both PRs shipped as specified. The 2026-07-10 false "Backup not configured" is structurally fixed:
the snapshot code-resolves backup/plans (reader==writer via read_myaxon_pointer, fail-soft), and the
menu renders degraded-safe (∅ → "snapshot unavailable" / silent, never a false negative), guarded by
six static neuron-text invariants over BOTH menu.md and its compiled twin.

## PRs
- PR-001 (f79dad6) — cmd_menu_snapshot += backup{enabled,url,status,last_push} + plans{active_count,
  done_count,active_stems}; resolved via the writer's own pointer (no path divergence); 9 fixture
  value-pinning tests (a healthy fixture alone would have caught the incident).
- PR-002 (b178af5) — menu.md + menu.cmp.md consume snap.*; 5-arm backup render (degraded arm first);
  os-warn unchanged (push-error only → no noise regression); invariants (a)-(f); output_manifest +
  program-hash re-bless.

## Verification
- Two independent FULL crucible gates GREEN — 5346 tests, all 38 BLOCK/WARN controls (pytest BLOCK ok).
- program-tool-conformance: 88 call-sites, 0 violations. program-integrity: ok (blessed).
- The council's constructed bypasses (∅-gate-drop, AND→OR connective, output-string camouflage,
  null/false label-swap) each FAIL invariant (b) — verified during authoring.

## Gaps caught in-flight (now part of the snapshot-field-change checklist)
1. output_manifest.json listed the pre-PR-001 snapshot fields → conformance flagged the new
   snap.backup/snap.plans reads as unknown-accessor. Fix: add both fields to the manifest (match live).
2. Editing blessed power-granting files (menu.md, menu.cmp.md) without re-blessing → program-integrity
   "tampered". Fix: `program-integrity bless` — and it MUST be the final mutation before the gate
   ("bless-LAST", re-learned from the axon-stale-pointers memory after gating too early once).

## Residuals (accepted, non-blocking)
- freshness WARN — pre-existing docs/code-map staleness, unrelated to this project.
- menu.contract.json inputs-count left stale — council-verified non-breaking (synapse tests assert
  shape + corpus rate, never inputs-count); optional hygiene.
- reader==writer holds by the init-invariant (W:myaxon-local is only ever init-stored to
  {myaxon-path}/memory/local), not literal construction; degradation-safe even if it ever diverged.
- The rendered STRING is not CI-executed (run.py punts render to the agent); enforcement is the Python
  snapshot fixtures + the static neuron-text invariants. "Class closed" = closed at the enforceable
  layers, not at render execution.

## Verdict
Ship-complete. The false-"not configured" class is closed at every CI-enforceable layer; no follow-up
required for the incident. Optional future work: contract-regen hygiene; move workspace-backup.md's
writer onto read_myaxon_pointer for literal reader==writer.
