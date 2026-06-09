# Masterplan — AXON Autonomy Discipline

## TARGET (the one thing this project must achieve)

**Convert AXON's autonomous development from "an agent trying to follow rules" into "a system that
enforces a renewable floor under three things that decay over a long run — Identity, Authority, and
Mission — so an overnight run is safe by construction."**

Concretely, after this project an unattended run:
- **cannot make a code change off-workflow** — the crucible gate REFUSES any code change that has no active
  phase + open PR spec in the loaded project, and the reanchor halts it proactively at boundaries (the
  freelancing this project was born from; grounded gap analysis in 01-study Part C). This is criterion zero;
- **cannot drift past a reanchor** — at every PR boundary and every context-compaction boundary it
  re-asserts identity + the WORKFLOW POSITION (active project / phase / prescribed next step) + goal +
  constraints + done-state + scope, and halts on mismatch;
- **cannot act outside its contract** — scope (files/dirs) and operations are an explicit allow-list
  declared up front; a touch outside it trips a circuit breaker;
- **cannot push through a red or ambiguous state** — a twice-red gate, repeated failure, or an
  escalation-surface op stops the run and surfaces a question, leaving a clean resumable checkpoint;
- **cannot wander off-mission** — what to work on next is a deterministic walk of the plan DAG's
  ready-frontier gated by a Definition-of-Ready, not a free choice;
- **is auditable in minutes and replayable** — it emits a standard run report and its trajectory can be
  replayed to any divergence point.

**The governing principle (earned, not assumed — see 01-study.md §1–2):** *intention decays, enforcement
does not.* Every soft discipline becomes an invariant the system checks. This is the whole project in one
line.

## Acceptance criteria (done when all hold, each landed as a small gated PR)

0. **(PRIME) Off-workflow code change is gate-refused** — a new changeset rule
   `R_CODE_CHANGE_REQUIRES_PR_PHASE`: a code-file changeset with no active phase + covering PR spec in the
   loaded project BLOCKS at the crucible gate (WARN→BLOCK via `L:code-change-requires-pr-phase`), and the
   reanchor halts it proactively at boundaries. A regression reproduces the 2026-06-03 freelance incident.
   This is the failure the project was born from — criterion zero, built first (01-study Part C).
1. **Autonomy contract** — a run declares goal + acceptance predicate + scope allow-list + operation
   allow-list + budget (PR-count / wallclock / token). The contract is the *entry gate* to overnight
   mode. Built on `autonomous_mode.py`.
2. **Circuit breakers** — the run halts-and-surfaces (never pushes through) on: same-change gate-RED
   twice · N consecutive failures · a touch outside the scope allow-list · an escalation-surface op ·
   budget exhausted. Each breaker has a test.
3. **Mandatory reanchor** — a checkpoint that, at each PR boundary and each compaction/resume boundary,
   re-*asserts* (not just re-reads) identity, goal+acceptance, dont-do, done-state, scope, and the
   working invariants (branch matches `_meta`, dev-mode as expected, no uncommitted drift, gate green,
   goal not already met). Fails closed on mismatch. Built on IDENTITY LOCK + `session.py`. Includes a
   **memory reanchor** (spot-check a recalled memory still matches the code before acting on it).
4. **Deterministic feature selection** — selection walks the ready-frontier of the plan DAG (only PRs
   whose `depends-on` are merged), gated by a Definition-of-Ready (has acceptance predicate + test plan +
   bounded scope); risk-above-threshold auto-escalates to "needs human." Built on `plan_dag.py`.
5. **Escalation protocol** — a defined escalation surface (destructive ops, kernel edits, ambiguous
   acceptance, repeated failure, anything dont-do flags); on hit: stop, write the question, leave a
   resumable checkpoint, don't guess. The mandatory-soft layer above `autonomous_mode` ALWAYS_DENY.
6. **Two-key rule for irreversible actions** — merge / push / outward-facing requires BOTH gate-green
   AND an independent check (an adversarial pass or a pre-declared human sanction).
7. **Run report + replay** — every autonomous run emits a standard artifact (selected / skipped /
   escalated + why, gate results, ledger reconciliation) and is replayable from its trajectory.
8. **Fan-out isolation invariant** — when a run spawns parallel agents, each works in its own worktree;
   hardcoding the shared tree is blocked. (Directly from the worktree-contamination incident, §1.)

Plus the standing floor: everything ships gated green, small single-concern PRs, full merge discipline,
ledger reconciled.

## Non-goals
- NOT removing the human — it's about *safe* autonomy, which includes knowing when to STOP and ask.
- NOT the correctness discipline (that's the sibling `axon-discipline`: harness, anti-masking, coverage).
- NOT a kernel rewrite. Build on `autonomous_mode` / `accountability` / `session` / `plan_dag`.

## Phase graph (directed)

- **1-safety-contract** → 2-reanchor
    The AUTHORITY floor (and the MVP of safe autonomy — nothing else is safe without it): the autonomy
    contract (criterion 1), circuit breakers (2), and the escalation protocol (5). Extends
    `autonomous_mode.py`; makes the contract the entry gate and the breakers/escalation the stop-rules.
- **2-reanchor** → 3-selection
    The IDENTITY floor: the mandatory reanchor checkpoint + memory reanchor (criterion 3). Built on
    IDENTITY LOCK + `session.py`; triggered at PR + compaction boundaries; asserts and halts on drift.
- **3-selection** → 4-observability
    The MISSION floor: deterministic DAG-driven feature selection + Definition-of-Ready/Done (criterion
    4). Built on `plan_dag.py` + `depends-on` + `synapse-suggest`.
- **4-observability** → (done)
    Auditability + the last guards: run report + replay (7), the two-key rule (6), and the fan-out
    isolation invariant (8). Wire the new gate controls so the discipline is enforced, not advisory.

Phases are added/edited by: code-dev phase new.
