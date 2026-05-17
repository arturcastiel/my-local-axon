# SYNAPSE-GLOSSARY (v1)

> One meaning per term. Authoritative for everything downstream.
> Resolves Q15.1. Inputs from Phase 1 findings F-005, F-008, F-011, F-013.
> If a downstream spec contradicts this glossary, the glossary wins.

## Top-level primitives

### Synapse
A single, atomic fire-able unit that, when invoked, observes state, performs
some operation, and produces an observable post-state. Concretely: a
**program file** (`workspace/programs/*.md`, `workspace/domains/{d}/programs/*.md`)
OR a **tool entry** (`tools/REGISTRY.json` entry) — both are synapses. A
synapse declares its contract (precondition / inputs / outputs / post-state /
next-conditional / cost / role / modes).

> Not a synapse: a kernel op (STORE/RETRIEVE/EXEC/etc.) — those are
> primitives of the kernel language, used inside synapse bodies.

### Workflow
A named, goal-bearing, persisted **directed acyclic graph of synapses** with
an `execution-mode` (`fixed`, `adaptive`, `hybrid`). Lives as a file under
`workspace/workflows/<name>.{yml,md}` (cross-domain) or
`workspace/domains/{d}/workflows/<name>.{yml,md}` (domain-bound). A workflow
is **not** a synapse — it is a coordinated firing pattern over synapses.

### Domain
A scoped family of workflows + synapses + file-conventions sharing
vocabulary. Lives as a folder under `workspace/domains/{name}/` containing
a `manifest.md` plus optional `programs/`, `workflows/`, `templates/`.
Examples today: `code-dev`, `library-dev`. Examples future:
`study-dev`, `science-dev`.

### Orchestrator
The single kernel-level loop that: (1) observes state, (2) ranks candidate
synapses against goal + workflow + history, (3) fires a chosen synapse,
(4) observes the post-state, (5) re-ranks, (6) loops until goal-met or
user-interrupt. Domain-agnostic. Built as a composition over existing
kernel tools (per F-014).

### Project
An **instantiated workflow run** with persistent state, phases, decisions,
findings, log, shadow. Lives under `my-axon/dev-projects/{slug}/` (code-dev),
`workspace/libraries/{name}/` (library-dev), or another domain's
manifest-declared container root. Not a synapse, not a workflow — the
**runtime container** of a workflow execution.

### Phase
A named sub-stage of a project with its own goal, working files, decisions,
deviations, log, reviewer-state. Multiple phases per project. Each phase
itself is a sub-workflow.

### Goal
A persisted, auditable statement of what success looks like for a project /
phase / workflow / step / PR / finding / demand. Fields: `statement`,
`measurement`, `acceptance-criterion`, `rejection-criterion`, `source`,
`status`. Always exists per D-007. See `goal-schema-v1.md`.

### State (or state vector)
The current readable workspace at a given moment: `W:` keys, `L:` keys,
`E:` log tail, file existence checks, project + phase metadata, active
program / phase, recent EMIT events. The orchestrator reads STATE
on every loop.

### Predicate
A boolean expression over STATE. Used by:
  - synapse `precondition` (must hold to fire)
  - synapse `post-state` (must become true after firing)
  - goal `acceptance-criterion` / `rejection-criterion`
  - workflow `trigger` (free-text or state condition)
  - `next-conditional` clauses (if-then suggestion edges)
Predicate language: `predicate-language-v1.md` (subset of `goal-schema-v1.md`).

### DAG (directed acyclic graph)
A persistent JSON + MD pair representing dependency/ordering relations
between nodes (synapses, PRs, phases, steps, study questions). DAGs nest:
a node may itself host a child-DAG. Five levels exist per D-009: project,
phase, plan, PR, study. See `dag-spec-v1.md`.

## Roles + axes

### Role (synapse axis)
A synapse's role in workflow plumbing. Vocabulary (closed list):
  - `mutator`   — writes state, files, or kernel records (e.g. STORE, WRITE)
  - `reader`    — reads + reports; no side-effect (e.g. status, audit)
  - `gate`      — ASSERT/HALT predicates; enforces invariants
  - `renderer`  — translates internal state to human-readable output
  - `router`    — dispatches to other synapses based on input
  - `composer`  — combines multiple synapse fires into a meta-action

Most existing programs are `mutator` + `renderer` hybrids; the role declares
the **dominant** semantic.

### Family (synapse axis)
A free-text grouping by filename-prefix convention. `code-dev`, `library-dev`,
`igap`, `axon-audit`, `meta`, `system`. Used by ranker for similarity bias.
Multi-valued allowed if a synapse genuinely belongs to multiple families.

### Domain (synapse axis)
The scoped domain (closed list — see § Domain above). Inferred from
filename prefix when not declared. `code-dev`, `library-dev`, (future).
A synapse without a domain declaration is `meta` (kernel-level).

### Mode (synapse axis)
A parameterized variant of the synapse (per F-013). Each declared mode has
its own precondition / inputs / outputs / post-state / cost overrides.
Examples: `code-dev-study` modes `{overview, subsystem, deep}`;
`code-dev-plan` modes `{tactical, strategic, operational, decision}`.

### Status (synapse axis)
A synapse's lifecycle state in the registry: `ACTIVE` (production),
`OPTIONAL` (opt-in), `STUB` (orphan; not implemented per F-012),
`ALIAS` (forwarder; see canonical), `DEPRECATED` (sunset planned),
`ARCHIVED` (no longer fires).

## Workflow execution modes

### Fixed
The workflow declares the synapse sequence; the orchestrator walks it
step by step. Examples: canonical code-dev chain, `python-code-dev` (WF-08).
Suggestions remain live (sideband + deviation) but never override
silently. See D-017.

### Adaptive
No predeclared sequence. At each step the orchestrator picks the next
synapse by ranking candidates against state + goal + history. Used for
free-text task entry. See D-017.

### Hybrid
Per-step mode field. Some steps Fixed, others Adaptive. Allows e.g. fixed
study → adaptive plan branching → fixed audit.

## Suggester vocabulary

### Suggestion
A surfaced candidate synapse for the user to fire (or for the orchestrator
to fire autonomously per `L:inference-mode`).

### Sideband suggestion
A suggestion fired without leaving the current Fixed workflow. Surfaces in
footer or a dedicated "you might also" panel. User can opt in or ignore.

### Deviation suggestion
A suggestion fired when current state diverges from the next Fixed-step's
precondition. E.g. tests fail before review → "fix tests first?". User
must accept to deviate.

### Ephemeral suggestion
A runtime-generated suggestion (not predeclared in any program's
`next-conditional`). Lives for one fire then logs. Promotes to
**predetermined** if user accepts ≥ N times (`L:suggestion-promotion-threshold`,
default 3) — per D-010.

### Predetermined suggestion
A suggestion declared in a synapse's `next-conditional` block or in
`workspace/synapses/<name>.next.md`. Stable across runs.

## DAG vocabulary

### Project DAG
The phase graph for a project. Lives at `<project-root>/DAG.{json,md}`.
Replaces / wraps `masterplan.md`.

### Phase DAG
The sub-step graph within a phase. Lives at
`<project-root>/phases/{n}/DAG.{json,md}`.

### Plan DAG
The PR graph within a plan. Lives at
`<project-root>/phases/{n}/03-prs/DAG.{json,md}` (or `<project-root>/03-prs/DAG.{json,md}`
for legacy v4).

### PR DAG
The sub-task graph within a PR (optional; only when a PR is subdivided).
Lives at `<project-root>/phases/{n}/03-prs/PR-NNN/DAG.{json,md}`.

### Study DAG
The research-question / track / finding graph within a study phase. Lives
at `<project-root>/phases/{n-study}/DAG.{json,md}`.

### Nested DAG
A child-DAG hosted at one of the levels above. Every nesting edge must
satisfy: child-DAG nodes appear as edges in parent-DAG.

### DAG sync
The check that DAG.json (canonical) and DAG.md (rendered) are consistent
and that nested DAGs satisfy the parent-edge requirement. Enforced by
the `dag-sync` tool (Phase 3 deliverable).

## Goal vocabulary

### Project goal
The top-level goal authored at `<project-root>/_goal.md`. Inherited by
all sub-goals.

### Phase goal
A goal authored in `<project-root>/phases/{n}/_meta.md` under the `goal:`
block. Inherits from project goal.

### Workflow goal (default-goal)
A goal declared in a workflow file's `default-goal:` field. Becomes the
active goal when the workflow runs.

### Step goal
A synapse's `goal-advances` field — the parent goal(s) this synapse fire
advances when its post-state is achieved.

### PR goal
A goal authored in PR-spec frontmatter (`<project-root>/phases/{n}/03-prs/PR-NNN.md`).
Inherits from phase goal.

### Finding goal
Implicit: each finding (`F-NNN-*.md`) implicates one or more Phase-2
design questions. The finding's "Implication" block is its goal-equivalent.

### Demand goal
A row in `<project-root>/_demands.md`. Carries `goal`, `measurement`,
`audit-criterion` per D-024.

## Anti-glossary (terms NOT to use)

To prevent drift, the following terms are **explicitly disallowed** in
schemas, code, and docs unless qualified:

- "program" alone — say **synapse** (when discussing the contract /
  graph / suggestions) or **program file** (when discussing the file on disk).
- "command" — say **synapse invocation** (programmatic) or **CLI alias**
  (user-typed shortcut).
- "tool" alone — say **synapse** (uniform) or **kernel tool**
  (when distinguishing from program-files explicitly).
- "next step" alone — say **next-conditional** (declared) or **suggestion**
  (runtime).
- "review" alone — say **PR-review** (the 9-phase sub-FSM),
  **self-review**, **reviewer-track**, or **review (verb)** — never bare.
- "mode" — context-disambiguate: **synapse mode** (parameter variant),
  **UI mode** (chat/build/run/etc. shortcut), **execution mode**
  (workflow fixed/adaptive/hybrid).
- "audit" — context-disambiguate: **synapse audit** (axon-audit),
  **project audit** (code-dev safety-audit), **demand audit** (this
  glossary's audit-criterion check).

## Glossary version + change rule

**Version: v1 (2026-05-17).**

Glossary edits require:
1. ADR in `phases/2-design/_decisions.md` citing the new term + rationale.
2. Bump the version (v1 → v2).
3. Sweep downstream specs for breakage; update each.

Downstream specs MUST cite glossary version in their front-matter:
`glossary: SYNAPSE-GLOSSARY v1`.
