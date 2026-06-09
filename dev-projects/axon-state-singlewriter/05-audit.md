# Phase 5 — Completion Audit · axon-state-singlewriter (F43/F44)

> Date 2026-05-30, main `f0ce399`, gate 22/0. The riskiest of the five projects (storage-layout change
> + migration). Verdict: **complete and safe.**

## Verdict
**Both findings closed; the migration is non-destructive.** Confidence **8.5/10** (deduction: the
legacy-snapshot migration heuristic — label+timestamp+keys identifies a snapshot — is a heuristic, not
a proof; chosen conservatively so a real W: json is never moved, verified by test).

## Coverage
- **F43 (single L: writer):** ✅ complete. One atomic writer in _longterm; both (and only) writers
  delegate; byte-identical parity test; delegation lock. No stragglers found in a full tools/ scan.
- **F44 (JSON W: capture + no conflation):** ✅ complete. `.json` W: state is captured + round-trips on
  restore (was silently lost); snapshots live in `working/.snapshots/` so `list`/`_read_working` no
  longer treat real W: json (intent-queue, crucible-last) as checkpoints; legacy snapshots auto-migrate.

## Migration safety (the flagged risk)
- **Non-destructive:** `os.replace` moves snapshot-shaped files into `.snapshots/`; real W: json stays.
  Idempotent (runs before every save/restore/list/replay). Test `test_real_json_state_is_not_migrated`
  proves crucible-last.json is left alone.
- **No orphaning:** `_resolve_snap_path` falls back to a legacy `working/<label>.json` if migration
  somehow didn't move it, so no label becomes unreachable.
- **Back-compat:** old bare-key snapshots restore as `.md` exactly as before; the 14 pre-existing
  checkpoint tests still pass unchanged (bar one path assertion updated for the new location).

## Honest notes
- One branch-first incident on PR-2 (committed on main, recovered cleanly — origin never polluted).
- The migration heuristic is conservative by design; if a future real W: json ever carried
  label+timestamp+keys it could be misclassified — acceptable given how unlike real W: state that is,
  and bounded (it would just move into .snapshots/, recoverable).
