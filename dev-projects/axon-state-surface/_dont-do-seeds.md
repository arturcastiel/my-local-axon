# Project-wide prohibition seeds

These entries seed each new phase's `_dont-do.md` on `code-dev phase start`.
Add project-wide invariants here (e.g. 'never commit generated files').

- No new top-level state store and no new top-level tool unless justified — extend the
  existing snapshot tool (`axon-state`) + `menu.md`. (inherited from axon-stale-pointers: reduce-surface)
- Never "fix" an execution-layer reasoning error by changing program logic — attribute the
  failure to its layer first. (owner directive 2026-07-10)
