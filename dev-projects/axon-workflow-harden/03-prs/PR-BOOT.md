# PR-BOOT — boot: show the exact memory-CLI form for STEP 1's identity STOREs

> Follow-on, surfaced by the "actually run the loop" validation step (my own closing critique of W5: I never
> ran the rebuilt workflow end-to-end). An instance attempting boot stalled on translating a `STORE(L:...)` op
> into a `memory` CLI call. Verified it's a real (if imprecisely-framed) robustness gap and fixed it.

> **✅ MERGED — !149 (`5e786b1`), gate GREEN (passed:true, 0 blocking, 0 warn).** Verified on main: the
> cognition-frame CLI form is in BOOT.md STEP 1, 9 boot-contract tests green. dev-mode dance clean (restored
> off; gate passed with dev-mode=false, confirming the crucible doesn't re-run check-write on the diff). Branch deleted.

- **Status:** merged !149

## The claim, vetted
Reported: *"the memory command syntax differs from the documented binding, so the boot call stopped before
state changed."* **Vetting:** the `memory` CLI works (`memory set --scope L --key … --value …`), the boot docs
use the AXON op `STORE(L:cognition-frame, "AXON-OS")`, and there is **no wrong documented CLI binding** — so the
framing is imprecise. But the SUBSTANCE holds: `axon/BOOT.md` STEP 2 pins its CLI explicitly
(`python3 tools/boot.py`), while STEP 1's **identity-critical** STOREs were given only as `STORE(...)` ops with
NO CLI form at the point of use. The agent must translate the op to a `memory` call unaided; a wrong guess
(e.g. positional `memory set L cognition-frame …`) errors and boot stalls **before the identity frame is set** —
the worst place to stall. This is the same class as the resweep "born-broken / spec-vs-executable drift" thesis.

## Fix
- `axon/BOOT.md` STEP 1: an upfront execution note showing the EXACT form for every boot STORE
  (`python3 tools/memory.py set --scope {W|L} --key <k> --value <v>`) + a "flags, never positional" warning +
  a `--help` pointer. Mirrors STEP 2's explicit CLI. The `STORE(...)` spec ops are untouched.
- `tests/test_boot_contract.py::test_step1_shows_memory_cli_form_for_the_stores` — pins the cognition-frame
  STORE's CLI form so the STEP 1↔STEP 2 symmetry can't silently regress (mirrors `test_step2_runs_tool_boot`).

## Why proportionate (not a deeper boot.py change)
`tools/boot.py` (TOOL(boot)) is a READ-ONLY context parser by design (returns JSON; the agent owns the STORE),
and boot deliberately sets the identity frame (STEP 1) BEFORE parsing state (STEP 2). So the fix is to make
STEP 1 unguessable, not to move the frame-set into the tool (which would change boot's read-only/ordering
contract). M-class deeper option deferred unless this recurs.
