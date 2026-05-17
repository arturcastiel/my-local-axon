# F-010 — `code-dev-diff` alias forwards to `code-dev-review --mode=diff` but router has no `diff` branch

**personas**: P5 · **workflow**: W-14 · **severity**: S2
**date**: 2026-05-16 · **status**: open · **related**: F-009

## Reproduction

```bash
grep -n "sub ≡ \"diff\"" workspace/programs/code-dev-review.md
# (no match)
```

## Observed

`code-dev-review.md` only has `scope`, `gaps`, `tests` branches plus the
implicit `all`. There is no `diff` branch. The `code-dev-review-diff.md`
internal exists (PR-28) but is never EXEC'd.

## Expected

Router has a `diff` branch that EXECs `code-dev-review-diff`.

## Proposed edit

Add to [code-dev-review.md](../../../../workspace/programs/code-dev-review.md#L40)
after the `tests` block:

```
IF sub ≡ "diff" OR sub ≡ "all" →
  → ""
  → "▼ DIFF (file-level changes)"
  EXEC(code-dev-review-diff)
```

## Rationale

The internal exists but is orphaned. Three lines fix it.
