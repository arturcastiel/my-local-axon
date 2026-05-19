# Demands register — axon-autoimprove

> ADRs / decisions that constrain or shape this project. Inherited demands
> from axon-synapse remain in force unless explicitly revised here.

## Inherited from axon-synapse (in force)

| ID    | Demand                                              | Notes |
|-------|-----------------------------------------------------|-------|
| D-007 | Goals always exist                                  | Auto-improve actions must serve `W:current-goal` |
| D-009 | DAG central at every level                          | Auto-improve actions appear as nodes in project DAG |
| D-010 | Suggestion engine ranked candidates                 | Ephemeral promotion (this project) is the tail end of D-010 |
| D-011 | Shadowing mandatory                                 | Auto-improve PRs touch source → shadow files required |
| D-021 | Ranker hit-rate ≥ 70 %                              | Baseline target — auto-tune must not regress below this |
| D-026 | Domain-agnostic kernel                              | Auto-improve actions must work on any domain, not just code-dev |
| R9    | No `axon/` writes without dev-mode                  | Auto-improve never writes kernel state |

## New for axon-autoimprove (seeded — phase-2 may revise)

| ID    | Demand                                              | Rationale |
|-------|-----------------------------------------------------|-----------|
| D-A01 | Every auto-action is reversible                     | Audit risk #4 — auto-actions on real state must roll back cleanly |
| D-A02 | Opt-in HARD                                         | Default OFF. First cron tick after flip-on requires user-confirm QUERY |
| D-A03 | Drift gate is absolute                              | `drift.state ≡ "diverged"` blocks every action. No exceptions. |
| D-A04 | Receipt per action                                  | `E:auto-improve-log` row required before action is considered complete |
| D-A05 | Cron entry idempotent                               | Re-running `auto-improve` same-day is a no-op (date-keyed receipt) |
| D-A06 | Tune step-size bounded                              | ≤ 0.05 per day, capped at 0.95 — synapse PR-120 inherited |
| D-A07 | Archive is move-not-delete                          | Archived entries stay restorable via `memory restore <id>` |
| D-A08 | One project, one toggle                             | `L:auto-improve` is the sole toggle — no per-action sub-toggles in v1 |
| D-A09 | Telemetry baseline is one-shot                      | `E:baseline-YYYY-MM` writes once; rotates monthly via cron |
| D-A10 | Ephemeral-promotion threshold matches D-21          | N = 5 fires → permanent. Same as synapse spec. |
| D-A11 | Audit-log row format frozen at design               | Schema decided in phase-2; downstream `axon-audit` 1d depends on it |
| D-A12 | No autonomous git                                   | Auto-improve writes to disk; human commits. R9-adjacent discipline. |
| D-A13 | **Closed-loop discipline (no open-loop tuning)**    | Every tunable-parameter action: (a) records metric M at decision time in `E:auto-improve-log`, (b) re-reads same metric next tick, (c) if M did not improve → auto-revert. 3 consecutive auto-reverts → pause rule + QUERY. Bug-class fix for open-loop scope. |
| D-A14 | **"Accept" definition for ephemeral promotion**     | A fire counts as an "accept" iff the user invokes the suggested program within 1 hour of the suggestion render AND the program was not also offered by a competing top-1 suggestion in the same window. Closes ambiguity flagged in audit. |
| D-A15 | **Two-phase receipt write (crash-safe)**            | `E:auto-improve-log` rows write `pending` before apply, then update to `applied`/`failed`. Next-tick scan reconciles orphan `pending` rows. Idempotent key: `(date, action, target_id)`. |
| D-A16 | **Auto-tune is bidirectional**                      | Threshold raises by 0.05 on neg-rate > 30 % (ceiling 0.95); lowers by 0.05 on neg-rate < 10 % (floor 0.50). Sample-size floor: ≥ 20 dispatches in window. |
| D-A17 | **Idle-gap re-confirm**                             | If last successful cron tick > 7 days ago, next tick re-prompts the opt-in QUERY before any action. Prevents 30-day archive cascade. |
| D-A18 | **Global rollback command**                         | `auto-improve rollback --days N` walks `E:auto-improve-log` in reverse and invokes per-action `undo` for each applied row in the window. Required for 14-day field run.|
| D-A19 | **Drift-gate read path is explicit**                | Auto-improve program reads drift via `TOOL(drift, read)`. Test `test_autoimprove_drift_gate.py` fakes diverged + asserts zero actions. |
| D-A20 | **Archive rate limit**                              | ≤ 50 episodic entries archived per cron tick. Excess rolls to next tick. Prevents long-idle cascade. |

## New for axon-autoimprove (2026-05-19 — from 02-deep-audit.md §7)

| ID    | Demand                                              | Rationale |
|-------|-----------------------------------------------------|-----------|
| D-A21 | **R9 at the IO chokepoint, not at the program**     | Every write to a path under `axon/` goes through a single helper (`_axon_io.atomic_write`) that checks `L:dev-mode`. Closes FA-15. New tools cannot bypass by forgetting to call `enforce.py`. |
| D-A22 | **Per-job circuit breaker on cron**                 | After 3 consecutive failures, a cron job auto-disables and surfaces a one-line note at next boot. Closes FA-13 + FA-24. |
| D-A23 | **Drift gate fails closed on missing trace**        | `drift gate` returns `state="unknown"` when no trace exists; consumers MUST treat `unknown == diverged`. Closes FA-14. |
| D-A24 | **Atomic append protocol for all log writes**       | All append-style logs (`igap`, `dispatch feedback`, `auto_audit`, episodic) write a complete row in a single buffered write + fsync. No tearable rows. Closes FA-18. |
| D-A25 | **kv_store rollback exists**                        | Resolves D-AUTO-001. The `loop-receipt` tool (PR-AUTO-201) is the chosen substrate — `_axon_rollback` snapshots are taken before any `L:` write that auto-improve performs. |
| D-A26 | **Synapse-suggest filter uses the real predicate evaluator** | `tools/synapse_suggest.py` calls `tools/predicate.py` (existing) instead of the regex placeholder. Filter defaults to True on unparseable preconditions (fail-open is the safe direction here — pre-conditions only narrow). Closes FA-17 + adjacent GAP-07. |
| D-A27 | **Static lint of `TOOL(…)` calls in programs**      | `tools/rules/r_tool_call_exists.py` walks every `workspace/programs/*.md` and validates `TOOL(name, sub, …)` against `tools/REGISTRY.json` + the tool's argparse surface. Fires at compile-time + at the response gate. Closes FA-16. |

## New for axon-autoimprove (2026-05-19 — from 04-discoverability.md §8)

| ID       | Demand                                              | Rationale |
|----------|-----------------------------------------------------|-----------|
| D-DISC-1 | **`discoverability.py coverage` tool**              | New `tools/discoverability.py coverage` walks `workspace/programs/*.md` + `tools/REGISTRY.json`, reads `workspace/programs/menu.md`, computes `(programs_named_in_menu / total_programs) × 100`. Exits 2 if < 50 %. |
| D-DISC-2 | **Menu-coverage CI lint**                           | A program lands without a menu entry (or a `# menu-exempt: true` front-matter directive) → CI fails. Wired into pre-push hook. Closes DISC-1 long-term. |
| D-DISC-3 | **`synapse-suggest --explain --recent` debug surface** | Prints top-N candidates + per-signal score breakdown without re-running orchestrator. Closes the orchestrator-circular discoverability loop. |
| D-DISC-4 | **Menu surfaces the autoimprove baseline counter**  | Once `E:baseline-YYYY-MM` exists, menu OS STATE renders `Baseline ✓ {days}d · hit-rate {pct}%`. Gives the user evidence that auto-improve is collecting data. |
| D-DISC-5 | **Menu surfaces the workflow layer (D-8/D-9/D-14)** | New menu section names `workflow new/run/list/edit/simulate/validate` and notes the `adaptive-free-text.yml` free-mode workflow. Synapse shipped this; menu hid it. |

## Triage process

- New demand surfaces → row added.
- Demand-fix design lands in phase-2 → linked to spec file.
- Implementation lands → linked to PR.
- Phase-4 retro verifies each closed.
