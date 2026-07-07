# Study — AXON Bugfix 01
Updated: 2026-07-01  ·  Iterations: 2  ·  AXON: 9/10  ·  User: pending

## Goal
Audit the AXON codebase itself (/home/arturcastiel/projects/new-axon/axon) for structural bugs: unwired
neurons (programs/tools that exist but are unreachable from any live dispatch path), missing files, and
broken routines. Heavy focus on the code-dev program family and workflows, and on the hr-team subsystem.
Deliverable is a fix-and-polish backlog, not immediate fixes — findings feed the next phase (code-dev plan).

## Priorities
1. code-dev workflows (routing correctness, workflow-YAML execution correctness) — explicit owner focus
2. hr-team subsystem (advisory-council wiring, audit-bundle persistence) — explicit owner focus
3. Cross-cutting unwired-tool / unwired-program detection across the whole repo
4. Missing-file / dangling-reference sweep beyond what axon-audit already mechanically covers
5. Rank everything by severity so the next phase can plan fixes in the right order

## Constraints
- Read-only audit — no fixes applied in this phase (owner's known preference: verify + present findings
  before committing to a plan, not auto-fix blind).
- Every finding must be verified against actual source/runtime behavior, not inferred from naming — several
  candidate "orphan" tools/programs turned out to be false positives once real reachability (cron, git hooks,
  cross-tool Python imports, dispatch-index) was checked.
- **Scoping decision (2026-07-01, owner):** C8 (`/memories/` dead path) is filtered out of this project's PR
  plan. Everything else (C1-C7, all HIGH/MEDIUM/LOW) proceeds to Phase 2.

## Tech Stack
AXON is a markdown-defined "program" (neuron) layer interpreted by an LLM agent, backed by Python CLI tools
(`tools/*.py`, dispatched via `axon.py`) and JSON state (REGISTRY.json, cron.json, dispatch-index.json,
_phases.json per project). Programs invoke each other via `EXEC()`, call tools via `TOOL()`, and are also
reachable via direct filename-typed commands and a semantic dispatch-index. Workflows are YAML node-graphs
(`workspace/domains/*/workflows/*.yml`) walked by `workspace/programs/workflow-run.md` + `tools/predicate.py`.

## Key Concepts
See `AUDIT-FINDINGS.md` in this project for the full findings (8 CRITICAL, 14 HIGH, 10 MEDIUM, ~14 LOW,
plus 6 cross-cutting root-cause patterns). Summary of the two explicitly-requested focus areas:
- **code-dev workflows**: every shipped fixed workflow (code-dev/cpp/python/library-dev) dies at its first
  review gate — the YAML files' predicate strings (`review.passes()`) don't match `predicate.py`'s registered
  builtins (`review.passed`). `adaptive-free-text.yml`'s first node dispatches a nonexistent program. Fixed/
  Adaptive/Hybrid execution modes aren't actually differentiated at the runtime level. `workflow validate`
  never runs the two lints that would have caught this.
- **hr-team**: the audit-bundle persistence path (manifest/transcript/decision/checksums) is fully implemented
  in `tools/hr_team.py` but never wired into any `.md` program — the core compliance feature doesn't run.
  M2-FILTERED invocation mode and `--family`/`--roles` filters are dead. Selector-computed auditor-weight
  elevation is silently discarded during aggregation.
- **code-dev router**: 8 "umbrella" family routers and the entire PR-ergonomics suite (`pr list/drift/sync/
  export/suggest-reviewer`) are unreachable via their own documented two-word syntax, because the router only
  matches single hyphenated tokens.

## Open Questions
1. Fix order: severity-first (SAFETY-CRITICAL + CRITICAL across all subsystems first), or subsystem-first?
2. The router-architecture root cause (pattern #1) now affects code-dev AND library-dev (~20 files) — worth a
   structural fix (two-token cmd parsing) vs per-file patches?
3. `pack`, `reservoir-mcp`, `reservoir-pvt` (+ possibly `token-bench`) are confirmed/candidate dead tools —
   does the owner want them removed as part of this project, or out of scope?
4. Scale of this PR set is now much larger (2 SAFETY-CRITICAL, 13 CRITICAL, 26 HIGH, 15 MEDIUM, ~16 LOW post
   round-2). One combined project, or split by subsystem given the depth?
5. S1/S2 (safety-critical governance + orchestrator) are structurally different from the rest — they're about
   what an agent could get away with doing, not just what doesn't work. Fix on the normal PR-backlog cadence,
   or treat as urgent/out-of-band?

## Round 2 — "close any gaps" pass (owner-requested, 2026-07-01)
5 additional parallel agents covered: library-dev domain parity, core infra (memory/scheduler/phase-model/goal
systems), the dispatch/synapse routing backbone, autonomous-mode/AEGIS governance, and a completeness-critic
pass (39 previously-unclassified orphan-list files + adversarial re-verification of 4 CRITICAL findings, all
4 independently CONFIRMED). Found 2 SAFETY-CRITICAL findings (S1: destructive-git-op/kernel-floor governance
not mechanically enforced; S2: orchestrator's autonomous decision loop fundamentally broken) and 5 new
CRITICAL, 12 new HIGH, 5 new MEDIUM findings. Full detail in AUDIT-FINDINGS.md (now "Round 2, closed").

## Architecture Snapshot
Full findings: `my-axon/dev-projects/axon-bugfix01/AUDIT-FINDINGS.md` (this project).
Audit method: `python3 axon.py axon-audit` (mechanical baseline, HEALTHY/37-39 — confirms forward EXEC/TOOL
reference resolution only, does not catch reachability) + a custom static cross-reference script (orphan-tool/
orphan-program candidate generation) + 5 parallel deep-read-and-run-verified subsystem audits (code-dev family,
hr-team, orphan-tool classification, workflows, missing-file/cron-drift sweep).

## Sources
- file: code-dev.md, code-dev-safety-audit.md, code-dev-safety-audit-structure.md, code-dev-whatif.md,
  code-dev-lifecycle.md, code-dev-migrate.md, code-dev-finalize.md, code-dev-pr-ready.md,
  code-dev-safety-preflight.md, code-dev-reviewer-track.md (and ~80 more code-dev-*.md files)
- file: hr-team.md, hr-team-convener.md, hr-team-deliberator.md, hr-team-selector.md, tools/hr_team.py
- file: workflow-run.md, workflow-validate.md, workflow-new.md, tools/predicate.py, tools/workflow_run.py,
  workspace/domains/code-dev/workflows/*.yml
- file: tools/REGISTRY.json, tools/cron.py, workspace/scheduler/cron.json, axon/tools/REGISTRY.md
- tool: axon-audit, workflow-runner check-stale, predicate eval (run live for verification)
