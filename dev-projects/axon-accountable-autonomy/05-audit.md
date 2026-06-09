# Phase 5 — Audit · axon-accountable-autonomy

**Verdict: the "spawn and move on" drift now has a mechanical guard, not just prose.** A ledger records
delegated/background work; the Stop hook surfaces anything un-reconciled at turn-end. Confidence 9/10.

## Residual / deferred (deliberate)
- **Explicit recording** (owner choice): the hook only catches work that was `open`ed — recording
  relies on discipline. Auto-capture from spawn surfaces (Workflow/Agent/background Bash) is the
  stronger-coverage follow-up if the explicit form proves leaky.
- **LOG-ONLY** (owner choice): surfaces, never blocks. Escalation to a hard stop is an owner switch,
  same posture as the response-gate — only after it's proven false-positive-free.
