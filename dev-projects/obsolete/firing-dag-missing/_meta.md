# Project: firing-dag-missing — find every code-dev path that skips DAG auto-emit
slug:            firing-dag-missing
schema-version:  v4
status:        obsolete
legacy:          false
phase:           1-study
workflow-step:   study-seeded-not-executed
branch:          main
codebase:        /mnt/c/projects/axon
parent:          axon (root)
sub-projects:    []
created:         2026-05-19
updated:         2026-05-19
predecessor:     none
seed-audit:      phases/1-study/_seed.md
trigger-incident: axon-copilot-anchor phases/2-design/_meta.md created without DAG
incident-fix:    7288c3c (axon-copilot-anchor: DAG + goals added manually)

## Working Context

A bug-class study, not a feature study. Triggered by an incident in `axon-copilot-anchor` phase-2 where the design `_meta.md` was created with a PR queue but **no DAG and no measurable goals table**. The user caught it. Manual fix landed at `7288c3c`.

The auto-emit logic for DAG.json **exists** — `workspace/programs/code-dev-plan.md` § "DAG AUTO-EMIT (PR-113)" generates `{project}/03-prs/DAG.json` from `depends-on` fields in PR files. But the trigger only fires when `code-dev-plan` is invoked. In `axon-copilot-anchor` the design phase wrote `_meta.md` directly with an embedded PR table, never invoking `code-dev-plan`, so DAG auto-emit was structurally bypassed.

**Hypothesis to study (phase-1):** several code-dev shortcut paths exist where a PR queue lands in a `_meta.md` or other phase doc without ever going through `code-dev-plan`, leaving DAG.json unbuilt. The bug is in the *invocation graph*, not the auto-emit code itself.

## Goal

Enumerate every code-dev path that lands PRs without firing DAG auto-emit, and propose a fix (one or more):
- (a) Make DAG auto-emit also fire on `_meta.md` write at phases 2-design / 3-build when a `PR queue` table is detected.
- (b) Add a guard at phase-2 close that ASSERT(`03-prs/DAG.json` exists OR `phase < 2-design`) and HALTs with the exact `code-dev-plan` command to run.
- (c) Refuse to advance phase-2 → phase-3 unless DAG.json is present and valid (`code-dev-pr` precondition).
- (d) Some mix of the above.

The phase-1 study should **diagnose** — not prescribe yet.

## Out of scope (v1)

- Rewriting `code-dev-plan` itself.
- Reformatting the existing DAG.json schema.
- Touching `axon-copilot-anchor` (its DAG is now correct; this project audits the path, not the symptom).

## Phase plan (preliminary)

| Phase | Status | Notes |
|---|---|---|
| 0-seed | n/a | inlined into phase-1 |
| 1-study | **seeded — not executed** | goal + seed audit landed; study not run yet |
| 2-design | TBD | crystallize fix |
| 3-build | TBD | ship guard / auto-emit broadening |
| 4-validation | TBD | replay axon-copilot-anchor flow and verify DAG would have been emitted |

## Entry condition for executing phase-1

Run when the user says "go" or "execute firing-dag-missing study". Until then: **seeded only, do not execute.**

## Cross-refs

- `workspace/programs/code-dev-plan.md` — the program that owns DAG auto-emit (PR-113)
- `my-axon/dev-projects/axon-copilot-anchor/phases/2-design/_meta.md` — the incident artifact (originally missing DAG; fixed at `7288c3c`)
- `my-axon/dev-projects/axon-autoimprove/phases/*` — reference example where DAG-equivalent ordering was present (manually) and worked correctly

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.
