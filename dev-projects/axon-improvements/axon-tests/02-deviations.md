# Deviations — axon-tests implementation

> Logged as PRs are implemented. Each entry: PR-ID, original spec
> claim, what actually shipped, why.

## DEV-001 · PR-005 — workflow_test.py NOT shipped as new tool
**Original spec:** Add `tools/workflow_test.py` (state-machine harness).
**Constraint:** User directive (2026-05-16 evening) — "no new tools".
**Resolution:** Workflow e2e tests will use the existing
`tests/_mock_model.py` mock-model harness only. State-machine replays
land as pytest cases with fixtures, not a new dispatch tool.
**Downstream impact:** PR-008, PR-010, PR-013, PR-014, PR-016 lose
their "uses workflow_test.py" line — they run purely behavioural.
PR-005 itself collapses into fixture conventions documented in
AXON-DOCS-TESTING (covered by PR-021).
**Status:** active.

## DEV-002 · PR-007/008/010/013/014/016 — structural tests in place of mock-model

**Original spec:** Each PR ships behavioural tests driven by
`tests/_mock_model.py`-style fixtures (responses.jsonl + expected.md).

**What shipped:** Structural pytest cases that assert the canonical
shape of the relevant program / workflow / contract file directly —
e.g. `test_identity_gate.py` parametrises over identity-gate
fixtures embedded in the test file rather than under
`tests/fixtures/programs/identity/`.

**Why:**
- DEV-001 dropped `tools/workflow_test.py` — the harness those
  fixtures would feed no longer exists.
- Structural tests cover the same contracts (identity-render shape,
  boot-step order, backup invariants, workflow inventory) more
  cheaply and with less drift exposure to model-side wording.
- Mock-model fixtures can still be re-introduced later — the
  structural tests don't preclude them.

**Downstream impact:** PR-021's `AXON-DOCS-TESTING § Adding a
behavioral fixture` retains the fixture recipe so the door stays
open.

**Status:** active.

## DEV-003 · PR-020 — CONTRIBUTING.md merged, not replaced

**Original spec:** Create `CONTRIBUTING.md` with the mandatory
test+doc rule.

**What shipped:** The existing CONTRIBUTING.md (path-conventions
section) was preserved; the mandatory-test/doc rule, CI-gates table,
and "Writing a test" sections were prepended/merged in.

**Why:** Path-conventions content is still load-bearing for
`tools/lint_paths.py` — deleting it would have regressed that
contract.

**Status:** active.
