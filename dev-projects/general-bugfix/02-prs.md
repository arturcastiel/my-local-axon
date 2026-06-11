# PR list / DAG — general-bugfix

Each PR = a fix + its paired guard (WARN→BLOCK). `[crit]` = fixes a critical bug. Deps are hard prerequisites.

## Step 0 — foundation
- **PR-0a · `lint_path_vars` (WARN)** — deps: none.
  New `tools/lint_path_vars.py`: every `W:ws-*`/`W:myaxon-*` reference in programs must be STORE-defined in
  WORKSPACE.md/MYAXON.md; flag undefined/dead path-vars. Crucible control (WARN). Test + Guarded-by. *(covers T3)*
- **PR-0b · scoped conformance flag-lint (WARN)** — deps: none.
  New `tools/program_tool_conformance.py` (flag side only): live `axon.py <tool> <sub> --help` introspection,
  **scoped to workflow/cron/conversational call-sites** (not a 157-tool sweep). Reuses `cron_conformance` helper.
  Crucible control (WARN). *(covers C2-flag, C4/C5 flag, shadow-init class)*
- **PR-0c · COMPILED-MIRROR KILL: decouple + verify** — deps: none.
  Rebuild the dispatch index from program SOURCE (name+description), independent of compilation; **verify
  `dispatch.match` reproduces from source** (regression test). No deletes yet.
- **PR-0d · COMPILED-MIRROR KILL: delete** — deps: PR-0c.
  `rm workspace/programs/compiled/` (45 `.cmp.md`) + the 5 compile tools + their ~4 test files; retire the
  compiled-coverage tripwire + freshness check **in lockstep**; drop `prefer-compiled`; update docs/registries.
  `run.py` STAYS. *(closes the §I largest prevention hole; reduce-surface)*

## Wave 1 — highest-value criticals
- **PR-1 · T2 workflow tool-contract** `[crit C2]` — deps: PR-0b.
  Repo-wide `predicate.eval .value→.result` sweep; fix synapse-suggest shape (`.candidates/.rank`→`name/score`)
  + `--state` file usage; `workflow-new` APPEND→STORE; validate error-count guards; fold `workflow-simulate`
  into `workflow-run --dry`. Promote the conformance lint to **BLOCK** for workflow call-sites. *(restores all workflow gating)*
- **PR-2 · T3 conversational subsystem** `[crit C3,C4,C5]` — deps: PR-0a.
  Repoint chat/plan/library `W:ws-*`→`W:myaxon-*` with loud ASSERT guards; delete `mode-router`'s false
  "not wired" comments + wire `new-chat`/`plan-new`; **restore `menu.md`'s mode-hints dict + modes [1]–[5]**;
  fix the plan `completed` token; pick ONE thread system. Promote `lint_path_vars` to **BLOCK**.

## Wave 2 — core loop + contracts
- **PR-3 · T1 phase-model unification** `[crit C1]` — deps: none (sequence after Wave 1 for value).
  Collapse `phases/{name}/` onto `_phases.json`/`phase_model`; **seed `_phases.json` in `code-dev-new`**; unify
  `new/start/list/done/back/skip` into one driver; one canonical phase vocabulary; retire the directory-SCAN.
  Guard: a phase-id ⇄ meta.phase consistency check. *(fixes broken done/back/skip + all-pending dashboard + metrics=0)*
- **PR-4 · T4 PR-spec + review contract** — deps: none.
  Pin ONE PR-spec heading/status schema (writer + all readers); fix next-PR detector, stale `W:active-program`
  names, the `W:code-dev-pr-id` overload; collapse the 7-file review surface into one subcommanded program;
  add **`code-dev review correctness`** (adversarial diff review, WARN-only). *(also the C7 residual mitigation)*
- **PR-5 · T5 shadow contract** `[crit C6]` — deps: none.
  Add the `--branch/--commit/--caller-*` flags to `shadow init` (or strip them); make the tool the single header
  source; replace the phantom `_READ_SHADOW_HEADER`; fix `study-area`'s `hit.fresh`; wire or retire `review-coverage`.
- **PR-6 · T6 library-dev plumbing + first test** `[crit library]` — deps: PR-2 (path-var repoint).
  Unify lib-path root + arg-key behind one guard; fix the dispatcher route (`W:_subcommand`→real key) + arg off-by-one;
  remove invalid `--stdin`; fix gaps regex + search→ingest dead-drop; add the **first program-level resweep/contract test**.
- **PR-7 · output_manifest + accessor-lint (heavy guard)** — deps: PR-1, PR-5, PR-6.
  `tools/output_manifest.json` (per-tool stdout keys, **pinned by tripwire tests**); extend the conformance lint
  with the accessor side; promote to **BLOCK**. *(catches the dead-accessor class repo-wide)*

## Wave 3 — safety + cleanup
- **PR-8 · C8 real-dry-run mechanism** `[crit C8]` — deps: PR-7 (output_manifest), `code_graph` (exists).
  `atomic_write` dry-run mode (record to manifest, skip `os.replace`); migrate whatif-reachable mutators to guarded
  verbs; **crucible BLOCK lint using `code_graph` reachability** — every whatif-reachable fn writes only via the
  substrate (treat reachable subprocess as a violation). Scope to the whatif-reachable subset first.
- **PR-9 · T8 reduce-surface + residue** `[crit C7-check-structure]` — deps: PR-3.
  `route-manifest` dispatcher for the 60+ code-dev routes; de-dup freeze/thaw↔hold + divide/combine↔partition;
  **`TOOL(meta,set)` + ban literal `_meta` REPLACE**; `residue_lint` (dead `## OUTPUT`/double-DONE, corrupted
  preconditions, stale `W:active-program`); fix `check-structure`→real audit; consolidate the 3 health-score writers.
- **PR-10 · T9 doc/UI honesty (R6)** — deps: PR-0d.
  Fix §C doc-drift (CONTEXT v3.7.0→3.8.0, ARCHITECTURE 84→160 tools, test count, six/seven-subsystems); remove
  advertised-but-unimplemented commands/modes/flags; fix the misleading `tests:` headers; auto-generate
  `lifecycle-tour`/`help` from the dispatch table; r6 command-backing folded into the conformance lint.
- **PR-11 · completeness-keystone** — deps: all guards (PR-0a/0b, PR-7, PR-8).
  Ensure every WARN guard is promoted to BLOCK with no orphan/WARN-graveyard (apply the "already-wired" correction
  the critic found). The meta-gate that makes the whole prevention spine fail-closed.

## Residual (ongoing, not a single PR)
- **C7 semantic correctness** — strengthen tests toward behavior-asserting + mutation tests across the fix-tracks;
  the WARN-only `review correctness` (PR-4) is the advisory floor. *Never a deterministic BLOCK (undecidable).*

## Critical path
`PR-0c→PR-0d` (mirror) ∥ `PR-0a→PR-2` ∥ `PR-0b→PR-1` → `PR-3` → `{PR-4,PR-5,PR-6}` → `PR-7` → `PR-8` → `PR-11`.
~14 PRs. Kernel edits (if any phase/menu fix needs a kernel-program touch) → human-apply spec, never auto-merged.
