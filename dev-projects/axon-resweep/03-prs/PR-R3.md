# PR-R3 — [HIGH] R9 axon/-write gate: enforce in a fresh clone / pre-boot (H1)

- **Status:** spec
- **Phase:** 1-fixes  ·  **Complexity:** M  ·  **dev-mode:** no (tools/hooks/)  ·  **Depends on:** none
- **Why / detail:** 01-study.md H1 (HIGH). The PreToolUse hook gated R9 behind `_axon_active()`, which reads
  the GITIGNORED `cognition-frame.md` — absent in a fresh clone / CI / pre-boot — so the only mechanical
  enforcer of "axon/ writes need dev-mode" short-circuited to allow-all. Proven by the sweep.

## Mechanism
`main()`: run the R9 `check-write` gate for any write target FIRST (identity-independent — `enforce.py
check-write` no-ops for non-axon/ targets, so it only ever gates real axon/ writes), then keep the dont-do
enforcement behind `_axon_active` (persona-scoped — a plain session is otherwise untouched, but R9 still
protects axon/).

## Acceptance
1. axon/ write + `_axon_active`=False (fresh clone) + dev-mode off → BLOCKED (exit 2). Was exit 0.
2. The R9 check-write is invoked regardless of persona (runs before the `_axon_active` gate).
3. Non-write tool (no target) → exit 0; non-axon/ write in a plain session → allowed (R9 no-ops). Existing
   `target_path` / `dont_do_violation` direct-unit tests unaffected.
4. `crucible gate` passed:true.

## Changes
- `tools/hooks/enforce_pretooluse.py` `main()` — reorder (R9 before persona); dont-do behind `_axon_active`.
- `tests/test_hooks.py` — two main() control-flow tests (R9 enforced when not-AXON; R9 runs before persona).

## Test plan
test_hooks.py + test_dont_do_write_time.py (confirm no regression) + full suite + gate. No dev-mode.
