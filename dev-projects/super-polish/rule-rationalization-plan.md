# Appended plan — rationalize the destructive-git-op rule (owner-flagged "weird")

## The observation
"AXON can't change axon [R9] but can change outside repos — yet `git commit --amend` on an outside repo
is human-only." Grounded: KERNEL-SLIM §697 + §567 + config.md:51 — **destructive git ops (force-push,
reset --hard, branch-delete, kernel-edit, amend/rebase = history-rewrite) are INVIOLABLE: human-only
regardless of any autonomous-mode grant.** Ordinary commit/push IS allowed under a scoped grant.

## Why it isn't actually arbitrary (but reads that way)
The gate is by **operation destructiveness**, not repo location: an ordinary edit/commit is reversible;
a history-rewrite / force-push / reset --hard can irreversibly destroy shared history. The "inviolable
regardless of grant" stance is a hard safety floor against an autonomous agent doing the irreversible.
The confusion is that this is conflated with R9 (which is about axon/ *integrity*, a different concern).

## The fix (two parts — rationalize, don't weaken)
1. **Clarify (docs, no behaviour change):** restate the rule as operation-risk-based — one coherent
   "destructive/irreversible git ops" class (amend/rebase/force-push/reset-hard/branch-delete), gated
   everywhere by risk; keep R9 (axon/ integrity) as a separate, clearly-labelled concern. Kills the
   "weird / inconsistent" reading.
2. **Add a narrow, explicit override path (the real friction-fix):** let an autonomous-mode grant
   OPTIONALLY delegate a SPECIFIC destructive op on a SPECIFIC non-kernel repo (e.g. "amend allowed on
   opm-simulators this session") — explicit, scoped, revocable, audited, default-OFF, NEVER kernel —
   mirroring the AEGIS test-execution delegation (§567). So when the owner WANTS the agent to amend, it
   can, without lifting the floor for everything.

## Constraints (this is a KERNEL change)
- KERNEL-SLIM edits require `L:dev-mode ≡ true` + are human-reviewed (Core Rule 10). So this plan is
  PROPOSED, not auto-executed. The override (part 2) must stay default-off + audited; the kernel-edit
  and "destroy history without explicit per-op grant" floor must remain.

## Status: IMPLEMENTED (2026-06-02, owner-directed "full power") — clarify + scoped override.
Branch `fix/git-op-rule-rationalize`; kernel bumped v1.1.4 → v1.1.5. Both parts done:
1. CLARIFY — KERNEL-SLIM §567 + §697 restated as operation-RISK-based (destructive class gated by
   risk; R9 = separate axon/-integrity concern); autonomous-mode.md updated to match.
2. SCOPED OVERRIDE — `autonomous_mode.py` `grant.destructive` allow-list: a grant may delegate a
   SPECIFIC destructive op for a SPECIFIC non-kernel repo (`--destructive`), default-empty, audited,
   revocable; kernel-change NEVER delegable. Floor unchanged by default. Tests: test_autonomous_mode_destructive.py.
