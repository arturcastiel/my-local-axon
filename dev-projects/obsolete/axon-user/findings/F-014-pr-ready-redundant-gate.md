# F-014 — `pr-ready` Gate A duplicates `preflight` Gate 0 (branch-sync twice)

**personas**: P2 · **workflow**: W-05 · **severity**: S2
**date**: 2026-05-16 · **status**: open

## Reproduction

Read:
- [code-dev-pr-ready.md L30-34](../../../../workspace/programs/code-dev-pr-ready.md#L30) — Gate A: branch-sync
- [code-dev-safety-preflight.md L30](../../../../workspace/programs/code-dev-safety-preflight.md#L30) — Gate 0: branch-sync

`pr-ready` calls `preflight` (Gate C). Both check branch sync.

## Observed

Two `git fetch` + `git rev-parse @{u}` invocations per `pr-ready`.

## Expected

Single branch-sync check.

## Proposed edit

In `code-dev-pr-ready.md`: drop Gate A entirely, rely on Gate C
(preflight handles it). Or, in `code-dev-safety-preflight.md`, accept a
`--skip-branch-sync` arg that pr-ready passes.

Recommended: drop Gate A from pr-ready (10-line removal).

## Rationale

Faster + clearer gate hierarchy.
