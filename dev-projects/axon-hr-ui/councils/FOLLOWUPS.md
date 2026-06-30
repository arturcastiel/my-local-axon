# Follow-ups — axon-hr-ui (deferred sub-PRs, tracked not dropped)
> Surfaced by audit councils during the autonomous build. Non-blocking; scoped out to keep PRs atomic.

## Disposition changes (audit-driven)
- **PR-013 (stranger-test gate tool) — DROPPED (orphan), folded into PR-014.** Built it as a standalone
  tool, but BOTH the audit challenger AND the `liveness.py` gate (AXON's anti-orphan-tool mechanism)
  flagged it: the tool is reached by nothing because the work it gates (PR-014) doesn't exist yet. Adding
  it to the liveness allowlist would circumvent the very gate that prevents the tool sprawl this project's
  #1 finding is about. Right call: the cold-start stranger-test requirement is recorded HERE as a hard
  PRECONDITION on PR-014 — build the gate (protocol + record + E:stranger-test-run check) AS PART OF PR-014,
  wired to its own preflight, so it's never an orphan. The protocol text is preserved in the dropped tool's
  git history / can be re-authored when PR-014 is funded.
- **PR-011 (surface code-dev-replay) — FOLDED into PR-003.** The menu is compiled (agent-driven pipeline,
  no one-shot recompile), so a standalone 1-line menu edit forces a disproportionate menu recompile. PR-003
  is already a staged menu change pending owner adjudication + recompile — so the replay surface line was
  added to the PR-003 branch (commit 8e60dc2); one recompile covers both. (Note: replay is already
  discoverable via `code-dev help`, which auto-SCANs code-dev-*.md; this just adds the menu surface.)
- **PR-012 (single save/sync verb) — DEFERRED (design needed).** The safe version (wrap the existing
  my-axon `workspace-backup push`) is a near-alias → the PR-006 redundancy trap. The "full" version
  (one verb that also pushes the shared axon CODE repo) is dangerous — it bypasses the per-PR review
  discipline the whole build relies on. C-sourced (lower confidence + the C-context-undefined caveat).
  Needs deliberate repo-scoping design (private-data auto-push OK; code repo surface-only, never blanket
  push) before it's safe to build. Not a quick autonomous PR.

- **PR-006 (code-dev `start` front door) — DROPPED by audit.** Two grounded auditors found it redundant
  with the no-arg `code-dev` dashboard (lists projects + commands) + `code-dev-next` (single next step),
  and noted adding an 89th program *increases* the sprawl the discovery council ranked #1. The "no front
  door" finding was inaccurate against the live repo. Right call: don't ship redundant surface. If revisited,
  improve the EXISTING no-arg dashboard's discoverability, not a new program.
- **PR-007 (resume-truth / `:done` marker normalization) — STAGE as kernel-tap.** The substantive fix is
  the terminal-marker semantics in KERNEL-SLIM's active-program/resume gates + axon/BOOT.md (kernel floor).
  The menu re-entry slice is marginal on its own. Queue for owner with the kernel-marker change.

## From the gap-find council (round-2 backlog → GAPFIND.json)
- **PR-018 (round-2 hardening) — MERGED subset:** phase_model.py now distinguishes DepsNotDone vs
  OutputsMissing (reason_code in --best-effort) + add() rejects ids that NORMALIZE to an existing phase
  (gap-find rank 1 infra + rank 4a). Tool-level + behavioral tests.
- **PR-019 (deferred from PR-018) — escalate outputs-missing + fix the emits/WRITE drift.** The gap-find
  rank-1 ERROR escalation in the 5 ladder programs was reverted: escalating outputs-missing to LOG(ERROR)
  is premature because the rank-3 drift (code-dev-study `# emits: 01-study.md` vs the flagged path writing
  `study/<mode>.md`) could make it false-alarm, and it can't be behaviorally tested without a markdown
  runner. DO TOGETHER: (a) reconcile code-dev-study's emits header with its mode-aware WRITE target;
  (b) THEN escalate the ladder to LOG(ERROR) on reason_code=outputs-missing; (c) add a program-execution
  test. The reason_code infra (PR-018) is the foundation this builds on.
- **Other gap-find items (GAPFIND.json):** rank 5/6 (advanced _phases.json has no consumer — resume reads
  _meta.md, not the manifest) is the real "visible" gap (relates to PR-008b); rank 4b/14 (code-dev-phase-new
  TOOL(phase-model, add) is fire-and-forget — raises after dag add-node → DAG/manifest split-brain on an
  unknown predecessor); rank 9 (synapse dedup degrades on unbalanced parens); rank 11 (R_TOOL_CALL_EXISTS
  blind to phase_model subcommands — the loop-built-parser scanner gap); rank 7 (compiled-staleness test is
  mtime-based + fragile to branch switches — should hash content). All tracked, none blocking.

## From PR-008 (phase state real AND visible)
- **PR-008b — the VISIBLE half (ActiveProgramStrip).** PR-008 shipped the REAL half (the forward ladder
  now advances _phases.json via best-effort phase-model done). A#2's finding was "real AND visible"; the
  visible part — an ActiveProgramStrip / phase-progress line surfacing the current manifest node + status —
  belongs with the menu work, which is owner-gated (PR-003 / Core Rule 12). Fold it in when the menu PR is
  adjudicated. The audit flagged the branch name promised "visible" but PR-008 delivers "real" only.

## From PR-005 (synapse dedup)
- **PR-005b — scrub on-disk declared preconditions + recompile.** 6 program files carry baked-in
  duplicate conjuncts (code-dev.md 13→3, code-dev-plan, code-dev-pr-create, code-dev-state-undo,
  code-dev-study, glossary). `synapse_infer.scrub_preconditions()` exists + is tested. Deferred because
  editing the source bumps mtime → `test_compiled_not_stale` requires regenerating the `.cmp.md` artifacts
  (only code-dev has one). Read-time dedup in `infer_program` already neutralizes the functional hazard
  (every consumer + re-ingest path dedups), so this is cosmetic source hygiene. Do: scrub + recompile in one PR.
- **PR-005c — synapse-validate semantic lint.** The council paired the dedup with a validate lint:
  WARN when a precondition conjunct repeats >2×; FAIL when a next-suggests/next-conditional name doesn't
  resolve to a real programs/*.md (the truncated `code-dev-phase-` dispatch break). Dropped from PR-005
  to keep it atomic; the dedup removes the symptom, this catches recurrence at validate time.

---

## AXON-COLDBOOT thread (2026-06-23) — onboarding tier, the O2/PR-014 mechanical half
Built after the 12:05Z resync (initially uncommitted + undocumented; now recorded here + in BUILD-STATE).
HR verdict 2026-06-23T131129Z-design-a-1d355ed1. Two layers + a single entry point:
- **Layer 0** `tools/boot_friction.py` (registered as `boot-friction`) — static, subject-free audit of the
  cold-start boot path: dead load-bearing targets, missing Step-0 install script, front-loading metric
  (bytes-to-menu + first menu-command line). Gate: exit 1 on a hazard. Conservative, false-positive-free.
- **Layer 1** `benchmark/cold-start/cold_stranger.py` — spawns a CONTEXT-NAIVE `claude -p` agent against a
  scrubbed checkout (no my-axon/, no .claude hook/output-style) and grades the transcript vs `rubric.json`.
  The author can't coach it — exactly a newcomer. `run.sh` = tests + Layer-0 + Layer-1 (dry-run | --live).

### Harness-robustness fixes shipped this session (benchmark-only, NOT kernel)
1. **Frozen-credential bug (the live T3/T4 401s) — FIXED.** `provision_isolated_home` copied the OAuth token
   ONCE at matrix start; it's short-lived (`expiresAt` ~hours) and the sandbox can't refresh it, so a long
   matrix straddled the expiry → mid-matrix 401. `copy_credentials(home)` now re-pulls the live token before
   every run. Proven: 2nd run had auth_aborted=0 and T3/T4 passed.
2. **529 Overloaded (live T1) — FIXED.** `is_transient_error()` + `_spawn_with_retry()` retry 5xx/overloaded
   with linear backoff (8s,16s, up to 3 attempts). Auth + content failures still fail fast.
3. **Honest tally + fail-fast.** `summarize_records()` separates `reached`/`passed` from
   `auth_aborted`/`infra_errors`/`skipped`; first auth death stops the matrix (rest = `skipped`, not failed).
Tests: `tests/test_boot_friction.py` + `tests/test_cold_stranger.py` (26 passed incl. these fixes).

### OPEN FINDING (owner design call) — T0-boot newcomer halts at the my-axon gate
A naive first boot (fresh checkout → no `my-axon/`) reaches BOOT STEP 2's my-axon detection, renders the
`[F]resh / [C]lone / [S]kip` prompt, and **QUERYs the user — halting before BOOT STEP 3 (banner + menu).** So a
newcomer can sit at a setup prompt before ever seeing the home screen. The cold-start rubric correctly fails it
(no `OS STATE`/`MODES`/tagline rendered). Rubric LEFT AS-IS — it caught a real gap. It also skipped the BOOT BANNER.
DESIGN QUESTION (feeds PR-014 + O2 stranger test): should first-run render the MENU FIRST then offer my-axon setup,
or auto-Fresh→menu, instead of blocking on a QUERY? Kernel boot-flow change → owner-gated (BOOT.md / KERNEL G-10).

### dag-summary ledger slice (separate logical PR, also uncommitted)
`tools/dag.py` gains `summarize()`/`cmd_summary()` (`TOOL(dag, summary)`); `code-dev-state-status.md` uses it to
show a DAG-aware PR ledger (a v4 project tracks PRs in DAG.json with 0 standalone PR-*.md → the glob-only count
read them as empty). `tests/test_dag.py` +62. Commit as its OWN slice, not folded into AXON-COLDBOOT.

---

## Deep HR council — GATE-STRANGER under "no human but the owner" (2026-06-23, 5 seats)
Owner constraint: never recruit/use any human but himself. Council evaluated how to satisfy (or honestly
retire) the cold-start onboarding gate under that constraint. Strong convergence (conf 0.82–0.88):

### Core finding (unanimous)
The non-author DESIRE/abandonment signal is **genuinely unobtainable** under the constraint:
- The author cannot be the stranger — a fresh machine + time-gap erases RECALL, not PRIORS; he still knows
  AXON's idiom (semantic fluency is exactly what a stranger lacks). Solo cold-testing = a "rusted-author"
  test, NOT a stranger test (measurement seat, conf 0.35 it's worth gating even the mechanical slice).
- An AI panel cannot be the stranger — an instruction-follower COMPLIES where a human QUITS; "I'd give up"
  is a performed token, not a person leaving. Desire failure is silent (close the tab) → un-generatable.
- The line the project must NOT tell itself: "we removed author bias by construction" — the author wrote the
  menu, tasks, and rubric, and grades against his own vocabulary.

### Concrete bug found + FIXED (PR-014b-coldboot-grader)
The benchmark's grader was substring-only → it PASSED a fabricated boot (live T4: "162 ACTIVE tools" while
python3 was sandboxed; real=160). Added `detect_fabrication()` corroborating boot-state claims against the
checkout's REGISTRY.json ground truth → confabulated boots now score `failure_kind:"fabricated"`. (25 tests.)

### Decision (implemented in DAG.json)
- **Rename + redefine GATE-STRANGER** → a MECHANICAL boot-conformance gate (drop the "stranger" pretense):
  satisfied by `run.sh --live` (Layer-0 green + reached tasks pass the hardened grader, >=3) + PR-T0-bootflow
  resolved. AXON-satisfiable — the AI is the subject, the owner just runs the benchmark.
- **Honestly DROP the desire half** as a blocker, with the written admission (above). NOT faked by a proxy.
- **CUT PR-014's persona-driven sub-items** (persona onboarding, human-tuned discoverability rank()) → new
  deferred project `axon-onboarding` (created at track-start). O2-stranger-test.sh kept as OPTIONAL
  post-share telemetry, NOT a gate. (Passive first-run telemetry can arm post-share — non-blocking milestone.)

### Path to CLOSE (only two bounded owner touches)
AXON: ship PR-014b grader (done, crucible verifying) + DAG redefinition (done). OWNER: (a) rule on
PR-T0-bootflow (menu-first boot), (b) run the hardened `run.sh --live` once. Then gate green → PR-014
executability merges → audit→done → CLOSE. No human-stranger ever required.
