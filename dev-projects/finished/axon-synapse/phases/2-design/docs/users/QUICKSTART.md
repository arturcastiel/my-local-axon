---
explains:      AXON onboarding (post-Phase-3 user experience)
audience:      tier-C (external users)
last-checked:  2026-05-17
version:       1
---

# AXON Quickstart — 5 minutes to your first workflow

> AXON is an operating system for structured knowledge work. It helps
> you (or an AI agent collaborating with you) walk repeatable processes
> while keeping audit trails, goals, and suggestions live throughout.

## What you'll be able to do in 5 minutes

- Boot AXON.
- See your goal, your active project, and what to do next.
- Run an existing workflow OR describe a new one in plain English.

## Prerequisites

- Python 3.11+ on the path.
- An AXON checkout (`git clone <axon-repo>`).
- An LLM harness that can read files + run shell commands. (Claude Code,
  GitHub Copilot, or any agent runtime — see `docs/agents/HOST-HARNESS.md`.)

## Step 1 — Boot

```
cd <axon-repo>
# Tell your agent: "Read startup.md and boot AXON."
```

Your agent reads `startup.md`, internalises the kernel, calls
`python3 axon.py boot`, loads your user-data folder, and renders the menu.

You should see something like:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  AXON  ·  <your-name>  ·  <today>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Health   ●●●●○  85/100
  Inference  5/10 — balanced
  Tools     69 active  ·  output: PYTHON_FAST
  Memory    0 working keys · L: stored on demand
  Project   — none loaded
  Backup    ✓ configured

  MODES
     [1] CHAT      ask questions, explore
     [2] BUILD     write a workflow or program
     [3] RUN       launch a workflow
     [4] MEMORY    browse what AXON knows
     [5] SYSTEM    settings, health, cron
     [6] PLAN      break down a goal
     [7] PROGRAMS  search / inspect / simulate
```

## Step 2 — Pick a path

### Path A — Run an existing workflow

```
workflow list
```

You'll see the workflows installed:

```
code-dev.canonical          fixed     code-dev      study → plan → pr → audit
python-code-dev             fixed     code-dev      lint + test + review + commit-msg
library-dev.canonical       fixed     library-dev   ingest PDFs → explain → report
adaptive-free-text          adaptive  any           AXON picks each step
```

Pick one:

```
workflow run code-dev.canonical
```

AXON sets your goal automatically (from the workflow's `default-goal`),
opens the first synapse, and walks the chain. At each step it shows what
it's about to do; you confirm OR redirect.

### Path B — Describe a new workflow

```
workflow new --from-description "I want to read 5 PDFs, find common themes, and write a literature-review summary"
```

AXON proposes:

```
Domain:    library-dev
Mode:      fixed
Goal:      Convert PDFs into an annotated, theme-mapped, reviewable summary
Step 1:    library-dev new <name>       OK?
Step 2:    library-dev ingest             OK?
Step 3:    library-dev explain --all      OK?
Step 4:    library-dev intersect          OK?
Step 5:    library-dev report             OK?
Save to workspace/domains/library-dev/workflows/lit-review.yml?
```

Confirm → workflow file written → run it any time.

### Path C — Just describe a task

```
> audit our team's CI failure rate over the past month
```

No specific mode. AXON enters **Adaptive** mode:

1. Asks you to confirm the inferred goal.
2. Ranks candidate neurons (programs / tools).
3. Asks you (or fires autonomously if `inference-mode ≥ 8`) the top
   candidate.
4. Observes the result, re-ranks, continues.
5. Exits when your goal's acceptance predicate evaluates true.

## Step 3 — Watch the suggestions

The footer below every response surfaces what AXON thinks you might do next:

```
─────
suggestions
  ▶ code-dev-suggest-tests   reason: post-implementation chain   conf: 0.84
    code-dev-self-review     reason: usage history               conf: 0.71
─────
```

Top-1 is what AXON would fire if running autonomously. Type the name to
accept, or type `dismiss` to deweight it.

## Step 4 — Set your goal manually (any time)

```
goal set "Ship feature X by Friday with 90 % test coverage"
```

The goal is now active. Every dispatch checks against the acceptance
predicate. `goal met` evaluates the predicate; `goal audit` traverses
all project/phase/PR goals to report status.

## Step 5 — Inspect what AXON knows

```
status              full project state
find-program <text> search neurons by capability
explain <neuron>    plain-English walkthrough
simulate <neuron>   dry-run without side effects
help <neuron>       usage + inputs + outputs + next
```

## Common patterns

| Need | Command |
|------|---------|
| Switch active project | `code-dev load <slug>` |
| Continue interrupted work | `resume` |
| See workflow progress | `workflow status` |
| Pause workflow | `workflow pause` |
| Abort workflow | `workflow abort` |
| Check goal alignment | `goal met` |
| Audit project | `code-dev safety-audit` |

## When things go sideways

- **AXON suggests something you didn't expect.** Type the suggestion
  name to accept, or `dismiss` to deweight. After 3 dismisses, the
  suggestion stops surfacing.
- **AXON doesn't know what to do.** It will QUERY you with the top-3
  options OR offer to register a new neuron / author a new workflow.
  Never silent-hangs.
- **You need to add a new tool.** Run `register-tool` (interactive
  wizard). Available to user after PR-117 lands.

## Next steps

- `docs/users/HOW-AXON-THINKS.md` — the neuron / synapse / axon model
  for outsiders (10 min).
- `docs/users/CHOOSING-A-DOMAIN.md` — figure out which built-in domain
  fits your work (5 min).
- `docs/users/AUTHORING-A-WORKFLOW.md` — direct + conversational
  workflow authoring (15 min).

## What this Quickstart can't promise

This Quickstart describes the **post-Phase-3** experience. As of
2026-05-17, the orchestrator + synapse-suggest + workflow-new commands
are designed but not yet implemented. Phase-3 PRs (101 .. 120 + 130 ..
132 + 116a..f) deliver them. Track readiness in
`phases/2-design/specs/migration-plan-v1.md`.
