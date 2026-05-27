# F-003 — code-dev-preflight mislabeled "alias stub" but is the full implementation

**personas**: P2, P5 · **workflow**: W-09 · **severity**: S1
**date**: 2026-05-16 · **status**: open

## Reproduction

```bash
head -5 workspace/programs/code-dev-preflight.md
# # PROGRAM: code-dev-preflight
# # desc:    alias stub — superseded by code-dev-safety-preflight; removed next release.
wc -l workspace/programs/code-dev-preflight.md
# 9 lines (post-stub) — full preflight is now in code-dev-safety-preflight.md
```

Wait — actually after PR-28's stub-overwrite, `code-dev-preflight.md` *was* turned
into a stub but the **destination** `code-dev-safety-preflight.md` was the copy. So
the active program now lives at the new file. Then F-001 still applies to
safety-preflight's header.

Cross-cutting issue: callers like `code-dev-pr-ready.md#L53` still EXEC
`code-dev-preflight` (the stub). Stub forwards via `EXEC(code-dev-safety-preflight $@)`,
which fires `LOG(WARN)` on every `pr-ready` call. Constant warn spam.

## Expected

- Either rewire callers to the new name (silence the warn), or
- Convert the WARN to a single one-shot DEBUG log per session.

## File / line citation

- [workspace/programs/code-dev-preflight.md](../../../../workspace/programs/code-dev-preflight.md#L1)
- [workspace/programs/code-dev-pr-ready.md](../../../../workspace/programs/code-dev-pr-ready.md#L53)

## Proposed edit

```diff
- preflight ← EXEC(code-dev-preflight, mode="check-only", pr=pr) | ∅
+ preflight ← EXEC(code-dev-safety-preflight, mode="check-only", pr=pr) | ∅
```

One line in `code-dev-pr-ready.md`.

## Rationale

Removes a guaranteed-on-every-push WARN log. Aligns with PR-26/27/28 rename intent.
