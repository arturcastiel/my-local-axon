# PR-017 — design (from workflow w3g1myq00, 2026-06-15)

Diagnosis complete. Returning the PR spec.

---

# PR-017 — Activate the orchestrator suggestion footer (axon-plus Goal B)

## 1. Why it's silent — root cause (confirmed, not inferred)

The footer machinery is all present and correct, but **nothing populates `W:orchestrator-last-tick` on a normal turn**. Three independent defects, in order of severity:

**D1 (structural — the real cause): the orchestrator is never run except inside an adaptive workflow.**
`grep` for `EXEC(orchestrator)` across the whole tree returns exactly one call site:
- `workspace/programs/workflow-run.md:216` — `IF wf.execution-mode ≠ "fixed" → EXEC(orchestrator)`

There is no boot tap, no response-gate tap, no per-turn hook, no menu tap. So `W:orchestrator-last-tick` is written **only** while an adaptive/hybrid workflow is mid-run — and `workflow-run.md:288` `CLEAR(W:orchestrator-last-tick)` wipes it the moment that workflow finishes. On boot, on the menu, in interactive chat, and during every fixed workflow, the tick is `∅`. Confirmed live: `memory get W:orchestrator-last-tick → {"found": false}`. Both render gates (`menu.md:382` and `OUTPUT-LAYER.md:96`) test `COUNT(sugg-cands) > 0`, which is always 0 → footer renders nothing. **The footer is silent because its data source is only ever populated inside a feature 99% of turns never enter.**

**D2 (not the cause, but a latent footgun): `L:suggestions-enabled` is unset.** Confirmed: `memory get L:suggestions-enabled → {"found": false}`. This is *fine* — both gates default it to `true` (`RETRIEVE(L:suggestions-enabled) | true`), so the toggle is not the blocker. Flagged only so the fix doesn't "solve" it by setting the key and mistaking that for the cure.

**D3 (would make it render garbage even once populated): candidate shape mismatch.** The footer renders `{c.name} reason: {c.reason} confidence: {c.score}`. But `synapse-suggest rank --explain` emits `reason` as an **array of debug strings** (`["intent+0.025","dispatch+0.064"]`) and the *human* score field is `score` (0..1) while `raw` is the unnormalized value. The orchestrator (`orchestrator.md:154-165`) stores `candidates` **verbatim** into the tick. So even after D1 is fixed, the footer would print `reason: ['intent+0.025', 'dispatch+0.064']` — a signal-weight dump, not a "why". There is **no `command`/how-to-run field at all** in the candidate record; the prompt's "each with why + how-to-run" requirement is currently unsatisfiable from the data.

## 2. What to wire (reduce-surface: reuse, do not add)

**Decision: do NOT add a per-turn orchestrator EXEC.** Running the full mutator orchestrator program every turn is a heavy, side-effecting tick (CHECKPOINT, EMIT, dispatch, `W:active-program` stomp) — wrong altitude for an advisory footer, and it fights the response gate. Instead reuse the **read-only** `anticipate.py`, which already wraps the same ranker with a margin gate and a silence-first contract, and already returns a `category` slice. The footer's data producer becomes a thin, read-only tick-writer.

**Change set (4 edits, 0 new tools, 0 new files):**

1. **`tools/anticipate.py` — extend the result record (reuse, no new tool).** Have `anticipate()` return the top-N (default 3) candidates already in footer-ready shape, not just the top-1 verdict. For each candidate emit:
   - `name` (have it),
   - `why` — collapse the `reason` array + `category` into one human clause (e.g. `"matches your recent input · system tool"`); derive from the dominant signal, not the raw weight string,
   - `command` — the run-string. Derive via the existing `programs_registry` / REGISTRY `usage:` field (programs already declare `# usage:`; tools have a REGISTRY entry). Fall back to the bare `name` when no usage string exists,
   - `score` — the normalized `score` (0..1), **never** `raw`.
   Keep the silence contract: below the `SUGGEST=0.20` margin → emit `[]`, never a guess.

2. **`axon/BOOT.md` boot step 3 + the response gate path — add ONE read-only tick-write.** After output render (the `!BG` band, alongside turn-logging), write the tick from anticipate:
   ```
   IF RETRIEVE(L:suggestions-enabled) | true ≡ true →
     ant ← TOOL(anticipate, "--input {W:raw-user-input} --top 3")   ← read-only, no --log spam every turn
     IF COUNT(ant.candidates) > 0 →
       STORE(W:orchestrator-last-tick, { ts: NOW(), candidates: ant.candidates, source: "anticipate" })
     ELSE → CLEAR(W:orchestrator-last-tick)    ← honest silence; stale candidates never linger
   ```
   This is the single missing wire. It is `!BG`, non-blocking, read-only, and runs on **every** turn — so boot, menu, and interactive chat all get a fresh tick. `workflow-run`'s existing populate/CLEAR stays as-is (it overwrites with workflow-context candidates during a run, then this band repopulates on the next free-text turn — exactly the handoff the existing `CLEAR` comment anticipates).

3. **`axon/OUTPUT-LAYER.md` §SUGGESTIONS FOOTER + `workspace/programs/menu.md:382-388` — render `why` + `command`.** Change the render line from the current `reason: {c.reason} confidence: {c.score}` to:
   ```
   {arrow} {c.name}   — {c.why}
        run: {c.command}                  confidence: {c.score}
   ```
   Both render blocks must match (test T-112.7 already pins menu↔output-layer parity). Recompile `menu.cmp.md`.

4. **`tools/REGISTRY.json` (anticipate entry) + docs** — bump anticipate's `purpose` to note it now produces the footer tick. One-line CHANGELOG row referencing PR-017.

## 3. Noise ceiling (≤3 — enforced at three layers, defense in depth)

- **Producer:** `anticipate --top 3` caps candidates at 3 before they ever reach memory.
- **Gate:** the margin gate (`SUGGEST=0.20`) already drops weak candidates → typical render is **1**, not 3. Silence is the default, not the exception.
- **Renderer:** `TAKE(sugg-cands, 3)` in full mode, `TAKE(sugg-cands, 1)` in compact mode (default) and under critical context-pressure, `sugg-on ← false` on drift-diverged — all already in `OUTPUT-LAYER.md:88-91`, unchanged. So the live ceiling is **top-1 in the default compact footer**, top-3 only in `full`. This satisfies "≤3 ranked candidates" while keeping the steady-state footprint minimal.

## 4. Tests (R13 — additions require coverage)

Extend `tests/test_output_layer_suggestions.py` and add `tests/test_anticipate_footer.py`:

- **T-017.1** — `anticipate(--top 3)` returns ≤3 candidates, each with `name`, `why`, `command`, `score` keys present (shape contract).
- **T-017.2** — `command` is non-empty: a program candidate's command equals its `# usage:` first form; a tool candidate falls back to its name. (closes D3's missing how-to-run)
- **T-017.3** — `why` is a human string, **not** the raw `reason` array and **not** containing `+0.0` weight tokens. (closes D3's reason-array leak)
- **T-017.4** — `score` is the normalized 0..1 field, never `raw`.
- **T-017.5** — silence contract: a no-margin / empty-ranker state returns `[]`, and the tick-writer `CLEAR`s rather than storing stale candidates. (cardinal rule: wrong > none)
- **T-017.6** — ceiling: with 10 ranked inputs, the producer caps at 3; assert compact-mode render shows exactly 1, full-mode ≤3.
- **T-017.7** (BOOT/gate wiring, static-text assertion like the existing PR-112 tests) — `axon/BOOT.md` contains the `STORE(W:orchestrator-last-tick, …)` from `anticipate` in the `!BG` post-render band, gated on `L:suggestions-enabled`. This is the regression guard that prevents the footer from silently de-wiring again.
- **T-017.8** — menu↔output-layer render parity: both blocks render `why` + `run:` line (extends existing T-112.7).
- **Regression:** keep all 9 existing `test_output_layer_suggestions.py` cases green, and the 3 `test_workflow_orchestrator_bridge.py` cases that pin `workflow-run`'s populate-then-CLEAR ordering (the new boot-band write must not break the bridge's stale-clear).

## 5. Acceptance criterion

On a fresh boot with no workflow running, `memory get W:orchestrator-last-tick` is non-empty after the first turn, and the menu footer renders at least the top-1 next-step with a plain-English `why` and a runnable `run:` command — verified by a non-test manual boot. Footer stays **silent** (no render, tick cleared) when the ranker margin is below threshold.

---

**Files referenced (all absolute):**
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/menu.md` (footer block: lines 37-40, 382-388)
- `/home/arturcastiel/projects/new-axon/axon/tools/synapse_suggest.py` (ranker; `reason` array shape at the `--explain` output)
- `/home/arturcastiel/projects/new-axon/axon/tools/anticipate.py` (the read-only wrapper to extend — the producer)
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/orchestrator.md` (tick writer, lines 154-165; only EXEC'd from workflow-run)
- `/home/arturcastiel/projects/new-axon/axon/workspace/programs/workflow-run.md` (sole `EXEC(orchestrator)` at line 216; CLEAR at line 288)
- `/home/arturcastiel/projects/new-axon/axon/axon/OUTPUT-LAYER.md` (§SUGGESTIONS FOOTER, lines 81-105)
- `/home/arturcastiel/projects/new-axon/axon/axon/BOOT.md` (where the missing `!BG` tick-write wire goes)
- `/home/arturcastiel/projects/new-axon/axon/tests/test_output_layer_suggestions.py` + `tests/test_workflow_orchestrator_bridge.py` (existing coverage to extend/keep green)

**One-line root cause:** the footer is silent because `W:orchestrator-last-tick` is written only inside adaptive workflow runs (and cleared on completion); no boot/per-turn tap ever populates it — so on every ordinary turn the candidate count is zero and both render gates short-circuit. Fix wires one read-only `anticipate`-driven tick-write into the post-render `!BG` band and repairs the candidate shape to carry `why` + `command`.

Note: implementation requires `dev-mode` (edits touch `axon/BOOT.md` and `axon/OUTPUT-LAYER.md`, which are write-gated). This spec is design-only; no files were modified.