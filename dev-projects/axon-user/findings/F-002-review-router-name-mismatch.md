# F-002 — code-dev-review router calls internals whose `# PROGRAM:` doesn't match

**personas**: P3, P5 · **workflow**: W-10 · **severity**: S1
**date**: 2026-05-16 · **status**: open · **depends-on**: F-001

## Reproduction

```bash
grep "EXEC(code-dev-review-" workspace/programs/code-dev-review.md
# EXEC(code-dev-review-scope)
# EXEC(code-dev-review-self)
# EXEC(code-dev-review-tests)

head -1 workspace/programs/code-dev-review-scope.md
# → "# PROGRAM: code-dev-scope-check"
```

## Observed

Review router (PR-28 rewiring) calls `code-dev-review-{scope,self,tests}`, but
those files' `# PROGRAM:` headers still announce `code-dev-{scope-check,
self-review, suggest-tests}`. Dispatch by header → "program not found".

## Expected

EXEC target resolves to the file *and* the header agrees.

## File / line citation

- [workspace/programs/code-dev-review.md](../../../../workspace/programs/code-dev-review.md#L33)
- [workspace/programs/code-dev-review-scope.md](../../../../workspace/programs/code-dev-review-scope.md#L1)
- [workspace/programs/code-dev-review-self.md](../../../../workspace/programs/code-dev-review-self.md#L1)
- [workspace/programs/code-dev-review-tests.md](../../../../workspace/programs/code-dev-review-tests.md#L1)

## Proposed edit

Subsumed by F-001 sweep.

## Rationale

`code-dev review` is one of the documented top-10 verbs (cheatsheet). It is
silently broken post-PR-28 until F-001 is applied.
