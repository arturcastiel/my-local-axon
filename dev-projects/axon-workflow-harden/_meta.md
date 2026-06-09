# Project: AXON workflow-subsystem harden (harmonize MR !141)
slug:            axon-workflow-harden
schema-version:  v4
status:          complete
legacy:          false
phase:           2-harmonize
workflow-step:   done
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
sub-projects:    []
created:         2026-06-04
updated:         2026-06-05

## DONE (2026-06-05) — 7 gated PRs merged; MR !141 harmonized
W3 !142 (stale-neuron renames) · W1 !143 (anti-skip runner + M3–M6) · W2 !144 (lint suite + reuse/tool refines
+ 2 BLOCK gates) · W4 !145 (workflow-new pre-write validation + questions registry) · W5a !146 (per-lap
sub-run-id mechanism + M1 collision-safe paths) · W5b !147 (the multiple-code-dev rebuild — C1–C5/H1–H5, the
once-non-functional meta-workflow now runs + is proven) · W5c !148 (H4 end-to-end multi-lap loop test).
EXCLUDED as the author flagged: iter-helper.py, tools/run_tests.py (pure scaffolding). DEFERRED follow-up:
**M2** — `terminals()` accepts a forgotten on-complete as a terminal (forgery vector); real fix = explicit
`terminal: true` schema-migration across all workflows + lint. Its own runner-hardening PR. Do NOT re-run the
!141 harmonization. See PR docs in 03-prs/ + the design in 04-w5-design.md.

## Working Context
Source: open **MR !141** (`feat/multiple-code-dev-iter-a-to-j`) on origin — authored by ANOTHER AXON instance
(GitHub Copilot CLI · Claude Opus 4.7). 32 files, **+3376/−29**, one squashed commit; **merges cleanly onto
current main** (verified via merge-tree). It ships: runner-level **anti-skip enforcement** (nested-workflow), a
**workflow lint suite** (check-stale / check-templating / explain), **workflow-new `validate_draft`** hardening,
the **multiple-code-dev** meta-workflow, + a fixture-aware test runner + an iteration-driver scaffold.

Goal of THIS project: **do NOT merge !141 wholesale.** Vet it (relevance + quality — done in `01-study.md`),
then HARMONIZE the good + relevant parts into **gate-first PRs** (our workflow), EXCLUDING the process
artifacts (`iter-helper.py`, `tools/run_tests.py`) the author themselves flags as non-production. The owner
merges through these PRs. The source branch `review/mcd-141` is kept locally for cherry-picking. NEXT:
study → (owner confirms scope) → plan/pr → build gate-first.
