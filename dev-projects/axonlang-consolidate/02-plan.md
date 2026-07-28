# Plan — axonlang-consolidate (lead-fixes)
Updated: 2026-07-14 · one wave, 6 fixes, yield-per-effort order B1→B6. All non-kernel.
Source: VERIFY-FINDINGS.md (R4 verification of the 4 quarantined run-3 leads).

## Wave 1 — the lead fixes
B1 gc-gate canonical reader (destructive-path hazard, ~5 lines) · B2 binding-liveness roots (~3 lines) ·
B3 hr-team persistence + events (.md, 2 edits + event collection) · B4 hr_team cwd _axon_paths + fail-closed
parse · B5 registry purpose/args WARN + string fixes · B6 stale comment. Each ships tests; full gate before push.
