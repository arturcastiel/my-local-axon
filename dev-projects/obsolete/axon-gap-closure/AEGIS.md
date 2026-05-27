# AEGIS — AXON's safe-autonomy mechanism

The triad (+audit) extracted from the code-dev autonomous loop, named 2026-05-26.

  GRANT   (autonomous-mode)  — who may act, scoped + revocable
  GATE    (crucible)         — proof it's safe; fail-closed, green-or-no-go
  POLICY  (project _policy)  — which steps are delegated, per context
  + AUDIT (reversible + logged)

AEGIS = Authorized, Effected through a Gate, Inside a Scoped policy. crucible is
the gate INSIDE aegis; aegis is the whole shield AXON acts behind.

Selector for "who gets AEGIS":
- readers (49 programs)         → exempt (no side-effect to gate)
- low-risk mutators             → audit + reversibility only (no grant/gate)
- medium/high-risk mutators     → full triad
- kernel / destructive          → NEVER autonomous (inviolable)
Prerequisite: populate `side-effect-risk` (currently unset on all 186) — it's the selector.

Per-program form (generalization, follow-up): a neuron `autonomy:` contract block
{eligible, gate:[controls], ops:[grantable], reversible}. PR-H ships the coarse
(project-level) policy; per-program is the fine-grained follow-up.

Flagship next consumer after this project: the auto-improve / igap-improve loop
(measure→close-gap→grow under a crucible gate) — the "aliveness" target.
