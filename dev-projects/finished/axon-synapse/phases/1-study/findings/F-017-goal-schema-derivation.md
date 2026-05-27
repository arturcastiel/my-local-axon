# F-017: Goal-schema derivation — proposed `goal:` field shape per level [T-C output]

**Severity:** medium (proposes Phase 2 schema; not a problem)
**Track:** T-C
**Date:** 2026-05-17
**Linked demands:** D-10 (goal-setting per step), D-24 (auditable goals)
**Linked decisions:** D-007, D-013

## Evidence — what's already in place

- `_demands.md` (this project) — each demand carries `goal + measurement
  + audit-criterion` (D-007 in action).
- `_goal.md` (this project) — project-level goal exists.
- `code-dev-study.md` (per F-013) — **inline acceptance predicate** exists:
  "Phase ends when both user and AXON rate satisfaction ≥ 7." First first-class
  goal-completion predicate found in production AXON.
- `code-dev-plan --mode={tactical,strategic,operational,decision}` (F-013)
  — different mode = different goal shape (PR list vs roadmap vs run-book
  vs ADR). The mode IS implicitly a goal-class declaration.

## Proposed goal-schema (Phase 2 input)

```yaml
goal:
  id:           goal-2026-05-17-1
  level:        project | phase | workflow | step | pr | finding | demand
  domain:       code-dev | library-dev | meta | ...
  statement:    "<one-sentence plain-English statement>"
  rationale:    "<why this goal — what user / system need it serves>"
  measurement:
    - "<observable signal — file existence, count, score, predicate>"
    - "<more signals OK; all must be checkable mechanically OR by user>"
  acceptance-criterion: "<the boolean test that marks the goal MET>"
  rejection-criterion: "<the boolean test that marks the goal FAILED>"
  parent-goal:  goal-2026-05-15-7   # if hierarchical
  child-goals:  []                  # populated as sub-goals are added
  source:       user | workflow-default | inferred-confirmed | inherited
  status:       open | in-progress | designed | met | deferred
  workflow:     "<workflow that this goal belongs to, if applicable>"
  inference-log:
    - { ts: <ts>, action: "proposed by AXON from M2", confirmed-by: user }
```

## Per-level goal derivation (proposed defaults)

### Level: **project**

- **Statement.** What this project ships when done.
- **Measurement.** Acceptance list (mirrors `_goal.md` for axon-synapse).
- **Default for code-dev-domain projects.** "Implementation matches PR list
  + audit shows zero open findings + finalize artifacts present."
- **Default for library-dev-domain projects.** "Library has shadow %, explain %,
  and report coverage above thresholds set in `_meta.md`."

### Level: **phase**

- **Statement.** What this phase delivers.
- **Measurement.** Phase output files exist + are non-stub.
- **Default for `1-study` phase.** "01-study.md populated; findings + INDEX;
  helpers; synthesis.md drafted; user + AXON satisfaction ≥ 7" (per
  code-dev-study's inline predicate).
- **Default for `2-design` phase.** "02-plan.md populated; ADRs ≥ 1 per major
  decision; DAG.json present at plan level."
- **Default for `3-implement` phase.** "Every PR in 02-prs.md has spec file
  + implementation log entry + shadow file (per D-11) + tests passing."
- **Default for `4-validate` phase.** "Retrospective complete; metrics
  vs original goals reported."

### Level: **workflow**

- **Statement.** What this workflow run produces.
- **Measurement.** Workflow file's `acceptance` block evaluates true after
  the final synapse fires.
- **Default for fixed-mode workflows.** "Every declared synapse fired
  successfully (post-state matched expectation) OR a documented deviation
  was confirmed by user."
- **Default for adaptive-mode workflows.** "Orchestrator declared goal-met
  AND user agreed in QUERY."

### Level: **step (synapse fire)**

- **Statement.** What this single synapse fire produces.
- **Measurement.** Synapse's declared `post-state` predicate.
- **Default.** Synapse-contract `post-state` is the authoritative source.

### Level: **PR**

- **Statement.** What this PR changes.
- **Measurement.** Spec exists + implementation log entry + shadow file (D-11)
  + tests pass + audit row "OK."
- **Default for code-dev.** "Spec in `03-prs/PR-NNN.md` + log entry +
  shadow in `phases/{n}/shadow/{pr}.md` + `safety-audit` row passes."

### Level: **finding**

- **Statement.** What design constraint this finding imposes.
- **Measurement.** Linked Phase-2-design-Q exists; linked Phase-3-PR-seed
  exists.
- **Default.** A finding without an `Implication` block is incomplete.

### Level: **demand** (this project's `_demands.md`)

- **Statement.** Already in ledger.
- **Measurement.** Already in ledger.
- **Default.** Demand row complete iff all three of `goal`, `measurement`,
  `audit-criterion` are non-empty (per D-24).

## Where the goal lives (resolving OQ-07)

OQ-07 asked: where does the goal-schema live — per-project file, per-phase
in `_meta.md`, or per-PR frontmatter?

**Proposed answer:** **All three, with hierarchy.**
- Project-level: `<project>/_goal.md` (free-form + structured front-matter).
- Phase-level: `<project>/phases/{n}/_meta.md` gets a `goal:` block.
- PR-level: `<project>/phases/{n}/03-prs/PR-NNN.md` gets a `goal:`
  frontmatter block.
- Workflow-level: `<workflow-file>` declares `default-goal:`.

Each level inherits its parent's `acceptance-criterion` as context; child
goals refine, never contradict.

## Implication for Phase 2 / Phase 3

- **Phase 2.** Spec the YAML schema + predicate language for `measurement`
  and `acceptance-criterion`. Predicate examples needed:
  - `file.exists("phases/1-study/01-study.md")`
  - `count(findings/F-*.md) >= 10`
  - `state.satisfaction.user >= 7 AND state.satisfaction.axon >= 7`
- **Phase 2.** Add `goal:` field to v5 schema for `_meta.md` at project +
  phase levels.
- **Phase 3.** `goal` tool — `set / get / confirm / list / met` subcommands.
- **Phase 3.** `code-dev safety-audit` extension — reports goal-met % per
  phase.

## Resolves

- **OQ-07** — goal-schema location: hierarchical, file per level.
- **D-10** — goal-setting on every code-dev step now has a concrete schema.
- **D-24** — demand-level goals already meet the schema.
