# F-004 — code-dev-safety-audit-structure is a duplicate of check-structure, not a router target

**personas**: P3 · **workflow**: W-09 · **severity**: S1
**date**: 2026-05-16 · **status**: open

## Reproduction

```bash
head -1 workspace/programs/code-dev-safety-audit-structure.md
# → "# PROGRAM: code-dev-check-structure"
diff workspace/programs/code-dev-check-structure.md \
     workspace/programs/code-dev-safety-audit-structure.md
# (the rewrite of check-structure to a stub means the bodies now differ —
#  but the *new* file still claims to be code-dev-check-structure)
```

## Observed

PR-28 absorbed `check-structure` into `safety-audit --structure`. The chosen
implementation pattern created `code-dev-safety-audit-structure.md` as the
internal implementation. But:
1. Its `# PROGRAM:` header is still `code-dev-check-structure` (F-001).
2. The router `code-dev-safety-audit.md` does **not** dispatch on `--structure`
   to this file — there's no IF branch reading the flag.

## Expected

Either:
- `code-dev-safety-audit.md` adds `IF ARG(1) ≡ "--structure" → EXEC(code-dev-safety-audit-structure)`, OR
- Delete `code-dev-safety-audit-structure.md` and let the stub
  `code-dev-check-structure.md` forward directly.

## File / line citation

- [workspace/programs/code-dev-safety-audit-structure.md](../../../../workspace/programs/code-dev-safety-audit-structure.md#L1)
- [workspace/programs/code-dev-safety-audit.md](../../../../workspace/programs/code-dev-safety-audit.md#L1) — no `--structure` branch

## Proposed edit

Simpler path: delete `code-dev-safety-audit-structure.md`; update the stub
`code-dev-check-structure.md` to `EXEC(code-dev-safety-audit-structure-impl)` ...
or just keep stub forwarding to `safety-audit --structure` and add the IF branch.

Recommended: add IF branch in safety-audit.md (5 lines).

## Rationale

Removes a confusing duplicate, makes the absorbed-alias contract testable.
