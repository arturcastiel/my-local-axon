# ADR-002 — Descope scheduler preemption + starvation-prevention (doc honesty)
Status:   accepted
Date:     2026-07-03
Owner:    axon-bugfix01 (decision D2, owner-delegated; kernel edit explicitly ordered by owner 2026-07-03)
Findings: C10 (audit 2026-07-01)

## Context
C10: SCHEDULER.md and KERNEL-SLIM.md documented a full preemption protocol (PAUSE → SNAPSHOT →
preempt-log → RESTORE → RESUME) and starvation-prevention aging with LITERAL ZERO backing code —
queue_tool.py supported add/list/complete/pop/clear only; PREEMPT exists only as a symbolic op in
core/LANG.md with no caller anywhere. The queue's real defects (lossy pop, unenforced deps,
inverted clear semantics) are FIXED for real (PR-015); the preemption prose is not implementable
without a process model AXON does not have.

## Decision
- Preemption + starvation-prevention are DESCOPED, not implemented: the kernel and SCHEDULER.md
  now say so explicitly. A !CRIT arrival while work is active is SURFACED to the user
  (QUERY/interrupt gate), never auto-preempted.
- PAUSE/RESUME/PREEMPT remain language-spec ops (core/LANG.md) — usable by future work, marked
  as having no scheduler backing today.
- Both QUEUE.md copies become contract documentation pointing at queue.json (the real state) —
  the markdown tables were permanently stale because no tool ever wrote them.

## Consequences
- KERNEL-SLIM.md's scheduler section stops overselling; what it now claims is mechanically true.
- Re-scoping preemption later = a real design project starting from this ADR (needs a process
  model + checkpoint/restore substrate, not just queue fields).
