# PR-T2-anchor — Pin the R9 anchor to the .axon-governed sentinel (close the AXON_ROOT bypass)
status: LANDED   # code 781463a + test-contract 3497235 both committed on fix/wave-g-residual-hardening; not yet merged to main
wave: 2 (security floor, pulled into Wave 0b — protect-before-arm)
findings: arch-audit M4 (red-team), plan-review/00-plan-audit.md
depends: none

## Goal
Close the live one-line R9 write-gate bypass the catalog-persona red-team found: with shell access an
agent runs `AXON_ROOT=/tmp <tool>` and the R9 path classifier believes the real kernel is "outside axon/"
→ a write to KERNEL-SLIM.md is ALLOWED with dev-mode OFF (verified: is_axon_path(kernel) → False).

## Change
- tools/_axon_paths.py `_resolve_axon_root`: the on-disk file location is the tamper-resistant anchor.
  An `$AXON_ROOT` override is honoured ONLY when it carries the tracked `.axon-governed` sentinel (a real
  governed checkout — boot/CI/federation still work). A sentinel-less env is rejected with a warning and
  falls back to the file root.

## Acceptance / Test
- tests/test_axon_path_unified.py: `AXON_ROOT=/tmp` must NOT relocate the anchor (is_axon_path(kernel)→True);
  a sentinel-bearing dir IS honoured.
- tests/test_tools_kernel.py: `test_env_override_takes_precedence` updated to the new secure contract
  (governed override honoured) + `test_env_override_without_sentinel_rejected` (rejection).
- Full suite green (4708 passed); crucible gate green.

## Constraints
- No KERNEL-SLIM edits. AXON-only commit trailer. Tests-in-change (Core Rule 13).

## Status notes
- Code change landed 781463a on fix/wave-g-residual-hardening (off-workflow — anchored retroactively by
  this spec). The test-contract fix (test_tools_kernel.py) landed 3497235.
- 2026-06-22: marked LANDED + DAG status=complete. Remaining: merge fix/wave-g-residual-hardening → main
  (human), confirm full suite + crucible green at merge.
