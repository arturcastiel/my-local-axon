# pr-9.6 — `preflight --mode=summary` + `next` reads `_meta.next-action`

**Wave**: W2 · **Goals**: T-C1, T-C2 (R2 top-15) · **Depends-on**: none

## Why (problem statement)
`code-dev preflight` today emits ~30 lines of structured output before every PR action. `code-dev next` re-reasons from `_meta.md` + `_actions.log` every time even when the cached "next-action" hint is sufficient. Both are hot-paths in the per-PR loop: R2 measured them as #6 (T-C1) and #7 (T-C2) on the executive backlog at score 3.0 each. Two small ergonomics changes save ~1.5 KB/turn of agent context — meaningful when stacked across a multi-PR session.

## Evidence (from studies)
- `helpers/cd-c4-p3-improvements.md` Rank 6, 7 → T-C1 (preflight summary, 3.0) and T-C2 (next reads next-action, 3.0).
- `helpers/cd-c3-p3-improvements.md` → "T-C1: preflight summary mode — 1-line `OK | <count> warnings | <count> blockers`".
- `helpers/cd-c3-p3-improvements.md` → "T-C2: `next` should read `_meta.next-action` (cached) first, fall back to legacy reasoning only if absent".

## Design notes
- `code-dev-preflight.md`: add `--mode=full|quick|summary` flag (default `full`).
  - `summary`: one line: `[OK|WARN|BLOCK] <count> warnings · <count> blockers (run with --mode=full for detail)`.
  - `quick`: existing `--quick` behavior (skip slow gates).
  - `full`: today's behavior.
  - All modes still write the full gate log to `_actions.log` so `--mode=summary` is genuinely fast for the user but observability is preserved.
- `code-dev-next.md`:
  - On entry, check `_meta.next-action` (single string field set by previous program completion).
  - If present and within freshness window (updated < 24 h ago and current PR state matches), emit it and return.
  - Else fall through to existing reasoning (`_actions.log` tail + `_meta.md` scan).
  - `_meta.next-action` is **set** by `code-dev-pr-review`, `code-dev-pr-ready`, etc. as their final write.
- Both changes are additive: omitting the flag / field keeps old behavior.

## Pitfalls (from failure-mode catalog)
- **F-B4 lost last-program reference** → `next` falls through to legacy reasoning if `next-action` absent.
- **F-C2 static-prefix drift** → `preflight --mode=summary` output is short, no impact on prefix.
- Stale `next-action` (PR state changed since last write) → freshness guard (24 h + state hash) invalidates.

## Interface sketch
```text
$ code-dev preflight --mode=summary
OK · 0 warnings · 0 blockers (run with --mode=full for detail)

$ code-dev next
(cached) code-dev pr-review 3 --phase=4
```

## Spec (canonical)
- **Files**:
  - modified: `workspace/programs/code-dev-preflight.md`, `code-dev-next.md`; programs that already set state (review, ready) gain a `_meta.next-action` write.
- **Acceptance**:
  1. `preflight --mode=summary` prints ≤ 120 chars, single line.
  2. `next` reads `_meta.next-action` first if present and fresh, else falls back to legacy.
  3. Freshness: `next-action` ignored if `updated > 24 h` or PR state hash mismatch.
  4. `tools/lint_paths.py` clean.
- **Rollback**: revert; old behavior fully restored.
- **Owner**: AGENT writes; HUMAN sanity-checks one turn.

## Codebase grounding
- **modify**: [`workspace/programs/code-dev-preflight.md`](../../../../workspace/programs/code-dev-preflight.md) — add `--mode=summary` short-circuit at top of `## LOAD CONTEXT`; reads only `_meta.md` (`branch`, `phase`, `workflow-step`, `current-pr`), emits one line.
- **modify**: [`workspace/programs/code-dev-next.md`](../../../../workspace/programs/code-dev-next.md) (current 10-moment classifier, ~120 lines) — before `## SIGNALS` block, read `meta.next-action` if present; if set with ts < 1h old, dispatch directly to `MOMENT: cached-next` and emit cached recommendation. Otherwise fall through to existing 10-moment logic.
- **`_meta.next-action` schema**: `next-action: code-dev <verb>` + `next-action-set-at: <ISO>`. Programs writing this: `code-dev-handoff.md`, `code-dev-freeze.md`, `code-dev-pr-ready.md` (set after their work).

## Cross-refs
- Master plan: `../03-plan.md` § Wave 2 / PR-9.6.
- Helpers: `helpers/cd-c4-p3-improvements.md` (T-C1, T-C2), `helpers/cd-c3-p3-improvements.md`.
- Consumers: PR-25.5 extends `next` further.
