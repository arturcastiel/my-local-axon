# 04 — Implementation log + decisions (axon-resilience)

> Phase 4-execute · 2026-06-09 · both PRs merged to origin/main (TNO GitLab), each gated on a green crucible.

## PR-1 — Cron↔tool `--workspace` contract robustness  ·  MERGED f99f5f8 (squash f337a99, MR !150)
**Built (vs plan): as specced, no divergence.**
- A1: `workspace/scheduler/cron.json` `axon-dispatch-stats` `dispatch-stats weekly` → `summary` (invalid subcommand).
- A2: `tools/freshness.py` — `--workspace` on the top parser (`default=default_workspace()`), threaded through the
  `programs_registry` callsites + `_retrieval_index_fresh`; `check(ws=None)`/`refresh(ws=None)` defaults keep the
  in-process API + manual form unchanged.
- Systemic: `tools/cron_conformance.py` (NEW) — reuses `cron._build_job_cmd`, `--help`-probes each placement
  (side-effect-free); BLOCK control in `tools/crucible.json`. 11/11 jobs conform. Stale `cron.py` comment refreshed.
- Tests: `tests/test_cron_conformance.py` (8) + `--workspace` regression in `test_freshness.py`.
- **Gate-feedback fixups before merge:** F21 (removed per-file `sys.path.insert` — rely on script-mode, since
  `axon.py` dispatches tools as subprocesses), F58 (`CONTEXT.md` tool count), F22 (dropped the `REGISTRY.json`
  literal from a hint string), regenerated `AXON-DOCS.md`.

## PR-2 — Self-care + identity persistence (non-kernel)  ·  MERGED b55c85f (MR !151)
**Built (vs plan): added a program wrapper that was not in the original plan — see DECISION 3.**
- `tools/self_care.py` + `workspace/programs/self-care.md` — read-only sweep (health + freshness + cron + drift +
  igap) + persistence self-check (verifies the host re-anchor wiring is installed). `check`/`report`/`--heal`.
- `startup.md` Step 0 probes `axon*.md` (glob) instead of literal `axon.md` (kills the false MISSING under the
  `axon-dev`/`axon-use` chooser).
- `workspace/harness/claude-code.md` — `L:host-cap-reanchor` points at self-care as its verifier.
- Tests: `tests/test_self_care.py` (5). 157 tools / 137 ACTIVE; CONTEXT.md + AXON-DOCS + program registry regen.
- **Machine config (not a repo commit):** installed the missing `UserPromptSubmit` re-anchor hook + hardened
  reminder in `~/.claude` — the decisive "becomes AXON every turn" fix. Reversible (backup + tagged block).

## Decisions (ADR)
1. **Fix the bug-class, not just the two jobs.** A merge-time `cron-conformance` BLOCK gate turns the silent
   cron-failure class into a gate failure at the seam (owner principle 4, scalable). Chosen over point-patching
   the two jobs alone.
2. **Inviolable kernel floor honored.** The durable-enforcement half of identity persistence (signature-gated Stop
   hook, compaction-boundary auto-reanchor, optional fail-closed boot) edits `axon/` — prepared as `99-kernel-spec.md`
   for human apply under dev-mode, never auto-merged. Everything else shipped non-kernel.
3. **`self-care` got a program wrapper.** `R_NO_ORPHAN_TOOLS` (BLOCK) requires a new ACTIVE tool be invoked by the
   system, not merely registered + tested. The thin `workspace/programs/self-care.md` wrapper (the `health-check.md`
   pattern) wires it and makes `self-care` a first-class menu command — better than the original "tool only" plan.
4. **Verbose-by-default tests.** Owner directive mid-run: run `pytest -v` streamed, not buffered+re-run. The crucible
   gate buffers pytest, so for live verbosity stream `pytest -v` to a file and tail it.

## Memory persisted (owner: "memory should also be added to code-dev and axon")
- AXON agent-memory **general** (boot-loaded): cron↔tool `--workspace` contract bug-class + gate; identity-persistence
  principle + the install/decay-detection mechanism.
- AXON agent-memory **project** (`axon-resilience`): the A1/A2 specifics, the gate-feedback lints, the kernel handoff.
- `L:cron-contract-conformance-gate` (informational flag); `E:session-log` trail entry.
- This `04-log.md` + `_events.log` (the code-dev ledger).
