# AXON GLOSSARY (v2)

> One meaning per term. Authoritative for everything downstream.
> Resolves Q15.1 + OP-01 (biology-correct vocabulary).
> If a downstream spec contradicts this glossary, the glossary wins.

## v2 change — biology-correct vocabulary rename

Project name **AXON** describes the orchestrator (the long neural projection
that carries signals). The original Phase-1 / Phase-2 v1 wording called each
program a "synapse" — but in neurobiology a **synapse** is the *connection*
between neurons, not the neuron itself. v2 fixes the inversion:

| v1 term | v2 term | Why |
|---------|---------|-----|
| synapse (= node / firing unit) | **neuron** | nodes are neurons |
| (next-conditional + confidence) | **synapse** | weighted edge = real synapse |
| precondition / input | (no change; or `dendrite` for prose) | receiver |
| orchestrator | **axon** (the carrier) | matches project name |

**Backwards-compat (D-026):** the user-facing umbrella term `synapse` remains
an accepted alias for `neuron` in commands, prose, and external docs. Specs
and schemas use `neuron` as canonical. Where collision is possible, schemas
use the fully-qualified form (`neuron-contract`, `synapse-edge`).

File renames are **deferred to Phase 3 PR-101a** (after vocabulary lock) to
preserve audit-traceability of v1 references during the transition.

## Top-level primitives

### Neuron (formerly: synapse-as-node)
A single, atomic fire-able unit that, when invoked, observes state, performs
some operation, and produces an observable post-state. Concretely: a
**program file** (`workspace/programs/*.md`, `workspace/domains/{d}/programs/*.md`)
OR a **tool entry** (`tools/REGISTRY.json` entry) — both are neurons. A
neuron declares its contract (precondition / inputs / outputs / post-state /
synapses / cost / role / modes).

> Not a neuron: a kernel op (STORE/RETRIEVE/EXEC/etc.) — those are primitives
> of the kernel language, used inside neuron bodies.

### Synapse (the edge)
A **weighted, conditional connection** between two neurons. Lives in a
source neuron's `synapses:` block (formerly `next-conditional:`). Each
synapse declares:
- a `condition` predicate
- a `target` (one or more downstream neurons)
- a `weight` ∈ [0, 1] — the connection strength (base ranker score)
- an optional `reason`

When a neuron fires and its post-state is observed, every synapse whose
`condition` evaluates true contributes its `target` × `weight` to the
candidate pool for the next firing.

### Axon (the orchestrator)
The single kernel-level loop that: (1) observes state, (2) walks active
synapses from the just-fired neuron, (3) combines synapse weights with
runtime signals (dispatch, pattern, usage, drift, context, goal) to
rank candidate neurons, (4) fires a chosen neuron, (5) observes post-state,
(6) re-walks synapses, (7) loops until goal-met or user-interrupt.
Domain-agnostic. The orchestrator IS the project's namesake.

### Workflow
A named, goal-bearing, persisted **directed acyclic graph of neurons +
synapses** with an `execution-mode` (`fixed`, `adaptive`, `hybrid`,
`exploratory`, `scheduled`). Lives as a file under
`workspace/workflows/<name>.yml` (cross-domain) or
`workspace/domains/{d}/workflows/<name>.yml` (domain-bound).

### Domain
A scoped family of workflows + neurons + file-conventions sharing
vocabulary. Lives as a folder under `workspace/domains/{name}/` containing
a `manifest.md` plus optional `programs/`, `workflows/`, `templates/`.
Examples today: `code-dev`, `library-dev`. Examples future:
`study-dev`, `science-dev`.

### Project
An **instantiated workflow run** with persistent state, phases, decisions,
findings, log, shadow. Lives under each domain's manifest-declared
`container-root`. **Not** a neuron, **not** a workflow — the runtime
container of a workflow execution.

### Phase
A named sub-stage of a project with its own goal, working files, decisions,
deviations, log, reviewer-state. Multiple phases per project. Each phase
itself is a sub-workflow.

### Goal
A persisted, auditable statement of what success looks like for a project /
phase / workflow / step / PR / finding / demand. Fields: `statement`,
`measurement`, `acceptance-criterion`, `rejection-criterion`, `source`,
`status`. Always exists per D-007.

### State (or state vector)
The current readable workspace at a given moment: `W:` keys, `L:` keys,
`E:` log tail, file existence checks, project + phase metadata, active
neuron / phase, recent EMIT events. The axon reads STATE on every loop.

### Predicate
A boolean expression over STATE with formal precedence + null + type rules
(see `predicate-language-v1.1`).

### DAG (directed acyclic graph)
A persistent JSON + MD pair representing dependency/ordering relations.
DAGs nest at five levels (project, phase, plan, PR, study) per `dag-spec-v1.1`.

## Roles + axes

### Role (neuron axis)
Closed list:
- `mutator`    — writes state, files, or kernel records
- `reader`     — reads + reports; no side-effect
- `gate`       — ASSERT/HALT predicates; enforces invariants
- `renderer`   — translates internal state to human-readable output
- `router`     — dispatches to other neurons based on input
- `composer`   — combines multiple neuron fires into a meta-action
- `seed`       — kernel boot neurons (boot, prefs); fire only at session start

### Family (neuron axis)
Free-text grouping by filename-prefix convention. Multi-valued allowed.

### Domain (neuron axis)
Closed list: `code-dev`, `library-dev`, future. Inferred from filename
prefix when not declared.

### Layer (neuron axis — NEW v2, splits the old `meta` overload)
Closed list:
- `kernel`    — kernel-level primitives (clock, shell, calculator, memory,
   boot, log)
- `system`    — workspace infrastructure (compile, run, verify, drift,
   dispatch, pattern, usage)
- `meta`      — meta-tools for AXON itself (axon-audit, igap, auto-improve)
- `shared`    — cross-domain neurons (flow-shadow, flow-explain — Phase 3+)
- `domain`    — domain-bound neurons (code-dev-*, library-dev-*)

Replaces v1's single overloaded `category` field. Each tool in REGISTRY
gains `layer:` plus the existing `category:` is preserved for backwards-compat.

### Mode (neuron axis)
A parameterized variant of the neuron. Each declared mode has its own
precondition / inputs / outputs / post-state / cost overrides.
Default for neurons without declared modes: a single `default` mode.

### Status (neuron axis)
A neuron's lifecycle state: `ACTIVE` | `OPTIONAL` | `STUB` | `ALIAS` |
`DEPRECATED` | `ARCHIVED`.

## Workflow execution modes (expanded v2)

### Fixed
Declared neuron sequence; axon walks it step by step. Suggestions remain
live (sideband + deviation).

### Adaptive
No predeclared sequence. At each step the axon picks the next neuron by
ranking against state + goal + history.

### Hybrid
Per-step `mode-override:` field. Some steps Fixed, others Adaptive.

### Exploratory (NEW v2 — closes GAP)
No goal predicate required. Used for discovery: ranker selects on
similarity + novelty + low cost; user confirms each fire. Ends on user
abort.

### Scheduled (NEW v2 — closes GAP)
Cron-triggered. Wraps a Fixed workflow with `state-precondition:` predicates
that must hold at fire time; else skipped. Reuses kernel cron infra.

## Suggestion vocabulary

### Suggestion
A surfaced candidate neuron for the user to fire (or for the axon to fire
autonomously per `L:inference-mode`).

### Sideband suggestion
Surfaces in footer / panel without altering the Fixed path.

### Deviation suggestion
Surfaces when state diverges from the next Fixed-step's precondition.

### Ephemeral suggestion
Runtime-generated, not declared in any synapse. Promotes to declared
after N accepts (per D-010).

### Predetermined suggestion
Declared in a neuron's `synapses:` block. Stable across runs.

## DAG vocabulary

### Project DAG · Phase DAG · Plan DAG · PR DAG · Study DAG
Five-level hierarchy per `dag-spec-v1.1`. JSON canonical; MD rendered.

### Nested DAG
A child-DAG hosted at one of the levels above. Every nesting edge must
satisfy: child-DAG nodes appear as edges in parent-DAG.

### DAG sync
Consistency check across `DAG.json` + `DAG.md` + nested DAGs. Enforced
by `dag-sync` tool.

## Goal vocabulary

Project goal · phase goal · workflow goal · step goal · PR goal ·
finding goal · demand goal — hierarchical, file per level (see
`goal-schema-v1.1`).

## Anti-glossary (terms NOT to use without qualification)

- "program" alone → say **neuron** (contract / graph / suggestions) or
  **program file** (file on disk).
- "tool" alone → say **neuron** (uniform) or **kernel tool** when
  distinguishing from program-files.
- "command" → say **neuron invocation** (programmatic) or **CLI alias**
  (user-typed shortcut).
- "next step" alone → say **synapse** (declared, weighted edge) or
  **suggestion** (runtime).
- "review" alone → say **PR-review**, **self-review**, **reviewer-track**.
- "mode" → disambiguate: **neuron mode** (parameter variant), **UI mode**
  (chat/build/etc.), **execution mode** (workflow fixed/adaptive/etc.).
- "audit" → disambiguate: **neuron audit** (axon-audit), **project audit**
  (code-dev safety-audit), **demand audit** (goal-schema-v1).
- "synapse" alone → in v2 specs means the edge; in user-facing prose
  remains acceptable as alias for neuron (per D-026).

## Glossary version + change rule

**Version: v2 (2026-05-17).** v1 → v2 vocabulary rename per D-026.
Downstream specs cite as `glossary: AXON-GLOSSARY v2`.
v1 alias accepted in user input forever; spec edits use v2 canonical.

Edits require: ADR + version bump + downstream sweep.
