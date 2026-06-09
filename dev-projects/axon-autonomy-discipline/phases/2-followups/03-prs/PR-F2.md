# PR-F2 — Breaker: wire the recorder, run-scoped reset, intent-keyed change-id

- **Status:** spec
- **Phase:** 2-followups
- **Complexity:** M
- **Depends on:** PR-F1 (breaker now WARN, so wiring the recorder can't brick the gate while we validate)
- **Why:** The audit's CRITICAL finding (F1): `autonomy_breaker.record()` has **zero non-test callers**, so
  the breaker state is always empty and `R_AUTONOMY_BREAKER` can never trip — a hollow rule. Plus F12 (the
  change-id is a hash of sorted paths, so an *evolving* retry that adds one file gets a new id → the
  same-change-red breaker never trips) and F13 (`consecutive_fails` resets only on an explicit green and
  `reset()` has no caller → stale cross-run accumulation → false halts once the recorder lands). This PR
  makes the breaker actually observe the gate, keyed on intent, scoped to a run.

## The shared prerequisite — an "autonomous run" marker (F3 reuses it)
Both the recorder (F2) and the cadence (F3) must act ONLY during an *unattended autonomous run*, NOT during
interactive dev that merely holds a grant (audit F3: the live grant is "full dev loop" = interactive). So
F2 introduces the marker both will use:

- **Signal:** `autonomous_mode.run_active(myaxon)` → True iff the grant is active AND marks an unattended
  run. Concretely: the grant JSON gains a `"mode"` field — `autonomy-contract` writes `mode:"unattended"`
  for a full-auto/overnight contract and `mode:"interactive"` (or omits it) otherwise. `run_active` returns
  `grant.get("active") and grant.get("mode") == "unattended"`. Back-compat: a grant with no `mode` →
  interactive (False) — so the LIVE grant does NOT trip the recorder, exactly right.
- This is the minimal, honest version of the deferred "operate-loop signal": no dispatch.py change, no
  orchestrator — just a truthful flag the contract sets and the rules read.

## Changes Required
### tools/autonomous_mode.py
- Add `run_active(myaxon) -> bool` (active AND `mode=="unattended"`). Thread an optional `mode` through
  `grant_on`/`write` so the contract can set it; default/back-compat = interactive.
### tools/autonomy_contract.py
- When the chosen level is the unattended/full-auto tier, pass `mode="unattended"` into the grant; else
  interactive. (Ties the marker to the powers interview — you only get recorder+cadence enforcement when you
  actually start an overnight run.)
### tools/autonomy_breaker.py
- `change_id`: key on the **active PR/phase** (intent), not the exact path set. New signature
  `change_id(changed, *, anchor=None)` — when `anchor` (e.g. the active phase id) is given, hash THAT;
  else fall back to sorted paths (back-compat for existing callers/tests). Doc the intent.
- Ensure `reset()` is reachable + add a `run_id`-scoped guard so consecutive-fails can't bleed across runs:
  record the active run/phase alongside the counter; on a new run/phase, auto-reset.
### tools/crucible.py — `run_changeset` (the wiring, the heart of F2)
- After the blocking/verdict is computed, and ONLY when `autonomous_mode.run_active(<myaxon>)`:
  compute `cid = autonomy_breaker.change_id(changed, anchor=<active phase>)` and
  `autonomy_breaker.record(<ws>, cid, "red" if blocking else "green")`. Green on every pass (resets the
  consecutive counter — F13); red on every block (twice-red on the same anchor trips — F1/F12).
- Resolve `<myaxon>`/`<ws>`/`<active phase>` via the canonical resolver (NOT a hardcoded path — anticipates
  F4; if F4 lands first, reuse its helper).

## Acceptance criteria
1. `run_active` is True only for an active **unattended** grant; the live interactive grant → False (assert).
2. With an unattended run active, two RED gates on the same active phase (even with different files the 2nd
   time) → breaker tripped on the 2nd (END-TO-END through `run_changeset`, not hand-fed state) — closes F12.
3. A GREEN gate records green → `consecutive_fails` reset to 0 (F13). A new run/phase auto-resets (F13).
4. Interactive run (no unattended marker) → `run_changeset` records NOTHING (no accumulation in attended dev).
5. `crucible gate` `passed:true` on this PR's own on-workflow changeset (parsed separately).

## Test plan
New end-to-end test driving `run_changeset` twice with an unattended grant + a stub gate result, asserting
the breaker trips the 2nd time (the test that would have caught F1). Unit tests for `run_active`, the
anchored `change_id`, and run-scoped reset. Full suite + gate green. Likely **dev-mode NOT needed**
(tools/ + tests/ only) — confirm no `axon/` write.

## Risk / sequencing note
F2 touches `crucible.py` `run_changeset` — the gate's spine. The recorder is strictly *additive* and
*guarded* (`run_active` False in every current context → no behavior change today), so it can't regress the
live gate. The breaker rule is WARN (PR-F1) throughout F2, so even a mis-wire can't BLOCK. F6 re-flips to
BLOCK only after the end-to-end test proves it trips for real.
