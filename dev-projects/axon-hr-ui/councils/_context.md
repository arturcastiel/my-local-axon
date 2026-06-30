# AXON Surface Context — for hr-team councils (axon-hr-ui)
> Grounding bundle. Councils critique THIS reality, not generic agent-OS ideas.
> Captured 2026-06-22 from the live new-axon dev checkout. Codebase: /home/arturcastiel/projects/new-axon/axon

## What AXON is
An "operating system for AI agents" — a harness layered over a host model (here: Claude Code). Internal
reasoning is a compressed symbolic language (AXON-LANG: EXEC/RETRIEVE/ASSERT/IF/LOOP/STORE/LOG…), translated
to plain English only at the output boundary. Memory scopes: W: (session), L: (longterm), E: (episodic),
local/ (machine). Behavior is governed by a kernel (KERNEL-SLIM.md) + programs (markdown "neurons") + tools
(Python, 160 active). The user is the OS owner; dev-mode unlocks kernel edits.

## THE UI (the AXON shell — primary surface)
- The home screen is `menu` — a SINGLE ~250-line ASCII dashboard re-rendered IN FULL on every boot, reboot,
  and reload. Core Rule 12 FORBIDS truncating/summarizing it ("partial output is a shell crash").
- Menu sections, top to bottom: Header → OS STATE panel (~20 status lines: health, inference mode, dispatch
  index, tools, memory keys, loaded project, drift, backup, reminders) → MODES [1]CHAT [2]BUILD [3]RUN
  [4]MEMORY [5]SYSTEM [6]PLAN [7]PROGRAMS [D]DEV → CODE DEVELOPMENT [8]code-dev [9]library-dev →
  HR TEAM [10] → WORKFLOWS → QUALITY/SELF-IMPROVEMENT → (conditional) SELF-IMPROVEMENT panel → DISCOVER →
  SELF-OBSERVE → META TOOLS → footer (tip + ranked suggestions).
- Interaction model: numeric mode shortcuts (1-7, D, 0/menu to exit). Once in a mode you "stay there" and
  type naturally; a mode-router or mode-detect routes free text. Active mode shown as a badge.
- Per-response "narrated state block" is MANDATORY while a program/workflow is active:
  `program/workflow · PHASE NN — NAME · state · status · advance: mark DONE → NN+1` plus an auto-popped
  next-suggestion. A per-turn footer shows ranked next-steps (orchestrator/anticipate).
- Other surfaces: FAIL blocks (Problem/Cause/Fix/Suggested-next, boxed), interrupt gate (K/I/A prompt when
  user types something new mid-program), resume prompt (C/R/S), human-handoff / decide / narrate response
  conventions. All ASCII, terminal-rendered, monospace.
- Output is text-only in a terminal; no graphical layer. Everything is the agent emitting formatted text.

## CODE-DEV (the flagship code-development harness — 88 sub-programs)
- Lifecycle ladder: study → plan → pr → log → audit. Enforced as an ordered `_phases.json` manifest
  (nodes + status pending|active|done|stale + dependency edges). Explicit DONE-to-advance; in-order gate
  (R_WORKFLOW_NODE_ORDER); backward edit cascade-invalidates downstream to "stale".
- A project = my-axon/dev-projects/{slug}/ with a v4 schema: _meta, _profile, _dont-do-seeds, masterplan,
  04-log, 05-branches, 03-prs/, and phases/{phase}/ each scaffolding 9 files (_meta,_files,_dont-do,
  _decisions,_deviations,reviewer-state,01-study,02-plan,02-prs).
- SHADOW GATE: every code-dev session that touches the codebase must start from a "shadow" index, not raw
  source (shadow/ dir). Knowledge tools: code-dev-knowledge-impact (caller/blast-radius via code-symbols),
  code-dev-knowledge-shadow, test-map.
- Supporting sub-programs (sample of the 88): safety (audit/freeze/preflight), review (correctness/
  coverage/tests/scope/self/diff), journal (decision/event/log/search), dont-do (tokenized prohibitions
  enforced by R_DONT_DO — prose prohibitions are rejected as un-enforceable), divide/combine/partition/
  merge (split or join work units), whatif/dry-run (plan without writing), pr-* (create/review/respond/
  github/ready/sync/update-spec), state (save/resume/status/handoff/undo/metrics), cascade, link, since,
  next, preflight, lifecycle-tour, replay, migrate.
- Inputs are interactive QUERY flows (slug, display name, absolute codebase path, first phase).
- AEGIS: test-execution MAY be delegated per-project (policy + grant + green crucible); BUILD stays
  human-only; kernel edits are the inviolable floor.

## WORKFLOWS (orchestrate programs into a hierarchy)
- 3 execution modes: Fixed (declared node graph, rigid in-order), Adaptive (orchestrator picks the next
  synapse each step), Hybrid. 6 installed (4 reference, 2 user).
- adaptive-free-text: accomplish a free-text goal by dispatching the highest-ranked synapse each step until
  an acceptance predicate is TRUE (cap 25 steps). multiple-code-dev: iterate code-dev, audit project state
  vs the goal, feed audit findings back as study input to a fresh iteration; repeat until green or rejected.
- Tooling: workflow-runner (list/run/simulate/validate), workflow new (author conversationally),
  workflow edit. Node-graph traversal is rigid: no node-jumping without explicitly entering ADAPTIVE mode.

## KERNEL UX CONSTRAINTS (apply to any UI/workflow idea)
- AXON-LANG is internal; all user-facing text is translated. No symbolic ops leaked to user unless asked.
- State surfacing + rigid traversal are kernel-enforced, not optional.
- Inference mode 0-10 gates how much AXON asks vs infers (default 3 = cautious).
- Context-pressure gate checkpoints + halts near token limits; resume reconstructs from W:active-phase + logs.
- "Building is a human task" — AXON never runs builds/tests unless a scoped grant says so.

## OBSERVED FRICTION (real signals captured during this session — seeds, not the whole list)
1. Metadata noise: code-dev.md's synapse precondition contains `project ≠ ∅` repeated 11× verbatim —
   auto-generated by synapse-infer (PR-108 bulk migration). Auto-inferred contract fields are noisy.
2. Surface sprawl: 88 code-dev-*.md programs + 160 tools. Discoverability needs dedicated tools
   (find-program, list-tools, explain, simulate) — i.e. the surface is too big to hold in head.
3. Learning curve: dozens of subcommands per family; the menu is dense; new users get quickstart/faq/glossary
   as coping mechanisms.
4. CLI papercuts: `kv-store set` requires a JSON-quoted value (`'"x"'`) or it errors with a raw JSON parse
   message — leaks implementation detail to the operator.
5. The menu is one monolithic ~250-line render every boot — information-dense but un-prioritized; everything
   has equal visual weight; no progressive disclosure.
6. Phase/workflow state is powerful but ceremony-heavy: manifests, gates, narrated blocks, checkpoints —
   strong for resumability, potentially heavy for small/quick tasks.

## SCOPE FOR THE COUNCILS
"Temporary goal: improve AXON UI and the programs/workflow experience — focus on code-dev and workflows."
Councils should produce CONCRETE, AXON-grounded improvements (specific programs, menu sections, gates,
flows), not generic UX platitudes. Everything is advisory_only.
