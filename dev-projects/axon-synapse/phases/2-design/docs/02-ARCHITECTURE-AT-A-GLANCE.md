---
explains:      synapse-contract v1.1, workflow-file v1.1, orchestrator-composition v1.1, domain-manifest v1.1, dag-spec v1.1
audience:      tier-A
last-checked:  2026-05-17
version:       1
---

# Architecture at a glance

## Layer cake

```
┌────────────────────────────────────────────────────────────────┐
│  USER LAYER                                                    │
│  (you, or another AI agent)                                    │
│                                                                │
│   free-text input          │  explicit command                 │
│         ↓                  │        ↓                          │
└────────────────────────────┼───────────────────────────────────┘
                             │
┌────────────────────────────┼───────────────────────────────────┐
│  AXON LAYER (orchestrator) │                                   │
│                            │                                   │
│   mode-detect    →   synapse-suggest   →   decide()            │
│   (intent class)     (ranker combiner)     (fire/ask/surface)  │
│                                                                │
└────────────────────────────┬───────────────────────────────────┘
                             │
┌────────────────────────────┼───────────────────────────────────┐
│  WORKFLOW LAYER            │                                   │
│                            │                                   │
│   workflow file (yml) — declared DAG of neurons + synapses     │
│   execution-mode: fixed | adaptive | hybrid | exploratory      │
│                  | scheduled                                   │
│   default-goal + acceptance-criterion + triggers               │
│                                                                │
└────────────────────────────┬───────────────────────────────────┘
                             │
┌────────────────────────────┼───────────────────────────────────┐
│  DOMAIN LAYER              │                                   │
│                            │                                   │
│   workspace/domains/{name}/manifest.md                         │
│   ├── workflows/                                               │
│   ├── programs/ (or refs into workspace/programs/)             │
│   ├── source-artifact-glob:  patterns                          │
│   └── verb-map: canonical → domain-specific                    │
│                                                                │
│   Today: code-dev, library-dev. Future: study-dev, science-dev │
└────────────────────────────┬───────────────────────────────────┘
                             │
┌────────────────────────────┼───────────────────────────────────┐
│  NEURON LAYER              │                                   │
│                            │                                   │
│   programs (workspace/programs/*.md)                           │
│   tools    (tools/REGISTRY.json + tools/*.py)                  │
│                                                                │
│   Each carries:                                                │
│     precondition  inputs  outputs  post-state  synapses        │
│     cost  blast-radius  reversibility  status  modes           │
│                                                                │
└────────────────────────────┬───────────────────────────────────┘
                             │
┌────────────────────────────┼───────────────────────────────────┐
│  KERNEL LAYER (AXON OS)    │                                   │
│                            │                                   │
│   axon/KERNEL-SLIM.md       — rules + ops                      │
│   axon/core/LANG.md         — symbolic language                │
│   axon/core/TRANSLATE.md    — output rules                     │
│   axon/OUTPUT-LAYER.md      — footer + suggestions block       │
│                                                                │
│   Identity gate · Cognition gate · Write gate · Drift gate     │
│   · Context-pressure gate · Confidence gate · Inference gate   │
└────────────────────────────┬───────────────────────────────────┘
                             │
┌────────────────────────────┼───────────────────────────────────┐
│  PERSISTENCE LAYER         │                                   │
│                            │                                   │
│   W: session-only          L: longterm (persisted)             │
│   E: episodic (append)     local/  machine-specific            │
│                                                                │
│   axon.git  (kernel)       my-axon.git  (user data + projects) │
└────────────────────────────────────────────────────────────────┘
```

## Three core flows

### Flow A — User says "I want a python workflow"

```
USER:  "I want a python workflow that lints, tests, reviews,
        and writes commit msg"
   ↓
mode-detect classifies intent → BUILD mode (workflow author)
   ↓
EXEC(workflow-new --from-description "<text>")
   ↓
dialog: phase A (name/domain/mode) → B (goal) → C (synapse picks)
       → D (triggers/suggestion-controls) → E (validate/save)
   ↓
At each candidate ask: synapse-suggest provides top-3
       (cold-start uses frequency prior for first 3 picks)
   ↓
output: workspace/domains/code-dev/workflows/python-code-dev.yml
   ↓
suggestion in footer: "workflow run python-code-dev" or
                       "workflow simulate python-code-dev"
```

### Flow B — User runs an existing workflow

```
USER:  "workflow run code-dev.canonical"
   ↓
load workflow file → set W:active-workflow
   ↓
orchestrator loop:
  for each step in workflow.synapses:
    if step.mode == fixed:
      candidate = step.name
    else:                              # adaptive
      candidates = synapse-suggest(state, goal, history)
      candidate  = decide(top, inference-mode)
    fire(candidate)
    if step.on-complete.if predicates match:
      jump per declared branch
    sideband: surface top-1 sideband suggestion in footer
    if state diverges from next-step.precondition:
      surface deviation suggestion
   ↓
when default-goal.acceptance-criterion evaluates true:
  EMIT axon.workflow.goal-met
  exit
```

### Flow C — Free-text task, no workflow

```
USER:  "audit the current axon-synapse project"
   ↓
mode-detect → low confidence on any specific mode (audit could
              be code-dev or meta)
   ↓
goal-infer: propose "Run a full project audit, report findings"
            QUERY user → confirm
   ↓
STORE(W:current-goal, ...)
   ↓
orchestrator enters Adaptive mode (no workflow active)
   ↓
loop:
  synapse-suggest top-3 against state + goal
  decide → ask (inference-mode 5 default)
  QUERY user with top-3
  fire chosen
  observe result; re-rank
   ↓
goal.acceptance-criterion → "audit.open-findings recorded" → met
   ↓
suggestion in footer: "code-dev safety-audit" (Phase-3+ canonical)
```

## Persistence: what lives where

```
axon.git (this repo, public-shareable)
  axon/                    kernel
  workspace/               workspace config
    programs/              all neurons (programs)
    tools/REGISTRY.json    all neurons (tools)
    domains/{name}/        domain manifests + workflows (post-PR-108)
    workflows/             cross-domain workflows
    preferences/           tunable knobs (smart-dispatch.md etc.)
    SYNAPSE-GLOSSARY.md    glossary (post-PR-101)
    SYNAPSE-CONTRACT.md    contract schema (post-PR-104)
    WORKFLOW-FILE.md       workflow schema (post-PR-105)
    DOMAIN-MANIFEST.md     domain spec (post-PR-106)
    DAG-SPEC.md            DAG schema (post-PR-110)

my-axon.git (private, your data)
  dev-projects/{slug}/     code-dev projects (incl. axon-synapse itself)
    _meta.md _goal.md _decisions.md _demands.md _flaws.md masterplan.md
    04-log.md  05-branches.md  DAG.{json,md}
    phases/{n}/
      _meta.md (with goal:)  _files _dont-do _decisions _deviations
      01-study  02-plan  02-prs  03-prs/  reviews/  shadow/
      findings/  helpers/  specs/  docs/  test-fixtures/
      DAG.{json,md}
  libraries/{name}/        library-dev projects
  memory/                  state persistence
  chats/  plans/  log/
```

## What happens on boot

```
1.  Read axon/startup.md → identify harness
2.  TOOL(boot) → returns paths, dev-mode, output-mode, tool registry,
                 inference-mode, cron jobs, queue, working-memory
3.  G-10: validate workspace paths
4.  my-axon detection → load MYAXON.md → STORE W:myaxon-*
5.  G-11: harness detection → load workspace/harness/{name}.md
6.  Resume? if W:active-phase != done: offer continue/restart/skip
7.  Workspace backup auto-push (if enabled)
8.  EXEC(menu) — render OS state dashboard
```

## What happens on every response

```
1.  prompt-log records the user input
2.  Active-program-interrupt-gate fires if W:active-phase active
    (workflow-aware behavior per D-034: continue / deviate / pause / abort)
3.  Output is computed
4.  Coherence guardian scans for persona-bleed / cognition-frame drift
5.  Response gate fires (R7, R_COHERENCE, R_REASONING_TRACE)
6.  Turn-log records summary
7.  igap records any inference gaps
8.  Output rendered with optional suggestions footer (Phase-3+)
9.  Drift state updated for next turn
```

## Why this architecture survives the "synapse OS" demand

| Demand | Architectural answer |
|--------|----------------------|
| D-2 auto-DAG on plan | PR-113 hook in `code-dev plan` finalize |
| D-3 auto-mutation | `dag` tool mutators call sync on every operation |
| D-4 DAG central nested | 5 levels per `dag-spec-v1.1`; sync-checker |
| D-6 synapse contract | inferred + declared override per `neuron-contract v1.1` |
| D-7 adaptive orchestrator | composition over existing tools per `orchestrator-composition v1.1` |
| D-8 workflow generator | `workflow-new --from-description` per `conversational-author v1.1` |
| D-9 pre-built workflows | 5 reference workflows ship in PR-118 |
| D-10 goals per step | hierarchical per `goal-schema v1.1` |
| D-13 after-action suggest | `synapses:` block + footer surface |
| D-15 most detailed | 17 findings + 24 flaws + 30 demands tracked |
| D-23 shadow enforced | 5 gates per `shadow-enforcement v1.1` |
| D-26 workflow OS | domain manifest + 5 closed-list axes |
| D-27 register neurons | `register-tool` + auto-reload |
| D-28 conversational author | `workflow-new --from-description` |
| D-29 fixed/adaptive | execution-mode in workflow file |
| D-30 suggest in fixed | sideband + deviation per `orchestrator-composition v1.1` |
