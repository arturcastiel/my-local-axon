# Goal Schema (v1) + Predicate Language (v1)

> glossary: SYNAPSE-GLOSSARY v1
> resolves: F-017, D-007, D-010, D-024, OQ-07
> serves: D-10 (goals per step), D-24 (auditable demands)

## Purpose

Define the canonical goal record + the predicate language used for
`measurement` and `acceptance-criterion`. Authoritative for all goal
declarations across the project.

## Goal record (YAML)

```yaml
goal:
  id:                 goal-<YYYY-MM-DD>-<N>       # unique, append-only
  level:              project | phase | workflow | step | pr | finding | demand
  domain:             code-dev | library-dev | meta | ...
  statement:          "<one-sentence plain-English statement>"
  rationale:          "<why this goal — user need or system invariant>"

  measurement:
    - "<predicate>"
    - "<predicate>"

  acceptance-criterion: "<predicate>"             # boolean: true → MET
  rejection-criterion:  "<predicate>"             # boolean: true → FAILED

  parent-goal:        goal-2026-05-17-1            # optional
  child-goals:        []                          # populated as children added

  source:             user | workflow-default | inferred-confirmed | inherited
  inference-log:                                  # only when source ≠ user
    - { ts: <iso>, action: "<what AXON proposed>", confirmed-by: user | null }

  status:             open | in-progress | designed | met | deferred
  status-history:
    - { ts: <iso>, from: <state>, to: <state>, reason: "<text>" }

  workflow:           "<workflow-name if applicable>"   # optional
  tags:               []
```

## Where goal records live (hierarchy resolution per OQ-07)

| Level | Location |
|-------|----------|
| **project** | `<project>/_goal.md` — front-matter YAML block + free-form body |
| **phase** | `<project>/phases/{n}/_meta.md` — `goal:` block |
| **workflow** | `<workflow-file>.yml` — `default-goal:` block |
| **step (synapse)** | synapse contract `goal-advances:` field |
| **pr** | `<project>/phases/{n}/03-prs/PR-NNN.md` — `goal:` front-matter |
| **finding** | `F-NNN-*.md` — "Implication" block (semi-structured) |
| **demand** | `<project>/_demands.md` — row with `goal + measurement + audit-criterion` |

Children inherit `measurement` and `acceptance-criterion` from parent as
**context**; they may refine but cannot contradict.

## Workflow-bound vs user-stated (per D-007)

### Workflow-bound

Goal is pre-declared on the workflow file (`default-goal:`). When the
workflow runs, the orchestrator instantiates a goal record with `source:
workflow-default`. No user prompt needed; the goal is enforced.

### User-stated

For ad-hoc / open-ended work, the goal is provided by the user. Path:

1. User types a goal explicitly (`goal set "<statement>"`).
2. OR AXON infers from first command: e.g. user types "study the auth code"
   → AXON proposes goal `"Study the auth module's structure and
   dependencies."` → confirms via QUERY → records with `source:
   inferred-confirmed`.

A session **without** a goal is a violation per D-007. The orchestrator
blocks dispatch when `W:current-goal == ∅` and inference-mode ≥ 3
(asks user); for inference-mode ≤ 2, blocks until user explicitly sets one.

## Predicate language (v1)

A small expression language for `measurement`, `acceptance-criterion`,
`rejection-criterion`, synapse `precondition` / `post-state`, workflow
`triggers.when` and `on-complete.if`.

### Grammar (informal)

```
expr      := or_expr
or_expr   := and_expr ('OR' and_expr)*
and_expr  := not_expr ('AND' not_expr)*
not_expr  := 'NOT' not_expr | atom
atom      := call | comparison | literal | '(' expr ')'

call      := IDENT '(' (arg (',' arg)*)? ')'
              # built-in functions — see § Functions

comparison := value (CMPOP value)?
              # CMPOP ∈ {==, !=, <, <=, >, >=}

value     := literal | ref | call
ref       := 'W.' IDENT | 'L.' IDENT | 'state.' DOTTED |
              'project.' DOTTED | 'phase.' DOTTED |
              'workflow.' DOTTED | 'pr.' DOTTED
literal   := STRING | INT | FLOAT | 'true' | 'false' | 'null'

STRING    := '"' .* '"' | "'" .* "'"
IDENT     := [a-zA-Z_][a-zA-Z0-9_-]*
DOTTED    := IDENT ('.' IDENT)*
```

Template interpolation: predicates may use `{W.key}` / `{L.key}` /
`{phase.field}` inside string literals to substitute current values.
E.g. `file.exists('phases/{phase.name}/01-study.md')`.

### Built-in functions

#### File / dir
- `file.exists(path)` → bool
- `dir.exists(path)` → bool
- `file.readable(path)` / `file.writable(path)` → bool
- `file.size(path)` → int (bytes)
- `file.mtime(path)` → int (epoch seconds)
- `file.contains(path, "substring")` → bool

#### Counts / queries
- `count(glob)` → int (e.g. `count('phases/1-study/findings/F-*.md') >= 10`)
- `glob_first(glob)` → string path (or null)
- `glob_all(glob)` → list[path]

#### State refs (implicit calls)
- `W.<key>` → value of `W:<key>` (null if absent)
- `L.<key>` → value of `L:<key>` (null if absent)
- `state.<dotted>` → arbitrary state lookup
- `project.<field>` → project `_meta.md` field
- `phase.<field>` → active phase `_meta.md` field
- `workflow.<field>` → active workflow file field
- `pr.<field>` → active PR file field

#### Shadow / DAG
- `shadow.contains(file)` → bool — shadow file exists + hash matches
- `shadow.coverage(phase)` → int (percent 0–100)
- `dag.consistent(level)` → bool — DAG.json ↔ DAG.md sync OK

#### Test / audit
- `tests.pass()` → bool — last `run-tests` invocation succeeded
- `tests.fail()` → bool — last `run-tests` failed
- `audit.open-findings` → int (last `code-dev safety-audit` result)
- `audit.critical-issues` → int

#### Pattern / string
- `<value> matches "<regex>"` → bool
- `<value>.contains("substring")` → bool

#### Domain-specific (extensible per domain manifest)
- code-dev: `pr.shadow-coverage`, `pr.has(spec | log | review)`
- library-dev: `library.shadow %`, `library.explain %`

Predicates are evaluated by the `predicate` tool (Phase 3 deliverable:
`tools/predicate.py`) against a STATE snapshot taken at evaluation time.

### Examples

Project goal acceptance:
```
"file.exists('05-audit.md') AND audit.open-findings == 0 AND shadow.coverage(project) == 100"
```

Phase 1 acceptance:
```
"file.exists('phases/1-study/synthesis-draft.md') AND count('phases/1-study/findings/F-*.md') >= 10"
```

Synapse `code-dev-study` post-state:
```
"file.exists('phases/{phase.name}/01-study.md') AND state.satisfaction.user >= 7 AND state.satisfaction.axon >= 7"
```

Workflow trigger:
```
"user said 'python workflow' AND project._meta.codebase contains *.py"
```

## Status lifecycle

```
open  →  in-progress  →  designed  →  met
                                  ↘
                                    deferred
```

Transition rules:
- `open → in-progress` — any synapse fires that references this goal.
- `in-progress → designed` — `acceptance-criterion` parseable + all
  measurement predicates well-formed (validation).
- `designed → met` — `acceptance-criterion` evaluates true against STATE.
- any → `deferred` — explicit user / system note; carries forward.

Transitions logged in `status-history` automatically.

## Goal-aware ranker contribution

The orchestrator's suggester (per F-014) uses goals as a ranker signal:

```
score(synapse, state, goal) =
    α · similarity(synapse.purpose, goal.statement)
  + β · count(predicate_in_post-state(synapse) implied by acceptance-criterion(goal))
  + γ · 1[synapse advances unmet measurement predicate]
  + δ · 1/cost.tokens-estimate
  - ε · cost.side-effect-risk
```

Coefficients in `L:ranker-weights` (Phase 3 default: balanced).

## Audit (per D-024)

The `goal audit` tool (Phase 3 deliverable) iterates all goal records and
reports:

- Goals with empty `measurement` or `acceptance-criterion`.
- Goals with `status: met` but `acceptance-criterion` evaluates false.
- Goals with no `status-history` entries (stale).
- Demand-row goals matching the `_demands.md` audit-criterion check
  (mandatory per D-024).

## Tooling (Phase 3 deliverables)

- `goal` program — set / get / confirm / list / met / audit subcommands.
- `predicate` tool — parse, validate, evaluate.
- `goal-infer` tool — infer goal from first command + recent state.

## Version + change rule

**Version: v1 (2026-05-17).** Predicate language v1.
Schema and predicate language evolve in lock-step.
