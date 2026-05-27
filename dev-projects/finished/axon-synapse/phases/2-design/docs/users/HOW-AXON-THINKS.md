---
explains:      AXON-GLOSSARY v2, the synapse model for outsiders
audience:      tier-C (external users)
last-checked:  2026-05-17
version:       1
---

# How AXON thinks

> A 10-minute read. After this you'll understand the synapse model,
> the orchestrator loop, and why AXON sometimes asks questions vs
> just doing the thing.

## One sentence

AXON is an **operating system for goal-directed work**: every program is a
node in a graph, every node declares what should follow it under what
conditions, and a goal-aware loop walks the graph asking you (or deciding
itself) which path to take.

## Borrowed from neuroscience

AXON's vocabulary is biological — because the architecture mirrors
distributed cognition. Once you see the mapping, the rest follows.

| Biology | AXON | What it is |
|---------|------|------------|
| **Neuron** | a program or tool | the firing unit |
| **Dendrite** | precondition / inputs | what the neuron reads |
| **Synapse** | weighted edge between neurons | conditional next-step suggestion |
| **Axon** | the orchestrator | carries the signal forward |

> Confusing terminology note: the user-facing umbrella term "synapse"
> often informally refers to the firing unit itself. Inside AXON's
> specs and schemas, a *synapse* is strictly the connection. The
> connection is what carries the *weight* and the *condition* —
> the actual smart part.

## Why this is different from a task runner

Make, Airflow, n8n, Zapier — all describe **directed graphs of tasks
with dependencies**. They run linearly or in parallel. They don't:

- Know your **goal**, only your tasks.
- **Ask you** when uncertain.
- Surface **alternatives** mid-execution.
- Adapt to **observed state** (only declared state).
- Track **audit trails** that match your goal language.

AXON does. It looks like a task runner from the outside (workflow files
with steps), but the steps are **suggestions**, not commands — the
orchestrator picks (or asks you to pick) which to follow based on what
just happened.

## The loop, in plain English

Imagine you're a research assistant who has just been told "find me 5
papers on CO2 storage and summarise common themes."

A task runner gives you a checklist:
```
1. search for papers
2. download
3. read
4. summarize
```

You follow it linearly. If step 2 fails (network error), the runner halts.
If you discover step 3 is harder than expected, you have no way to ask
for guidance. If your goal changes mid-stream ("actually I need 10
papers"), you start over.

AXON's loop is different. At each step:

1. **Observe.** What's the current state? What files exist? What did
   the last neuron produce? What's the user's goal?
2. **Rank candidates.** From the synapses of the last-fired neuron
   (plus all registered neurons in the relevant domain), rank what
   should fire next.
3. **Decide.** If confident: fire. If not: ask you to choose. If less
   confident: silently surface candidates in the footer.
4. **Fire.** Run the chosen neuron.
5. **Observe again.** Did it succeed? What's the new state? Did the
   goal's acceptance predicate become true?
6. **Loop or exit.**

For our research example:
- After `library-dev ingest`, the orchestrator sees: 5 files indexed,
  shadows written, no explanations yet. It suggests `library-dev explain
  --all` because that's declared in the `ingest` neuron's synapses.
- After `explain`, it sees: 5 explanations exist. Suggests `library-dev
  intersect` — but ALSO offers, as sideband, `library-dev search` in case
  you noticed gaps and want more papers.
- After `intersect`, it suggests `library-dev report` to write the summary,
  and `library-dev cite` to produce the bibliography.

If you mid-stream realise "I actually need 10 papers" — you say so —
AXON re-classifies, suggests `library-dev search` for the missing 5,
and the workflow forks. The goal stays current; the path adapts.

## When does AXON ask vs just do?

A single setting controls this: `L:inference-mode` (0 to 10).

| Setting | Behaviour |
|---------|-----------|
| 0–1 (ask-always) | AXON asks you before every fire, even high-confidence |
| 2–4 (cautious) | Asks if confidence < 0.8 |
| 5 (balanced, default) | Asks if < 0.7; surface-only if 0.7–0.85; fires if ≥ 0.85 |
| 6–7 (assertive) | Fires if ≥ 0.6; surface-only otherwise |
| 8–10 (autonomous) | Fires top-1 always; surfaces nothing |

Change with `kv-store set L:inference-mode 7`.

## Why goals are mandatory

Every fire is gated by a goal's acceptance predicate. If you have no
goal set, the orchestrator either:
1. Infers one from your first command + asks you to confirm, OR
2. Refuses to dispatch (in strict mode) until you state one.

This is intentional. The most common failure of generic AI assistants
is **goal drift** — they help with a request, then several turns later
are doing something orthogonal. AXON's goal ledger prevents this. Every
program fire logs which goal it advances; `goal audit` traces it.

## Fixed vs Adaptive workflows

**Fixed workflow:** you know the path. You authored (or accepted) a
sequence of neurons in a YAML file. AXON walks it, with sideband
suggestions live (you can opt into a deviation but never silently).
Best for: established processes — code reviews, paper writing,
build-test-deploy chains.

**Adaptive workflow:** you have a goal but not a path. The orchestrator
picks each step based on state + history + signal ranking. Best for:
exploratory work, novel problems, free-text task entry.

**Hybrid:** mix per step. Some steps Fixed (always run audit at end),
others Adaptive (figure out triage when tests fail).

**Exploratory:** no goal predicate. Used for discovery. Novelty-weighted.

**Scheduled:** cron-triggered. Wraps a Fixed workflow with state-preconditions.

## What you actually control

| Control | What it does |
|---------|--------------|
| Goal | "What is done?" — the loop exit predicate |
| Inference-mode | "How autonomous?" — ask vs fire threshold |
| Workflow file | "What path?" — declared step sequence |
| Synapse contracts | "What can follow what?" — graph topology |
| Domain manifest | "Which conventions?" — file layout + verbs |
| Suggestion budget | "How much footer noise?" — rate limits |
| Dev-mode | "Can it write kernel files?" — safety gate |
| Shadow enforcement | "Must every PR have a paper trail?" — audit gate |

## What you don't control (kernel invariants)

- AXON never runs builds or tests autonomously. Always human-only.
- AXON never silent-hangs. Zero-candidate triggers a QUERY.
- AXON never writes `axon/` without dev-mode flip.
- AXON never deviates a Fixed path without explicit user accept.

These are kernel-level rules. Workflows can't override them.

## The promise

You get: a goal-aware, audit-trail-keeping, suggestion-driven environment
that adapts when state demands and respects your authored process when
you have one.

The cost: AXON's vocabulary (neuron / synapse / axon / domain / phase /
workflow / goal / predicate). About 30 minutes of reading to internalize.

## Next steps

- `QUICKSTART.md` — boot AXON and run a workflow in 5 minutes.
- `CHOOSING-A-DOMAIN.md` — pick the right domain for your work.
- `AUTHORING-A-WORKFLOW.md` — describe your own process.
