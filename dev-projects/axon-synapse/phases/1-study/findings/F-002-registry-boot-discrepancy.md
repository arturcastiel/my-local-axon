# F-002: Registry has 75 tools but boot reports 69 — OPTIONAL tools invisible to menu/status

**Severity:** medium
**Track:** T-A
**Date:** 2026-05-17

## Evidence

- `tools/REGISTRY.json` contains 75 tool entries.
- `python3 axon.py boot` JSON output reports `tools.count == 69`.
- REGISTRY status breakdown: ACTIVE=69, OPTIONAL=6.
- Difference is exactly the 6 OPTIONAL tools — boot filters them out.

The 6 invisible-to-boot OPTIONAL tools include (from registry inspection):
`compile-write`, `hooks`, `compile-suggest`, `compile-optimizer`, `session-save`,
`programs-registry` (subject to full enumeration in T-A batch 2).

The menu and `status` program both render tool count from the boot output,
so the user has no way to discover that 6 additional tools exist.

## Why this matters for the synapse model

OPTIONAL tools that exist but are not discoverable cannot participate in:

- `synapse-suggest` rankings (engine reads ACTIVE only from boot context).
- `find-program` capability search (binds to the visible registry).
- Menu rendering (`Tools 69 active` line never mentions OPTIONAL).

This means the orchestrator's view of available actions is **truncated** — a user
who needs `hooks` capability has no signal it exists.

## Implication for Phase 2 / Phase 3

- Decision needed: are OPTIONAL tools "feature flags" (user must opt-in) or
  "supplementary" (always available, just lower-priority)?
- If feature-flagged: surface them in menu with `[OPTIONAL]` tag + a one-command
  enable path (e.g. `tool enable hooks`).
- If supplementary: include in boot's tool count, distinguish in `find-program`.

## Suggested action

- **Phase 2 design Q.** Codify OPTIONAL semantics. Add `requires_opt_in: bool`
  to REGISTRY schema if feature-flag semantics chosen.
- **Phase 3 PR seed.** `menu.md` update — surface OPTIONAL tool count and a
  one-command enable path. `axon-audit` extension — flag OPTIONAL tools that
  have no opt-in mechanism.
