# Project: axon-finish
schema-version: v4
status:        obsolete
workflow-step:  plan
branch:         main
created:        2026-05-25
goal:           Consolidate ALL remaining AXON activities across every project into one
                tiered, dependency-ordered backlog — the single source of "what's left."
source:         Cross-project survey + existence-check (2026-05-25). Key finding: the
                ~142-PR cross-project backlog is MOSTLY PHANTOM (stale spec records, not
                missing code — mcp_client / goal / orchestrator already shipped). The real
                remainder is small and gated. See masterplan.md.
profile:        Meta / consolidation project — not new features, a map of the TRUE
                remaining work and what gates each item (autonomous · usage · human · retired).
baseline:       tno/main green 4607 · 126 tools · 0 FAIL · freshness + coherence clean ·
                compass: structural 97 / usage 0.

## Start with
code-dev load axon-finish → work Tier A (autonomous) top-down; Tier B waits on usage.

---
> **CONSOLIDATED 2026-05-27** — moved to `obsolete/`; superseded by **axon-improvements**.
> Remaining scope (if any) is tracked in `axon-improvements/masterplan.md`. Original history preserved here.
