# Drift Fail-Closed Spec (v1)

> glossary: AXON-GLOSSARY v2
> closes:   FA-14 (drift gate fail-open on missing trace, a.k.a. B-03)
> resolves: (none new — D-AUTO-002 already resolved)
> serves:   D-A23 (drift gate fails closed on missing trace),
>           D-A19 (explicit TOOL(drift, read) — extended here with fail-closed semantic)
> sibling:  `loop-receipt-v1.md` (drift state changes will eventually emit receipts)

## Purpose

Today, `tools/drift.py:cmd_gate` returns `state="stable"` whenever the
drift trace file is absent. The in-process equivalent in
`tools/_axon_lib.py:drift_gate` does the same on both missing-file
**and** parse-failure. The lone fatal consumer
`tools/auto_improve.py:324` reacts only to `state == "diverged"`. The
combination is **fail-open**:

```
fresh workspace (no trace)
  → drift gate returns state=stable
  → auto_improve treats this as authorisation
  → every auto-action fires on a workspace with zero observed drift evidence
```

This violates D-A03 ("drift gate is absolute") on the first run after
any `drift reset` or clean boot, and silently defeats the autoimprove
acceptance criterion *"zero auto-actions fire when drift.state ≡
diverged"* in the corner case of no trace at all.

The fix: introduce a new gate state `"unknown"` returned when there is
no positive evidence of drift state (missing trace, unparseable trace,
or stale trace older than a TTL). All fatal-gate consumers treat
`unknown` the same as `diverged` — the system fails closed.

## Non-goals

- NOT a redesign of `compute_score` or the HALT/WARN thresholds. Score
  arithmetic is unchanged.
- NOT a new trace lifecycle. `drift reset` still clears the trace; the
  fix is **how** consumers interpret the resulting no-trace state.
- NOT a freshness check on trace **content**. The optional staleness
  check is wall-clock against `trace.recorded_at`, not a content
  freshness audit.
- NOT a global escape hatch. Even with `L:dev-mode ≡ true`, the gate
  still returns `unknown` on missing trace; consumers MAY (but are not
  required to) downgrade to WARN under dev-mode. That is a per-consumer
  decision, not a gate decision.

## Contract — `tools/drift.py` + `tools/_axon_lib.py` v1.1

### New gate state

```jsonc
{
  "score":     0.0,
  "state":     "unknown",                 // NEW canonical value
  "decision":  "halt",                    // NEW: was "quiet"
  "modifier":  -50,                       // NEW: matches diverged
  "program":   null,
  "note":      "no active trace" |
               "trace unparseable" |
               "trace stale (older than {TTL_S}s)"
}
```

The state vocabulary becomes `{stable, drifting, diverged, unknown}`.
`unknown` is a **terminal** state for the gate-decision side; consumers
that previously treated only `diverged` as fatal MUST be widened.

### Trigger conditions for `state="unknown"`

| Condition                                  | Note string                              |
|--------------------------------------------|------------------------------------------|
| Trace file does not exist                  | `"no active trace"`                      |
| Trace file exists but is not valid JSON    | `"trace unparseable"`                    |
| Trace exists, JSON valid, but `recorded_at` older than `DRIFT_TRACE_TTL_S` | `"trace stale (older than 7200s)"` |
| Trace exists, JSON valid, but `expected`/`actual` keys absent | `"trace malformed"`                |

### Module constants (new)

```python
# tools/drift.py
DRIFT_TRACE_TTL_S         = 7200          # 2 h — gate goes "unknown" past this
GATE_UNKNOWN_DECISION     = {"state": "unknown", "decision": "halt",
                              "modifier": -50}
```

`DRIFT_TRACE_TTL_S` is a constant in v1 — no override path. A future
spec can promote it to `L:drift-trace-ttl-s` if a real use-case
emerges.

### Code surfaces touched

1. `tools/drift.py:cmd_gate` — every early-return that previously
   produced `state="stable"` becomes `state="unknown"` with the
   matching note. The TTL check is added after the load-trace branch.
2. `tools/_axon_lib.py:drift_gate` — same three branches (missing,
   parse-fail, stale) return `unknown`.
3. `tools/auto_improve.py:324` — widen the predicate:
   ```python
   if drift.get("state") in ("diverged", "unknown"):
   ```
   Plus the error message gains the note string.
4. `axon/programs/auto-actions.md` and any other `.md` program that
   reads `drift.state ≡ diverged` (search-and-replace done in
   implementation PR) — widened to the fail-closed predicate
   `drift.state ∈ {"diverged", "unknown"}`.

### Trace recording side

`cmd_record` and `cmd_init` write a `recorded_at` ISO-8601 UTC string
into the trace JSON on every successful append. Legacy traces without
the field count as recorded "now" the first time the gate reads them
(write-back done by `cmd_gate`); this is the only legacy-handling
concession.

## Storage

- No new files. Trace already lives at the path returned by
  `drift.trace_path(workspace)`.
- One new field in the trace JSON: `"recorded_at"` (ISO-8601, UTC).

## Integration

### Consumers that must widen the fatal predicate

`grep -rn "state.*diverged" tools/ workspace/ axon/` returns the full
list. v1 audit:

- `tools/auto_improve.py:324` — fatal — widen.
- `tools/auto_audit.py` — surfaces drift state in audit text — DO NOT
  widen (it's reporting, not gating).
- `workspace/programs/orchestrator.md:52` — reads `drift, gate` into a
  state var; the gate decision is already a per-state decision string,
  so no widening needed at the call site; the **decision** field
  already says `"halt"` when state is `unknown`, so existing
  `IF decision ≡ "halt"` consumers fail closed automatically.
- `workspace/programs/menu.md` — reads gate state for badge; treats
  `diverged` as ⚠. Add `unknown` to the same badge.

### Tests already in place that must continue to pass

- `tests/test_drift.py` — existing happy-path tests; **no change**
  unless they rely on the missing-trace = stable invariant. If they do,
  flip them to assert `unknown` (test patch is part of PR-AUTO-213).
- `tests/test_tools_kernel.py::TestDriftGate` — exists and is the
  primary regression surface for gate decisions.

## Test plan — `tests/test_drift_fail_closed.py` (new)

Hermetic, monkeypatched `default_workspace` to `tmp_path`.

| # | Test                                            | Asserts                                                       |
|---|-------------------------------------------------|---------------------------------------------------------------|
| 1 | `test_missing_trace_returns_unknown`            | No trace file → `state=unknown decision=halt modifier=-50`    |
| 2 | `test_unparseable_trace_returns_unknown`        | Trace is `not-json` → `state=unknown`, note `"trace unparseable"` |
| 3 | `test_malformed_trace_missing_keys_returns_unknown` | Trace is `{}` → `state=unknown`, note `"trace malformed"` |
| 4 | `test_stale_trace_returns_unknown`              | Trace `recorded_at` = now - 8000 s → `state=unknown`, note `"trace stale (older than 7200s)"` |
| 5 | `test_fresh_stable_trace_passes`                | Trace `recorded_at` = now, expected≡actual → `state=stable`   |
| 6 | `test_in_process_drift_gate_mirror`             | `_axon_lib.drift_gate(ws)` returns identical dict to subprocess `cmd_gate` for all 4 unknown cases |
| 7 | `test_legacy_trace_without_recorded_at_writeback` | Trace JSON has no `recorded_at` → gate reads as fresh, writes the field back, second call sees it as fresh |
| 8 | `test_auto_improve_halts_on_unknown`            | Mock `drift_gate` → `state=unknown`; `auto_improve --dry-run` exits with the drift-halt message |
| 9 | `test_decision_is_halt_when_unknown`            | The `decision` field is `"halt"` (not `"quiet"`) when state is `unknown` — protects the `decision`-only consumers |
| 10 | `test_module_constant_ttl_value`                | `drift.DRIFT_TRACE_TTL_S == 7200` (lock the default) |

## PR map

- **PR-AUTO-213** — `tools/drift.py` + `tools/_axon_lib.py` +
  `tools/auto_improve.py` widening + the 10-test file + the menu-badge
  one-liner. Single PR; the rule-of-thumb "rule and fixes ride
  together" applies here too (`state=unknown` must be everywhere it
  matters in one shot, otherwise main goes red on whichever consumer
  lags).

## Closes / Resolves

- **FA-14 / B-03** — drift gate fail-open on missing trace.
- **D-A23** — "drift gate fails closed on missing trace" — fully
  delivered.
- **D-A19 extension** — explicit `TOOL(drift, read)` semantic now
  documents the four `unknown` triggers.

## Open questions

None. The TTL default of 7200 s (2 h) is a v1 conservative pick — a
typical AXON session is < 1 h, and a 2-h gap without a trace strongly
suggests the workspace has gone cold. Promote to a kv-store override
in v2 only if the field reports usage.

## Out of scope for v1

- A new `drift status` subcommand that returns just the state without
  computing score (nice-to-have menu surface).
- Per-program TTL overrides (e.g. long-running compile jobs may want
  longer).
- A `drift trace --rotate` retention policy. Today the trace is
  single-file; rotation is a separate concern.
