# High-Level Plan — AXON Bug-Free 3
Updated: 2026-07-13  ·  Iterations: 1  ·  AXON: 9/10  ·  User: 10/10  ·  mode: tactical

## Context (from Phase 1)
Goal: convert the run-3 ledger (1 CRIT · 19 HIGH · 16 MED · 9 LOW, AUDIT-FINDINGS.md) into
dependency-ordered, independently mergeable fix waves inside the autonomous envelope
(AEGIS × grant, fail-closed); kernel-floor items become a human-gated spec PR.

## Architecture Overview
Self-hosted codebase — the 4-sweep study (shadow/sweep-{A,B,C,D}*.md) is the architecture map.
Defect concentration: (1) newest families (codemap/graphify/obsidian/doctrine) re-introduce the
bugfix02 reader↔writer classes; (2) four incomplete prior fixes; (3) kernel-declared interfaces
drifted from tool reality; (4) guard paths that mutate or fail open.

## Wave A — Golden-path breakers (PR-001..006)
User-visible features that silently don't work. Smallest diffs, highest yield.
Workflow name-resolution (dual-root), workflow caller contracts, codemap arg contract +
shadow dispatch, envelope binds (meta.get/.value ×8 + shell + obsidian unchanged-path),
graphify impact query, pattern.py pref-parse crash.

## Wave B — Integrity & audit (PR-007..010)
Guards that mutate or fail open: phase-model refusal oracle, doctrine preflight fail-closed,
hr-team refusal pipeline (+ protocol override + reround unlock), doctrine-node stale-record recovery.

## Wave C — Self-report truthfulness (PR-011..014)
Drift alignment kills the drift-unknown → auto-improve breaker deadlock MECHANICALLY
(tool-side `record --type` compat + TTL-aware check + staleness refresher — no kernel edit);
suggestion-chain recalibration to the absolute score scale; tick shape unification + situate
bridge; reporting batch (session-summary log tree, status queue field, simulate arg).

## Wave D — Store unifications (PR-015..018)
Reader==writer: chat index, episodic store, agent-memory tier enumeration; routing/guards
batch (workspace-backup subcommand key, MYAXON.md overwrite guard, resume program-exists
check, active-phase convention).

## Wave E — Prevention ratchet (PR-019..020)
Two new crucible lints — zero-writer-key + envelope-bind (named justification per
reduce-surface: those classes account for ~14 findings this run) + lint-path-vars kernel-file
scope + small-integrity cleanup batch.

## Wave F — Kernel floor (PR-021, HUMAN-GATED)
Spec + exact patches for KERNEL-SLIM.md:118 (W:ws-path), BOOT.md:186/:196, the dead drift
band text (:192/:292/:345/:380 + OUTPUT-LAYER.md:129), chat-index note, plan-new.md.
Prepared, never self-merged. Depends on PR-011 so the kernel text change is a no-op swap.

## Discipline
Full `crucible gate` (all 38 controls, 24 BLOCK) before every push; red = find the writer,
never retry. Commits: Co-authored-by: AXON <axon@arturcastiel.github.io> only. Deferred
(evidence-gated, per plan-atomic-prs): 4 quarantined leads verification · workflow-new
preview/convergence/from-desc · cosmetics → 02-prs.deferred.md.
