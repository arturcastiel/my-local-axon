# Spec deltas — v1 → v1.1 (remediation pass)

> 2026-05-17. User: "remediate everything, important you pointed the
> names metaphor error". Closes flaws FL-01..FL-10 + gaps GAP-01..GAP-08
> + improvements I-01..I-06. Specs that don't appear below are unchanged.

Each section below lists the change without re-emitting the whole spec.
Authoritative spec files retain v1 filenames where the change is
localized; rename-heavy specs (glossary v2) overwrite in place. New
specs land as `<name>-v1_1.md`. Migration plan v1.1 supersedes v1.

---

## SYNAPSE-GLOSSARY → AXON-GLOSSARY v2 (closes OP-01)

In-place rewrite. Biology-correct rename: neuron / synapse / axon.
Layer axis added (kernel/system/meta/shared/domain) — splits old `meta`
overload (OP-03). Two new execution modes: exploratory, scheduled
(addresses GAP).

## predicate-language-v1.1 (closes FL-01, FL-02, FL-03, GAP-06)

New standalone spec file. Formal grammar with precedence (AND > OR,
NOT prefix, implication right-assoc, comparison non-associative).
Strict type system + safe-eval null mode + opt-in strict-null.
Snapshot semantics: entry-time default, continuous opt-in.
50-fixture test corpus seeded.

## goal-schema-v1 → v1.1 (closes GAP-05)

Single edit: parent-met-child-open semantics defined.
- If parent.acceptance evaluates true while ≥ 1 child.status ∈
  {open, in-progress}: parent.status auto-bumps to `met-with-open-children`;
  user QUERY surfaces in audit.
- Child closure does not affect parent (parent stays met).
- Rejection cascades: parent.rejection-criterion true → all child goals
  transition to `parent-rejected` (terminal).

## synapse-contract-v1 → neuron-contract-v1.1 (closes FL-08, OP-04)

Term rename: synapse-contract → neuron-contract. `next-conditional:` →
`synapses:`. Field-level changes:

- `requires-shadow` default reworked: instead of "outputs source-file
  path" (ambiguous), domain manifest declares `source-artifact-glob:`
  patterns; neuron declares `affects-source: bool`. The inference is
  `requires-shadow = affects-source AND domain.source-artifact-glob
  matches outputs`. Removes FL-08.
- New field `blast-radius: { reversibility: <one-way|reversible>,
  affected-paths: [glob], rollback: <recipe> }`. Closes OP-04 by making
  per-neuron rollback declared.

## workflow-file-v1 → v1.1 (closes GAP-01, GAP-02, GAP-03)

- New `execution-mode` values accepted: `exploratory`, `scheduled`
  (matches glossary v2).
- `domain` field accepts list (cross-domain workflows) with resolution
  rule: when ambiguous, first-listed domain's manifest wins (GAP-01).
- New `mode-switch` field on each step: declares allowed mid-workflow
  transitions (`fixed→adaptive`, `adaptive→fixed`, `*` = anything).
  Closes GAP-02.
- New `suggestion-budget` block (closes GAP-03):
  ```yaml
  suggestion-budget:
    sideband-per-step: 1
    sideband-per-run:  10
    dismiss-decay:     0.5     # after dismiss, weight halves for 30 min
  ```

## orchestrator-composition-v1 → v1.1 (closes FL-04, FL-05, FL-07, FL-09)

### FL-04 — ranker tie-break ladder

When top-k candidates have raw-score within 0.05 of each other, apply
secondary sort:

```
1. higher  declared-canonical    (canonical > alias > stub-never)
2. higher  recency.last-fired    (favour recent context)
3. higher  role-match            (mutator if state needs change; reader otherwise)
4. lower   cost.tokens-estimate  (cheap wins ties of equal merit)
5. higher  goal-alignment.score  (re-check)
6. lexicographic name            (deterministic final fallback)
```

Reproducibility: same state + same goal + same history → identical
top-1 across sessions.

### FL-05 — zero-candidate fallback

```
IF candidates == []:
    EMIT axon.orchestrator.no-candidates
    fallback = lookup-by-goal-keywords(goal.statement) → top-3 from
               full registry by TF-IDF
    IF fallback != []:
        QUERY: "No declared candidates. Closest matches (full registry): [list].
                Pick, or describe what to do."
    ELSE:
        QUERY: "No matches. Options: register-tool (new neuron),
                workflow-new (new workflow), or describe your task in
                free text."
    log axon.orchestrator.no-candidate-fallback {state-hash, goal-id}
```

Never silent-hang.

### FL-07 — cold-start ranker bootstrap

On first session (zero dispatch / usage / pattern history):

- Frequency-prior bootstrap: read `tools/REGISTRY.json` invocation_source
  field; neurons with `invocation_source` containing `program` start
  with prior weight 0.5; `cli` 0.3; `kernel` 0.0 (never user-facing).
- Disable signal weights for absent signals; renormalize remaining.
- After 20 user-confirmed fires, lift cold-start mode; resume full
  ranker.

### FL-09 — interrupt-gate integration

KERNEL-SLIM § Active-program-interrupt-gate fires on user input mid-program.
Spec the workflow-aware behavior:

```
when interrupt-gate fires AND W:active-workflow != null:
    classify(user-input) →
      a) workflow-continuation-command (yes/no/continue/...): pass to gate as-is
      b) workflow-deviation-request:  surface as deviation suggestion
                                     (per shadow / workflow-aware deviation)
      c) workflow-pause-and-task:     CHECKPOINT workflow; route new input
                                     through adaptive free-text path
      d) workflow-abort:              terminate workflow; menu
classification uses mode-detect signal weights with workflow-context bonus.
```

## shadow-enforcement-v1 → v1.1 (closes FL-10)

Grace-flag flip protocol made explicit:

```
The grace flag L:shadow-enforcement-strict flips from false → true ONLY when:
  1. tool: shadow-coverage-report --root <project> returns coverage == 100
     for EVERY active project (twice consecutive, ≥ 5 min apart).
  2. axon-audit shows zero shadow-related open findings.
  3. User-confirm via:  shadow-enforce strict  command (QUERY required).
On flip:
  - L:shadow-enforcement-strict-flipped-ts recorded
  - EMIT axon.shadow.enforcement-strict
  - Subsequent PR finalize gates hard-fail on missing shadow.
Unflip path: dev-mode + explicit user command (last-resort).
```

## dag-spec-v1 → v1.1 (closes GAP-04, GAP-08)

### GAP-04 — md → json recovery

While DAG.md is one-way rendered, a `dag recover --from-md <path>`
sub-command parses md back to a candidate JSON (best-effort). Output
is a DRAFT (`DAG.recovery.json`) — never auto-overwrites. User reviews
before promoting to `DAG.json`. Documented as last-resort path.

### GAP-08 — mixed-case filename migration

axon-master uses `pr-N.md` lowercase. axon-cleanup uses `PR-NNN.md`
uppercase. Migration tool `dag normalize-pr-filenames --project <slug>`
case-normalizes all `PR-*`/`pr-*` files to lowercase, updates DAG.json
node names + edge references, leaves a backwards-compat symlink for
the old name. Idempotent.

## domain-manifest-v1 → v1.1 (closes OP-03, supports FL-08)

`layer:` axis added per AXON-GLOSSARY v2.
`source-artifact-glob:` field added (closes FL-08):

```yaml
source-artifact-glob:                # which file patterns count as "source"
  - "**/*.py"                        # code-dev: Python files
  - "**/*.cpp"                       # code-dev: C++
  - "**/*.md"                        # ... etc.
```

For library-dev: `**/*.pdf`, `**/*.txt`. Per-domain definition removes
ambiguity in `requires-shadow` inference.

## migration-plan-v1 → v1.1 (closes FL-06, OP-04)

### FL-06 — PR-116 subdivided

```
PR-116  shadow retroactive bulk migration  →  SPLIT INTO:
  PR-116a   axon-master      (55 PRs)
  PR-116b   axon-tests       (21 PRs)
  PR-116c   axon-cleanup     (25 PRs)
  PR-116d   axon-user        (17 PRs)
  PR-116e   axon-docs        (1 PR)
  PR-116f   axon-synapse     (0 PRs yet — placeholder for ongoing)
Total still 119 PRs of shadow; per-project rollback granularity.
Each PR has internal DAG (per-PR sub-DAG per dag-spec-v1.1).
```

### OP-04 — per-file rollback for PR-108

PR-108 (metadata migrate) gets a `--rollback-per-file` mode using
`undo` tool (already in REGISTRY). On any header-parse failure during
re-read, that file's previous content restored; rest of PR continues.
Restore is automatic; per-file rollback logged in 04-log.

### NEW PR seeds

- **PR-130 · Spec docs propagation.** Promote v1.1 spec changes from
  Phase-2 specs/ into `workspace/` authoritative locations alongside
  PR-101 glossary docs. Depends-on: pr-101.
- **PR-131 · Predicate-language v1.1 ships.** Replaces PR-102's scope
  in v1; PR-102 now ships v1.1.
- **PR-132 · Workflow `exploratory` + `scheduled` modes.** Adds executor
  paths. Depends-on: pr-115.

## NEW improvements (I-01..I-06)

### I-01 · `_flaws.md` running register

`<project>/_flaws.md` holds known-tracked design flaws (current + closed).
Updated on every spec bump. Closes the "good enough to ship with known
risks" channel from previous turn — a flaw without a tracking row is
not a flaw, it's a defect.

### I-02 · Spec version log

`<project>/phases/{n}/specs/_versions.md` records each spec's version
history: v1 → v1.1 with ADR, date, summary. Single-source-of-truth for
"what changed when."

### I-03 · Orchestrator fixture test corpus

`<project>/phases/2-design/test-fixtures/orchestrator-fixtures.yaml` —
50 (state, goal, expected-top-1, rationale) tuples used by PR-111 to
test the ranker. Seeded this turn with 5 examples; PR-109 / PR-111 expand
to 50.

### I-04 · Per-PR rollback recipe template

Every PR spec template in `03-prs/PR-NNN.md` gains a mandatory
`## Rollback` section: revert command + check command + decision-tree
for partial failures.

### I-05 · Blast-radius declaration

Every neuron contract carries `blast-radius` (see neuron-contract-v1.1).
Every PR spec carries blast-radius summary (paths affected, files
touched, max-rows-changed). Audit surfaces high-blast-radius PRs.

### I-06 · Reversibility tier

PRs tagged `reversibility: one-way` | `reversible` | `partial`. One-way
PRs (e.g. kernel writes) require dev-mode + user-confirm + audit-row.
Reversible PRs can roll back via `undo` tool. Partial PRs document the
non-reversible subset.

---

## Cumulative versioning

| Spec | v1 status | v1.1 status |
|------|-----------|-------------|
| SYNAPSE-GLOSSARY | shipped | rewritten in-place → v2 |
| predicate-language | embedded in goal-schema | new standalone v1.1 |
| goal-schema | shipped | edit (parent-child semantics) |
| synapse-contract | shipped | renamed → neuron-contract v1.1 |
| workflow-file | shipped | v1.1 (modes, mode-switch, suggestion-budget) |
| domain-manifest | shipped | v1.1 (layer axis, source-artifact-glob) |
| dag-spec | shipped | v1.1 (md→json recovery, filename normalizer) |
| orchestrator-composition | shipped | v1.1 (tie-break, zero-cand, cold-start, interrupt) |
| shadow-enforcement | shipped | v1.1 (grace-flag flip protocol) |
| conversational-author | shipped | v1.1 (cold-start dialog opening) |
| migration-plan | shipped | v1.1 (PR-116 split, PR-108 rollback) |
