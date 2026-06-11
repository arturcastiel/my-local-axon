# PR-9 — reduce-surface + residue [C7 check-structure]

Status: merged
Merged: MR !175 → main (squash) · crucible green 30 controls
Branch: general-bugfix/pr-9-reduce-surface → main
Depends-on: PR-3 (merged)
Phase: 3-prs
Covers: §B7 (string-REPLACE anti-pattern), §B3 (migration residue), surface duplication

## Change
- **NEW `TOOL(meta, set/get)`** — field-addressed `_meta.md` access, atomic via the
  substrate (R9 + dry-run apply automatically). The single mutation verb replacing
  literal string REPLACE (the silent-no-op anti-pattern).
- **NEW `residue_lint`** (4 residue classes, deterministic): dead double-DONE tails ·
  repeated-precondition corruption · alias-identity collisions · literal meta-writes.
  Wire-time cleanup: **22 dead tails removed, 1 identity fixed** (review-self).
  Crucible control WARN with `promotes_on` = the 27-site meta-write migration
  (keystone-compliant — no graveyard).
- **4 alias-stubs DELETED** (check-structure, scope-check, suggest-tests, diff) with
  routes rewired to the real dispatchers — `check-structure` now reaches the REAL
  structure audit (`code-dev-safety-audit --structure`), closing the C7 wrong-audit bug.
  Deprecation-logged; dangling synapse edges removed (the DAG BLOCK gate caught them).
- **Single health-score writer**: `health.py --persist` owns `L:health-score(+date)`;
  stats.md writes removed (reads only); self_care + health-check route through it.
  Bonus latent bug fixed: health.py never bound its parsed args (`--include-kernel`
  was dead since birth — exposed by the edit, now bound).
- **Route conformance lock**: every `EXEC(code-dev-*)` target in the dispatcher must
  exist (the dead-route class, mechanically).

## Deferred (explicit follow-ups, not silent)
- The 27 literal meta-write call-sites → `TOOL(meta, set)` migration (the control's
  promotes_on condition; todo filed).
- freeze/thaw↔hold + divide/combine↔partition de-dup · `phases/{name}/` dir retirement
  (5 consumers) · simulate/run implementation fold · full route-manifest rewrite —
  each is a behavioral refactor deserving its own gate cycle (todo filed).

## Guarded-by
- `residue-lint` (promotes_on) · DAG consistency (BLOCK, proved itself here) ·
  route-conformance + 6 PR-9 locks. Gate green (30 controls).
