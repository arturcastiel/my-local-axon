# Code-dev canonical FSM — analysis (T-A batch 2 follow-on)

> Source: code-dev family masters: `code-dev-load`, `code-dev-study`,
> `code-dev-plan`, `code-dev-pr-create`, `code-dev-safety-audit`,
> `code-dev-finalize` (stub). Date: 2026-05-17.

## High-level chain

```
code-dev new                    ← scaffold project (v4 schema)
       ↓
code-dev load <slug>            ← set W:code-dev-project
       ↓
code-dev study  [--mode=O/S/D]  ← Phase 1: ingest, goal, confidence ≥ 7 gate
       ↓
code-dev plan   [--mode=t/s/o/d]← Phase 2: high-level + PR list
       ↓                          (--mode=tactical default)
code-dev pr [N] [--mode=...]    ← Phase 3: per-PR spec
       ↓                          (real program: code-dev-pr-create;
       ↓                           "code-dev-pr" is a deprecated alias)
code-dev log                    ← Phase 4: implementation log per session
       ↓
code-dev pr-review [N]          ← per-PR review (the FSM walked in F-009)
       ↓
code-dev safety-audit           ← Phase 5: cross-reference plan vs log
                                  (real program; "code-dev-audit" is alias)
       ↓
code-dev finalize               ← orphan-stub; never implemented
                                  (PR-119 follow-up flagged)
       ↓
code-dev shadow                 ← mandatory per D-011 (D-23)
```

## Per-program parameter / mode systems

### code-dev-study modes

`--mode={overview, subsystem, deep}` — each with its own token budget:

| Mode | input-cap | output-cap | Use |
|------|-----------|------------|-----|
| overview (default) | 8000 | 4000 | breadth read of source / docs |
| subsystem | 16000 | 6000 | one-file deep dive |
| deep | 32000 | 12000 | reverse-engineer entire subsystem |

`--output={engineering, executive, machine}` — controls render shape.
`--target=<path|glob>` — file or pattern (≤200 files).
`--input=<path>` — pre-load JSON/text (coverage data, gh outputs).

**Acceptance criterion (declared inline!):** "Phase ends when both user and
AXON rate satisfaction ≥ 7." This is one of the only explicit goal-completion
predicates in the code-dev family today. Direct input into D-010 (goals).

### code-dev-plan modes

`--mode={tactical, strategic, operational, decision}`:

| Mode | Output |
|------|--------|
| tactical (default) | `02-plan.md` + `02-prs.md` + `02-phases/phase-N-<slug>.md` |
| strategic | `02-plan.md` + `02-roadmap.md` (tier-1 vision + plan index) |
| operational | `02-plan.md` (run-book form: ordered steps + estimates) |
| decision | `02-plan.md` + `03-decisions/adr-NNN-<slug>.md` (one ADR per call) |

`--budget N` — caps PR count; overflow lands in `02-prs.deferred.md`.
`--rule "<text>"` — ad-hoc governance rule injected for this run (PR-11).

### code-dev-safety-audit

`code-dev audit` — full audit of all PRs (deprecated alias resolves here).
`code-dev audit [PR-N]` — audit specific PR.
`code-dev audit diff` — only PRs with issues.

**Non-destructive.** Reads + reports, never modifies plans/specs. Output:
`05-audit.md`. Re-runnable.

## Deprecated aliases + orphan stubs discovered

| Aliased name (user-typed) | Real target | Status |
|---------------------------|-------------|--------|
| `code-dev-audit` | `code-dev-safety-audit` | DEPRECATED ALIAS; "removed next release" |
| `code-dev-pr` | `code-dev-pr-create` | DEPRECATED ALIAS; "removed next release" |
| `code-dev-finalize` | (none — stub only) | ORPHAN STUB; PR-119 follow-up |

This is a code-dev hygiene finding (F-012).

## Synapse-contract candidate fields from this walk

Each code-dev synapse declares (today):

```
# desc:     <natural-language purpose>
# usage:    <invocation patterns>
# inputs:   W:keys, files (read)
# outputs:  files (written)
# next:     suggested follow-up program(s)
# example:  CLI examples
# tips:     hints
# notes:    caveats
# modes:    parameter modes with token-budget overrides
# budget:   default token caps
```

Plus inline `## HELP` blocks, `## GUARD` (ASSERTs), `## IDENTITY LOCK`,
`## INPUT`, `## OUTPUT`, etc.

The synapse-contract schema must accommodate:

1. **Modes / parameters** — programs are parameterized; the synapse fires
   differently per `--mode`. Schema needs `parameters:` and `param-modes:`.
2. **Token budgets per mode** — already declared by program; lift into
   synapse contract for orchestrator cost estimation.
3. **Acceptance predicates** — `code-dev-study`'s "satisfaction ≥ 7" must
   be expressible as a `post-state` predicate.
4. **Alternative implementations** — when an alias points to a real
   program, the synapse contract should declare the canonical target.
5. **Stub / unimplemented** — `code-dev-finalize` has no logic; contract
   needs a `status: stub` state so the orchestrator knows not to fire it
   in production paths.

## Workflow-mode mapping (per D-017)

Today's code-dev hierarchy is implicitly **Fixed** (per D-014/D-025):
`new → load → study → plan → pr → log → pr-review → safety-audit → finalize`.

The mode is enforced by `## GUARD` blocks: e.g. `code-dev plan` asserts
`02-prs.md` exists from a prior `code-dev study`. This is a **fixed-mode
precondition gate**.

A *parameterized adaptive* layer would let the user say "I want to study,
then jump to writing a PR (no plan)" — and the orchestrator would
either dispense with the gate (if user-confirmed) or generate a minimal
synthetic plan to satisfy it.

## Findings to emit

- **F-012** — code-dev has 3 deprecated/orphan entry points; user-typed
  verbs route through stubs; PR-119 unfinished.
- **F-013** — code-dev programs are already parameterized synapses
  (modes, budgets, output shapes); the contract schema must capture this.
