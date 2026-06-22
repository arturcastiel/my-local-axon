<!-- AUTO-GENERATED from DAG.json by tools/dag.py — do not hand-edit. -->
# DAG · plan · arturcastiel

- schema-version: `v1`
- generated:      `2026-06-22T07:43:07Z`
- generator:      `tools/dag.py (axon-rearm plan, post-audit)`
- nodes:          34
- edges:          13
- critical-path:  PR-T0-2a → PR-T0-2

## Nodes

| id | kind | name | label | status |
|----|------|------|-------|--------|
| PR-T0-1 | pr | Instrument the drift detector (A1) | Instrument the drift detector (A1) | pending |
| PR-T0-2 | pr | Arm the enforcement flags (A2 · OD-1) | Arm the enforcement flags (A2 · OD-1) | pending |
| PR-T0-2a | pr | Seed `# emits:` / `outputs:` SSOT (A2a) | Seed `# emits:` / `outputs:` SSOT (A2a) | pending |
| PR-T0-3 | pr | Mechanical counters (A3) | Mechanical counters (A3) | pending |
| PR-T1-1 | pr | One shared changeset base resolver (B1) | One shared changeset base resolver (B1) | pending |
| PR-T1-2 | pr | CI fetch-depth + merge-base (B2) | CI fetch-depth + merge-base (B2) | pending |
| PR-T1-3 | pr | Real CR-13 end-to-end test (B3) | Real CR-13 end-to-end test (B3) | pending |
| PR-T1-4 | pr | Close R13 coverage loopholes (B4) | Close R13 coverage loopholes (B4) | pending |
| PR-T1-5 | pr | Frozen shrink-only test-grandfather (OD-5) | Frozen shrink-only test-grandfather (OD-5) | pending |
| PR-T2-1 | pr | Gate the dev-mode toggle (C1) | Gate the dev-mode toggle (C1) | pending |
| PR-T2-2 | pr | Protect the enforcement core (C2) | Protect the enforcement core (C2) | pending |
| PR-T2-clone | pr | Clone/CI fail-closed (OD-6 · Wave G G3-D2) | Clone/CI fail-closed (OD-6 · Wave G G3-D2) | pending |
| PR-T2-3 | pr | Build G1c or delete the claim (C3) | Build G1c or delete the claim (C3) | pending |
| PR-T3-1 | pr | Prose-vs-wiring meta-rule (D1) | Prose-vs-wiring meta-rule (D1) | pending |
| PR-T3-2 | pr | Drift-gate unknown → fail-closed (D2 · OD-2) | Drift-gate unknown → fail-closed (D2 · OD-2) | pending |
| PR-T3-3 | pr | Unify the dual drift encoding (D3) | Unify the dual drift encoding (D3) | pending |
| PR-T3-4 | pr | R_PHASE_TRACKED to a biting runner (D4) | R_PHASE_TRACKED to a biting runner (D4) | pending |
| PR-T4-shadow | pr | Investigate the 29 legacy programs (OD-4) | Investigate the 29 legacy programs (OD-4) | pending |
| PR-T4-1 | pr | Fix the dead resume program (E1) | Fix the dead resume program (E1) | pending |
| PR-T4-2 | pr | QUARANTINE prune + orphan gates (E2) | QUARANTINE prune + orphan gates (E2) | pending |
| PR-T4-3 | pr | Test-or-delete below-radar drift tools (E3) | Test-or-delete below-radar drift tools (E3) | pending |
| PR-T4-4 | pr | Registry status enum + alias_of (E4 · OD-7 enabler) | Registry status enum + alias_of (E4 · OD-7 enabler) | pending |
| PR-T4-5 | pr | Fix workflow-run --name (E5 · OD-7) | Fix workflow-run --name (E5 · OD-7) | pending |
| PR-T5-1 | pr | Reconcile self-models (F1) | Reconcile self-models (F1) | pending |
| PR-T5-2 | pr | Menu link + count integrity (F2) | Menu link + count integrity (F2) | pending |
| PR-T5-3 | pr | Naming conventions + authoring-guide section (F3 · OD-7) | Naming conventions + authoring-guide section (F3 · OD-7) | pending |
| PR-T5-4 | pr | Generate the typed program graph (F4 · OD-3) | Generate the typed program graph (F4 · OD-3) | pending |
| PR-T6-exp | pr | Thin-kernel heavy-ceremony OFF-vs-ON (OD-8) | Thin-kernel heavy-ceremony OFF-vs-ON (OD-8) | pending |
| PR-T4-hrteam | pr | Wire the hr-team execution seam so AXON can ALWAYS convene a | Wire the hr-team execution seam so AXON can ALWAYS convene a real council | pending |
| PR-T2-anchor | pr | Pin the R9 anchor to the .axon-governed sentinel (M4) | Pin the R9 anchor to the .axon-governed sentinel (M4) | complete |
| PR-T2-devmode-default | pr | dev-mode ships default-OFF (M4) | dev-mode ships default-OFF (M4) | pending |
| PR-T2-loopreceipt | pr | Constrain the R9 actor-whitelist to a PATH not an actor (M4) | Constrain the R9 actor-whitelist to a PATH not an actor (M4) | pending |
| PR-T1-cihost | pr | Resolve the gating CI pipeline (M5) | Resolve the gating CI pipeline (M5) | pending |
| PR-T2-flags | pr | Protect the flag dir (M3) | Protect the flag dir (M3) | pending |

## Edges

| from | to | kind |
|------|----|------|
| PR-T0-2a | PR-T0-2 | depends |
| PR-T1-1 | PR-T1-2 | depends |
| PR-T1-1 | PR-T1-3 | depends |
| PR-T1-1 | PR-T1-4 | depends |
| PR-T1-1 | PR-T1-5 | depends |
| PR-T0-1 | PR-T3-2 | depends |
| PR-T4-4 | PR-T4-5 | depends |
| PR-T4-4 | PR-T5-3 | depends |
| PR-T0-1 | PR-T6-exp | depends |
| PR-T0-3 | PR-T6-exp | depends |
| PR-T0-1 | PR-T2-2 | depends |
| PR-T0-3 | PR-T2-2 | depends |
| PR-T3-3 | PR-T2-2 | depends |
