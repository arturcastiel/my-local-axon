# Project: general-bugfix — full AXON audit (bugs + architecture maturity + new features)

slug:            general-bugfix
schema-version:  v4
status:          complete
legacy:          false
phase:           audit (DONE)
workflow-step:   pr
branch:          main
codebase:        /home/arturcastiel/projects/new-axon/axon
parent:          (none)
sub-projects:    []
created:         2026-06-09
updated:         2026-06-10 (13 MRs merged: all 8 criticals closed, keystone set; PR-9 + PR-10 remain)

## Goal
The most detailed study AXON has run on itself. Spawn a swarm of agents to study EVERY program (172
workspace + 29 kernel) + every tool (160) + the system itself (kernel, compiler, scheduler, gates, tests).
Each agent evaluates BOTH (a) correctness bugs and (b) improvement opportunities — new code-dev modes, new
workflow programs, better naming, simplification, fixes, new features. Think from all perspectives (users,
competitors, online best-practices). Challenge ideas. Goal: mature the code and make AXON genuinely great.

## Method
Multi-phase study workflow: program audits (fan-out by family) · tool/system/architecture audits ·
perspective + competitor + online research · adversarial synthesis. Uses the new `code-graph` for
structural/god-node/dead-code grounding. Target: study confidence ≥ 0.90 before handing to the owner for
technical discussion → planning.

## Authorization
Full autonomy through the STUDY phase (owner directive 2026-06-09). No code changes in study — findings only.
Hand to owner at ≥0.90 confidence to discuss technical perspective + findings, then planning mode.
Kernel floor intact (no autonomous kernel merge); dev-mode granted only for the graphify-obsidian REGISTRY card.

## Phase log
- 1-study: IN PROGRESS — swarm audit of all programs/tools/system → consolidated findings → 01-study.md.

## Study outcome (2026-06-10)
23-agent swarm (resumed once past a usage-limit) → 186 bugs / 167 improvements / 98 features → 01-study.md.
8 verified critical bugs (phase split-brain · predicate .value/.result kills all workflow gates · chat+plan on
dead path-vars · mode-router false comments · menu drops modes 1-5 · shadow init flags · check-structure wrong
audit · whatif false dry-run). Adversarial critic docked 0.9→0.62 on verified doc-drift (84-vs-160 tools,
3.7.0-vs-3.8.0, 214-vs-271 test files) — folded in as §C findings + test-green confirmed → honest 0.9.
Phase 1 DONE at 0.9. Owner takes over for technical discussion → planning. Source data: tasks/wx0gpsjlo.output.

## Plan (2026-06-10)
Phase 2 DONE. 02-plan.md + 02-prs.md: ~14 PRs in 4 waves (Step-0 foundation incl. COMPILED-MIRROR KILL · Wave-1
workflow+conversational criticals · Wave-2 phase/PR-spec/shadow/library+output-manifest · Wave-3 dry-run/reduce-surface/
doc-honesty/keystone). Strategy = interleave fix-then-guard (WARN→BLOCK), per §J. Ready for owner go → execute.
