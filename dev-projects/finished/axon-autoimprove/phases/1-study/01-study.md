# 01-study — axon-autoimprove

> Phase 1 deliverable. Findings from read-only inspection of `tools/cron.py`,
> `tools/drift.py`, `tools/usage.py`, `tools/memory.py`, `tools/kv_store.py`,
> `tools/compile*.py`, plus the axon-synapse AUDIT.md + RETRO.md.

## Open questions — answered

### Q1: Does cron honor `drift.state ≡ "diverged"` today?

**Answer: NO.** `tools/cron.py` line 344 registers `axon-auto-improve` as a
daily job at 09:30; it has no drift-gate read. `tools/drift.py` ships a
classifier (`classify(score)` returns "stable" / "drift" / "diverged" at
score ≥ 0.40) but cron does not call it. **Implication**: the drift gate
must be enforced inside the `auto-improve` *program* (workspace), not
in cron. D-A19 already mandates `TOOL(drift, read)`.

### Q2: What's the `E:` schema today? Is `E:auto-improve-log` a new key family?

**Answer: extension, not new family.** `tools/memory.py` line 7 defines
`SCOPE_MAP = {"W": working, "L": longterm, "E": episodic}`. `E:` is already
the episodic scope. Adding `E:auto-improve-log` is a normal `E:` key — no
schema migration. Storage format follows existing episodic conventions
(`my-axon/memory/episodic/`).

### Q3: D-21 N=5. What's the counter state today?

**Answer: unmeasurable from disk** — `synapse_suggest.py` keeps the accept
counter in `E:` but no entry yet has ≥ 5 because the suggestions footer
(PR-112) only went live 1 day ago. **Risk averted**: no "50 promotions
land on first run" scenario. The counter starts effectively at zero.

### Q4: How does `tools/usage.py find-program` store data?

**Answer: per-entry append log** (line 51 `read_entries(...)`, line 115
`aggregate(workspace, by="program", since=...)`). Each invocation appends
one row to a per-day log. Baseline-snapshot format: aggregate over a 7-day
window via `aggregate(by="program", since="-7d")` → freeze the resulting
dict as `E:baseline-YYYY-MM`. Format already supported; just needs a
`cmd_baseline` entry point in `tools/usage.py`.

### Q5: Precedent for daily-cron orchestrator programs?

**Answer: yes** — three already shipped via cron defaults
(`axon-memory-compact`, `axon-session-save`, `axon-programs-registry`).
The pattern is: cron entry → workspace program → tools. We crib structure
from `axon-memory-compact` (closest analog: episodic data, age threshold,
reversible). Read its program file in phase-2 design.

## Findings

| ID  | Finding | Evidence | Impact |
|-----|---------|----------|--------|
| F-A1 | Cron stub exists but no orchestrator program file | `tools/cron.py:344` registers `auto-improve`; `workspace/programs/auto-improve.md` does NOT exist | PR-201 must create the program |
| F-A2 | Drift gate read path must live in workspace program, not cron | `tools/cron.py` has no `drift` import | D-A19 stands |
| F-A3 | `kv_store.py` has no `rollback` function exposed at module level | grep returned 0 matches | PR-204 may need to add it (or use `memory.py`'s rollback path which DOES exist at line 17-22) |
| F-A4 | `memory.py` rollback IS shipped (line 17 `rollback_path`, 22 `save_rollback`, line 93 `restore`) | grep | reversibility primitive available for `E:` keys; auto-tune may need separate L:-key rollback |
| F-A5 | `usage.py aggregate(by, since)` ready for baseline use | line 115 | PR-207 is a thin wrapper |
| F-A6 | `compile.py` + `compile-write.py` + `compile_optimizer.py` + `compile_suggest.py` all exist | ls | auto-compile (PR-203) likely composes these — no new compile logic |
| F-A7 | No `--remove` flag visible in `compile.py` quick grep | need deeper read in phase-2 | possible gap; phase-2 verify |
| F-A8 | `drift.py classify()` returns string, not enum — predicate comparison `drift.state ≡ "diverged"` is a string compare | line 98-101 | matches D-A19 syntax |

## Per-action inventory (refined from seed)

### Action 1 — auto-compile
- **Trigger**: `usage.aggregate(by="program", since="-7d")` → filter ≥ 5 + not compiled
- **Compose**: `usage.is_compiled(ws, name)` (line 172 exists) + `compile.py` invoke
- **Reversibility**: F-A7 gap — phase-2 verify `compile --remove` or write it
- **Receipt key**: `(date, "compile", program_name)`

### Action 2 — auto-tune
- **Trigger**: dispatch neg-rate over last 20 dispatches from `E:dispatch-log` (synapse PR-119)
- **Target**: `L:dispatch-threshold`
- **Reversibility**: kv_store rollback NOT shipped (F-A3). PR-204 must either (a) add it or (b) use `memory.py` rollback pattern on L: keys
- **Closed loop**: store `M_t = neg-rate@t` in receipt, re-read `M_{t+1}` next tick (D-A13)
- **Bidirectional**: D-A16 raise/lower bounds [0.50, 0.95]
- **Receipt key**: `(date, "tune", "dispatch-threshold")`

### Action 3 — auto-archive
- **Trigger**: scan `my-axon/memory/episodic/` for entries > 30d
- **Compose**: existing `axon-memory-compact` cron does monthly compaction — must NOT collide. Phase-2 decision: either subsume `memory-compact` into auto-improve, or restrict auto-improve to entries NOT already touched by `memory-compact`
- **Rate limit**: ≤ 50 entries (D-A20)
- **Reversibility**: `memory.py restore` (line 93) ✓ shipped
- **Receipt key**: `(date, "archive", entry_id)`

## Telemetry inventory

| Source | Lives in | Captured? | Baseline plan |
|--------|----------|-----------|---------------|
| `usage.py find-program` | per-day log files | ✓ from synapse | PR-207 snapshot via `aggregate(since="-7d")` |
| ranker top-1 hit-rate | `E:ranker-hits` (synapse PR-119) | ✓ counter live | re-read at +14d for acceptance #11 |
| dispatch neg-rate | `E:dispatch-log` (synapse PR-119) | ✓ counter live | auto-tune input |
| ephemeral-accept counter | `E:ephemeral-accepts` (synapse PR-109) | ✓ counter live | promotion input |

**Conclusion**: every telemetry source needed is already wired by axon-synapse.
This project consumes; it does not instrument.

## Risk map — re-evaluated

| Flaw | Original concern | Disk verification | Status |
|------|------------------|-------------------|--------|
| FA-01 | 30d archive cascade | confirmed scannable; D-A17 + D-A20 sufficient | 🟧 spec-fixed |
| FA-02 | flip-flop receipts | D-A05/D-A15 idempotent key resolves | 🟧 spec-fixed |
| FA-03 | tune chases noise | D-A16 sample-floor 20 sufficient | 🟧 spec-fixed |
| FA-04 | archive collision | `axon-memory-compact` runs monthly 1st; auto-improve runs daily — overlap window 1d/month | 🟧 elevated to phase-2 design decision (subsume vs guard) |
| FA-05..FA-11 | self-audit batch | all addressed by D-A13..A20 | 🟧 spec-fixed |

**New finding NOT in original flaw list:**

| ID  | Flaw | Status |
|-----|------|--------|
| FA-12 | `kv_store.py` does not expose rollback at module level — auto-tune needs L: rollback primitive | 🟥 open — phase-2 decision: extend kv_store OR adopt memory.py rollback pattern for L: keys |

## Phase-2 entry brief

After phase-1 closes (now), phase-2 must author 5 specs + 2 decisions:

**Specs:**
1. `specs/auto-improve-orchestrator-v1.md` — daily program contract (cron → drift → opt-in → action dispatch → receipt)
2. `specs/auto-action-contract-v1.md` — per-action interface: `should_fire(state) → bool`, `apply(state) → result`, `undo(receipt) → result`, `measure(state) → metric` (closed-loop)
3. `specs/auto-improve-receipt-v1.md` — `E:auto-improve-log` row schema, two-phase commit (D-A15), idempotent key
4. `specs/ephemeral-promotion-v1.md` — D-A14 accept definition, threshold, promotion path
5. `specs/telemetry-baseline-v1.md` — snapshot format, monthly rotation, comparison helper

**Decisions (ADR):**
- D-AUTO-001: kv_store rollback — extend or adopt memory pattern? (FA-12)
- D-AUTO-002: auto-archive vs axon-memory-compact — subsume or guard? (FA-04)

Then `code-dev plan` fires → PR roster PR-201..PR-210 generated → phase 3 opens.

## Exit criteria — all met

- ✅ All 16 flaws either confirmed-closed-by-spec or downgraded to specific phase-2 decisions (FA-04, FA-12 = 2 🟥 → phase-2; OP-02 = soft-deferred to v2 measurement)
- ✅ Each acceptance criterion in `../../_goal.md` has a phase-3 PR placeholder (PR-201..PR-210 covers 11/11)
- ✅ Per-action inventory complete with reversibility primitives identified
- ✅ Telemetry inventory shows zero new instrumentation needed
- ✅ `code-dev plan` ready to fire after phase-2 specs land

**Phase 1 status: ready to close. Phase 2 (design) is next.**
