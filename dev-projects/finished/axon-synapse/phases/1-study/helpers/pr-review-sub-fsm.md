# PR-Review sub-FSM — analysis (T-A batch 2)

> Source: `workspace/programs/code-dev-pr-review.md` (master) +
> `workspace/programs/code-dev-pr-review-p1.md` .. `p9.md` (split scaffolds).
> Date: 2026-05-17.

## TL;DR

There are **two implementations** of the PR-review FSM today:

1. **Monolithic master** (`code-dev-pr-review.md`) — full 9-phase workflow with
   real logic, 140+ lines, sequential execution.
2. **Split scaffolds** (`code-dev-pr-review-p1.md` .. `p9.md`) — 9 autogen-stub
   shells from PR-20.8 (axon-master plan). Each calls a placeholder
   `review_pN(pr-num)` verb. Shared state lives in `_reviewer-state.json`
   (PR-20.5 cache via `cd_cache` tool).

**The phase semantics drift between the two implementations** — same phase
numbers, different meanings. This is itself a finding (see F-009).

## Master file (`code-dev-pr-review.md`) phases

| Phase | Name in master | Action |
|-------|----------------|--------|
| P1 | Context load | Read PR tracking, log, upstream state, file list |
| P2 | Study | Shadow every touched + dependency file |
| P3 | Conflict analysis | API drift, superseded work, design decisions |
| P4 | Harmonization plan | Numbered steps: file · region · change · verify |
| P5 | Rebase | Rebase onto upstream, drop superseded commits |
| P6 | Execution | Apply harmonization plan step by step |
| P7 | Verification | Grep sweeps, build, targeted ctest |
| P8 | Commit organization | `git reset --mixed` → logical commit groups |
| P9 | Documentation | GitHub description + technical explanation + tracking |

## Split scaffolds (`code-dev-pr-review-pN.md`) phases (PR-20.8)

| Phase | Name in stub | `review_pN` placeholder |
|-------|--------------|------------------------|
| P1 | summary | PR overview + scope check |
| P2 | diff | file-by-file diff walk |
| P3 | (unread, projected) | (likely impact / conflict) |
| P4 | (unread, projected) | (likely harmonization) |
| P5 | tests | test presence + coverage delta hooks |
| P6 | (unread, projected) | (likely execution) |
| P7 | (unread, projected) | (likely verification) |
| P8 | (unread, projected) | (likely commit organization) |
| P9 | final | synthesize verdict + reviewer-state.json write |

## Phase drift between the two implementations

| Phase | Master | Stub | Drift |
|-------|--------|------|-------|
| P1 | Context load | summary | misaligned |
| P2 | Study (shadow) | diff | misaligned |
| P5 | Rebase | tests | strongly misaligned |
| P9 | Documentation | final verdict | mostly aligned |

This is **schema drift between the two implementations of the same FSM**.
A user running `code-dev-pr-review-p5` expects (per stub) test review;
a user running `code-dev-pr-review --phase=5` (per master) expects rebase.

## State-carrier inspection

Both implementations use `cd_cache` tool to read/write `_reviewer-state.json`:

```
TOOL(cd_cache, reviewer-load,  "--project-dir {project-dir}")
TOOL(cd_cache, reviewer-save,  "--project-dir {project-dir} --state {TOJSON(state)}")
```

`cd_cache` has 9 callers (F-004 #5) — confirmed as the workflow-state plumbing
of code-dev. This is the **state-vector substrate** for the FSM (D-013).

Each split emits a transition event:

```
EMIT(code-dev.pr.review.phase, {pr: pr-num, phase: pN})
```

These EMIT calls are the **orchestrator hook points** — a future orchestrator
subscribes to `code-dev.pr.review.phase` and can suggest the next synapse
(or branch the workflow) based on which phase completed.

## Transition graph (intended)

Linear by default:
```
P1 → P2 → P3 → P4 → P5 → P6 → P7 → P8 → P9
```

Resumable: master accepts `--phase N` to start at any phase. State is
preserved in `_reviewer-state.json` between phases.

Conditional next-conditional opportunities (un-declared today):
- After P3 (conflict analysis): if `state.p3.conflicts == 0` → may skip P4/P5.
- After P7 (verification): if `state.p7.tests_failed > 0` → branch to
  `code-dev-pr-review-p5` (rebase) or `code-dev-review-tests`.
- After P9: should auto-suggest `code-dev-shadow` (D-011) + `code-dev-audit`.

These are **prime synapse-contract migration targets** — declaring them
formally lights up the orchestrator's first useful FSM.

## Implications

- The PR-20.8 split appears incomplete or abandoned in favor of the master.
  Determining ground-truth is a finding (F-009).
- The 9 stub files reference PR-20.5 (`_reviewer-state.json`) + PR-2 (compile
  gate) + PR-12 (rename safety) — they encode dependencies that **should**
  become precondition predicates in the synapse contract.
- `cd_cache` is the existing state-vector substrate for code-dev. Generalizing
  to a domain-agnostic state carrier (per D-015) means abstracting `cd_cache`
  to `synapse-state` or similar.
- EMIT events are already wired. The orchestrator's subscription layer is the
  bridge between "synapse fires" and "ranker re-ranks."
