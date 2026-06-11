# 99 — Kernel human-apply spec (identity-persistence durability)

> **INVIOLABLE FLOOR — DO NOT MERGE AUTONOMOUSLY.** Every change below edits a file under `axon/`
> (the OS kernel). Per Core Rule 9/10 + the AEGIS policy + the autonomous-mode grant (all three deny
> `kernel-change`), these require `L:dev-mode ≡ true` and a human to apply + re-state the command.
> This document is the prepared, ready-to-apply spec the owner asked AXON to "prepare a solution" for.
>
> Context: produced by the `axon-resilience` study (01-study.md, Track B / owner principle 5). The
> NON-KERNEL parts ship in PR-2 (self-care program, `startup.md` probe glob, `UserPromptSubmit` hook
> install, harness self-check). What remains here is the part that makes identity persistence *durable
> + enforced* rather than advisory — and that lives in the kernel.

---

## Why these three changes (the gap PR-2 can't close)

The identity **contract** already exists in the kernel (IDENTITY, the 8-clause identity-contract,
identity gate, coherence guardian) and a re-anchor **program** already exists
(`workspace/programs/axon-reanchor.md`). PR-2 installs the per-turn `UserPromptSubmit` hook so "you are
AXON" is re-injected every turn. But two enforcement seams remain kernel-only:

1. There is **no mandatory, machine-detectable per-response identity signature**, so a Stop hook cannot
   mechanically catch a response that drifted out of character. `setup-persona.sh` Step 3 deliberately
   skips installing the Stop hook for exactly this reason ("your startup file does not currently
   prescribe a signature").
2. The re-anchor program is **not auto-fired at the compaction/turn boundary** — both `axon-reanchor.md`
   and `autonomy-reanchor.md` explicitly defer that wiring as "kernel-touching."

Closing these makes "becomes AXON, not a persona" *enforced*, not merely re-asserted.

---

## CHANGE 1 — Mandate a required per-response identity signature (enables the Stop-hook drift catch)

**Files:** `axon/OUTPUT-LAYER.md`, `axon/KERNEL-SLIM.md` (response gate).

**What:** The output layer already emits a footer (`▸ AXON …` per `axon/OUTPUT-LAYER.md`). Promote it
from cosmetic to a **required, stable, machine-detectable marker** and enforce its presence at the
response gate.

- In `axon/OUTPUT-LAYER.md`: declare a canonical signature token that MUST appear in every rendered
  response footer (e.g. a zero-width-safe literal like `⟦AXON⟧` or the existing `▸ AXON` prefix promoted
  to mandatory). Specify it is emitted in ALL footer modes (compact|full|minimal) — minimal currently may
  omit it; minimal must still carry the bare marker.
- In `axon/KERNEL-SLIM.md` COMPLIANCE ENFORCEMENT → Response gate: add a new rule, e.g.
  **`R_IDENTITY_SIGNATURE`** (BLOCK-capable, opt-in via `L:identity-signature-required`, same shape as
  the existing `R_REASONING_TRACE` / `R_COHERENCE`): the pending output MUST contain the canonical
  signature token, else `LOG(ERROR, "identity-signature missing")` + HALT + re-render.
- This is what lets the host **Stop hook** (`verify.py output`, installed by
  `scripts/enable-enforcement.sh` / `setup-persona.sh` Step 3) fire `exit 2` when the marker is absent —
  turning drift detection from advisory into mechanical, exactly as the "Enforcement reality" note in
  KERNEL-SLIM anticipates.

**Test (add under dev-mode):** `tests/test_identity_signature.py` — (a) `verify.py output` with a marker
present → pass; (b) absent → exit nonzero; (c) all three footer modes include the marker.

**Risk:** Low-moderate. The marker must be chosen so it never collides with normal prose and survives
translation. Roll out as WARN (`L:identity-signature-required` unset) first, promote to BLOCK after a
session of observation.

---

## CHANGE 2 — Auto-fire `axon-reanchor` at the compaction / turn boundary

**File:** `axon/BOOT.md` (dispatch flow) — and a one-line capability note in `axon/KERNEL-SLIM.md`.

**What:** Today the `UserPromptSubmit` hook (PR-2) re-injects a reminder, but the kernel does not itself
*run* `axon-reanchor` when it detects a fresh/compacted context. Add to the boot/turn dispatch:

- On turn entry, if `L:cognition-frame ≠ "AXON-OS"` OR `W:reasoning-mode ≠ "kernel-ops"` (the
  compaction-cleared signal the kernel already checks every 5 turns via G-02), **auto-`EXEC(axon-reanchor)`
  before routing the user input**, rather than only restoring the two keys.
- Document the hook contract in `axon/BOOT.md`: the host `UserPromptSubmit` mechanism (PR-2) is the
  *trigger*; `axon-reanchor` is the *handler*; the kernel owns the decision to fire it.

**Test:** `tests/test_reanchor_autofire.py` — simulate `L:cognition-frame` unset → assert the dispatch
path selects `axon-reanchor` before the user program.

**Risk:** Low. `axon-reanchor` is read-only (re-loads kernel + restores frame). Worst case is one extra
re-anchor per fresh context.

---

## CHANGE 3 (optional) — Fail-closed persistence gating at boot

**File:** `axon/BOOT.md` (boot contract). **Only if the owner wants boot to HALT when persistence is
absent** (stronger than the current non-blocking probe).

**What:** The NON-KERNEL fix in PR-2 makes `startup.md` Step 0 probe `axon*.md` (cosmetic — stops the
false MISSING). If instead persistence should be a *hard precondition* — boot refuses to proceed until the
`UserPromptSubmit` re-anchor hook verifies installed — that gating belongs in the kernel boot contract:

- In `axon/BOOT.md`: after harness detection, assert the declared `L:host-cap-reanchor` mechanism is
  actually wired (re-using the self-check `self-care` performs in PR-2); if not, `HALT` with the
  `setup-persona.sh` install instruction instead of continuing in degraded mode.

**Test:** `tests/test_boot_persistence_gate.py` — fixture with/without the hook → boot proceeds / HALTs.

**Risk:** Moderate — a fail-closed boot can lock the owner out on a fresh machine before the installer
runs. Recommend keeping this OPT-IN behind `L:persistence-fail-closed` (default false). The PR-2
non-kernel probe-glob fix is sufficient for the common case; this is only for maximal strictness.

---

## Apply procedure (owner, under dev-mode)
1. `dev-mode`  (enable `L:dev-mode ≡ true`).
2. Re-state the intent (Core Rule no-queue: the gate refusal is never queued; the command must be re-stated).
3. Apply CHANGE 1 → CHANGE 2 → (optional) CHANGE 3, each with its test.
4. `python3 tools/crucible.py gate` green → commit (trailer `Co-authored-by: AXON <axon@arturcastiel.github.io>`).
5. `dev-mode off`.

## Ordering vs PR-2
PR-2 (non-kernel) ships first and is independently valuable (persistence installed, self-care live,
probe fixed). This kernel spec is the durability upgrade layered on top — it makes the persistence PR-2
installs *enforced at the response boundary* rather than re-asserted by reminder alone.
