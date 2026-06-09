# PR-2C — kernel/program defaults: context-pressure gate, igap type, drift-icon, inference default

- **Status:** merged (!137, ae1ab7d)
- **Phase:** 2-reaudit-fixes  ·  **Complexity:** M  ·  **dev-mode:** yes (scoped: axon/KERNEL-SLIM.md +
  OUTPUT-LAYER.md; restored off)  ·  **F50:** v1.1.5→v1.1.6 + lock  ·  **Depends on:** none
- **Source:** re-MEGA findings — F-KCTX, F-IGAPTYPE, F-DRIFTICON, F-INFDEFAULT (each grounded against the real
  context/igap/drift CLIs before fixing).

## Fixes
- **F-KCTX** (KERNEL-SLIM.md:307-321) — the context-pressure gate read `pressure.level/.pct/.tokens`, but
  `context status` returns `{pressure, percent, accumulated_tokens}` → the checkpoint-before-token-limit gate
  was DEAD (never fired). Now keys on `ctx-p.pressure` / `ctx-p.percent`. DROPPED the "Record pressure" line:
  it fed the undefined `pressure.tokens` (errored) and `context record` ACCUMULATES (`+= args.tokens`), so
  re-recording the accumulated total each phase would double-count.
- **F-IGAPTYPE** (KERNEL-SLIM.md:273) — `igap record --type missing-route` is not in VALID_TYPES
  {low-confidence, semantic-search, fallback-exec, absent-instruction} → always failed (silent, !BG). The
  find-program routing-gap → `semantic-search`.
- **F-DRIFTICON** (OUTPUT-LAYER.md:43) — drift-icon keyed `drift.status`; the drift gate returns `state` (as
  the rest of the file uses). → `drift.state`.
- **F-INFDEFAULT** (no dev-mode) — orchestrator.md:53 OBSERVE default was `| 5` while the canonical default
  (KERNEL-SLIM:45 + the K1 footer) is 3 → `| 3`; and 3 hand-written AXON-DOCS (ARCHITECTURE/CHEATSHEET/
  WORKFLOWS) said "default 5" → "default 3". (Other `5`s are label-maps / the `5≡balanced` branch /
  recommended-lists — correct, untouched.)

## dev-mode + F50 discipline
- Scoped dev-mode: enabled L:dev-mode ONLY for the 2 axon/ edits (verified `enforce check-write` allowed →
  edited → restored false, verified blocked again). orchestrator + AXON-DOCS + tests edited with dev-mode off.
- F50: bumped `AXON v1.1.5`→`v1.1.6` + updated EXPECTED_VERSION/EXPECTED_SHA256 (sha f675bd65…) in the lock test.

## Acceptance
1. Content-locks: orchestrator/docs default 3; KERNEL-SLIM ctx-p.pressure/.percent (no pressure.level/.pct/
   .tokens, no "Record pressure"); igap semantic-search; OUTPUT-LAYER drift.state. [test_resweep_program_subcommands.py]
2. F50 lock green (version 1.1.6 + sha). [test_kernel_version_lock.py]
3. `crucible gate` passed:true.

## Changes
- `axon/KERNEL-SLIM.md` · `axon/OUTPUT-LAYER.md` · `workspace/programs/orchestrator.md` ·
  `workspace/AXON-DOCS-ARCHITECTURE.md` · `-CHEATSHEET.md` · `-WORKFLOWS.md` ·
  `tests/test_kernel_version_lock.py` · `tests/test_resweep_program_subcommands.py`
