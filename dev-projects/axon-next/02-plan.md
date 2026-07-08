# High-Level Plan — AXON Next (Autonomy Doctrine + T3 floor)
Updated: 2026-07-08  ·  Iterations: 1 (+ council rebuild)  ·  AXON: 8.5/10  ·  User: approved ("continue", 2026-07-08)

## Context (from Phase 1)
Goal: ship the AUTONOMY DOCTRINE — a first-class construct attachable to any program/
workflow: owner gives the mission; AXON proposes the routine; the routine becomes a
validated graph; valid ⇒ run-until-end under a per-project deviation policy, recorded in
a standing AUTONOMY.md written by a fail-closed activation interview — on top of the T3
mechanical floor (deletion-verb gate coverage, grant TTL, program integrity). Study:
01-study.md (G1-G12 gaps, S1-S10 seams, "≈70% assembly").

## Architecture (COUNCIL-REBUILT — the central decision)
**D1 — the doctrine graph is AUTHORED AS WORKFLOW YAML and EXECUTED by the existing
advance-guard stack; DAG.json is a ONE-WAY DERIVED LEDGER** (statuses, provenance,
mermaid fluxogram) — the canonical-file/rendered-mirror idiom the repo already uses.
The architecture skeptic overturned the study's extend-dag.py lean with source evidence:
dag.py's cycle guard structurally rejects the legal back-edges real routines need
(workflow_run.py:11-14 vs dag.py:160-163); the execution teeth are keyed to the workflow
dict shape; check-stale/validate-draft have no DAG.json entry point — extending dag.py
= building a second, worse workflow engine plus an adapter. YAML+derived-ledger resolves
the G2 split-brain by construction. Council-unanimous after evidence.

**Mechanical obedience is a shipped feature, not a covenant.** Every seat converged on
the same unassigned seam: S7b — a current-node op-class check inside shell.gate_check —
is the host-level tooth that makes "the DAG must be run and obeyed" literally true.
It has its own PR (015). Supporting teeth: deterministic resolve-next (the tool, not the
walker, picks which conditional edge fires — next_allowed today ignores `if:`, verified),
the grant⟷doctrine binding (grant.doctrine field; authorized() refuses ops under an
unattended grant outside a valid run — kills the red-team's raw-grant bypass), and a
REAL G1c write-barrier (the shell gate's comments cite an OS write-barrier that
grep-provably does not exist — the phantom is built or the comments die).

## Decisions locked at plan time (owner, 2026-07-08: "continue" on recommendations)
- D1 graph format: workflow-YAML authored + derived DAG.json ledger (above).
- D2 unattended: EVIDENCE-GATED PROMOTION — attended runs on the same artifacts are the
  WARN phase; arming flips on promotes_on: 3 clean, fully-receipted attended doctrine
  runs. "All modes" honored as staging, not dropped.
- D3 deviation v1: halt-and-handoff ONLY (the policy field ships and is honored
  fail-closed; append-repair mutation machinery is v2 — all four seats: earn mutation).
- D4 budget unit: node-completions (consumed by the loop-contract wall + TTL boundary).

## Council record (4 seats, 2026-07-08; Step-0 re-verified at synthesis)
- Architecture skeptic 4/10→7/10: format flip (adopted); S7b unassigned (fixed: PR-015);
  PR-011/014 forward edge (fixed: staged activation); XL splits (applied).
- Security red-team 2/10→~6-7/10 conditional: grant binding BLOCKER (fixed: PR-008);
  G1c phantom BLOCKER (fixed: PR-002); receipts self-attestation (fixed: hash-chain
  PR-004 + host-mirror PR-016); deletion coverage widened (PR-001); TTL self-renew hole
  (fixed: human-only renew + PreToolUse deny, PR-003). One claim REVERSED at Step-0:
  aegis resolve() has 2 production callers (test_runner, graphify_bridge), not zero.
- Ordering attacker 4/10→8/10: forward edges killed; ONE receipts enum bump (PR-004);
  walking skeleton demanded (PR-009); fail-closed hook flip staged not smuggled
  (inside PR-001, log-only soak + promotes_on); unowned items assigned (scope binding →
  PR-015; S7b → PR-015; per-node resolve routing → PR-014).
- Scope economist 8/10: lean-cut spine adopted (coherence wave dissolved into acceptance
  criteria; two draft PRs were never PRs); append-repair + unattended deferred/staged;
  E2E proof runs on an EXTERNAL repo so the doctrine's birth certificate is also the
  platform's first external-evidence artifact (standing-audit Challenger honored).

## Waves (4 waves, 17 PRs — 02-prs.md is the ledger)
- A — T3 floor (001-005): stands alone even if the doctrine slips; owner-committed.
- B — doctrine spine (006-009): interview → AUTONOMY.md → fail-closed activation +
  grant binding → WALKING SKELETON (the spine integrates at PR-009, not PR-017).
- C — the graph (010-014): schema kinds + outputs; goal-ctx + resolve-next; validation
  preflight + activation stage 2; derived ledger + fluxogram; the doctrine runner.
- D — mechanical obedience + proof (015-017): S7b node-op-class gate + scope binding;
  evidence-gated unattended arming; external-repo E2E + docs + v2 stub.

## Constraints honored
reduce-surface (every piece extends autonomy-contract / workflow_run / loop_receipt /
gate_check / crucible — no parallel engines) · tests-with-neurons (every PR ships tests;
full suite per merge) · WARN+promotes_on staging for every new gate (incl. the hook
fail-closed flip and unattended arming itself) · kernel floor untouched everywhere ·
plan-atomic-prs (no forward deps — council-verified after restructuring) · budgets
human-set (TTL renew + loop walls) · lossless-mandate on schema changes.
