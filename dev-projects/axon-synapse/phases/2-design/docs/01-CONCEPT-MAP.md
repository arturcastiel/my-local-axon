---
explains:      AXON-GLOSSARY v2, synapse-contract / neuron-contract v1.1
audience:      tier-A
last-checked:  2026-05-17
version:       1
---

# Concept Map — neuron / synapse / axon

## The biology, mapped

```
        DENDRITES (inputs)              SYNAPSES (weighted edges)
        ────────────                    ─────────────────────────
              │                                     │
              ↓                                     ↓
           ┌──────┐         signal             ┌──────┐
           │NEURON│ ─────────axon─────────────►│NEURON│
           └──────┘                            └──────┘
              │                                     │
              ↓                                     ↓
           outputs                              outputs
```

| Biology | AXON | Role |
|---------|------|------|
| **Neuron** | program (`workspace/programs/*.md`) OR tool (`tools/REGISTRY.json`) | the firing unit |
| **Dendrite** | precondition / inputs (`# inputs:`) | what neuron receives |
| **Synapse** | declared edge with weight (`synapses:` block; was `next-conditional`) | weighted connection between neurons |
| **Axon** | the orchestrator loop (project's namesake) | carries the signal forward |
| **State** | W: / L: / E: keys + files + events | what neurons read and observe |
| **Goal** | acceptance predicate per level | what the cell-cluster is trying to do |

## The hierarchy

```
                  ┌──────────────────────────────┐
                  │           AXON                │  ← the orchestrator
                  │  (observes state, ranks       │     (this project's
                  │   neurons, fires, re-ranks)   │      namesake)
                  └──────────┬───────────────────┘
                             │
       ┌─────────────────────┼─────────────────────┐
       │                     │                     │
   ┌───▼────┐           ┌────▼───┐           ┌─────▼───┐
   │WORKFLOW│           │WORKFLOW│           │WORKFLOW │
   │ (DAG of│           │        │           │         │
   │neurons)│           │        │           │         │
   └───┬────┘           └────────┘           └─────────┘
       │
       │  synapses (weighted edges)
       │
   ┌───┴────────────────────────────┐
   │                                │
┌──▼───┐   synapse(condition,    ┌──▼───┐
│NEURON│ ─────────weight)───────►│NEURON│
└──┬───┘                          └──┬───┘
   │                                 │
   │                                 │
   │     synapse(cond, w)            │
   │ ─────────────────────────►   ...│
   │                                 │
   │  multiple outgoing synapses     │
   │  per neuron — the ranker picks  │
   │                                 │
```

## Domains, projects, phases

```
DOMAIN  ←   manifest declares verb-map + workflows + file-conventions

  workflows[]
  programs[] (neurons specific to this domain)
  default-goal templates

      │
      ↓
PROJECT  ←   instantiated workflow run (a container)

  _meta.md  _goal.md  _decisions.md  _flaws.md  _demands.md  04-log.md
  phases/

      │
      ↓
PHASE  ←   sub-stage with its own goal

  _meta.md (goal:)
  01-study.md  02-plan.md  02-prs.md
  03-prs/   reviews/   shadow/   findings/   specs/
  DAG.json + DAG.md  (per dag-spec v1.1)

      │
      ↓
PR / step  ←   single neuron fire (or sub-DAG)

  PR-NNN.md  (carries: goal · blast-radius · reversibility · rollback)
  shadow/PR-NNN.findings.md
```

## The orchestrator loop (one cycle)

```
   ┌───────────────────────────────────────────────────────────┐
   │  (1) observe                                              │
   │      snapshot STATE = {W:, L:, files, events, goal, hist} │
   └─────────────────────┬─────────────────────────────────────┘
                         ↓
   ┌───────────────────────────────────────────────────────────┐
   │  (2) rank candidates                                      │
   │      combiner over signals:                               │
   │        intent · dispatch · usage · pattern · drift ·      │
   │        context · synapses · goal-fit · shadow-obligation  │
   │      tie-break ladder if scores within ±0.05              │
   │      cold-start: frequency-prior bootstrap (first 20)     │
   │      zero-candidate: TF-IDF registry fallback             │
   └─────────────────────┬─────────────────────────────────────┘
                         ↓
   ┌───────────────────────────────────────────────────────────┐
   │  (3) decide                                               │
   │      based on confidence × L:inference-mode (0..10):      │
   │        fire | ask | surface-only                          │
   └─────────────────────┬─────────────────────────────────────┘
                         ↓
   ┌───────────────────────────────────────────────────────────┐
   │  (4) fire                                                 │
   │      ASSERT precondition  → exec → ASSERT post-state      │
   │      EMIT axon.neuron.fired                               │
   └─────────────────────┬─────────────────────────────────────┘
                         ↓
   ┌───────────────────────────────────────────────────────────┐
   │  (5) observe-result + record                              │
   │      update STATE, usage, drift, recent-fires             │
   └─────────────────────┬─────────────────────────────────────┘
                         ↓
   ┌───────────────────────────────────────────────────────────┐
   │  (6) goal.met?  →  exit                                   │
   │      else: loop                                           │
   └───────────────────────────────────────────────────────────┘
```

Mode variants:

- **Fixed workflow:** step 2 replaced by `take next from declared synapses`.
- **Adaptive workflow:** full loop as drawn.
- **Hybrid:** per-step which mode applies.
- **Exploratory:** no goal predicate; novelty-weighted candidate selection.
- **Scheduled:** cron triggers entry; step 1 checks state-precondition.

## The five DAG levels

```
┌─────────────────────────────────────────────────────────────┐
│  PROJECT DAG   <project>/DAG.{json,md}                      │
│  = phase graph (1-study → 2-design → 3-impl → 4-validate)   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  PHASE DAG   phases/{n}/DAG.{json,md}               │    │
│  │  = sub-step graph within a phase                    │    │
│  │                                                     │    │
│  │  ┌─────────────────────────────────────────────┐    │    │
│  │  │  PLAN DAG   03-prs/DAG.{json,md}            │    │    │
│  │  │  = PR graph within a phase's plan           │    │    │
│  │  │                                             │    │    │
│  │  │  ┌─────────────────────────────────────┐    │    │    │
│  │  │  │  PR DAG (optional)                  │    │    │    │
│  │  │  │  = sub-task graph within one PR     │    │    │    │
│  │  │  └─────────────────────────────────────┘    │    │    │
│  │  └─────────────────────────────────────────────┘    │    │
│  │                                                     │    │
│  │  STUDY DAG  phases/1-study/DAG.{json,md}            │    │
│  │  = research-question → track → finding graph       │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

`dag-sync` validates nested consistency: child-DAG nodes ↔ parent-DAG edges.

## The closed lists you should memorize

| Axis | Values |
|------|--------|
| Execution mode | `fixed` · `adaptive` · `hybrid` · `exploratory` · `scheduled` |
| Role | `mutator` · `reader` · `gate` · `renderer` · `router` · `composer` · `seed` |
| Layer | `kernel` · `system` · `meta` · `shared` · `domain` |
| Status | `ACTIVE` · `OPTIONAL` · `STUB` · `ALIAS` · `DEPRECATED` · `ARCHIVED` |
| Goal status | `open` · `in-progress` · `designed` · `met` · `met-with-open-children` · `deferred` · `parent-rejected` |
| Reversibility | `one-way` · `reversible` · `partial` |
| Suggestion kind | `predetermined` · `ephemeral` · `sideband` · `deviation` |

If a value isn't in the closed list, it's wrong (or needs a glossary v3
bump with an ADR).
