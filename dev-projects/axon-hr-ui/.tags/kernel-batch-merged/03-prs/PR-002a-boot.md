# PR-002a-boot — enforcement-posture line in the boot banner (KERNEL)
Status: merged
Phase: pr
Lane: SHARED — AXON builds + stages → OWNER runs ship.sh (kernel merge = inviolable floor)

## Problem
AXON's gates (R7, R_COHERENCE, write-gate, …) are BLOCK-capable but only BITE when a host hook runs the
verifier each turn AND the per-rule activation flags are set. Until then they run by agent discipline
(advisory). Nothing at boot tells the operator which posture is live — so "enforced" reads as "cannot be
bypassed" when it actually can. Class-1 safety: that overstatement must never appear.

## Approach (kernel — axon/BOOT.md STEP 4 banner)
Add one honest posture line, sourced from `verify status`:
- `activation_flags_on_disk ≠ {}` → "gates BLOCK · halt: <mode>".
- else → "advisory — gates LOG, they do not block (no activation flags / hook)".
Never imply gates cannot be bypassed when advisory. Sourced from live state, not a hardcoded label.

## Files (KERNEL — owner merges)
- `axon/BOOT.md` (STEP 4 banner: posture line from verify status)

## Acceptance
- Boot banner shows the live enforcement posture (advisory now — activation_flags_on_disk is empty).
- No "cannot be bypassed" wording. Full crucible green.
- STAGED on branch `axon-hr-ui/PR-002a-boot`; OWNER runs `ship.sh axon-hr-ui/PR-002a-boot` (kernel floor).

## Notes
Kernel edit — dev-mode permits the WRITE; the MERGE is human-only. AXON stops at a green branch + HALT.
