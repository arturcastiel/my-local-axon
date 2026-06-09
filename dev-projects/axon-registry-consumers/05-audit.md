# Phase 5 — Audit · axon-registry-consumers

**Verdict: F22 consumer migration substantially complete.** Of the 20 backlog consumers: 12 migrated
to the accessor (3 fully off the literal, 9 delegate the load via `path=`), 6 stay raw by design
(registry_drift/axon_audit validators, coherence_lint/narrate target the *programs* registry, freshness
prints it, programs_registry is the programs registry), and the lock now covers `tools/rules/`.
Confidence 8.5/10. The accessor is now the single load/parse path; remaining path literals are for
parameterised targets, not schema coupling.

The biggest *safe* gap from the audit is closed.
