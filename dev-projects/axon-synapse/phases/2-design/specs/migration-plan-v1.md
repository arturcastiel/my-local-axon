# Migration Plan (v1) — Phase 1 findings → Phase 3 PRs

> glossary: SYNAPSE-GLOSSARY v1
> resolves: Phase 1 findings F-001..F-017 → Phase 3 PR seeds
> serves: D-19 (no tests break), D-25 (preserve code-dev), D-26 (workflow OS)

## Purpose

Sequence the Phase 3 work so each PR lands without breaking earlier
behaviour, with the ordering implied by the dependency graph among
schemas + the existing tools/programs.

## Migration principles (recap)

1. **No code-dev rename, no file moves.** D-014/D-025.
2. **No tests break.** D-019. Every PR runs the existing test suite + new
   synapse-validate suite.
3. **Inferred-first, declared-override.** D-005 hybrid. Bulk infer; let
   authors override progressively.
4. **Auto-discoverable.** D-020/D-027. New synapses + workflows surface
   automatically once registered.
5. **Backwards-compatible aliases.** F-012. `code-dev-audit`, `code-dev-pr`,
   `code-dev-shadow` permanently invocable.
6. **Shadow grace.** F-016. `L:shadow-enforcement-strict=false` until
   retroactive migration completes.

## Dependency graph (PR-level)

```
                ┌─────────────────┐
                │ PR-101          │
                │ glossary v1     │  ← ships first; everything else cites it
                └────────┬────────┘
                         │
        ┌────────────────┼──────────────────────────┐
        │                │                          │
┌───────▼───────┐  ┌─────▼─────┐           ┌────────▼────────┐
│ PR-102        │  │ PR-103    │           │ PR-104          │
│ predicate     │  │ goal      │           │ synapse-contract│
│ language tool │  │ schema    │           │ schema          │
└───────┬───────┘  └─────┬─────┘           └────────┬────────┘
        │                │                          │
        └────────┬───────┴────┬─────────────────────┤
                 │            │                     │
       ┌─────────▼──┐   ┌─────▼────┐       ┌────────▼────────┐
       │ PR-105     │   │ PR-106   │       │ PR-107          │
       │ workflow   │   │ domain   │       │ synapse-infer + │
       │ file v1    │   │ manifest │       │ validate tools  │
       └─────┬──────┘   └─────┬────┘       └────────┬────────┘
             │                │                     │
             │                └──────┬──────────────┤
             │                       │              │
             │            ┌──────────▼──────────┐   │
             │            │ PR-108              │   │
             │            │ domain-folder       │   │
             │            │ scaffold + manifests│   │
             │            │ + metadata-migrate  │   │
             │            └──────────┬──────────┘   │
             │                       │              │
             └──────────┬────────────┴──────────────┘
                        │
            ┌───────────▼───────────┐
            │ PR-109                │
            │ synapse-suggest tool  │
            │ (composition v1)      │
            └──────────┬────────────┘
                       │
        ┌──────────────┼─────────────────┐
        │              │                 │
┌───────▼──────┐ ┌─────▼──────┐  ┌───────▼────────┐
│ PR-110       │ │ PR-111     │  │ PR-112         │
│ DAG spec v1  │ │ orchestrator│  │ output-layer   │
│ + dag tool   │ │ loop       │  │ suggestions    │
│ + sync       │ │ (program)  │  │ section        │
└───────┬──────┘ └─────┬──────┘  └───────┬────────┘
        │              │                 │
┌───────▼──────┐ ┌─────▼──────┐  ┌───────▼────────┐
│ PR-113       │ │ PR-114     │  │ PR-115         │
│ plan_dag     │ │ shadow     │  │ workflow-new   │
│ auto-emit    │ │ enforcement│  │ (conversational│
│ hook         │ │ gates      │  │  author)       │
└───────┬──────┘ └─────┬──────┘  └───────┬────────┘
        │              │                 │
        └────────┬─────┴─────┬───────────┘
                 │           │
        ┌────────▼────────┐  │
        │ PR-116          │  │
        │ shadow          │  │
        │ retroactive     │  │
        │ bulk migration  │  │
        └────────┬────────┘  │
                 │           │
        ┌────────▼───────────▼────────┐
        │ PR-117                       │
        │ alias canonicalization +     │
        │ finalize stub closure +      │
        │ self-review collision fix    │
        └────────────────┬─────────────┘
                         │
        ┌────────────────▼─────────────┐
        │ PR-118                        │
        │ reference workflows ship:     │
        │  code-dev.canonical.yml,      │
        │  python-code-dev.yml,         │
        │  cpp-code-dev.yml,            │
        │  library-dev.canonical.yml,   │
        │  adaptive-free-text.yml       │
        └────────────────┬──────────────┘
                         │
        ┌────────────────▼──────────────┐
        │ PR-119  axon-audit extension  │
        │   shadow coverage row +       │
        │   synapse-validate row        │
        └────────────────┬──────────────┘
                         │
        ┌────────────────▼──────────────┐
        │ PR-120  igap + auto-improve   │
        │   wire to synapse-suggest     │
        │   (re-rank on igap signals)   │
        └───────────────────────────────┘

Phase 4 follow-ups (post-1.0):
        PR-150  study-dev domain (proof of D-026)
        PR-151  cross-domain workflows (science-dev review delegating)
        PR-152  ranker tuning from lived data
        PR-153  workflow-compile (cache compiled workflows)
```

## PR roster (rough specs, full specs land in `03-prs/PR-NNN.md` after `code-dev plan`)

### PR-101 · SYNAPSE-GLOSSARY v1 → docs
- Files: `workspace/SYNAPSE-GLOSSARY.md` (copy of phase-2 spec).
- Deps: none.
- Risk: low (docs only).
- Tests: lint markdown; assert glossary headings present.

### PR-102 · `predicate` tool
- Files: `tools/predicate.py` + `axon/tools/predicate.md`.
- Implements: parser + AST + evaluator per `goal-schema-v1` § Predicate language.
- Deps: PR-101.
- Risk: medium. New tool, lots of code paths.
- Tests: 50 fixture predicates; unit tests for built-in functions.

### PR-103 · `goal` tool + goal-schema v1
- Files: `tools/goal.py`, `axon/tools/goal.md`, schema template.
- Subcommands: set / get / confirm / list / met / audit.
- Deps: PR-101, PR-102.
- Risk: medium.
- Tests: round-trip a goal record; audit on demand-ledger.

### PR-104 · Synapse-contract schema v1
- Files: `workspace/SYNAPSE-CONTRACT.md` (spec); REGISTRY.json schema bump
  with backward-compat (new fields all optional).
- Deps: PR-101.
- Risk: low. Schema docs + JSON-schema for validation.
- Tests: validate existing 75 tool entries pass with sparse contracts.

### PR-105 · Workflow file v1 spec + schema
- Files: `workspace/WORKFLOW-FILE.md` (spec) + JSON-schema.
- Deps: PR-101, PR-102, PR-103, PR-104.
- Risk: low.
- Tests: validate two fixture workflow files.

### PR-106 · Domain manifest v1 + reference manifests
- Files: `workspace/DOMAIN-MANIFEST.md` (spec) + `workspace/domains/code-dev/manifest.md` + `workspace/domains/library-dev/manifest.md`.
- Deps: PR-101.
- Risk: low.
- Tests: validate both reference manifests.

### PR-107 · `synapse-infer` + `synapse-validate` tools
- Files: `tools/synapse_infer.py`, `tools/synapse_validate.py`.
- Implements: parse program headers + bodies, emit contract JSON.
- Deps: PR-104.
- Risk: medium-high. Parser robustness.
- Tests: infer contracts for 20-program corpus; spot-check accuracy.

### PR-108 · Domain folder scaffold + metadata migration
- Files: `workspace/domains/` directory + symlinks back to `workspace/programs/`
  for backwards compat. Bulk-add `domain:` field to every existing synapse
  contract via inference.
- Deps: PR-106, PR-107.
- Risk: medium. Must preserve all existing invocation paths (D-014/D-025).
- Tests: existing test suite passes; every program still invokable by old name.

### PR-109 · `synapse-suggest` tool (orchestrator composition v1)
- Files: `tools/synapse_suggest.py`, `axon/tools/synapse-suggest.md`.
- Implements: combiner formula per `orchestrator-composition-v1`.
- Deps: PR-102, PR-103, PR-104, PR-107.
- Risk: high. Core new functionality.
- Tests: ranker fixture (50 state→expected-tool pairs); accept ≥ 70 %
  top-1 hit for initial bar (D-21 90 % target is Phase 4 goal).

### PR-110 · DAG spec v1 + `dag` tool + sync
- Files: `tools/dag.py`, `axon/tools/dag.md`, `workspace/DAG-SPEC.md`.
- Implements: bootstrap, mutators, render, verify, sync.
- Migrates: existing 3 plan-level DAG files to schema v1.
- Deps: PR-101.
- Risk: medium.
- Tests: cycle check, nested sync, render fidelity.

### PR-111 · Orchestrator loop (program)
- Files: `workspace/programs/orchestrator.md`.
- Implements: the loop in `orchestrator-composition-v1` § The loop.
- Deps: PR-109, PR-110.
- Risk: high. Adds a new mainline.
- Tests: 5 fixture sessions end-to-end; both fixed + adaptive modes.

### PR-112 · Output-layer suggestions section
- Files: `axon/OUTPUT-LAYER.md` (dev-mode write — gated PR).
- Implements: footer `suggestions` block per spec.
- Deps: PR-109.
- Risk: medium. Touches kernel.
- Tests: snapshot rendering; verifies absence when `L:suggestions-enabled=false`.

### PR-113 · plan_dag auto-emit hook
- Files: `workspace/programs/code-dev-plan.md` (extension).
- Implements: on plan finalize → `dag bootstrap plan` + populate from PR list.
- Deps: PR-110.
- Risk: low. Wraps existing `plan_dag.py` invocation.
- Tests: run `code-dev plan` on fixture; assert DAG files emerge.

### PR-114 · Shadow enforcement gates
- Files: `workspace/programs/code-dev-safety-audit.md` extension;
  `code-dev-knowledge-shadow.md` `--bulk-phase` mode.
- Implements: shadow-coverage row in audit; gate placement per
  `shadow-enforcement-v1`.
- Deps: PR-104 (shadow's contract).
- Risk: medium.
- Tests: audit reports correct coverage on a fixture project with mixed
  shadow state.

### PR-115 · `workflow-new` conversational author
- Files: `workspace/programs/workflow-new.md`, `workflow-run.md`,
  `workflow-list.md`, `workflow-edit.md`, `workflow-simulate.md`,
  `workflow-validate.md` (tool).
- Implements: dialog per `conversational-author-v1`.
- Deps: PR-105, PR-109.
- Risk: medium.
- Tests: 5 fixture descriptions → valid workflow files.

### PR-116 · Shadow retroactive bulk migration
- Files: `workspace/programs/shadow-retroactive-bulk.md`.
- One-shot migration over all `my-axon/dev-projects/*` (119 PRs).
- Flips `L:shadow-enforcement-strict=true` on completion.
- Deps: PR-114.
- Risk: medium. Touches many existing files.
- Tests: dry-run mode; idempotency; rollback marker via `undo`.

### PR-117 · Alias canonicalization + finalize stub + self-review collision
- Files: `workspace/programs/code-dev-audit.md`, `code-dev-pr.md`,
  `code-dev-shadow.md` (alias formalization — preserve permanently);
  `code-dev-finalize.md` (implement per PR-119 of axon-cleanup);
  resolve `code-dev-self-review` vs `code-dev-review-self`.
- Deps: PR-108 (domain metadata).
- Risk: medium.
- Tests: aliases still resolve; finalize now does something useful.

### PR-118 · Reference workflows
- Files: `workspace/domains/code-dev/workflows/code-dev.canonical.yml`,
  `python-code-dev.yml`, `cpp-code-dev.yml`,
  `workspace/domains/library-dev/workflows/library-dev.canonical.yml`,
  `workspace/workflows/adaptive-free-text.yml`.
- Deps: PR-105, PR-108.
- Risk: low. Pure workflow files.
- Tests: validate; simulate each on fixture project.

### PR-119 · `axon-audit` extension
- Files: `workspace/programs/axon-audit.md` extension.
- Implements: shadow-coverage row, synapse-validate row, demand-audit row.
- Deps: PR-107, PR-114, PR-103.
- Risk: low.

### PR-120 · Wire igap + auto-improve to synapse-suggest
- Files: `tools/igap.py` extension, `workspace/programs/auto-improve.md` extension.
- Implements: igap records trigger synapse-suggest re-rank (signal source).
- Deps: PR-109.
- Risk: low.

## Test-safety strategy (D-19 mandate)

Every PR runs:
1. Existing test suite (no regressions).
2. PR-specific tests.
3. `synapse-validate` against the whole synapse corpus.
4. `dag verify` against every project's DAGs.

CI gate: all four must pass. Failures block merge.

## Dev-mode strategy (D-004 / D-014)

PRs that touch `axon/`:

- PR-112 (output-layer change) — dev-mode flip, single PR scope, flip back.
- All other PRs land entirely under `workspace/` or `my-axon/` — no
  dev-mode needed.

The kernel itself (axon/KERNEL-SLIM.md and core files) is untouched by
this project (per F-010 — kernel is already domain-agnostic).

## Migration order rationale

1. **Glossary first** — vocabulary lock prevents downstream drift.
2. **Predicate + goal next** — every other spec uses predicates.
3. **Synapse contract + workflow + domain** — three sibling schemas.
4. **Infer/validate tools** — bulk-fill contracts before anything depends.
5. **Orchestrator composition** — needs contracts, predicates, goals.
6. **DAG plumbing** — needed by orchestrator + plan auto-emit.
7. **Output-layer + auto-emit hooks** — surface the new behaviour.
8. **Shadow enforcement + retroactive** — close the D-23 gap.
9. **Reference workflows + alias cleanup** — ship the user-visible deliverables.
10. **Audit extensions + integration glue** — final wiring.

## Rollback per PR

Every PR includes a one-line rollback procedure in its spec. Most are
"revert the file change(s) and re-run boot." High-risk PRs (PR-108,
PR-116) include a `code-dev-undo` step.

## Acceptance for Phase 3 → Phase 4

Phase 3 closes when:

1. All 20 PRs merged.
2. Existing test suite still passes.
3. `synapse-validate` reports ≥ 80 % programs with contracts (D-6).
4. `shadow.coverage(all projects)` == 100 % (D-23).
5. `code-dev.canonical.yml` workflow runs end-to-end on a fixture project.
6. `workflow-new --from-description "<text>"` produces a valid workflow.

## Open items punted to Phase 4

- Domain `study-dev` bootstrap (D-26 second-domain proof).
- Ranker tuning from lived data (D-21 90 % top-1 hit bar).
- Workflow compilation cache (perf).
- Cross-domain workflow examples (science-dev's review delegating to
  code-dev-pr-review).

## Version + change rule

**Version: v1 (2026-05-17).** Plan changes go through `code-dev-divide` /
`code-dev-combine` mutators (per D-3 / DAG spec).
