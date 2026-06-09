# PR-G1 — Breaker correctness: a green clears the same-change red streak (re-audit HIGH)

- **Status:** spec
- **Phase:** 3-reaudit-fixes
- **Complexity:** S
- **Depends on:** none (do first — R1 is a live BLOCK false-positive on the now-active breaker)
- **Why:** Re-audit R1 (HIGH): `autonomy_breaker.record()` zeroes `consecutive_fails` on green but leaves the
  per-change `reds` counter append-only until `reset`. Because the gate's change-id is phase-anchored (F12),
  ALL changes in a phase share one id, so `reds>=2` ("same change failed twice") really means "the 2nd
  gate-red anywhere in this phase" — and it survives an intervening green. End-to-end repro (verified by the
  re-audit through the real gate): change A reds → fix A greens → a DIFFERENT change B reds on its first
  attempt → R_AUTONOMY_BREAKER fires at BLOCK. That halts a healthy unattended run (multiple PRs, honest
  reds). Plus R4 (reset only on contract write, not the direct-CLI unattended path) and R8 (`_resolve_myaxon`
  no-pointer fallback points at parent-of-repo, not the repo sibling).

## Mechanism
- **R1:** in `record()`, the `green` branch also sets `entry["reds"] = 0` — a passing gate clears the
  same-change streak. Preserves the L1 lesson (red→red with no green still trips) and F12 (an evolving retry
  still trips) while removing the false halt (red→green→red does NOT trip).
- **R4:** the CLI `on` handler, when `--mode unattended`, resets the breaker (mirrors what
  `autonomy_contract.write` already does) so a directly-granted unattended run starts clean.
- **R8:** `_resolve_myaxon` no-pointer fallback `os.path.join(workspace, "..", "..", "my-axon")` →
  `os.path.join(workspace, "..", "my-axon")` — the repo sibling (workspace's sibling), matching
  `_myaxon_root` and the actual layout (`repo/workspace` + `repo/my-axon`).

## Acceptance criteria
1. `record` red→green→red on ONE (anchored) cid → NOT tripped; red→red (no green) → tripped; green→red→red
   (a failed fix grinding) → tripped. (R1 — the end-to-end false-positive closed + L1/F12 preserved.)
2. `autonomous_mode on --mode unattended` resets pre-existing breaker state (R4).
3. `_resolve_myaxon` with no pointer returns `<repo>/my-axon` (R8); explicit-arg + pointer paths unchanged.
4. `crucible gate` passed:true on this on-workflow changeset.

## Changes Required
### tools/autonomy_breaker.py
- `record()` green branch: `entry["reds"] = 0` alongside `consecutive_fails = 0`.
### tools/autonomous_mode.py
- `_resolve_myaxon` fallback → repo sibling (`"..", "my-axon"`).
- CLI `on` handler: if `mode == "unattended"`, `autonomy_breaker.reset(workspace)` (deferred import).
### tests
- `test_autonomy_breaker.py`: red→green→red does NOT trip (the R1 regression test); red→red + green→red→red
  still trip.
- `test_autonomous_mode.py`: `_resolve_myaxon` no-pointer fallback = repo sibling; `on --mode unattended`
  resets breaker state (or assert via the function path).

## Test plan
Targeted breaker + autonomous_mode tests; full suite + gate (parse passed SEPARATELY). No dev-mode
(tools/ + tests/ only).
