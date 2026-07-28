# Project-wide prohibition seeds

These entries seed each new phase's `_dont-do.md` on `code-dev phase start`.
- Never re-report a bug already ledgered by axon-bugfix01/02 (they are fixed + merged) — verify against their AUDIT-FINDINGS first.
- Never ledger a finding that was not reconfirmed against SOURCE + (where non-mutating) a LIVE run.
- Never fix inside axon/ kernel/core without owner (inviolable floor); capture + propose only.
