# Phase 1 — Study — SEED (not yet executed)

slug:            01-seed
schema-version:  v4
status:          seeded
opened:          2026-05-19
to-execute:      blocked — execute only on explicit user signal

---

## Why this project exists

**Trigger incident.** While shipping `axon-copilot-anchor` phase-2, AXON created `phases/2-design/_meta.md` with a 5-PR queue but no DAG table and no measurable goals. The user spotted the omission. The fix landed at commit `7288c3c` — DAG + goals added by hand.

**The bigger question.** Why didn't the DAG auto-emit fire on its own? `workspace/programs/code-dev-plan.md` § "DAG AUTO-EMIT (PR-113)" writes `{project}/03-prs/DAG.json` from `depends-on` fields. The logic exists. The trigger didn't fire because `code-dev-plan` was never invoked — `_meta.md` was authored directly with an embedded PR table.

This is a class of bug: **silent path bypass.** Every code-dev shortcut that lands PRs without going through `code-dev-plan` silently skips DAG auto-emit (and any other invariant `code-dev-plan` enforces). The autoimprove project happened to work because the DAG-equivalent table was authored by hand and survived review — the path was wrong but the output was right.

## Initial hypothesis (to verify in phase-1)

1. **At least 3 code-dev paths exist that can land a PR queue without firing `code-dev-plan`:**
   - Direct `_meta.md` authoring at phase-2-design (the incident path).
   - `code-dev-resume` after a checkpoint that pre-dates the plan step.
   - `code-dev-pr-create` invoked before `code-dev-plan` has emitted a plan file.
2. **Auto-emit is content-coupled, not event-coupled.** It reads `prs_ordered` from the plan file; if no plan file exists, nothing fires.
3. **No guard at phase-2 closure** asserts `03-prs/DAG.json` exists before advancing to phase-3.
4. **Symptom severity scales with project size.** Small projects (1-2 PRs) survive without a DAG; large projects (axon-autoimprove with 15) succeed by accident because the human author writes the ordering manually.

## Phase-1 work (NOT YET EXECUTED — seed only)

**On user signal "go" / "execute firing-dag-missing study":**

1. **Audit `code-dev-plan.md`** — locate the exact STORE / WRITE op that emits DAG.json. Identify its preconditions.
2. **Audit `code-dev-pr*.md`** — find every program that creates a PR or queue and whether it cross-references `code-dev-plan`.
3. **Audit `code-dev-meta*.md`** — find every program that writes `_meta.md` for any phase and whether DAG presence is asserted.
4. **Build a path-trace matrix** — for each invocation start state (`menu` → ... → phase-2 close), record whether DAG.json is guaranteed.
5. **Identify the 3 (or N) bypass paths** and rank by frequency / impact.
6. **Recommend a fix family** — (a) broaden auto-emit triggers, (b) add closure guard, (c) refuse phase-3 entry without DAG, or a mix.
7. **Output**: `phases/1-study/01-bypass-paths.md` (catalogued paths) + `02-recommendation.md` (fix family). Then phase-1 closes.

## Goal (measurable, gated at phase-4)

| # | Goal | Target | Source |
|---|---|---|---|
| G-1 | Number of code-dev paths that can land a PR queue without DAG.json | 0 (after phase-3 ships) | manual path-trace replay; `grep` audit |
| G-2 | False-positive rate on the new guard (refuses legitimate phase advances) | < 5% | manual review of 20 historical phase advances |
| G-3 | Time-to-DAG after a PR queue is authored | ≤ 0 (synchronous) | smoke test: write `_meta.md` with PR table → check `03-prs/DAG.json` exists |

## Out of scope

- Rewriting DAG.json schema or visualisation.
- Touching `axon-copilot-anchor` (already fixed).
- Adding DAG to legacy projects that never had one.

## On execution

When the user says "go": follow phase-1 work items 1–7 in order. Produce the two output artifacts. Then write `_closure.md` and bump `_meta.md` → phase 2-design.

## Cross-refs

- `workspace/programs/code-dev-plan.md` § DAG AUTO-EMIT (PR-113) — the existing auto-emit
- `my-axon/dev-projects/axon-copilot-anchor/phases/2-design/_meta.md` — incident artifact
- `7288c3c` — the manual fix commit
