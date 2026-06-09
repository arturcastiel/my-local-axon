# Decisions (ADRs) — 1-safety-contract

Grounded by the 2026-06-03 study (01-study.md Part B). Several earlier-TBD decisions now have a
direction; remaining open points are flagged for `code-dev plan`.

- **ADR-001 — Contract = a new program that UNIFIES the two existing authority systems.** AXON has two
  decoupled authority layers: AEGIS policy (`_policy.md`, high-level capabilities) and the autonomous-mode
  grant (`autonomous_mode.py`, per-repo/op). `autonomy-contract.md` interviews the human via
  `TOOL(decide,…)` and writes BOTH (policy file + `autonomous-mode on`), plus an accountability entry.
  OPEN: one unified contract file expanded into the two, or write both directly (decide in plan).
- **ADR-002 — Reanchor = WIRE + WIDEN the existing `axon-reanchor.md`, don't build new.** The program
  already restores identity; we (a) auto-fire it at the compaction boundary (`session.recover()` →
  `EXEC(axon-reanchor)`) and the PR boundary, and (b) widen it to also re-assert goal/scope/done-state/
  invariants for autonomous runs (fail-closed). OPEN: where the compaction trigger lives — `boot.py`
  auto-recover hook vs. a new KERNEL-SLIM gate vs. a Claude Code UserPromptSubmit hook
  (`L:host-cap-reanchor` target). Has dev-mode/F50 implications — decide in plan.
- **ADR-003 — Circuit breakers + selection = rules + crucible controls + a fixed workflow.** Breakers are
  `tools/rules/r_autonomy_*.py` (STATIC, WARN→BLOCK via `L:autonomy-discipline-required`) wired as
  `crucible.json` controls so they enforce at the gate. The discipline as a whole is a FIXED
  `workspace/workflows/autonomy-discipline.yml` whose synapses are the gates — mirroring how `code-dev`
  governs development. Escalation question channel: a queued question file surfaced in the run report
  (no live session) — refine in plan.
- **ADR-004 — Subsystem shape mirrors `code-dev`** (router + specialized programs + phase/workflow
  enforcement + ledger/replay). Programs: autonomy-contract, autonomy-reanchor (or extend axon-reanchor),
  autonomy-breaker-assess, autonomy-select, router `autonomy.md`.

_Budget meter: start with PR-count (deterministic, cheap); wallclock/token need a meter — defer._

- **ADR-005 — Criterion ZERO: bind code-change ⇒ on-workflow, at the gate (the teeth).** Grounded by the
  deep study (01-study Part C): off-workflow / out-of-order code work is UNPREVENTABLE today — every
  primitive (`skip-guard`, `phase-model`, `R_WORKFLOW_NODE_ORDER`) binds only inside code-dev; the gate
  has no rule linking a code change to a PR spec + active phase. Decision: add a new changeset rule
  `R_CODE_CHANGE_REQUIRES_PR_PHASE` (`tools/rules/`), wired into `crucible.run_changeset`, WARN→BLOCK via
  `L:code-change-requires-pr-phase`. It BLOCKS a code-file changeset with no active phase + covering PR
  spec in the loaded project. This is the FIRST thing built (PR-1) — it is the mechanism that makes the
  2026-06-03 freelance incident impossible to repeat. A regression reproduces that incident (the ratchet).
- **ADR-002 (AMENDED) — reanchor re-asserts WORKFLOW POSITION, not just identity.** B3 scoped the reanchor
  to identity + project-frame; that would NOT have caught the freelance (identity never slipped — the
  workflow position did). The reanchor must also re-assert active project/phase/next-step and run the
  ADR-005 off-workflow check PROACTIVELY at boundaries (halt + redirect). The existing draft
  (`tools/autonomy_reanchor.py` + `workspace/programs/autonomy-reanchor.md`, kept per path A, defects
  cleaned) is PR-2's skeleton, to be extended with the workflow-position check.
- **ADR-006 — Governing frame: separation of powers + act-through-the-anticipation-layer.** One agent both
  IS AXON (executes) and CONTROLS AXON (directs); unsplit, the director overrides the executor (the
  freelance). Split: the DIRECTOR may invoke ANY AXON program (the full catalog via `dispatch`/`EXEC`),
  suggested or not — the boundary is USE-AXON-NOT-FREELANCE (every action a registered program/tool
  invocation, never a made-up off-AXON action), with order + gates still binding; the EXECUTOR runs it
  gated and holds the gate. AXON's anticipation layer — `synapse-suggest` (rank) → `anticipate.py`
  (margin-gated; honest SILENCE below 0.20) → `orchestrator` (observe→decide→render→record), with
  `L:inference-mode` as the ask↔fire dial — ASSISTS the choice but does not fence it. Autonomous mode goes STALE
  if the orchestrator is not ticked (the layer was ACTIVE-but-uninvoked until wired into the tick). Operate
  every step THROUGH the orchestrator / `workflow-run`, never off-menu. Criterion-zero (ADR-005) is one
  instance of this frame. (01-study Part D.)
- **ADR-007 — Reanchor cadence: every 5 commands-to-AXON, post-response (owner spec).** In autonomous mode,
  fire `autonomy-reanchor` after every 5th command the agent issues to AXON — counted on
  `W:autonomous-command-count`, fired AFTER the command's full response (not mid-command). EXTENDS the
  kernel `G-02` every-5-turns identity check (`KERNEL-SLIM:154–162`) from identity-only to the full frame
  (identity + workflow position). COMPOSES with the boundary triggers (PR boundary, compaction-resume).
  Wired in PR-005 (the operate-loop counter); it fires the PR-002 reanchor. (01-study D6.)
- **ADR-008 — Mitigations for the two plan unknowns (deep study, 01-study Part E).** (a) Gate-rule
  predicate: `ctx` carries only `{changed_files, repo_root}`, so the rule reads the active project from
  `workspace/memory/working/code-dev-project.md` and is SILENT when none is loaded (hotfix exemption);
  "code" = the `r_new_needs_test` classifier; project-meta + generated + non-code EXEMPT; "covering" =
  weakest-sound first (active phase + ≥1 open PR spec), file-level later; WARN→BLOCK + reproduction test.
  (b) Cadence enforcement: `dispatch.py` increments `W:autonomous-command-count` (runtime chokepoint, not
  agent discretion); a NEW backstop `tools/autonomy_cadence.py` + control `R_AUTONOMY_CADENCE` detect a
  lapse > 5 commands (detection = enforcement). Residuals named: file-level coverage is heuristic
  (WARN-first); hard real-time firing needs a host hook (owner-install, future) — backstop substitutes at
  gate granularity. Adds **PR-006** (cadence backstop); plan confidence 8 → 9.
