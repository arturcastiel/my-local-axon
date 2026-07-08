slug:            doctrine-v2
schema-version:  v4
status:          backlog
phase:           (none)
workflow-step:   (none)
branch:          (none)

## Working Context
Successor to axon-next. Nothing here silently evaporated from v1 — each item was a
deliberate, council-endorsed deferral (economist + all seats: halt-and-handoff first,
earn mutation with receipts).

### Scope (v2)
- PR: mid-run APPEND-REPAIR deviation mechanics — a repair node appended to a live
  trajectory + re-verify + resume (the riskiest new mechanic; v1 halts instead). Requires
  the loop_receipt `dag-repair` intent (already reserved in v1.1).
- PR: legacy vocabulary alignment — kernel-change (grant) vs kernel-edit (aegis
  INVIOLABLE); amend/rebase into aegis INVIOLABLE.
- PR: wire develop/pr-create/merge/build through aegis_policy.resolve() mechanically for
  NON-doctrine programs (doctrine runs already route per-node in v1).
- PR: LIVE external-repo unattended mission — the doctrine's first external-evidence run,
  launched once doctrine-arming's 3-clean-attended-run gate is met on a real project.
- Optional: goal.* ctx deepening if a real routine needs richer acceptance predicates.

### Entry condition
v1 (axon-next) merged + at least one real attended doctrine mission run by the owner.
