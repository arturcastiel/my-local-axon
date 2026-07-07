# ADR-004 — L: scope has ONE backend: the .md longterm store
Status:   accepted
Date:     2026-07-07
Owner:    axon-bugfix01 (decision D3, owner-delegated 2026-07-03)
Findings: C9 (audit 2026-07-01; live-verified split-brain)

## Context
C9: `config wizard` wrote L:inference-mode etc. via tools/kv_store.py (diskcache), while the
kernel's own gates (KERNEL-SLIM inference gate, menu, boot) resolve L: via memory.py/_longterm.py
over workspace/memory/longterm/*.md. Each backend reported the other's keys as not-found: running
the wizard to change autonomy-governing settings was a SILENT NO-OP for the behavior it was
supposed to change. Independently confirmed for L:health-score — a stale frozen-at-100 .md orphan
with no current writer (health.py wrote the kv side).

## Decision
- The CANONICAL and ONLY backend for the L: scope is `workspace/memory/longterm/*.md`, read via
  `_longterm.py` (the single reader, F18) and written via `_longterm.write_longterm_value` /
  memory.py (the single writer, F43 — atomic + rollback sidecars).
- kv_store REFUSES the `L:` namespace loudly in both directions (get/set/delete/exists exit 2
  with a pointer here) — the split-brain cannot be silently recreated. kv-store remains available
  for high-frequency NON-scope data.
- config.md and health.py rewired to the canonical writer; the health-score orphan is now live
  (real writer + rollback).

## Rejected
- Converging on diskcache: the kernel's gates, the boot loader, the hooks (dev-mode!), and every
  R_* rule read the .md store — moving them all to diskcache risks the exact write-gate
  inconsistency F18 fixed, and .md files are git-visible/auditable.
- Dual-write bridging: hides the problem, doubles the failure modes.

## Follow-up (out of scope)
- W: keys in kv-store would be the same class; the working scope's canonical home is
  workspace/memory/working/*.md. Guard if a real consumer appears.

## Related

- Plan: [`../02-plan.md`](../02-plan.md)
