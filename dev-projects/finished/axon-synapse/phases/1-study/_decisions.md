# Decisions (ADRs) — 1-study

## D-001 — 2026-05-17 — Audit-first, derive goals from findings
**Context.** Goals for each code-dev step (study/project/plan/PR/code) are not
codified anywhere in axon/ today. User asked: "what is the goal of a study, what
is the goal of a project, what is the goal of a plan, what is the goal of a code?"
**Decision.** Audit current AXON first; derive goal definitions from observed
behavior + gap analysis. Do **not** define goals prescriptively before the audit.
**Consequences.** Phase 1 ships a goal-derivation document, not a goal manifesto.
Phase 2 codifies the goals as schema fields on phase/step records.

## D-002 — 2026-05-17 — One umbrella project, not split
**Context.** Four options offered: umbrella / two coordinated / audit-only first / per-feature.
**Decision.** Single project `axon-synapse` covers audit + design + implement + validate.
**Consequences.** Tighter cohesion, slower per-PR cycle. Internal phases substitute for
project boundaries. Sub-projects may spin out later if a feature grows large.

## D-003 — 2026-05-17 — Programs are synapses; AXON is adaptive orchestrator
**Context.** User vision: "I see each axon program as a synapse, axon orchestrates …
identify workflow — user has a task, you try to understand, and dispatch proper
tools — code dev has already this fixed — but I want something that adapts on the
way — like axon signaling and going to other tools."
**Decision.** Synapse model is the architectural North Star. A program must declare
its inputs (preconditions), outputs (artifacts), post-state (what becomes true after
it runs), and natural next-states (suggestions). The orchestrator reads task +
goal + workspace state, ranks candidate synapses, fires one, observes new state,
re-ranks, repeats. Workflows are emergent paths through the synapse graph, not
hard-coded sequences.
**Consequences.** code-dev's current fixed hierarchy becomes one workflow among
many — the orchestrator may follow it, deviate from it, or suggest a custom path.

## D-004 — 2026-05-17 — dev-mode OFF for this project
**Context.** Many implementation PRs will touch axon/ core.
**Decision.** Project default OFF. dev-mode flipped ON only for the specific PR
being implemented, then back OFF. Logged per-flip.
**Consequences.** No accidental kernel writes during study/design. Implementation
PRs require explicit dev-mode hand-off step.

## D-005 — 2026-05-17 — Synapse contract: hybrid (inferred + declared override) [resolves OQ-01]
**Context.** 174 programs to characterise. Pure-declared = lots of authoring;
pure-inferred = accuracy risk.
**Decision.** Static analyser seeds `precondition`/`post-state`/`next-conditional`
from program bodies (STORE/RETRIEVE/WRITE/EXEC patterns). Program authors may
override any inferred field by declaring it in the header. Declared > inferred.
**Consequences.** Phase 2 ships an inference engine (new tool: `synapse-infer`).
Phase 3 migrates programs over time — no big-bang authoring sprint.

## D-006 — 2026-05-17 — DAG persistence: both `DAG.json` + `DAG.md`, sync-checked [resolves OQ-04]
**Context.** User asked for auto-DAG on plan + mutation on merge/split.
**Decision.** Both files exist. `DAG.json` is machine source; `DAG.md` is
human-rendered view auto-emitted on json change. A sync-checker (`dag-sync` or
extension to `plan_dag`) fails loud on drift. Hand-edits land in `.md`; on
commit, a hook reverse-parses md → json and re-emits md to canonicalize.
**Consequences.** New tool/program: `dag-sync` (verifies + reconciles).
Auto-DAG hook fires on `code-dev plan` completion. DAG mutation API
(`code-dev-merge`, `code-dev-divide`, `code-dev-fold-in`) must call the same hook.

## D-007 — 2026-05-17 — Goal ownership: always-on, dual-mode [resolves OQ-02]
**Context.** User: "goals should always exist — in development phase they must
be prebuilt with predefined goals for coding depending on the workflow — but
in this case it must be asked."
**Decision.** Two modes:
  - **Workflow-bound goal** — derived from the workflow definition. E.g. running
    `code-dev plan` injects a built-in goal: "produce a verifiable PR list with
    deps + budgets + acceptance criteria."
  - **User-stated goal** — for ad-hoc / open-ended work, user states; AXON may
    infer from first command and ASK to confirm. Goal-less dispatch is forbidden.
A goal ledger (`W:current-goal` + `L:goal-history`) is the orchestrator's primary
signal alongside state. New tool: `goal` (set / get / confirm / list).
**Consequences.** Every dispatch path checks `W:current-goal ≠ ∅` before firing.
Workflow definitions carry a `default-goal:` field. Free-text user input
triggers goal-inference + confirm-prompt before any program runs.

## D-008 — 2026-05-17 — Study depth: most detailed, no cap [resolves OQ-09]
**Context.** User: "Most detailed research ever."
**Decision.** Phase 1 enumerates **every** program (174) and **every** tool
(69). Findings are unbounded per track. Tracks split into subtracks if a single
file exceeds 80 KB or 50 finding-references.
**Consequences.** Phase 1 is multi-session. CHECKPOINT after every track segment.
Study runs as a multi-turn program; G-02 mid-loop identity reassertion applies.
Synthesis happens once all tracks reach `:done` — no early synthesis.

## D-009 — 2026-05-17 — DAG is the central organizing primitive at every level
**Context.** User: "in code-dev each phase must have a graph in case multiple
tools or phases are used — and file organization obeys the same — a dag for a
study with multiple layers — but for development — a dag for several phases —
and a dag for several prs — they can be nested if needed — and dag MUST BE
CENTRAL on the organization."
**Decision.** DAG is not a side-artifact of `code-dev plan` — it is the
**primary organizing structure** at every level. Required levels:
  - **Project DAG** — graph of phases (currently `masterplan.md`).
  - **Phase DAG** — graph of sub-steps / tracks within a phase.
  - **Plan DAG** — graph of PRs within a plan (today's `DAG.json`).
  - **PR DAG** — graph of sub-tasks / commits / shadow files within a PR.
  - **Study DAG** — graph of research questions → tracks → findings.
DAGs nest: each node may itself be a DAG (sub-DAG). File layout mirrors the
nesting: `{level}/DAG.json` + `{level}/DAG.md` per node that has children.
**Consequences.** v4 schema gets extended to v5 in Phase 2 design:
  - Project root: `DAG.json` + `DAG.md` (phase graph; replaces `masterplan.md`
    or wraps it).
  - Per-phase: `phases/{n}/DAG.json` + `phases/{n}/DAG.md`.
  - Per-plan: existing `03-prs/DAG.json` + `DAG.md`.
  - Per-PR (if subtasked): `03-prs/PR-NNN/DAG.json`.
DAG sync-checker (D-006) extended to validate nested DAG consistency
(child-DAG nodes must exist as edges in parent-DAG).

## D-010 — 2026-05-17 — Suggestion firing: state-driven, predetermined + mutable
**Context.** User: "depending on your current state or what you doing, axon
fires a suggestion of another synapse or neurons (tools related based on the
workflow) — they can be predetermined like what we have so far in code-dev but
they can modify."
**Decision.** Suggestion engine fires on three signals:
  1. **Post-program completion** — read the just-completed synapse's
     `next-conditional`, evaluate predicates against current state, rank top-k.
  2. **State delta** — when W: keys cross thresholds (e.g. `igap-total > 0`),
     fire a pre-registered suggestion.
  3. **User input parse** — for free text, intent-classify then suggest top-k
     synapses; QUERY user before firing.
Predetermined suggestions live in `workspace/synapses/<program>.next.md` (or
inline in program header as `next-conditional:`). They are **mutable** at runtime:
the orchestrator may add ephemeral suggestions based on workflow context (e.g.
"you just implemented PR-N → suggest code-dev shadow + code-dev self-review");
ephemeral suggestions are surfaced once and then logged for promotion to
predetermined if the user accepted them ≥ N times.
**Consequences.** New tool: `synapse-suggest` (rank, fire, log). New L: key:
`L:suggestion-promotion-threshold` (default 3). Output-layer footer gets a
"suggestions" section (gated by `L:suggestions-enabled`, default true).

## D-012 — 2026-05-17 — Regression-safe rollout: no tests break, new tools auto-discoverable
**Context.** User: "no tests should break — and once new tools are added they
can be suggested — we need to think in a way that proper tool always gets
suggested."
**Decision.** Two hard rules:
  1. **Regression-safe.** Every PR that touches synapse infrastructure must
     pass the existing test suite. Any test that has to be modified to pass
     gets called out in the PR description with rationale. Failing tests
     block merge — no exceptions, no `--no-verify`.
  2. **Auto-discoverable tools.** Adding a tool to REGISTRY.json must be the
     only step required to make it suggestable. The suggester reads REGISTRY
     at boot, indexes synapse-contract fields, and includes new entries in
     ranking automatically. No per-tool manual wiring.
**Consequences.** Synapse-suggest must accept a sparsely-declared tool
(precondition: ∅, post-state: ∅) and rank it via inferred fields + caller
frequency + recency. Test suite becomes part of the kernel invariant — every
project audit verifies tests still pass.

## D-014 — 2026-05-17 — Preserve current code-dev hierarchy; it stays as the canonical code workflow
**Context.** User: "the current code-dev hierarchy works pretty well, we want
something different but I want that we don't lose it."
**Decision.** Code-dev's existing program family and step ordering (new →
study → plan → pr → log → audit → finalize, with the 9-phase pr-review
sub-FSM) is **preserved verbatim** as the canonical *code* workflow under the
new orchestrator. It becomes a first-class workflow definition under
`workspace/workflows/code-dev.{yml,md}` once the workflow schema lands.
**Non-goal.** Refactoring or renaming code-dev programs. Existing call sites,
file conventions, and behaviors stay stable. Migration adds metadata
(synapse contracts, goals) **on top of** existing programs — no breaking
changes to the workflow user already runs.
**Consequences.** Backwards compatibility is a hard constraint on every
Phase 3 PR. Any change to a `code-dev-*` program must preserve its existing
invocation contract; new behavior is opt-in via a flag or surfaces through
the orchestrator layer, never by silently altering the program.

## D-016 — 2026-05-17 — New synapses + new workflows are first-class, runtime-registrable artifacts
**Context.** User: "we can register new tools (synapses) — and new workflows —
combinations of tools — user describes workflow and you infer the tools that
should be used iteratively getting feedback from user."
**Decision.** Both **synapses** (tools/programs) and **workflows** (synapse
sequences) are first-class registrable artifacts:
  - **Synapse registration** — drop a tool entry into `tools/REGISTRY.json`
    OR a program file into `workspace/programs/` OR `workspace/domains/{name}/programs/`.
    Boot picks it up automatically (per D-020 auto-discoverable).
  - **Workflow registration** — a workflow file at
    `workspace/workflows/{name}.{yml,md}` (domain-shared) or
    `workspace/domains/{d}/workflows/{name}.{yml,md}` (domain-bound).
    Each declares: `goal`, `domain`, `synapse-sequence` (DAG), `triggers`,
    `acceptance-criteria`.
  - **Authoring methods (both supported):**
    1. **Direct** — user authors the workflow file by hand.
    2. **Conversational** — user describes the workflow in natural language;
       AXON proposes synapses + DAG iteratively; user confirms each step;
       AXON writes the final file. New entry-point program:
       `workflow-new --from-description "<text>"`.
**Consequences.** Phase 2 spec'd: synapse-contract schema (F-005), workflow
file schema, conversational-author program. Phase 3 implements
`workflow-new` (interactive), `workflow run <name>`, `workflow list`,
`workflow simulate <name>`.

## D-017 — 2026-05-17 — Two workflow execution modes: Fixed and Adaptive (with suggestions in both)
**Context.** User: "after all programs are there I can have a python-code-dev
for instance with specific sequence (sometimes the user can know pretty well
what they want) and also a mode that you don't know exactly and that's the
automatic one … this does not mean that in fixed ones you cannot suggest
things based on what they are doing."
**Decision.** Every workflow has an `execution-mode:` field with two values:
  - **`fixed`** — predeclared synapse sequence; orchestrator follows it
    step by step. Examples: `python-code-dev` (study → lint → test → review →
    commit-msg → audit), `paper-write` (outline → draft → cite → review).
    The user knows the path; AXON walks it. **Suggestions still fire** —
    contextual / sideband (e.g. "you just edited test_X.py — run
    code-dev-suggest-tests?") — but never alter the fixed path silently.
    User can accept a suggestion to deviate; deviation is logged.
  - **`adaptive`** — no predeclared sequence; orchestrator at each step
    observes state + goal, ranks candidate synapses, asks user (per
    inference-mode), fires, re-observes. Used when the user has a goal but
    not a path. Default for free-text task entry.

**Hybrid mode.** A workflow may be fixed for its first N steps then become
adaptive (e.g. fixed `study → plan`, then adaptive PR-cycle that branches
per finding). Each step declares `mode: fixed | adaptive` independently.

**Suggestion contract.** Even in `fixed`-mode workflows, the suggestion
engine (D-010) is always live:
  - **Sideband suggestions** — non-disruptive footer/banner suggestions
    that the user can opt into without leaving the fixed workflow.
  - **Deviation suggestions** — proposed when state diverges from the
    fixed-path precondition (e.g. tests fail before review step).

**Consequences.** Workflow schema has `execution-mode`, `step-mode-per-step`,
`allow-suggestions`, `allow-deviation`. Default for the default code-dev
workflow: `fixed` (preserves D-014 behavior). Default for free-text task entry:
`adaptive`. Phase 3 ships at least one fixed (canonical code-dev) +
one adaptive (free-text task router) + one hybrid as reference workflows.

## D-015 — 2026-05-17 — AXON Synapse is a workflow OS — code is one domain among many
**Context.** User: "in reality this would make us have a piece of software
capable of automating not code, not development, but workflow — code-dev is
an example of code workflow but we want to be able to leverage other stuff —
for science and study as well — that why this vision has to be very precise."
**Decision.** The synapse model and orchestrator are **domain-agnostic**.
Code-dev is one **workflow domain** alongside future domains: `science-dev`
(experiment design, hypothesis, run, analyze, paper), `study-dev` (reading,
notes, synthesis, presentation), `library-dev` (already exists — ingest, shadow,
explain, intersect, report), `writing-dev`, `data-dev`, etc.

**Architectural primitives** (precise to avoid drift):
  - **Workflow** = a named, goal-bearing sequence (DAG) of synapses.
  - **Synapse** = a program or tool that fires to transition state.
  - **Domain** = a family of workflows sharing vocabulary, file conventions,
    and a default workflow set (e.g. `code-dev` domain ships
    `code-dev.{study,plan,pr-cycle,post-impl,audit}` workflows).
  - **Orchestrator** = domain-agnostic loop that observes state, ranks
    synapses, fires, re-observes.
  - **Goal** = an auditable success criterion attached to project / phase /
    workflow / step.
  - **Project** = an instantiated workflow run, with its own state, phases,
    decisions, findings, log, shadow.

**Consequences.**
  1. The synapse contract spec (F-005) must not encode code-specific concepts.
     Generic fields: `precondition`, `inputs`, `outputs`, `post-state`,
     `next-conditional`, `goal-advances`, `cost`, `domain`, `family`, `role`.
  2. Domain modules live under `workspace/domains/{name}/`: workflow files,
     program subset, file-convention spec. Existing `code-dev-*` programs get
     re-homed conceptually into `domain: code-dev` without filename changes.
  3. New domain addition becomes a Phase-4+ capability: drop a domain folder
     in, register its workflows, suggester picks it up automatically (per D-012
     auto-discoverable).
  4. Vocabulary precision is mandatory: "workflow", "synapse", "domain",
     "project", "phase", "goal" each have one fixed meaning. Glossary file
     (`workspace/SYNAPSE-GLOSSARY.md`) authored in Phase 2.

## D-013 — 2026-05-17 — Synapse model = pseudo state machine (FSM)
**Context.** User: "maybe a pseudo state machine in which the next state (or
tool) is inferred by axon."
**Decision.** Formalize the synapse model as a **pseudo-FSM**:
  - **States** = workspace state vectors (W:/L: keys, file existence,
    project phase, active goal).
  - **Synapses** = transitions (programs / tools that fire to change state).
  - **Transition predicates** = `precondition` (gate on entry) +
    `post-state` (assertion on exit) + `next-conditional` (suggestion edges).
  - **Non-deterministic.** Multiple synapses may match a given state — the
    ranker picks top-k by goal-fit / confidence / cost.
  - **Pseudo, not strict.** Synapses may fail mid-fire (FAIL block); the
    orchestrator handles that as a state observation, not a contract violation.
**Consequences.** The synapse contract spec (F-005) gains FSM semantics:
post-state predicates must be **observable** (not abstract intent). The
orchestrator becomes a state-tracking loop. Phase 2 designs the state vector
schema explicitly (which W:/L: keys participate, file-existence predicates,
phase-meta predicates).

## D-011 — 2026-05-17 — Shadowing is mandatory and orchestrator-enforced
**Context.** User: "DONT FORGET to enforce shadowing operation and so on."
`code-dev-knowledge-shadow` + `code-dev-shadow` exist today. Use is discretionary.
**Decision.** Shadowing — the capture of "what files this PR touched + what
findings reference them" — is **mandatory** for every PR that modifies source
files. Enforcement points:
  - `code-dev pr` finalize step → ASSERT `phases/{n}/shadow/{pr}.md` exists or
    create it from git diff + finding references.
  - `code-dev audit` → ASSERT every PR has a shadow file; FAIL audit if missing.
  - Synapse-suggest → after `code-dev pr` completes, the top suggestion is
    `code-dev shadow` (until shadow exists).
**Consequences.** Phase 2 spec'd a `_meta.md` field `requires-shadow: true|false`
(default true). Phase 3 PRs that touch source without producing a shadow file
get blocked at the audit gate. Existing PRs without shadows get retroactively
shadowed during the migration PR.
