# Project goal — axon-autoimprove

> Closes the deferred items from axon-synapse: auto-improve loop (was PR-130-132
> in synapse v1 plan, dropped from v1.1) + production telemetry baseline +
> ephemeral-suggestion auto-promotion. The composition path is live; this
> project teaches it to improve itself.

## Stated rationale (2026-05-18, seeded from axon-synapse AUDIT.md)

axon-synapse closed with 8/10 acceptance criteria met. The 1 partial
(ephemeral-suggestion auto-promotion) and 1 deferred (manual-lookup baseline)
both require the same missing capability: **a daily, reversible, opt-in loop
that observes lived data and applies narrow improvements**.

PR-120 (igap + auto-improve wire to synapse-suggest) shipped the *toggle*
(`L:auto-improve`) and the cron stub but left the orchestration empty. A
contributor who flips the toggle today gets nothing — risk #5 in the audit.

This project wires it.

## Acceptance — when is this project done?

1. **Cron contract**: `L:auto-improve = true` triggers a daily AXON cron entry
   (`auto-improve`, 09:30) that runs `auto-improve` orchestrator program;
   `false` no-ops with a single INFO log line.
2. **Three actions live & reversible**:
   - **auto-compile** — programs with ≥ 5 uses in last 7d that aren't compiled
     get compiled. Reversible via `compile --remove`.
   - **auto-tune** — dispatch threshold adjusted **bidirectionally** by 0.05
     when neg-rate > 30 % (raise) or < 10 % (lower) over last ≥ 20 dispatches.
     Bounded [0.50, 0.95]. Reversible via `kv-store rollback`.
   - **auto-archive** — episodic memory entries > 30d move to annual archive.
     **Rate-limited** to ≤ 50 entries per cron tick (FA-01 mitigation).
     Reversible via `memory restore`.
3. **Ephemeral-suggestion auto-promotion** wired: when an ephemeral suggestion
   accumulates ≥ N **fires** (D-A14 definition: user invokes the suggested
   program within 1 hour of the suggestion render — see D-A14), it promotes
   to permanent. N = 5 (D-21 inherited). Closes synapse acceptance #7.
4. **Drift gate**: zero auto-actions fire when `drift.state ≡ "diverged"`.
   Audit log records the skip. Read path is `TOOL(drift, read)`; test
   `test_autoimprove_drift_gate.py` asserts zero actions when diverged.
5. **Receipt — two-phase write**: every auto-action writes a row to
   `E:auto-improve-log` in two steps: `pending` before apply, `applied` or
   `failed` after. Crash between steps → next tick observes `pending` row
   and either completes or rolls back. Idempotent by `(date, action, target)` key.
6. **Telemetry baseline captured**: `tools/usage.py find-program` counter
   collects ≥ 7 days of data; baseline persisted as `E:baseline-YYYY-MM`,
   rotates monthly. Closes synapse acceptance #10.
7. **Opt-in HARD**: default is OFF. First cron tick after flip-on requires
   user-confirm QUERY before any action fires. Idle-gap > 7d also re-triggers
   the confirm QUERY (FA-01 mitigation).
8. **R9 preserved**: no `axon/` write in this project. Auto-actions touch
   `tools/`, `workspace/programs/`, `my-axon/memory/`, `E:` keys only.
9. **Closed-loop discipline** (D-A13): every tunable-parameter action records
   the metric at decision time + re-reads it next tick. If the metric did
   not improve, the action **auto-reverts**. 3 consecutive auto-reverts pause
   the rule and surface a QUERY. No open-loop tuning anywhere in v1.
10. **Global rollback command**: `auto-improve rollback --days N` reverts the
    last N days of auto-actions in reverse order. Required for the 14-day
    field run (acceptance #11) — a slow-burn regression must be undoable.
11. **Hit-rate improvement demonstrable**: after 14 days of opt-in operation,
    ranker top-1 hit-rate or dispatch-correctness improves on at least one
    measured signal vs the captured baseline. **Or** the auto-revert /
    pause-rule branch fires (proving the closed loop works even when the
    open-loop direction was wrong). Either outcome satisfies #11.

## Non-goals (this project)

- No ML / learned ranker. Auto-tune is rule-based threshold adjustment only.
- No new ranker signals (synapse shipped 11 — adding more is a separate scope).
- No second-domain proof (science-dev) — that's a separate future project.
- No replacement of the orchestrator or the suggestions footer — both stay as
  shipped by synapse.
- No autonomous git operations. Auto-improve writes locally; the human commits.
- No multi-machine sync of `E:` baselines — single-machine first.

## Out of scope, but seeded for future

- Cross-session learning curve plots (would need a UI surface).
- Per-domain auto-tune (auto-improve works on code-dev only in v1).
- Cost-aware action scheduling (run cheap actions daily, expensive ones weekly).
