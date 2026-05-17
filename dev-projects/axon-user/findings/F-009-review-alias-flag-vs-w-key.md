# F-009 — Absorbed-alias stubs forward `--mode=X` flags that router ignores

**personas**: P5 · **workflow**: W-14 · **severity**: S2
**date**: 2026-05-16 · **status**: open

## Reproduction

```bash
grep -h EXEC workspace/programs/code-dev-{scope-check,self-review,suggest-tests,diff,check-structure}.md
# EXEC(code-dev-review --mode=scope $@)
# EXEC(code-dev-review --mode=self $@)
# EXEC(code-dev-review --mode=tests $@)
# EXEC(code-dev-review --mode=diff $@)
# EXEC(code-dev-safety-audit --structure $@)
```

`code-dev-review.md` router reads `sub ← RETRIEVE(W:code-dev-review-sub) | "all"` and
branches on `sub ≡ "scope" | "gaps" | "tests"`. `--mode=X` CLI flags are not read.

## Observed

The 5 absorbed-alias stubs forward by CLI flag, but the router consumes a
W: scope. Aliases silently fall through to `sub == "all"` and run everything.

## Expected

Either: (a) stubs `STORE(W:code-dev-review-sub, "X")` before EXEC, or
(b) router accepts `--mode` CLI flag.

## Proposed edit (option a — preferred)

For each stub, replace `EXEC` line with:

```
STORE(W:code-dev-review-sub, "scope")
EXEC(code-dev-review)
```

5 files, 2-line change each.

Also: rename mismatched router branches —
`code-dev-self-review` forwards `mode=self`, but router branch is `sub ≡ "gaps"`.
Pick one: rename branch to `self` OR keep `gaps` and have the stub store `gaps`.

## Rationale

Right now `code-dev scope-check` actually runs the full review — slow, wasteful,
and confusing. This is a W-14 deprecation regression.
