---
explains:      docs-plan-v1
audience:      tier-A (project author — you)
last-checked:  2026-05-17
version:       1
---

# READ-FIRST  ·  axon-synapse

> If you only have 20 minutes, read this file + the four numbered docs
> below. The full corpus is reference material; you don't need to read
> it linearly.

## Reading order (≈ 25 min total)

| # | Doc | Read for | Time |
|---|-----|----------|------|
| 1 | `00-EXECUTIVE-SUMMARY.md` | What axon-synapse is, why it exists, where we are | 3 min |
| 2 | `01-CONCEPT-MAP.md` | Neuron / synapse / axon model + glossary in pictures | 5 min |
| 3 | `02-ARCHITECTURE-AT-A-GLANCE.md` | How the pieces fit + the loop + the layers | 7 min |
| 4 | `03-DECISION-DIGEST.md` | All 36 ADRs in one line each — scan, deep-read what surprises | 5 min |
| 5 | `04-FLAW-DIGEST.md` | Known flaws + their fixes (or deferrals) — confidence calibrator | 3 min |

Total: ~ 23 min for the full insider load.

## Reference (read when relevant)

| Need | Open |
|------|------|
| "What does **<term>** mean here?" | `phases/2-design/specs/SYNAPSE-GLOSSARY.md` (v2) |
| "What did we decide about **<topic>**?" | `phases/2-design/_decisions.md` |
| "Which Phase-3 PR addresses **<finding>**?" | `phases/2-design/specs/migration-plan-v1.md` |
| "What does the **<spec>** say in detail?" | `phases/2-design/specs/<spec>-v1.md` (or `-v1_1` if newer) |
| "Why was this demanded?" | `_demands.md` (project root) |
| "Where am I in the multi-phase plan?" | `masterplan.md` (project root) |
| "What broke / nearly broke?" | `_flaws.md` (project root) |

## If you only have 5 minutes

Read **`00-EXECUTIVE-SUMMARY.md`** alone. It covers vision, current
state, next move, and the headline risks. Everything else is
elaboration.

## If you're showing AXON to someone else

Send them:

- `docs/users/QUICKSTART.md` (5 min)
- `docs/users/HOW-AXON-THINKS.md` (10 min)
- `docs/strategy/MAKE-IT-USEFUL-FOR-OTHERS.md` (15 min — for collaborators)

## If you're an LLM agent booting on AXON

`docs/agents/AGENT-BOOT.md` — your boot path. (Phase 3 PR-130 ships
this; for now follow `axon/startup.md` + `KERNEL-SLIM.md`.)

## Maintenance

This file is the entry point. If you can't find what you need from
here, that's a bug — file it as a finding under `_flaws.md` as `DOC-FL-NN`.
