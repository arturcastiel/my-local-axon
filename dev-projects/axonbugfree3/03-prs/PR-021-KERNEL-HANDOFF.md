# PR-021 — KERNEL-FLOOR HANDOFF (HUMAN-ONLY)
project: axonbugfree3 · wave F · prepared 2026-07-13 · status: AWAITING OWNER

> These edits touch `axon/` kernel/core + `axon/programs/` — the inviolable floor.
> No grant delegates them; they are NEVER self-merged. Each hunk is exact and
> pre-verified against the current tree. Apply with dev-mode ON, then run one full
> `crucible gate` (the new envelope-bind lint + lint-path-vars scope-widening below
> are part of the verification).

---

## Context — why these are now safe / no-ops
Wave C already landed the TOOL-SIDE half of the drift fix: `drift record` accepts
`--type/--detail`, `drift refresh` exists, `check` is TTL-aware, and boot mechanically
refreshes the trace. So the kernel's drift calls (below) now RESOLVE against a live
interface — the kernel-text edits are interface-alignment/clarity, not behavior change.
The `W:ws-path` and `plan-new` edits are independent one-liners.

---

## HUNK 1 — `axon/KERNEL-SLIM.md:118` · F-H8 (prompt-log phantom workspace)
`W:ws-path` has NO writer anywhere (repo-wide grep: only local vars in two programs).
The per-turn prompt-log band passes it, so the record fail-closed skips despite consent.
Drop the flag — `prompt_log.py` defaults to the canonical `AXON_ROOT/workspace`.

    - TOOL(prompt-log, record,
    -      "--prompt {W:raw-user-input} … --workspace {W:ws-path}")
    + TOOL(prompt-log, record,
    +      "--prompt {W:raw-user-input} …")          # canonical-default workspace

Also `:322` (context-pressure gate) passes `--workspace {W:ws-path}` to `context status`
— same phantom key. Either drop it (canonical default) OR seed `W:ws-path` at boot.
RECOMMENDED: drop it, matching hunk 1.

## HUNK 2 — `axon/BOOT.md:186` · F-H9 (drift re-init guard tests existence, not staleness)
The guard's own comment (`:184-185`) promises "stale trace → next boot re-inits", but it
tests FILE-EXISTS only, so it fires at most once per trace lifetime. Wave C's mechanical
`refresh_drift_trace` (boot.py, before tick_cron) already MITIGATES this — this edit makes
the kernel TEXT match the behavior.

    - IF NOT FILE-EXISTS("workspace/working/drift-trace.json") →
    -   TOOL(drift, init, "--no-program")
    + # freshness, not mere existence — a stale trace must re-init (mirrors boot.py's
    + # mechanical refresh_drift_trace). `drift refresh` is idempotent + stale-only.
    + TOOL(drift, refresh)

## HUNK 3 — `axon/BOOT.md:196` · below-cap (anticipate inputs have no writer)
`W:recent-input` and `W:last-summary` have no writers; at boot W: is empty, so the footer
tick always ranks "". Use keys that exist.

    - ant ← TOOL(anticipate, "--input {RETRIEVE(W:recent-input) | W:last-summary | ''} --footer --top 3")
    + ant ← TOOL(anticipate, "--input {RETRIEVE(W:raw-user-input) | ''} --footer --top 3")

## HUNK 4 — `axon/KERNEL-SLIM.md:192,292,345,380` + `axon/OUTPUT-LAYER.md:129` · F-H10
The `drift record --type …` calls now WORK (wave C restored the interface) — no edit
needed for correctness. OPTIONAL clarity: `OUTPUT-LAYER.md:129`'s `drift reset` note is
still dangerous advice (reset DELETES the trace → gate unknown). Change the note to point
at `drift refresh` (stale-only repair) instead of `drift reset`.

    - TOOL(drift, reset)   ← clear per-turn drift signals (NOTE: dangerous mid-run …)
    + TOOL(drift, refresh) ← stale-only trace repair (safe; reset DELETES the trace and
    +                         forces the gate to unknown — prefer refresh)

## HUNK 5 — `axon/programs/plan-new.md:44,51` · below-cap (goal rendered after CLEAR)
`:44 CLEAR(W:plan-goal)` runs before `:51 → "Goal: {W:plan-goal}"`, so the confirmation
always shows an empty goal. Capture the goal into a local before clearing.

    Near :8, after resolving the goal:
    + goal-text ← RETRIEVE(W:plan-goal)
    …
    :51  - → "Goal: {W:plan-goal}"
         + → "Goal: {goal-text}"

## HUNK 6 — `tools/lint_path_vars.py` scope widening · F-M4 (COUPLED to hunk 1)
ONLY after hunk 1 lands (else this flags the still-present `W:ws-path` and reds the gate).
Add the kernel files to the lint's scan scope so the path-var class is caught there too.

    def _program_files():
        for base in ("workspace/programs", "axon/programs",
    +                 "axon"):   # KERNEL-SLIM / BOOT / OUTPUT-LAYER — path-var refs must resolve
            …
    (exclude axon/core/*.md + axon/compiler/*.md spec docs, as memory_key_lint does, to
     avoid illustrative-snippet false positives.)

---

## Verification (owner runs, dev-mode ON)
1. Apply hunks 1-5 (kernel + plan-new).
2. Apply hunk 6 (lint scope) — depends on hunk 1.
3. `python3 tools/lint_path_vars.py check`  → expect ok:true (W:ws-path gone).
4. `python3 tools/envelope_bind_lint.py check`  → ok:true.
5. One full `crucible gate` → 0 blocking.
6. Boot AXON → confirm the drift band live-fires (menu drift row ≠ unknown) and the
   prompt-log band records (not "prompt-log-enabled is false").

## Ledger coverage
F-H8 (hunks 1) · F-H9 (hunk 2) · F-H10 kernel-text (hunk 4, optional) · F-M4 (hunk 6) ·
below-cap BOOT:196 (hunk 3) · plan-new (hunk 5). F-H13 (chat-index) needed NO kernel edit —
wave D fixed it tool-side (index.py resolves the my-axon store); the BOOT.md:108 comment is
accurate as-is.
