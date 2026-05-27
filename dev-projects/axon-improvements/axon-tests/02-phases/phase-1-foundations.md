# Wave A — Foundations (R1)

> Phase-file (v4.2): groups PRs in Wave A under one release.
> See also: ../02-plan.md, ../02-prs.md, ../02-roadmap.md.

## Theme
Build the gate before pouring tests through it.

## PRs in this wave

| PR     | Title                                              | Complexity | Status |
|--------|----------------------------------------------------|------------|--------|
| PR-001 | Wire full pytest suite into CI                     | S          | spec ready |
| PR-002 | pytest-cov + coverage gates (100% rules / 80%)     | S          | spec ready |
| PR-003 | Install scan_pre_push as real git hook             | S          | spec ready |
| PR-004 | Doc co-output template + advisory linter           | M          | spec ready |
| PR-005 | tools/workflow_test.py (state-machine harness)     | M          | spec ready |
| PR-006 | Rules-test scaffold + meta-enforcer                | S          | spec ready |

## Exit criteria for Wave A
- CI runs the full 315-case suite on every push/PR.
- Coverage measured + gated per package.
- Pre-push hook installable in one command.
- Doc co-output convention documented + warned.
- Workflow harness available for use.
- Rules-test layout established with mechanical "every rule has a
  test" enforcement.

## Dependencies inbound
None (Wave A is the foundation).

## Dependencies outbound
Wave B (PR-007..011) and Wave C (PR-012..017) all consume artifacts
from Wave A:
- PR-001 enables every later test to actually run in CI.
- PR-002 enables PR-017 (tool-gap coverage).
- PR-004 enables every "Doc PR" downstream.
- PR-005 enables PR-008 (boot), PR-010 (backup), PR-013/014 (workflows).
- PR-006 enables PR-009 (R9) and PR-011 (rest of rules).
