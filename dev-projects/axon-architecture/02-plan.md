# Phase 2 — PLAN (decisions) · axon-architecture

## Decisions
1. **Priority = leverage, not theme order.** Security (D) first (live external attack surface), then the
   enforcement keystone (A: CI-runs-crucible — it makes every later changeset rule actually bite), then
   liveness (B), then state-correctness (C), then severity (E), boundaries (F), cleanup (G).
2. **AUTO by default; 3 OWNER PRs.** OWNER = PR-3K (KERNEL relabel), PR-4 (hook install/activation),
   PR-24 (kernel header hash). dev-mode unlocks the kernel WRITE; the MERGE stays human. Everything else
   is AUTO through the fail-closed gate.
3. **Keystone ordering guard.** PR-2 wires `crucible gate` into CI. Precondition: confirm `crucible gate`
   is green on main *before* PR-2 (it has been all session) so PR-2 doesn't red the build on landing.
   After PR-2, every subsequent PR is gated by crucible in CI too — self-reinforcing.
4. **Repo-wide-impact PRs get extra care** (own gate run, no batching): PR-2 (CI), PR-15 (WARN semantics
   change), PR-17 (package/import refactor). Land each alone, verify green, then continue.
5. **Don't activate, only enable.** This project makes enforcement *installable + honest*; it does NOT
   flip the `L:*-required` flags or install the host hook (owner-gated). PR-3/PR-3K make the real posture
   observable + truthfully labelled; PR-4 makes the hook installable. The owner throws the switch.
6. **Findings, not assumptions.** Re-cluster against `/tmp/arch_findings.md` at each PR's spec; MINORs in
   the unverified tail are confirmed during their own PR before fixing.

## Sequencing notes
- Waves 0–3 (PR-1..14) close all 14 CRITICALs. That is the "flawless core"; Waves 4–6 are MAJOR hardening
  + cleanup.
- PR-7 (rule manifest) + PR-6 (orphan control) interact: land PR-5 (resolver) → PR-6 (orphan gate) →
  PR-7 (manifest wires the 8 dead rules, which the orphan gate then protects).
- PR-10/11/12 (workspace/dev-mode/L:-reader unification) share the "single source of truth" pattern; do
  PR-12 (the reader) first so PR-11 (dev-mode) and PR-10 (workspace) build on it.
- After PR-2, expect some currently-WARN crucible controls to matter more — PR-15 (WARN non-fatal) is
  sequenced into Wave 4 so the CI gate (PR-2) lands with today's semantics, then the severity model is
  fixed deliberately.

## Confidence
PLAN grade 9/10. Deduction: PR-17 (package refactor) blast radius is large and may need to split; the
exact OWNER/AUTO boundary on PR-24 (boot.py AUTO vs kernel-header OWNER) is decided at its spec.

## Gate to PHASE 03
PLAN DONE → write `03-prs/PR-01.md` (security) first, implement, gate, merge; then PR-02 …, in order.
