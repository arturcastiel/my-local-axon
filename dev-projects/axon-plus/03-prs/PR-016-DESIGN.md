# PR-016 — design (from workflow w3g1myq00, 2026-06-15)

I now have the complete, authoritative picture. The PR-112 footer reads `W:orchestrator-last-tick` (`tick.candidates`) and renders the `suggestions` block — this is the single existing surface. The situation-trigger engine must inject its one deduped hint into that same tick record (a new `tick.hint` field consumed by the footer), keeping ≤1 hint and gating against the candidates so they don't double up.

I have everything required to write the concrete PR-016 spec. No further reads needed.

---

# PR-016 — B: SITUATION-TRIGGER engine (≤1 hint/response, deduped, why+command)

**Project:** axon-plus · **Phase:** 3-quality-discover · **Goal:** B (discoverability) · **Complexity:** M
**Depends on:** none (signal sources already on disk) · **Pairs with:** PR-017 (footer activation), which renders this engine's output
**Respects:** reduce-surface (extend the existing footer/tick + anticipate family — no parallel hint surface), R13 (new tool ships tests).

## 1. Design in one paragraph

Add **one** detector tool, `tools/situate.py`, that reads already-existing on-disk signals (turn logs, usage, igap, orchestrator tick) and emits **at most one** situation-hint per call. The hint is injected into the **same** `W:orchestrator-last-tick` record that `anticipate.py` already feeds, and surfaced by the **existing PR-112 footer** (`axon/OUTPUT-LAYER.md` SUGGESTIONS block) — never a new surface. Dedup and the noise ceiling are enforced **inside the tool** against a small append-only ledger (`workspace/working/situate-ledger.json`), written through the same `loop_receipt` singlewriter discipline `igap.py` uses. The orchestrator calls it once per tick; if it returns silence, nothing renders.

## 2. The four signals → detectors (all read existing artifacts; no new instrumentation)

Each detector is a pure function `detect(state) -> Hint | None`. A `Hint` carries `{trigger, why, command, dedupe_key, priority}` — **why+command are mandatory fields, structurally enforced** (a hint without both is invalid and dropped at construction).

| # | Signal | Source already on disk | Threshold (config) | Hint command |
|---|--------|------------------------|--------------------|--------------|
| 1 | long grep/read streak → study mode | `state["recent-tools"]` from `W:orchestrator-last-tick` tool history + turn-log tool column | ≥ `streak-floor` (default 6) consecutive read/grep ops, no write between | `code-dev-study` |
| 2 | repeated manual steps → workflow | `tools/usage.py top --window 1d` cluster: same program/step run ≥ `repeat-floor` (default 3) | `workflow-new` |
| 3 | N graph queries → export map | count of `axon-graph` / graph-consumer fires in tick history ≥ `graph-floor` (default 3) | `graphify-obsidian` |
| 4 | entering a code-dev phase → phase tool | `W:active-phase` transitions into a `code-dev-*` phase this turn (compare prev tick's phase) | the phase-relevant program (`code-dev-test-map` / `code-dev-review-scope` for study/review phases — reuse `_GRAPH_CONSUMERS` mapping already in `synapse_suggest.py`) |

Detectors run in **priority order** (4 phase-entry > 1 streak > 2 repeat > 3 graph). First non-None, deduped hint wins; the rest are discarded **this turn** (that is the ≤1 ceiling).

## 3. Dedup mechanism (the load-bearing part)

A `dedupe_key` is `"{trigger}:{target_command}"` (e.g. `streak:code-dev-study`). The ledger `workspace/working/situate-ledger.json` holds:

```json
{"emitted": [{"key": "streak:code-dev-study", "turn": 42, "ts": "..."}], "last_turn": 42}
```

Rule (in `situate.py`, function `_is_duplicate`):
- A hint is **suppressed** if its `dedupe_key` was emitted within the last `dedupe-window` turns (default 8) — read from the ledger's `emitted` list, filtered by `turn >= current_turn - window`.
- Window is **turn-based, not time-based**, so it survives wall-clock gaps. Current turn comes from `W:turn-count` (passed via `--turn`).
- On emit, append `{key, turn, ts}` and prune entries older than the window. Single writer: the whole read-modify-write is wrapped in `loop_receipt(actor="situate", intent="emit-hint", target_kind="file", path=ledger, pre_value, post_value, …)` exactly as `igap._bump_session` does — satisfies axon-state-singlewriter.
- **Anti-double-up with the footer's own candidates:** before emitting, drop the hint if its `target_command` already appears in `tick.candidates[:3]` (passed in via `--tick-candidates`). The situation hint is for things the ranker did *not* already surface — this is what stops PR-016 and PR-017 from showing the same suggestion twice.

## 4. Noise-ceiling enforcement (≤1 per response)

Two independent ceilings, both mechanical:
1. **Per-call ceiling:** `situate(...)` returns `Hint | None` — the type makes >1 impossible by construction. The detector loop `break`s on first surviving hint.
2. **Per-turn idempotence:** the ledger's `last_turn` guards re-entry. If `current_turn == last_turn` (engine already emitted this turn — e.g. orchestrator ticked twice), return silence immediately. This means even if the orchestrator calls the tool multiple times in one user turn, **at most one hint reaches output per turn**.

A config `L:situate-enabled` (default `true`) and `L:situate-ceiling` (default 1, exposed for future tuning but the code treats >1 as 1 in this PR — ceiling is hard) gate the whole engine. Silence is first-class, exactly like `anticipate.py`'s "silent" density.

## 5. Render — through the existing footer, not a new one

- `situate.py emit` returns `{hint: {...} | null, suppressed_reason}`.
- **`orchestrator.md`** (extend the existing ANTICIPATE block, ~line 121–127): after computing `anticipation`, add one call:
  `hint ← TOOL(situate, emit, "--turn {turn} --tick-candidates {candidates}") | {hint: ∅}`
  and store it into the tick record: add `hint: hint.hint` to the `STORE(W:orchestrator-last-tick, {…})` dict (§ RECORD, ~line 154).
- **`axon/OUTPUT-LAYER.md`** SUGGESTIONS FOOTER (extend, ~line 94): after the candidates loop, append:
  ```
  IF tick.hint ≠ ∅ →
    → "  ⚡ {tick.hint.why}"
    → "     → run: {tick.hint.command}"
  ```
  This rides the **same** `sugg-on` gate and the same drift/context-pressure suppression already there — no new gate, no new block above TEARDOWN.

This is the reduce-surface compliance point: zero new user-visible surfaces; the engine writes into `W:orchestrator-last-tick.hint` and the one existing footer renders it.

## 6. Files to touch (exact)

| File | Change |
|------|--------|
| `tools/situate.py` | **NEW** — detectors, dedup ledger, `emit`/`status`/`clear` subcommands. Stdlib-only, `loop_receipt`-wrapped writes, `default_workspace()` like igap. |
| `tools/REGISTRY.json` | **NEW entry** `situate` (status ACTIVE, category `os`, purpose, `health.probe`: `python3 tools/situate.py --workspace /tmp status`, `expect: ok`). |
| `workspace/programs/orchestrator.md` | Add the `TOOL(situate, emit …)` call in ANTICIPATE block; add `hint:` to the `STORE(W:orchestrator-last-tick, …)` dict. |
| `axon/OUTPUT-LAYER.md` | Append the `tick.hint` render lines inside the existing SUGGESTIONS FOOTER block. **dev-mode-gated edit (R9).** |
| `workspace/tools/situate.md` | **NEW** tool doc card (mirrors `workspace/tools/synapse-suggest.md`). |
| `workspace/preferences/` (output.md or agent.md) | Document `L:situate-enabled`, `L:streak-floor`, `L:repeat-floor`, `L:graph-floor`, `L:dedupe-window`. |
| `tests/test_situate.py` | **NEW** — see §7. |
| `my-axon/dev-projects/axon-plus/03-prs/PR-016.md` | Replace stub with this spec; flip 02-prs.md status. |

Note: the `axon/OUTPUT-LAYER.md` edit requires `L:dev-mode ≡ true` (Core Rule 9) — flag it in the PR so the implementer enables dev-mode before that one edit. Everything else is in `tools/` and `workspace/` (not write-gated).

## 7. Tests (`tests/test_situate.py`) — R13

Pattern mirrors `tests/test_anticipate.py` (sys.path-insert `tools`, import `situate`, `tmp_path` for ledger).

1. `test_each_detector_fires_on_its_signal` — feed a synthetic `state` for each of the 4 signals at threshold; assert the right `trigger` + `command`.
2. `test_below_threshold_is_silent` — streak of 5 (< floor 6) → `None`.
3. **`test_ceiling_holds_one_hint_per_turn`** — feed a state that trips **all four** detectors at once; assert exactly one hint returned, and it is the highest-priority (phase-entry); assert a second `emit` call with the same `--turn` returns silence (`last_turn` idempotence). **This is the ceiling test.**
4. **`test_hint_carries_why_and_command`** — assert the returned hint has non-empty `why` (human-readable WHY) **and** a `command` that is a runnable program name; assert constructing a `Hint` with either field missing raises/drops. **This is the why+command test.**
5. `test_dedup_suppresses_within_window` — emit `streak:code-dev-study` at turn 10; at turn 12 (window 8) the same key is suppressed; at turn 20 it fires again (outside window).
6. `test_no_double_up_with_footer_candidates` — if `tick.candidates` already contains the target command, the hint is dropped.
7. `test_ledger_write_is_receipt_wrapped` — emit, then assert a loop-receipt terminal record exists for actor `situate` (singlewriter discipline, same assertion style as igap receipt tests).
8. `test_situate_is_wired_into_orchestrator` — lock-test (the re-orphaning guard, copied from `test_anticipate.py::test_anticipate_is_wired_into_orchestrator`): assert `orchestrator.md` contains `TOOL(situate` and `OUTPUT-LAYER.md` contains `tick.hint`. Prevents the "feature goes missing" disease this whole project targets.

## 8. Gates

R13 tests · scanners (residue-lint, program-tool-conformance — `situate` must appear in REGISTRY and be invoked) · crucible green · the `test_situate_is_wired_into_orchestrator` lock-test doubles as the anti-orphan gate.

---

### Boundary notes for the implementer
- **PR-016 vs PR-017 split:** PR-016 *produces* the deduped hint and writes `tick.hint`. PR-017 *activates* the PR-112 footer (the ranked top-3 candidates). They share the tick record and the one footer; PR-016's §5 OUTPUT-LAYER edit adds only the `tick.hint` lines — if PR-017 lands first, PR-016 just adds its two lines inside the already-live block.
- **Why no new instrumentation:** every signal source (turn logs, `usage top`, igap, tick tool-history) already exists from Wave 0/1 — PR-016 is a *reader*, consistent with reduce-surface.

Relevant paths (all absolute):
- `/home/arturcastiel/projects/new-axon/axon/tools/situate.py` (to create)
- `/home/arturcastiel/projects/new-axon/axon/tests/test_situate.py` (to create)
- `/home/arturcastiel/projects/new-axon/axon/tools/anticipate.py` (sibling pattern)
- `/home/arturcastiel/projects/new-axon/axon/tools/synapse_suggest.py` (ranker + `_GRAPH_CONSUMERS` map to reuse)
- `/home/arturcastiel/projects/new-axon/axon/tools/igap.py` (loop-receipt singlewriter + daily-ledger pattern to copy)
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/orchestrator.md` (ANTICIPATE block ~L121, RECORD STORE ~L154)
- `/home/arturcastiel/projects/new-axon/axon/axon/OUTPUT-LAYER.md` (SUGGESTIONS FOOTER ~L94 — dev-mode-gated edit)
- `/home/arturcastiel/projects/new-axon/axon/my-axon/dev-projects/axon-plus/03-prs/PR-016.md` (stub to replace with this spec)
- `/home/arturcastiel/projects/new-axon/axon/my-axon/dev-projects/axon-plus/02-prs.md` (status line L124-130 to flip)