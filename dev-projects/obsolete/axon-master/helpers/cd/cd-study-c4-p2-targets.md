# CD·STUDY·C4·P2 — explicit deliverables (targets), per wave

> Every deliverable from C3 implementation, re-stated as a target with acceptance criteria. This is the "definition of done" reference.

## Convention

Each target has:
- **ID:** stable identifier.
- **What:** one-line description.
- **Files:** files added/touched.
- **Acceptance:** observable behavior.
- **Depends:** prior targets.

---

## Wave S0 — Plumbing

### T-S0.1  Study folder convention
- **Files:** schema doc (`workspace/programs/_code-dev-schema-v4.md` minor bump), `_meta.md` writer.
- **Acceptance:** new projects auto-create `study/` and `study/_index.md` on `lifecycle init`.

### T-S0.2  Migrator for existing projects
- **Files:** new program `code-dev-migrate-study.md`.
- **Acceptance:** running on axon-master moves `01-study.md` into `study/overview.md`; leaves `01-study.md` as a 2-line redirect.

### T-S0.3  `_index.md` maintainer helper
- **Files:** `tools/study_index.py` (read-modify-write, atomic via temp+rename).
- **Acceptance:** unit tests cover concurrent append, malformed input recovery.

### T-S0.4  Journal vocabulary
- **Files:** docs only.
- **Acceptance:** `journal search --kind=study.overview` returns past runs.

---

## Wave S1 — Core study modes (P0)

### T-S1.1  `study --mode=overview` (refactor)
- **Acceptance:** writes `study/overview.md`; `_index.md` updated; idempotent ≥ 80%.

### T-S1.2  `study --mode=subsystem --target=<path>`
- **Acceptance:** writes `study/subsystems/<sanitized-name>.md`.

### T-S1.3  `--target=<glob>`
- **Acceptance:** glob expansion before walk; budget honored.

### T-S1.4  `--output engineering|executive|machine`
- **Acceptance:** machine variant emits front-matter + sectioned markdown parseable by `tools/study_index.py`.

### T-S1.5  Multi-file output
- **Acceptance:** no mode ever appends to another mode's file; each mode writes its own file.

### T-S1.6  `_index.md` auto-update
- **Acceptance:** every mode run appends `(timestamp, mode, target, status, token-usage)`.

### T-S1.7  `--budget tokens=N`
- **Acceptance:** HALT with partial output if exceeded; `_index.md` row marks `status=partial`.

### T-S1.8  `--input <path>`
- **Acceptance:** mode reads supplied JSON/text and integrates into output.

### T-S1.9  Staleness flags
- **Acceptance:** `state show` displays staleness; `_index.md` exposes age per mode.

### T-S1.10  `flow plan --budget N`
- **Acceptance:** plan output capped at N PRs; overflow in `02-prs.deferred.md`.

### T-S1.11  `flow plan --rule "..."`
- **Acceptance:** each --rule echoed in plan output "Rules honored" section; PR proposals filtered.

### T-S1.12  `state next` integration
- **Acceptance:** `state next` includes ≥ 1 study suggestion when applicable.

---

## Wave S2 — Additional study modes

### T-S2.1  `study --mode=security`
- **Acceptance:** scans declared auth/input/secret surfaces; emits findings table.

### T-S2.2  `study --mode=dependencies`
- **Acceptance:** parses manifests; emits BOM; optional `--input snyk.json` integration.

### T-S2.3  `study --mode=tests`
- **Acceptance:** runs against test files; optional `--input coverage.json` computes deltas.

### T-S2.4  `study --mode=api-surface`
- **Acceptance:** symbol table emitted; `--diff --since=<ref>` computes breaking changes.

### T-S2.5  `study --mode=performance`
- **Acceptance:** heuristic hot-path analysis; recommended PRs.

### T-S2.6  `study --mode=history`
- **Acceptance:** parses `--input git-log.json`; emits churn × complexity hotspots.

---

## Wave S3 — Plan modes

### T-S3.1  `plan --mode=execution` (default, refactor)
- **Acceptance:** emits today's plan shape; passes existing tests.

### T-S3.2  `plan --mode=risk-first`
- **Acceptance:** sorts by severity DESC.

### T-S3.3  `plan --mode=budgeted` (already in S1)
- **Acceptance:** covered by T-S1.10.

### T-S3.4  `plan --mode=constrained` (already in S1)
- **Acceptance:** covered by T-S1.11.

### T-S3.5  `plan --mode=cost`
- **Acceptance:** sorts by `est-tokens, est-hours` ASC.

### T-S3.6  `plan --mode=alignment`
- **Acceptance:** ranks by `_meta.goals` match.

### T-S3.7  `plan --mode=exploratory`
- **Acceptance:** thematic groupings; no strict ranking.

### T-S3.8  `plan --mode=dry`
- **Acceptance:** does NOT write `02-prs.md`; output to chat/stdout only.

### T-S3.9  `plan --replay`
- **Acceptance:** reads prior plan; annotates each entry with current state.

### T-S3.10  `plan --multi-dev K`
- **Acceptance:** splits into K tracks; emits `02-prs.track-A.md` etc.

### T-S3.11  `plan --epic` (replaces `plan-master`)
- **Acceptance:** behavior matches old `plan-master`; old name stubbed.

---

## Wave S4 — Recipes

### T-S4.1  Recipes directory
- **Files:** `workspace/study-recipes/{new-repo-onboarding, pre-release-audit, refactor-prep, perf-hunt, quarterly-health, bug-triage, brownfield-dd}.md`.

### T-S4.2  `study --recipe=<name>` runner
- **Acceptance:** runs all steps; per-step `_index.md` update; HALT-on-fail with QUERY back.

### T-S4.3  `study --suggest-next`
- **Acceptance:** emits ranked list of mode suggestions with rationale.

### T-S4.4  `study --diff --since-last`
- **Acceptance:** emits only deltas from last run.

### T-S4.5  `study --checkpoint` + `--resume`
- **Acceptance:** mid-run interrupt + resume produces same final state.

---

## Wave S5 — Niche modes + integrations

### T-S5.1..S5.6  Modes: dead-code, naming, observability, error-handling, data-model, dataflow.

### T-S5.7  `pr ready` warn on staleness
- **Acceptance:** stale-study warning visible in `pr ready` output for relevant PRs.

### T-S5.8  `pr ready --strict`
- **Acceptance:** blocks merge gate when stale relevant studies exist.

### T-S5.9  `safety preflight` reads security study
- **Acceptance:** preflight includes "security study fresh? ✓/✗".

### T-S5.10  `meta board` studies column
- **Acceptance:** Kanban column or icon for each PR shows status of relevant studies.

---

## Wave S6 — Polish

### T-S6.1  `meta cheatsheet study` + `meta cheatsheet plan`.
### T-S6.2  Semantic diff in `study --diff` (where feasible).
### T-S6.3  Token-usage report aggregated across `_index.md`.
### T-S6.4  Remove `01-study.md` redirect post-1-release.
### T-S6.5  `workspace/AXON-DOCS-STUDY.md` documentation.

## Roll-back per wave

- S0: revert schema change; `01-study.md` restored from git.
- S1..S3: revert programs; modes silently disappear.
- S4..S6: revert; recipes / integrations disappear; core untouched.

## Pre-conditions across the programme

- Round-2 compile-write regression gate must ship first (prevents bloated mode files).
- Round-3 Wave-1 (verb routers) must ship first for `knowledge` and `flow` umbrellas to exist (otherwise top-level `code-dev study` / `code-dev plan` shims used).

→ Next-study suggestions: `cd-study-c4-p3-next-study.md`.
