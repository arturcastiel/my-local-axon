# High-Level Plan — AXON Bugfix 01
Updated: 2026-07-03  ·  Iterations: 1  ·  AXON: 8/10  ·  User: 8/10

## Context (from Phase 1)
Goal: Audit the AXON codebase itself for structural bugs — unwired neurons, missing files, broken
routines — and turn the verified findings (AUDIT-FINDINGS.md: 2 SAFETY-CRITICAL, 13 CRITICAL, 26 HIGH,
15 MEDIUM, ~17 LOW) into a severity- and dependency-ordered fix backlog. C8-round-1 (`/memories/` dead
path) is scoped out per owner decision 2026-07-01.

## Architecture Overview
AXON is a markdown-defined program (neuron) layer interpreted by an LLM agent, backed by Python CLI
tools (`tools/*.py` via `axon.py`) and JSON state (REGISTRY.json, cron.json, dispatch-index.json,
_phases.json). Programs invoke each other via `EXEC()`, call tools via `TOOL()`; workflows are YAML
node-graphs run by `workflow-run.md` with gates evaluated by `tools/predicate.py`. Governance =
PreToolUse hook (`tools/shell.py gate_check`) × autonomous-mode grant × AEGIS `_policy.md` × crucible.

## Strategy
Eight dependency-ordered waves, severity-first with root-cause grouping:
safety-critical enforcement (A) → workflow engine (B) → router architecture (C) → state/scheduler/
goals (D) → hr-team (E) → user-facing safety/onboarding (F) → cron/mirrors/misc (G) → systemic
lints + doc honesty (H). The audit's dominant defect shape — "implemented and unit-tested but never
wired into the production call site" — gets a permanent mechanical guard in Wave H (PR-028).

## Decisions taken at plan time (owner delegated, 2026-07-03: "you decide")
- **D1 — hybrid workflow mode**: descope honestly via ADR (PR-010); implementable later.
- **D2 — scheduler preemption**: doc-honesty descope (PR-016), not a minimal implementation;
  queue *integrity* (pop/deps/clear) IS fixed for real (PR-015).
- **D3 — `L:` backend unification** (PR-014): converge on the `.md`-file longterm store
  (`workspace/memory/longterm/`, read by the kernel's own gates, git-visible); `kv_store`
  becomes a compatibility shim or is retired. Formalized as an ADR in the PR.
- Kernel-core line edits inside PR-016/PR-030 are carved out for per-change owner confirm
  (kernel-floor constraint; grant denies kernel-change).

## Wave map (details per PR in 02-prs.md)
- **A — Safety-critical enforcement**: PR-001..004 (S1, S2)
- **B — Workflow engine**: PR-005..010 (C1, C4, C8, H4, H5)
- **C — Router architecture**: PR-011..013 (C5, C6, C7, M7, M8, H8, H9, H10, H11, H12, H19)
- **D — State/scheduler/goals**: PR-014..018 (C9, C10, C11, C12, M13, M14)
- **E — hr-team**: PR-019..021 (C2, C3, H2, H3, M1, M2, M3 + hr-team LOWs)
- **F — User-facing safety/onboarding**: PR-022..024 (C13, H15, H16, H17, H18, M15)
- **G — Cron/mirrors/misc**: PR-025..027 (H6, H7, H13, H14, H20..H26, M5)
- **H — Systemic guards + doc honesty**: PR-028..030 (pattern-7 liveness lint, pattern-2
  inline-EXEC-args lint + H1, M4, M6, M9, M10, M13, LOW sweep)

## Constraints honored
tests-with-neurons (every PR ships tests) · plan-atomic-prs (backward deps only) · reduce-surface
(new lints live under existing `tools/rules/R_*` + crucible surface) · kernel-floor (kernel edits
human-only) · budget-human-wall (untouched) · test = full repo pytest suite, full counts reported.

## Known non-coverage (honest scope statement)
The study's residual-gap list (menu.md, status/stats, todo, board, workspace-backup, my-axon-init,
auto_audit.py, …) was never audited; this plan fixes findings, it does not claim full-repo coverage.
Follow-up sweep phase recommended after the backlog lands. Findings dated 2026-07-01 — every PR spec
re-verifies its finding against HEAD before implementation.
