# Handoff — PR-F alias cleanup (DEFERRED 2026-05-26)

## Why deferred
Removing the 18 deprecated code-dev-* aliases is a CORPUS-WIDE refactor, not housekeeping:
- ~253 standalone references in other program files + 44 in the code-dev.md router.
- PREFIX-COLLISION hazard: `code-dev-pr` is a prefix of ~15 real programs
  (code-dev-pr-create/-review/-sync/-link/...); `code-dev-shadow` of code-dev-knowledge-shadow.
  Regex replacement WILL corrupt real names. Risk >> value (aliases work; sunset "next release").

## The 18 aliases → canonical
audit→safety-audit · decision→journal-decision · event→journal-event · explain→knowledge-explain
freeze→safety-freeze · handoff→state-handoff · impact→knowledge-impact · log→journal-log
metrics→state-metrics · pr→pr-create · resume→state-resume · search→journal-search
self-review→review-self · shadow→knowledge-shadow · status→state-status · tag→state-save
tour→lifecycle-tour · undo→state-undo

## How to do it safely (when chosen)
1. Build/use a proper RENAME TOOL (AST/token-aware, NOT regex) that distinguishes
   `EXEC(code-dev-pr)` (alias) from `code-dev-pr-create` (real) — exact-token, paren-delimited.
2. Repoint router EXEC(code-dev-<alias>) → EXEC(<canonical>) (44 refs, paren-delimited = safe).
3. Clean next-suggests + cross-refs (253) — standalone-token only, prefix-safe.
4. Delete 18 alias .md + 18 .cmp.md.
5. programs-registry generate; run the FULL crucible gate (pytest) before push; revert on any red.
6. Each canonical target already exists + is real (verified 2026-05-26).
