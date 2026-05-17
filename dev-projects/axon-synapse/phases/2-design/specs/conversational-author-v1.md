# Conversational Workflow Author (v1)

> glossary: SYNAPSE-GLOSSARY v1
> resolves: D-016, D-028
> serves: D-7 (adaptive orchestrator demonstrating itself), D-9 (pre-built
> workflows), D-29 (fixed/adaptive modes — author can pick)

## Purpose

Specify the interactive dialog that turns a user's plain-English description
of a workflow into a valid `workspace/.../workflows/<name>.yml` file. This
is the entry point for D-28; it is also the simplest end-to-end demonstration
that the orchestrator's ranker is good enough to recommend tools.

## Entry points

- `workflow-new` — bare invocation; interactive.
- `workflow-new --from-description "<text>"` — seeds the dialog with the
  user's description.
- `workflow-new --template <existing-workflow>` — clone-and-modify an
  existing workflow.
- `workflow-new --interactive false --from-description "<text>"` —
  non-interactive: AXON proposes a full workflow in one shot; user
  approves the whole file (high-friction; only use when user confidence
  high).

## Dialog phases

### Phase A — Name + domain + execution-mode

```
AXON: What name do you want for this workflow? (lowercase, hyphens; e.g. python-code-dev)
USER: <name>

AXON: Domain? (auto-detect or pick one)
       - code-dev    (source files, PRs, tests)
       - library-dev (PDFs, articles, citations)
       - meta        (kernel-level, no domain)
       - new         (declare a new domain)
USER: <pick>

AXON: Execution mode?
       - fixed     (you know the path; AXON walks it)
       - adaptive  (AXON decides each step; suggests + confirms)
       - hybrid    (per-step mix)
USER: <pick>
```

### Phase B — Goal capture (per goal-schema-v1)

```
AXON: In one sentence, what does this workflow accomplish?
USER: <statement>

AXON: How will we know it's done? Pick measurement predicates:
       (1) "All declared synapses fired successfully"
       (2) "Test suite passes"
       (3) "Audit shows zero open issues"
       (4) "Shadow coverage 100%"
       (5) Custom...
USER: <multi-select>

AXON: Confirm goal:
       Statement:  <...>
       Measurement: [<predicates>]
       Acceptance: <derived from measurement>
       Rejection:  <auto: tests.fail OR audit.critical > 0>
USER: confirm | edit
```

### Phase C — Synapse-by-synapse build

This is the heart. For each synapse in turn:

```
AXON: Step 1. What should happen first?
       Based on your description and domain '<d>', I suggest:
         a) code-dev-study   (read the codebase) — confidence 0.78
         b) code-dev-load    (switch to a project) — 0.62
         c) code-dev-plan    (skip study) — 0.41
       Or describe in your own words.
USER: a

AXON: Step 1 = code-dev-study.
       This synapse has modes: overview / subsystem / deep.
       Based on your project size, I suggest: subsystem.
       OK?
USER: yes

AXON: Step 1 args:
       target = ? (path or glob; default: project codebase root)
USER: **/*.py

AXON: Recorded:
       - { id: s1, name: code-dev-study, mode: subsystem, args: { target: '**/*.py' } }

AXON: Step 2. After step 1 completes, what next?
       Synapses commonly chained after code-dev-study (from next-conditional + history):
         a) code-dev-plan    — 0.81
         b) code-dev-suggest-tests — 0.55
         c) code-dev-study (again, different mode) — 0.31
USER: b

AXON: Step 2 = code-dev-suggest-tests.
       Conditional next: if suggested-tests count > 0 → run-tests; else
       skip. Use conditional?
USER: yes

AXON: ...
```

The ranking signals fed to suggestions during the dialog are the same as
the orchestrator's runtime ranker (`orchestrator-composition-v1`).

### Phase D — Triggers + suggestions controls

```
AXON: When should this workflow surface as a suggestion?
       Pick triggers:
       - keyword:  "python workflow", "py code-dev"
       - state:    project has *.py files
       - explicit: only via `workflow run <name>`
USER: <multi-select>

AXON: Allow sideband suggestions during this fixed workflow? (default yes)
USER: yes

AXON: Allow deviation suggestions? (default yes)
USER: yes
```

### Phase E — Validation + save

```
AXON: Validating workflow file...
       ✓ All synapse names resolve
       ✓ DAG acyclic (Kahn check)
       ✓ Predicates parse
       ✓ Schema version v1
       Save to: workspace/domains/code-dev/workflows/python-code-dev.yml ?
USER: yes

AXON: Saved.
       To run: workflow run python-code-dev
       To edit: workflow edit python-code-dev
       Suggested next: workflow simulate python-code-dev  (dry-run check)
```

## Special cases

### Synapse not found

```
AXON: Step 3. You said "lint". I don't see a python-lint synapse registered.
       Options:
       a) Register a new synapse (interactive wizard — register-tool)
       b) Use an existing alternative:
          - code-dev-review-self  (runs some lint heuristics)
          - run-tests             (linter often run via test harness)
       c) Skip this step
USER: a

AXON: Launching register-tool wizard... [hands off]
```

After `register-tool` completes, control returns to the dialog with the
new synapse in the registry; the conversational author proposes it as
step 3.

### Adaptive sub-segment

```
AXON: Step 4. After tests, what if tests fail?
       Options:
       a) Branch to a fixed fix-up sequence
       b) Adaptive sub-segment — AXON triages and picks fix synapses
       c) Halt workflow
USER: b

AXON: Step 4 conditional branch:
       - if tests.pass() → next: step 5 (review)
       - if tests.fail() → adaptive sub-segment, exit when tests.pass()
       Recorded as `mode-override: adaptive` block.
```

### User accidentally describes a workflow that already exists

```
AXON: Your description matches existing workflow `code-dev.canonical` —
       80 % overlap. Options:
       a) Use existing workflow (no new file)
       b) Clone existing and modify
       c) Author independently (will create a sibling)
USER: <pick>
```

## Output artifacts

The dialog produces:

1. Workflow file at chosen path.
2. ADR in active project's phase `_decisions.md` (if the dialog was inside
   a project): "Authored workflow `<name>` via conversational dialog."
3. `04-log.md` entry recording the dialog summary.
4. EMIT(`axon.workflow.authored`, {name, domain, mode, synapse-count}).

## State preserved between dialog turns

Each step writes to `W:_workflow-author-state` so the dialog is
resumable mid-way:

```yaml
W:_workflow-author-state:
  name: python-code-dev
  domain: code-dev
  execution-mode: fixed
  goal: { ... partial ... }
  synapses: [ ... built so far ... ]
  step-cursor: 3
  triggers: [ ... ]
```

User can `pause` and `resume conversational-author`.

## Implementation (Phase 3 deliverable)

- New program: `workflow-new.md` (entry point, interactive).
- Internally calls `synapse-suggest` for each candidate ranking.
- Calls `register-tool` when user adds a new synapse.
- Calls `workflow-validate` before save.
- Calls `dag-bootstrap` to create the workflow's internal DAG.

Pattern reused from existing programs:
- `harness-builder.md` (interactive wizard scaffold).
- `register-tool.md` (interactive registration).
- `code-dev-new.md` (interactive new-project).

## Validation tests (Phase 4)

1. Replay 5 fixture descriptions; assert valid workflow files emitted.
2. Inject an invalid synapse name; assert graceful "not found → register?" path.
3. Mid-dialog interrupt + resume; assert state restored.
4. Two parallel authoring sessions; assert no interference (W: keys
   namespaced by session id).

## Version + change rule

**Version: v1 (2026-05-17).** Dialog scripts may evolve; YAML output
schema bumps require `workflow-file` spec bump.
