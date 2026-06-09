# PR-W5a — workflow runner: per-lap sub-run-ids + collision-safe trajectory paths

> **✅ MERGED — !146 (`ec956f7`), gate GREEN (passed:true, 0 blocking, 0 warn).** Verified on main: per-visit
> hooks + hashlib + the 10-test file present. Branch deleted. 2 files / +150/−6.

- **Status:** merged !146
- **Phase:** 2-harmonize · **Complexity:** M (deterministic runner layer) · **dev-mode:** no · **First of the W5 rebuild.**

## What W5a does (the runner MECHANISM — additive, opt-in, default behavior unchanged)
- **M1 · collision-safe trajectory paths.** `_traj_path` derived the filename by a non-injective sanitize
  (`re.sub(r"[^A-Za-z0-9_.-]","_")`) — `::`-composed nested ids at depth ≥3 (and any `_`/punct ids) could collapse
  onto ONE file and cross-contaminate. Now appends a short stable sha1 of the FULL run-id; readable prefix kept.
- **C2/C3 · per-lap sub-run-ids.** `_sub_traj_run_id` / `sub_workflow_completed` / `advance` take an optional
  `visit` index (`advance` CLI: `--parent-visit`) that suffixes `::v{n}`. A LOOPING parent node re-enters its
  sub-node each lap; the bare `{parent}::{node}::{sub}` id collided across laps → lap-2 appended to lap-1's
  terminated trajectory (corruption, C3) AND lap-1's stale terminal satisfied the guard (skip, C2). Per-lap ids
  give each lap its own trajectory so the teeth bite every lap. `visit=None` reproduces the exact pre-loop id, so
  every existing single-pass nested run is untouched (29 backward-compat tests confirm).

## Why a separate PR (and what's deferred)
- The per-lap **mechanism** is unit-testable in isolation (10 tests: distinct ids, lap-1 ≠ satisfies lap-2,
  advance blocks lap-2 until its own sub runs, M1 depth-3 no-collision, path-traversal still safe). Landing it
  first keeps the security-critical teeth reviewable on their own.
- **Deferred to W5b:** the `workflow-run.md` WIRING that computes the per-lap visit index (count of visits to the
  looping node) and threads it into both the child run-id (`::v{n}`) and the `advance --parent-visit` call — it
  lands with the loop it serves (the multiple-code-dev meta-workflow). M2 (explicit terminal + lint) → W5c
  (hardening), as it is a schema+migration change, not required for the loop to run.

## Acceptance
1. Per-lap ids distinct; lap-1 completion does NOT satisfy lap-2; advance blocks lap-2 until its sub runs. ✓ (10)
2. M1: distinct ids → distinct files (depth-3 no collision); path-traversal still contained. ✓
3. Backward-compat: visit=None == legacy id; all nested/antiskip/runner tests green. ✓ (29 + 571 broad)
4. `crucible gate` passed:true. — pending

## Changes
- `tools/workflow_run.py` (import hashlib; `_traj_path` hash; `_sub_traj_run_id`/`sub_workflow_completed`/`advance`
  + the `advance` CLI gain optional `visit`/`--parent-visit`) · `tests/test_workflow_loop_antiskip.py` (new, 10)
