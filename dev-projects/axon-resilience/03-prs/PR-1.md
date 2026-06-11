# PR-1 — Cron↔tool `--workspace` contract robustness (fix 2 silent failures + gate the class)

> Phase 4-execute · effort M · depends: None · branch: axon-resilience/pr-1-cron-contract

**Status:** ✅ MERGED — origin/main f99f5f8 (MR !150, squash). Full crucible gate GREEN (25 controls, 0 blocking, 0 warnings; 4566 tests). cron-conformance 11/11 live on main; AXON-DOCS regenerated. Gate-feedback fixups (F21 sys.path / F58 count / F22 registry-literal) folded in before merge.

## Objective
The cron runner injects `--workspace <ws>` into every job (leading placement, with a trailing
retry for multi-token CLI jobs). Two jobs failed silently against that contract and only surface
when the breaker nears tripping. Point-fix both AND add a systemic merge-time gate so the whole
bug-class (invalid subcommand / `--workspace` accepted nowhere / single-token trap) is caught at
the seam instead of rotting until a weekly cron fails repeatedly. (Owner principle 4 — scalable.)

## Files touched
- `workspace/scheduler/cron.json` — A1: job `axon-dispatch-stats` program `dispatch-stats weekly`
  → `dispatch-stats summary` (`weekly` is not a valid subcommand: summary|savings|precision).
- `tools/freshness.py` — A2: add `--workspace` to the TOP parser (`default=default_workspace()`,
  absolute) so cron's leading injection parses; thread the resolved ws into the two
  `programs_registry.py` callsites + `_retrieval_index_fresh`; `check(ws=None)`/`refresh(ws=None)`
  default so the in-process API + manual no-arg form stay unchanged.
- `tools/cron_conformance.py` — NEW. Proves every cron job satisfies the contract: reuses
  `cron.py._build_job_cmd` (can't drift from the runner) and probes each placement with `--help`
  (side-effect-free). `check` (BLOCK gate, exit 1 on violation) + `report` (per-job table).
  Classifies B1-tool-unresolved / B2-subcommand-invalid / B3-workspace-unacceptable / single-token-trap.
- `tools/cron.py` — refresh the now-stale `_build_job_cmd` placement comment (freshness migrated to
  top-parser; deprecation-log is the remaining subparser-only tool) + point at the new gate.
- `tools/REGISTRY.json` — register `cron-conformance` (ACTIVE, kernel).
- `tools/crucible.json` — add `cron-conformance` as a BLOCK static control.
- `tests/test_cron_conformance.py` — NEW (8 tests): live cron.json conforms; healthy-leading;
  B2 on `dispatch-stats weekly`; trailing-retry rescue; path-form present/missing; empty; CLI exit 0.
- `tests/test_freshness.py` — +2 regression tests: leading `--workspace` parses (`check`/`refresh`);
  `check(ws)` accepts an explicit path and defaults.

## Approach
A1 is a one-line config correction. A2 follows house style (`programs_registry`/`dispatch_stats`
both put `--workspace` on the top parser with `default=default_workspace()`) — verified
`programs_registry` accepts an absolute `--workspace` (rc 0). The conformance gate is the load-bearing
piece: it operationalizes the contract `cron.py` only documents, so a future job with a bad subcommand
or a `--workspace`-less tool is BLOCKED at merge. `--help` exploits argparse short-circuiting to test
PARSE success without running any job action (verified compile's passthrough errors cleanly without
running `rank`).

## Gate (what proves it landed)
`python3 tools/cron_conformance.py check` exit 0 (11/11 conform) · `tests/test_cron_conformance.py` +
`tests/test_freshness.py` green · full `crucible.py gate` passed:true with the new BLOCK control active ·
commit trailer lint clean.

## Tests
- tests/test_cron_conformance.py (8) · tests/test_freshness.py (regression +2) · crucible changeset (R_NEW_NEEDS_TEST satisfied by test_cron_conformance.py).

## Rollback
Additive + one config line + one freshness signature change (back-compatible defaults). Revert by:
drop the crucible control, delete cron_conformance.py + test_cron_conformance.py, revert freshness.py /
cron.py / REGISTRY.json / cron.json. No kernel edit, no schema change.

## Risk
Low. cron-conformance is BLOCK but verified 11/11 conform on the current tree, so it cannot red an
otherwise-green gate; it only fires when a real contract violation is introduced — which is the point.
