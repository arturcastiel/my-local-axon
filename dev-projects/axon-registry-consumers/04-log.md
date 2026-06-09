# Implementation Log — axon-registry-consumers (F22 finish)

## Merged — 2026-06-01
| PR | MR | What |
|----|----|------|
| PR-1+PR-2 | !96 | Migrated 12 REGISTRY consumers to `_axon_registry` (combined with the lock update, since they're causally bound). 3 came fully off the literal (compile_optimizer, drift, rename_snapshot) → dropped from the lock ALLOWLIST; 9 delegate the LOAD but still name a path for `load_registry(path=...)` → stay. Lock now also scans `tools/rules/` (closes the audit's scope hole) with `r_no_orphan_tools` allowlisted. |

**main 32161a2 → (now 0d0c624) · gate 22/0.**

## Method note (accountable autonomy in practice)
Migration ran as a 20-agent workflow; agents self-reported `verified:true` on all 12. The crucible gate
(reconciliation) caught a real failure they didn't: my own F22 `test_allowlist_only_shrinks` ratchet
demanded the 3 fully-migrated files leave the allowlist. Fixed + re-gated green before merge. The
self-reports were NOT trusted — the loop was tended, not abandoned.

## Residual (acceptable)
The 9 path-parameterised consumers still construct a REGISTRY.json path to pass to the accessor — the
schema-coupling (the real F22 risk) is gone, but path-derivation remains for files that target a
non-default/parameterised registry location. That's correct for them.
