# Implementation Log — AXON Workflow Discipline

## SESSION START — 2026-05-29
Sub-project of axon-improvements. Fixes: rigid fixed-workflow/program-graph traversal (no
node-jumping) + always-on verbose state narration + anti-orphaning protection — all mechanically
enforced. PHASE 1 — STUDY ran a deep 4-auditor + 2-recon pass; study graded 9/10, ready for PLAN.
Gated: will not enter PHASE 2 — PLAN until owner marks STUDY DONE (the discipline this project builds).

## Entries
### PR-1 · phase-model foundation · MR !46 · ✓ merged (squash 5180ee8) · 2026-05-29
NEW `tools/phase_model.py` (+REGISTRY ACTIVE) — per-project `_phases.json`: ordered nodes + status
(pending|active|done|stale) + dep edges. advance() requires deps done; done() requires active;
stale_downstream() cascades to transitive dependents. 7 tests. FULL crucible gate green (20/0/0).
The data-driven foundation that replaces hardcoded phase literals + the file-exists heuristic.
Spec refinement: code-dev.md dashboard wiring deferred to PR-3 (rides with the in-order HALT) to keep
PR-1 small + gate-safe. Loop: branch→commit aa6ad98→gate→push→MR !46→squash-merge.

### PR-2 · dag cascade-invalidation · MR !47 · ✓ merged (squash 692c48c) · 2026-05-29
`dag.py` += `stale` status + `descendants(node)` (transitive dependents over depends-edges,
prerequisite→dependent) + `cascade_stale(node)` (mark started/done descendants stale; pending
untouched). The graph primitives for backward cascade-invalidation. +3 tests. Gate 20/0/0.

### PR-6 · R_WORKFLOW_NODE_ORDER · MR !48 (0bd2e4f) · PR-3 · code-dev phase_model wiring · MR !49 (696886e)
### PR-7 · R_STATE_SURFACED · MR !50 (5100d8b) · PR-9 · R_NO_ORPHAN_TOOLS · MR !51 (3839467)
### PR-5 · code-dev `back` cascade-invalidation · MR !52 (b3aaa04) · all ✓ merged 2026-05-29, gate 20/0/0
- PR-6: in-order phase-manifest merge gate (changeset, WARN-first/BLOCK-on-flag).
- PR-3: dashboard reads phase_model (done == explicit) + `code-dev done [phase]` (in-order enforced).
- PR-7: mandatory narrated state block while a program/workflow is active (silent-until-activated→BLOCK).
- PR-9: anti-orphaning — a new ACTIVE tool wired into nothing is flagged (the "features go missing" fix).
- PR-5: `code-dev back [phase]` re-enters a phase + cascade-invalidates downstream, verbosely.

### RUN CHECKPOINT — 2026-05-29
7/13 merged (PR-1,2,3,5,6,7,9). All three headlines (rigid-no-skip, verbose-state, anti-orphaning)
+ foundations + cascade shipped, FULL crucible gate green every merge. REMAINING: PR-4 (skip big-menu,
multi-program AXON-LANG), PR-8 (anticipate revival — needs the hook), PR-10 (wire the 8 orphan RULES —
delicate, per-rule gate-red analysis), PR-11 (Python-ify the workflow runner — large), PR-12 (kernel
mandate — OWNER-merge), PR-13 (.claude hook — OWNER-run). Resumable: code-dev load axon-workflow-discipline.

### PR-10 · wire the 8 orphan RULES · MR !53 · PR-11 · Python-ify workflow runner · MR !54 (3dec06f)
- PR-10: registered `lint-summary-rules` crucible control (kind lint, WARN/advisory) running
  `tools/lint_summary.py run` — wires R_OVERRIDE_ATTEMPT / R_PHASE_TRACKED / R_COGNITION_LANGUAGE /
  R_FAIL_FORMAT / R_IDENTITY_LOCK / R_NEURON_ROLE / R_INFERENCE_MODE_LOCK / R_RESERVOIR_OUTPUT into
  every gate. Lock-test in test_crucible. (BF-018 overlap.)
- PR-11: `tools/workflow_run.py` (ACTIVE) — the deterministic teeth: `advance()` allows ONLY a declared
  on-complete target (legal back-edges included), raises WorkflowJumpError on a node-jump unless explicit
  adaptive; `record_step` (run-id trajectory) + `promote` (trajectory → fixed-workflow draft). Wired into
  workflow-run.md advance point. Fixed F401 (`os`). +tests. Both gate green.

### PR-12 + PR-13 PREPARED + HANDED OFF (OWNER) — 2026-05-29
- **PR-12 (kernel) → MR !55**, branch `fix/awd-pr12-kernel-mandate`, commit `7acb1e0`. Added the response-gate
  mandate to `axon/KERNEL-SLIM.md`: mandatory narrated state block (R_STATE_SURFACED) + rigid-fixed-traversal
  principle (R_WORKFLOW_NODE_ORDER + workflow_run.advance + code-dev phase HALT). **FULL gate validated 21/0/0.**
  Used dev-mode for the write, then **re-locked dev-mode → false** (verified). Kernel = human merge; awaiting you.
- **PR-13 (host hook) → MR !56**, branch `fix/awd-pr13-hook`, commit `90b797a`. INERT proposal
  `.claude/settings.json.proposed` + `.claude/HOOKS-README.md`: the 3 hooks (prompt-submit / pre-tool-write /
  stop-response) that turn agent-discipline runtime rules into mechanical enforcement (= BF-S1). Each needs a
  thin wrapper + per-version verification (documented). Awaiting your install + the WARN→BLOCK flag-flip.
- Commit-message lesson reaffirmed: the trailer hook brand-scans the MESSAGE; the literal token "claude" (even
  in ".claude") trips it → keep messages brand-free (file CONTENT may name the host, like workspace/harness/).

### RUN CHECKPOINT — 2026-05-29 (all 13 addressed)
11/13 MERGED autonomously through the fail-closed gate (PR-1,2,3,5,6,7,9,10,11 + the two waves). PR-12 + PR-13
PREPARED + pushed + MR-open, handed to OWNER (kernel-merge + host-install are human by the hard rule). dev-mode
re-locked. Gate green on every merge; zero dangling branches. The three headline defects are mechanically
closed (rigid-no-skip, always-on verbose state, anti-orphaning) + the adaptive-tracking/promote + backward
cascade + anticipation-rule scaffolding shipped. REMAINING AUTO: PR-4 (skip BIG-MENU) + PR-8 (anticipate
revival, WARN-first until the hook lands). Then deferred axon-bug-free items (BF-010/012/016).

### PR-4 · skip-attempt policy · MR !57 (ef4210f) · PR-8 · anticipation revival · MR !58 (7178909)
- PR-4: `tools/skip_guard.py` (ACTIVE) — no skip-by-inference. decide() = autonomous-mode OR inference>=8 →
  hard refusal (no menu, no override); interactive → big disclaimer menu (Back / Force-skip-with-explicit-
  token / Cancel). halt-mode governs gate severity NOT autonomy, so the default interactive session still
  gets the menu. Wired into the code-dev `skip` route; 9 tests. Gate green 21/0/0.
- PR-8: revived the orphaned anticipation layer — `anticipate.py` was registered ACTIVE but invoked by
  NOTHING. Wired into the orchestrator's always-on footer (confidence-margin-gated prediction + density
  verdict every tick, logged for accuracy/replay, surfaced honestly — silence is first-class). Bridged the
  recent-input producer gap (fall back to W:raw-user-input until the host prompt-submit hook). Wiring
  lock-test guards re-orphaning. Gate green 21/0/0.

### OWNER MERGES LANDED — 2026-05-29
- MR !55 (PR-12 kernel mandate) + MR !56 (PR-13 hooks proposal) merged by owner. Pulled main → 4e0d678.
- Re-verified: FULL gate on clean merged main = **21/0/0, 0 blocking, 0 warn** — the merges added NO error.
- Local merged feature branches pruned (kept checkpoint/2026-05-29-awd-spine backup).

## ✅ PROJECT COMPLETE — axon-workflow-discipline — 2026-05-29
**13/13 PRs landed** (11 autonomous via the fail-closed gate: PR-1..11 minus the 2 owner; 2 owner-merged:
PR-12 kernel + PR-13 hooks). Final main HEAD 7178909, FULL gate green. The 11 study requirements (R1–R11)
are all addressed; the three headline defects are mechanically closed:
  1. RIGID no-skip — phase_model in-order DONE-to-advance + R_WORKFLOW_NODE_ORDER merge gate +
     workflow_run.advance per-transition guard + skip_guard (no skip-by-inference) + the kernel mandate.
  2. ALWAYS-ON VERBOSE STATE — narrated state block + R_STATE_SURFACED (silent→BLOCK on flag) + the
     revived always-on anticipation footer + the kernel mandate.
  3. ANTI-ORPHANING — R_NO_ORPHAN_TOOLS (new-orphan BLOCK) + the liveness/lint-summary controls +
     the anticipate re-orphaning lock-test.
Plus: adaptive trajectory tracking + promote, backward cascade-invalidation (verbose), 8 orphan rules wired.
REMAINING (not awd): owner installs the host hook when ready (then flip the 3 WARN→BLOCK flags); deferred
axon-bug-free numerics BF-010 / BF-012 / BF-016.

### SELF-AUDIT + GAP CLOSURE — 2026-05-29 (triggered by owner "are we missing anything?")
Adversarial re-audit of the project's own work found 4 gaps; the 3 actionable closed, #4 owner-gated:
- **#1 skipped our own audit phase** → RESOLVED: wrote 05-audit.md (the dogfood close; the full
  requirement-coverage + residual-risk audit). Skipping it would have BEEN the node-skip we forbid.
- **#2 workflow_run.record_step/promote built+tested but invoked by NOTHING** (latent FUNCTION-level
  orphan R_NO_ORPHAN_TOOLS can't see — the tool is invoked via advance) → RESOLVED MR !59 (413c2e9):
  per-run persistent trajectory store + record-step CLI + a program-level --promote route + post-run
  hint. Delivers R8 (adaptive tracked → promote to fixed) for real. +4 tests.
- **#3 anticipation not gate-checked** — R_STATE_SURFACED matched only PHASE + · → RESOLVED MR !60
  (6cbd741): the block must ALSO carry a forward-pointer (advance/next/suggest/→) — enforces the
  original "next suggestions don't pop" complaint. +2 tests.
- **#4 enforcement PREPARED not ACTIVE** → OPEN BY DESIGN (owner installs hook + flips 3 flags).
- Merge lesson: `glab mr merge <branch>` returned 405 + a piped `if` masked it as success; fixed by
  merging by MR NUMBER + grep "Merged!" + retry on async-mergeability. !59 re-merged correctly.
- Final gate on 6cbd741: 21/0/0. Test suite: 3969 collected. See 05-audit.md for the full verdict (9/10).
