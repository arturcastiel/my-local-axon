# PR List — AXON HR UI
Updated: 2026-06-23  ·  Original plan PRs: 15  ·  Source: masterplan.md (4-council deep run) · advisory_only
Order: quick-wins (PR-001..007) → foundation (008..009) → workflow-overhaul (010..012) → gate+later (013..015).
Rule: no PR depends on a later-numbered PR. Each maps 1:1 to a masterplan initiative.

> ⚠ **CANONICAL PR STATUS NOW LIVES IN `03-prs/DAG.json`** (30 nodes; regenerate the human view with
> `dag render`). This file is the ORIGINAL masterplan plan (the 15) plus mid-stream additions registered
> during the build (see "Mid-stream additions" at the bottom). Per `CODE-DEV-RESYNC.md`, the DAG is the
> source of truth for PR existence + status; this list is narrative — once they disagree, the DAG wins.
> Live ledger: `dag summary --file 03-prs/DAG.json`.
>
> Reconciliation 2026-06-23 (original 15 → DAG): MERGED = 001, 003, 004, 005, 008, 011, 002a-relabel(split
> from 002); STAGED-FOR-OWNER (kernel) = 002a-boot, 007; DEFERRED = 010, 012, 015; DROPPED = 006, 013 (→folds
> into PR-014a-coldboot); GATED = 014 (owner GATE-STRANGER); OPEN(AXON) = 002b, 005bc, 008b, 009b. Also merged
> outside the original 15: PR-016-017, PR-018, FIX-FRESHNESS, FIX-FLAKY-GATE; gates done: GATE-SUITE, GATE-RULE12.

## PR-001 — phase_model.py `add` subcommand + wire into code-dev-phase-new
- **Status:** MERGED (main 04bf90c) · audit caught+fixed an R_TOOL_CALL_EXISTS regression · 4785 tests green
- **Complexity:** S
- **Scope:** tools/phase_model.py (new `add` subcommand); workspace/programs/code-dev-phase-new.md (call after DAG add-node)
- **Depends on:** none
- **Why:** The only undisputed data-corruption bug (init #1, A#1/C). code-dev-phase-new writes masterplan.md+DAG.json but never _phases.json, and phase_model has no add/insert — custom phases never reach the node-order SSOT. Unblocks PR-008.
- **Acceptance:** `phase_model.py add --project P --id X --name N --after DEP` inserts a node, derives deps from predecessors, asserts id-not-present, persists _phases.json; phase-new no longer emits PHASE SPLIT-BRAIN.
- **Spec:** 03-prs/PR-001.md (not written yet)

## PR-002 — Relabel SHADOW GATE advisory + boot/menu enforcement-posture line
- **Status:** not-started
- **Complexity:** S
- **Scope:** workspace/programs/code-dev.md (SHADOW GATE label); menu.md / BOOT.md (enforcement-posture StateLine from verify.py status)
- **Depends on:** none
- **Why:** init #2 (A#3). 'SHADOW GATE (enforced)' is a prose label over an advisory LOG+STORE; gates are advisory unless the Stop-hook is installed but nothing surfaces that. Ship label (option a) + posture line — NOT hard-halt (option b): surface state, don't enforce it.
- **Acceptance:** label reads 'advisory · fail-open'; boot shows 'ENFORCEMENT: advisory (hook not installed)…' sourced from verify.py status; shadow panel renders a line in the total==0 case.
- **Spec:** 03-prs/PR-002.md (not written yet)

## PR-003 — OS-STATE nominal-collapse to one severity-escalated line
- **Status:** not-started
- **Complexity:** S
- **Scope:** workspace/programs/menu.md (OS STATE panel render); the per-turn output-layer
- **Depends on:** none
- **Why:** init #3 (B/A/C). OS-STATE emits the full nominal signal list every turn — signal-to-noise crushes the token budget. Collapse to one rollup line when all nominal; escalate per-signal only on non-nominal. Literal fixed-format string (NOT a formal grammar — that is PR-015).
- **Acceptance:** all-nominal boot renders one 'OS: nominal (…)' line; a non-nominal signal escalates only that line; token delta measured.
- **Spec:** 03-prs/PR-003.md (not written yet)

## PR-004 — kv-store --raw flag / JSON-fallback for bare scalar strings
- **Status:** not-started
- **Complexity:** S
- **Scope:** tools/kv_store.py (set action)
- **Depends on:** none
- **Why:** init #4 (A). kv-store rejects bare scalars with an opaque json.loads error (hit twice this session). Wrap json.loads in try/except; add --raw; auto-fallback to literal string with a note.
- **Acceptance:** `kv-store set --key K --value foo` stores "foo" (with note or --raw); quoted + valid-JSON paths unchanged; tested for all three.
- **Spec:** 03-prs/PR-004.md (not written yet)

## PR-005 — synapse-infer ASSERT dedup + synapse-validate semantic lint
- **Status:** not-started
- **Complexity:** S
- **Scope:** tools/synapse_infer.py (~line 276, join over dedup); synapse-validate (semantic lint); canonical IDENTITY-LOCK/DONE name invariant (A#7)
- **Depends on:** none
- **Why:** init #5 (A). synapse-infer concatenates ASSERT bodies with zero dedup (11× repeated precondition observed in code-dev.md; truncated dead synapse 'code-dev-phase-'); synapse-validate only parse-checks. Pure data-layer, kernel-safe.
- **Acceptance:** generator joins an order-preserving deduped list; validate WARNs on >2× repeated conjunct, FAILs on next-suggests names that don't resolve to a real programs/*.md; counts recomputed.
- **Spec:** 03-prs/PR-005.md (not written yet)

## PR-006 — Ship a `code-dev start` entry-point program
- **Status:** not-started
- **Complexity:** M
- **Scope:** workspace/programs/code-dev-start.md (new); menu CODE DEVELOPMENT block; tests
- **Depends on:** none
- **Why:** init #6 (A#10 ≡ C#2, deduped). 88-program surface has no single obvious front door; new/returning users can't find the ladder entry. One guided entry-point that routes to new/load/study/resume.
- **Acceptance:** `code-dev start` detects state (no project → new; project loaded → resume/next) and routes; registered ACTIVE with test coverage (Core Rule 13).
- **Spec:** 03-prs/PR-006.md (not written yet)

## PR-007 — Cheap re-entry summary block at boot (resume-truth, persona-independent)
- **Status:** not-started
- **Complexity:** S
- **Scope:** BOOT.md / menu.md resume path; code-dev-state-resume.md; :done marker flip
- **Depends on:** none (synergy with PR-001)
- **Why:** init #7 (C/A). Returning users get no truthful 'where was I' summary; the :done terminal marker is inconsistent (this session's 'councils-done' didn't match the gate pattern). Persona-independent re-entry block from W:active-phase + logs.
- **Acceptance:** boot renders a 1-block re-entry summary when a prior phase exists; terminal markers normalized so the gate reads them correctly.
- **Spec:** 03-prs/PR-007.md (not written yet)

## PR-008 — FOUNDATION: phase state that is real AND visible
- **Status:** not-started
- **Complexity:** L
- **Scope:** tools/phase_model.py (advance/done wired); ladder programs code-dev-study/plan/pr/log/audit (call done() on their own DONE); menu ActiveProgramStrip; pre-write/:done markers
- **Depends on:** PR-001
- **Why:** init #8, folds A#2 + B#8/B#1 + C#7. The forward ladder never advances _phases.json (advance()/done()/stale_downstream() coded but never invoked) so the node-order gate guards a frozen manifest. Make advancement a gated side effect AND surface it (ActiveProgramStrip). Keep scope bounded — do NOT silently re-expand into the full state-machine deepening the challenger/harness-designer/completer-finisher warned against.
- **Acceptance:** completing 'plan' advances the manifest; the gate guards real state; an ActiveProgramStrip shows current phase/progress; bounded to done()-on-DONE, no forced advance.
- **Spec:** 03-prs/PR-008.md (not written yet)

## PR-009 — Adaptive-loop semantic exit (goal.rejection.met writer)
- **Status:** not-started
- **Complexity:** M
- **Scope:** workspace/workflows/adaptive-free-text.yml; workflow-runner rejection-predicate evaluation
- **Depends on:** none
- **Why:** init #10 (A). adaptive-free-text terminates only on the 25-step cap because goal.rejection.met() has no production writer — a bandaid. PRECONDITION: verify the challenger's dissent that PR-5.1 steps>25 short-circuit already terminates the loop, BEFORE building, to avoid dead complexity.
- **Acceptance:** loop terminates on a real rejection predicate before the cap; if already-terminating, the PR is closed as verified-no-op with evidence.
- **Spec:** 03-prs/PR-009.md (not written yet)

## PR-010 — Reshape reanchor ceremony by deterministic cadence (never context-suppression)
- **Status:** not-started
- **Complexity:** M
- **Scope:** UserPromptSubmit reanchor hook; axon-reanchor program; KERNEL G-02 cadence
- **Depends on:** none
- **Why:** init #9 (C/B/A). Reanchor ceremony fatigue. SAFETY-CRITICAL: a context-conditional suppression would silently disarm every advisory gate riding the reanchor hook. Reshape by deterministic cadence only.
- **Acceptance:** reanchor fires on a deterministic cadence (not every turn) with no gate riding it disabled; explicitly NOT suppression-based; gate-coverage unchanged.
- **Spec:** 03-prs/PR-010.md (not written yet)

## PR-011 — Severity-gated audit→fix branch + promote/replay menu verb
- **Status:** not-started
- **Complexity:** M
- **Scope:** workspace/workflows/multiple-code-dev.yml (audit→fix branch); menu (surface promote/replay)
- **Depends on:** PR-008 (real phase state)
- **Why:** init #11 (A). multiple-code-dev re-loops audit→plan even for trivial fixes; the adaptive→fixed promote/replay loop is built but operator-undiscoverable. PRECONDITION: verify the 'undiscoverable' dissent (one seat claims it IS surfaced post-run) before building.
- **Acceptance:** low-severity audit findings branch straight to fix; promote/replay verb surfaced in the menu; dissent verified first.
- **Spec:** 03-prs/PR-011.md (not written yet)

## PR-012 — Single AXON-native save/sync verb hiding the two-repo split
- **Status:** not-started
- **Complexity:** M
- **Scope:** workspace-backup program; a unified `save`/`sync` verb over workspace/ + my-axon/
- **Depends on:** none
- **Why:** init #12 (C). The axon.git / my-axon.git two-repo split leaks to the operator. One verb that does the right commit/push per tree.
- **Acceptance:** one `save`/`sync` command backs up both trees per their rules (workspace push + my-axon push) without the operator reasoning about which repo.
- **Spec:** 03-prs/PR-012.md (not written yet)

## PR-013 — GATE: one real cold-start stranger test (blocks the onboarding tier)
- **Status:** not-started
- **Complexity:** S
- **Scope:** tests/ or benchmark/ stranger-test harness; E:stranger-test-run record
- **Depends on:** none
- **Why:** init #13 (C). Every onboarding persona is invented (only the author is observed). This is a Phase-0 GATE: nothing persona-driven (PR-014) merges until E:stranger-test-run has ≥1 recorded session.
- **Acceptance:** a runnable cold-start protocol + one recorded stranger session; gate predicate exposed for PR-014.
- **Spec:** 03-prs/PR-013.md (not written yet)

## PR-014 — GATED: fast-boot + first-run restore + program discoverability rank()
- **Status:** not-started
- **Complexity:** L
- **Scope:** BOOT.md (fast-boot path); first-run onboarding; find-program / dispatch rank() rewrite
- **Depends on:** PR-013
- **Why:** init #14 (C/A). Discoverability + onboarding ROI rests on an unverified program count and invented personas. BLOCKED behind PR-013; each sub-piece scoped to recorded pain only.
- **Acceptance:** does not start until PR-013 gate clears; fast-boot + restore + rank() each justified by a recorded stranger-test finding.
- **Spec:** 03-prs/PR-014.md (not written yet)

## PR-015 — DEFERRED: component grammar (GRAMMAR.md) as internal render contract
- **Status:** deferred
- **Complexity:** L
- **Scope:** axon/GRAMMAR.md; OUTPUT-LAYER.md (internal render contract only)
- **Depends on:** PR-003, PR-008
- **Why:** init #15 (B). A formal component grammar is demoted to an internal render contract; CapabilityTable + standalone ASCII viz deferred. Per-turn ASCII re-emission cost means viz primitives multiply token spend every turn.
- **Acceptance:** if taken up, grammar stays internal (no user-facing DSL); deferred until PR-003/PR-008 land.
- **Spec:** 03-prs/PR-015.md (not written yet)

---

## Mid-stream additions (2026-06-23 reanchor — registered in 03-prs/DAG.json)
> PRs that did NOT exist in the original masterplan-15; surfaced during the autonomous build and
> retro-registered as DAG nodes (a code-first→node-first drift correction; see CODE-DEV-RESYNC.md §9).

### PR-014a-coldboot — AXON-COLDBOOT mechanical preflight  ·  status: staged (built, uncommitted)
- **Kind/lane:** pr · AXON autonomous (non-kernel)
- **Scope:** `tools/boot_friction.py` (Layer 0 static boot-path audit, registered `boot-friction`);
  `benchmark/cold-start/*` (Layer 1 naive-agent harness: cold_stranger.py, tasks.json, rubric.json, run.sh);
  `tests/test_boot_friction.py` + `tests/test_cold_stranger.py`.
- **Why:** realizes dropped PR-013 as the WIRED preflight for PR-014 onboarding; author-runnable, needs no
  owner stranger session. Robustness fixes: per-run credential refresh (frozen-token 401 fix), 5xx/overloaded
  retry, honest reached/auth/skip tally.
- **Edges:** PR-013 folds-into this; this informs PR-014 + PR-T0-bootflow.
- **Acceptance:** suite green (26 cold-boot tests); live run shows auth-clean + transients retried.
- **Next:** branch `axon-hr-ui/PR-014a-coldboot` → HR-audit → crucible → squash-merge.

### PR-DAG-LEDGER — code-dev status DAG-aware PR ledger  ·  status: staged (built, uncommitted)
- **Kind/lane:** pr · AXON autonomous (non-kernel) · STANDALONE (unrelated to coldboot)
- **Scope:** `tools/dag.py` (`summarize()`/`cmd_summary()` → `TOOL(dag, summary)`); `tests/test_dag.py`;
  `workspace/programs/code-dev-state-status.md` (DAG ledger line).
- **Why:** the glob-only PR count read v4 DAG-only projects (PRs in DAG.json, 0 standalone PR-*.md) as empty.
- **Next:** branch `axon-hr-ui/dag-summary-ledger` → crucible → squash-merge.

### PR-T0-bootflow — newcomer boot halts at my-axon gate before menu  ·  status: owner-open (finding)
- **Kind/lane:** finding · OWNER (kernel boot-flow — BOOT.md / G-10)
- **Surfaced by:** AXON-COLDBOOT T0-boot — a fresh checkout (no my-axon/) renders the `[F]/[C]/[S]` setup
  prompt and QUERYs the user, halting before BOOT STEP 3 (banner+menu). Rubric correctly failed it.
- **Design question (owner):** render menu FIRST then offer my-axon setup, or auto-Fresh→menu?
- **Edges:** informed by PR-014a-coldboot; informs PR-014.
