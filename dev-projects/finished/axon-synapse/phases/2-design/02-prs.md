# PR list — 2-design  ·  axon-synapse  ·  Phase 3 roster

> glossary: SYNAPSE-GLOSSARY v1
> source: migration-plan-v1.md
> DAG: 03-prs/DAG.json + 03-prs/DAG.md

## PR-101 · SYNAPSE-GLOSSARY → docs
**Depends-on**: (none)
**Risk**: low (docs only)
**Files**: `workspace/SYNAPSE-GLOSSARY.md`
**Description**: Promote the Phase-2 glossary to a workspace-level
authoritative file. Everything downstream cites it.

## PR-102 · predicate tool
**Depends-on**: PR-101
**Risk**: medium
**Files**: `tools/predicate.py`, `axon/tools/predicate.md`
**Description**: Parser + AST + evaluator for the v1 predicate language.
Validates: 50 fixture predicates; built-in functions (file.exists,
count, shadow.contains, tests.pass, etc.).

## PR-103 · goal tool + goal-schema v1
**Depends-on**: PR-101, PR-102
**Risk**: medium
**Files**: `tools/goal.py`, `axon/tools/goal.md`, `workspace/templates/goal-v1.yml`
**Subcommands**: set / get / confirm / list / met / audit
**Description**: Goal records per goal-schema-v1. `goal audit` traverses
project, phase, workflow, step, PR, finding, demand levels.

## PR-104 · synapse-contract schema v1
**Depends-on**: PR-101
**Risk**: low
**Files**: `workspace/SYNAPSE-CONTRACT.md`, `tools/REGISTRY-schema.json` (bumped)
**Description**: Schema docs + JSON-schema validator for synapse contracts.
Existing tools pass with sparse contracts; new fields all optional.

## PR-105 · workflow file v1 spec + schema
**Depends-on**: PR-101, PR-102, PR-103, PR-104
**Risk**: low
**Files**: `workspace/WORKFLOW-FILE.md`, `tools/workflow-file-schema.json`
**Description**: YAML schema for workflow files. `execution-mode` field,
`synapses[]` DAG, `default-goal`, `triggers`, `suggestion-channel`.

## PR-106 · domain manifest + reference manifests
**Depends-on**: PR-101
**Risk**: low
**Files**: `workspace/DOMAIN-MANIFEST.md`, `workspace/domains/code-dev/manifest.md`,
`workspace/domains/library-dev/manifest.md`
**Description**: Two reference manifests validating the schema. Existing
programs / tools still invokable.

## PR-107 · synapse-infer + synapse-validate tools
**Depends-on**: PR-104
**Risk**: medium-high (parser robustness)
**Files**: `tools/synapse_infer.py`, `tools/synapse_validate.py`,
`axon/tools/synapse-infer.md`, `axon/tools/synapse-validate.md`
**Description**: Parse synapse files; emit contract JSON. Validate spot-check
against 20 programs (target ≥ 90 % accuracy).

## PR-108 · domain folder scaffold + metadata migration
**Depends-on**: PR-106, PR-107
**Risk**: medium (must preserve all invocation paths)
**Files**: `workspace/domains/code-dev/{programs,workflows}/` (symlinked or
manifest-referenced); all program files get a `# synapse:` block (inferred).
**Description**: No filename changes. All programs gain `domain:` field via
inference. Existing test suite must still pass.

## PR-109 · synapse-suggest tool (orchestrator composition v1)
**Depends-on**: PR-102, PR-103, PR-104, PR-107
**Risk**: high (core new functionality)
**Files**: `tools/synapse_suggest.py`, `axon/tools/synapse-suggest.md`
**Description**: Combiner formula per orchestrator-composition-v1.
Initial bar: ≥ 70 % top-1 hit on labeled fixture set. (Phase 4 target: 90 %.)

## PR-110 · DAG spec + `dag` tool + sync
**Depends-on**: PR-101
**Risk**: medium
**Files**: `tools/dag.py`, `axon/tools/dag.md`, `workspace/DAG-SPEC.md`
**Subcommands**: bootstrap / add-node / add-edge / remove-* / merge / split /
fold-in / set-status / render / verify / sync
**Description**: 5-level DAG plumbing. Migrate existing 3 plan-level DAGs
to schema v1.

## PR-111 · orchestrator loop (program)
**Depends-on**: PR-109, PR-110
**Risk**: high (new mainline)
**Files**: `workspace/programs/orchestrator.md`
**Description**: The loop from orchestrator-composition-v1. End-to-end
test: 5 fixture sessions, both fixed + adaptive modes.

## PR-112 · output-layer suggestions section [dev-mode]
**Depends-on**: PR-109
**Risk**: medium (touches kernel via dev-mode flip)
**Files**: `axon/OUTPUT-LAYER.md`
**Description**: Footer suggestion block. Gated by `L:suggestions-enabled`
(default true). dev-mode flipped for this PR only, then back.

## PR-113 · plan_dag auto-emit hook
**Depends-on**: PR-110
**Risk**: low
**Files**: `workspace/programs/code-dev-plan.md` (extension)
**Description**: On plan finalize → `dag bootstrap plan` + populate from
PR list. Resolves D-2.

## PR-114 · shadow enforcement gates
**Depends-on**: PR-104
**Risk**: medium
**Files**: `workspace/programs/code-dev-safety-audit.md` extension;
`code-dev-knowledge-shadow.md` `--bulk-phase` mode.
**Description**: Shadow-coverage row in audit. Gate placement per
shadow-enforcement-v1.

## PR-115 · workflow-new conversational author
**Depends-on**: PR-105, PR-109
**Risk**: medium
**Files**: `workspace/programs/workflow-new.md`, `workflow-run.md`,
`workflow-list.md`, `workflow-edit.md`, `workflow-simulate.md`,
`workflow-validate.md`
**Description**: Conversational dialog per conversational-author-v1.

## PR-116 · shadow retroactive bulk migration
**Depends-on**: PR-114
**Risk**: medium (touches many existing files)
**Files**: `workspace/programs/shadow-retroactive-bulk.md`
**Description**: One-shot migration over all `my-axon/dev-projects/*`
(119 PRs). Flips `L:shadow-enforcement-strict=true` on completion.
Includes dry-run + undo.

## PR-117 · alias canonicalization + finalize stub + self-review collision
**Depends-on**: PR-108
**Risk**: medium
**Files**: `workspace/programs/code-dev-audit.md`, `code-dev-pr.md`,
`code-dev-shadow.md` (preserved permanently as aliases);
`code-dev-finalize.md` (implemented per PR-119 of axon-cleanup);
`code-dev-self-review.md` / `code-dev-review-self.md` (one becomes alias).
**Description**: Resolves F-012 + F-007.

## PR-118 · reference workflows ship
**Depends-on**: PR-105, PR-108
**Risk**: low
**Files**: `workspace/domains/code-dev/workflows/{code-dev.canonical,python-code-dev,cpp-code-dev}.yml`;
`workspace/domains/library-dev/workflows/library-dev.canonical.yml`;
`workspace/workflows/adaptive-free-text.yml`
**Description**: 5 reference workflows. Each validated + simulatable.

## PR-119 · axon-audit extension
**Depends-on**: PR-107, PR-114, PR-103
**Risk**: low
**Files**: `workspace/programs/axon-audit.md` extension
**Description**: New audit rows: synapse-contract coverage, shadow coverage,
demand audit (per goal-schema-v1).

## PR-120 · igap + auto-improve wire to synapse-suggest
**Depends-on**: PR-109
**Risk**: low
**Files**: `tools/igap.py` extension; `workspace/programs/auto-improve.md` extension
**Description**: igap records become a signal source for the suggester
ranker. Re-rank on new igap entries.

---

## Post-1.0 (Phase 4 candidates — NOT scheduled in Phase 3 cycle)

### PR-150 · study-dev domain (D-26 second-domain proof)
**Depends-on**: PR-106, PR-115
**Description**: Bootstrap `workspace/domains/study-dev/` + programs +
canonical workflow. Validates the multi-domain claim on a non-code domain.

### PR-151 · cross-domain workflow examples
**Depends-on**: PR-150
**Description**: e.g. `science-dev review` delegating to code-dev-pr-review.

### PR-152 · ranker tuning
**Depends-on**: PR-109, PR-120
**Description**: Adjust `L:ranker-weights` based on lived data; bring
top-1 hit rate to ≥ 90 % per D-21.

### PR-153 · workflow-compile
**Depends-on**: PR-115
**Description**: Cache compiled workflow files in `workspace/workflows/compiled/`.
Perf optimization.

---

## Acceptance / handoff to Phase 3

Phase 3 starts with PR-101 (no dependencies). Phase 3 closes when:

- All 20 PRs (PR-101..PR-120) merged.
- Existing test suite still passes (D-19).
- ≥ 80 % synapse-contract coverage (D-6).
- shadow.coverage = 100 % across all projects (D-23).
- 5 reference workflows validated + simulatable (D-9).
- `workflow-new --from-description` produces a valid workflow on 3 fixture descriptions (D-28).

Phase 4 picks up post-1.0 deliverables + the ranker-tuning target.
