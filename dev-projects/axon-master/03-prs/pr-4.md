# pr-4 — Governance schema + precedence doc + plan-reads-rules stub

**Wave**: W1 · **Goals**: G.gov.01, G.gov.02, partial G.plan.04, G.gov.04 (stub) · **Depends-on**: none · **Parallel-with**: PR-3

## Why (problem statement)
There is no canonical schema for `safety/rules.md`, no precedence ordering between kernel / user-memory / project-rules / inline `--rule`, and `code-dev plan` makes no claim about which rules shaped its output. R6 marks U-5 ("governance composition rules") as a Tier-1 unaddressed gap. R5 plan-modes adds `--mode=constrained` and `--rule "..."` which presuppose a working rules layer. Until precedence is defined, F-E3 (rule contradiction) and F-E1 (plan violates rules silently) are unbounded risks. This PR is the stub: schema + doc + `Governance trace` section in plan output. PR-10 and PR-11 add the gating teeth.

## Evidence (from studies)
- `helpers/cd-gap-c3-p1-governance.md` → "rules.md is referenced by 5 programs but has no schema; no precedence with dont-do; no audit".
- `helpers/cd-gap-c2-p4-failure-modes.md` → F-E1 (plan violates rules), F-E2 (pr ready false-green), F-E3 (rule contradiction) — Class E.
- `helpers/cd-study-c3-p1-plan-modes.md` → plan mode `constrained` requires `--rule "..."` injection.
- `helpers/cd-gap-c1-p3-goals-extracted.md` → G.gov.01-05, G.plan.04 (plan reads rules), G.plan.12 (plan reads `safety/rules.md`).

## Design notes
- `workspace/safety/rules.md` schema:
  ```
  # rules.md — project rules of engagement

  ## R-NNN — <one-line title>
  status: active | dormant | retired
  scope: project | global
  applies-to: plan | review | merge | all
  rationale: <why>
  added: <ISO date>
  ```
- Empty file = `[]` (parses successfully; warn-once at first reference).
- `tools/rules.py` exposes a `PRECEDENCE` constant (8 levels):
  1. kernel/identity locks
  2. user-memory operational-safety
  3. AGENT contract (`AGENTS.md`)
  4. project `safety/rules.md` (active rules)
  5. inline `--rule "..."` injection (this run only)
  6. project `dont-do.md` (legacy; routes through `safety dont-do` per R4)
  7. workflow conventions (`workspace/programs/*`)
  8. defaults
- `workspace/AXON-DOCS-GOVERNANCE.md` documents the precedence with 1 worked example (rule R-001 blocks an option; user override forbidden); PR-24 expands to 5+ examples.
- `code-dev-plan.md` emits a `## Governance trace` section every run (empty in W1: `loaded 0 rules, filtered 0, flagged 0, conflicts 0`).
- `code-dev-pr-ready.md` gains a `--strict` flag (this PR: stub that prints `"not yet implemented — see PR-10"` and exits 1). Real teeth land in PR-10.

## Pitfalls (from failure-mode catalog)
- **F-E1 plan violates rules** → trace section makes violation visible (no teeth yet, but auditable).
- **F-E3 rule contradiction** → rules schema documents `applies-to`; PR-22 adds `rules audit` to detect contradictions.
- Empty rules.md silent-bypass → warn-once on first reference, recorded in `_actions.log`.

## Interface sketch
```text
$ code-dev plan
…
## Governance trace
loaded:  workspace/safety/rules.md (0 rules)
         workspace/dont-do.md (absent)
         study/_index.md (pre-W2; not consulted)
         kernel rules, user-memory rules, AGENT contract (all in force)
filtered: 0
flagged:  0
conflicts: 0
HALT triggers: 0

$ code-dev pr ready 3 --strict
strict gating: not yet implemented (PR-10 ships it)
exit 1
```

## Spec (canonical)
- **Files**:
  - new: `workspace/safety/rules.md` (empty with comment header), `workspace/AXON-DOCS-GOVERNANCE.md`, `tools/rules.py`, `tests/test_governance.py`.
  - modified: `workspace/programs/code-dev-plan.md`, `workspace/programs/code-dev-pr-ready.md`, `tools/REGISTRY.json`.
- **Acceptance**:
  1. Empty `rules.md` parses → `[]` with warn-once "0 rules loaded".
  2. `tools/rules.py` exposes `PRECEDENCE` constant; doc generated from it.
  3. `code-dev plan` always emits `## Governance trace` (counts only in W1).
  4. `code-dev pr ready --strict` prints stub message + exit 1.
  5. 8 precedence levels documented in `AXON-DOCS-GOVERNANCE.md`.
  6. 1 worked precedence example in the doc.
  7. `tools/lint_paths.py` clean.
- **Rollback**: revert files (governance trace disappears; precedence doc deleted).
- **Owner**: AGENT writes; HUMAN reviews precedence doc.
- **Parallelism**: ⊥ PR-3 (independent files).

## Cross-refs
- Master plan: `../03-plan.md` § Wave 1 / PR-4.
- Helpers: `helpers/cd-gap-c3-p1-governance.md`, `helpers/cd-gap-c2-p4-failure-modes.md` (Class E), `helpers/cd-study-c3-p1-plan-modes.md`.
