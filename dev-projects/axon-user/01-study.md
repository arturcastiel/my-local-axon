# 01-study — AXON observed from a user POV

Compiled from 5 personas × 15 workflows simulation (2026-05-16). Authoritative
detail in per-persona reports under [reports/](reports/) and individual findings
under [findings/](findings/).

## What works well

- **Boot + identity gate** — once a novice gets past `startup.md`'s audience
  split, the kernel reads cleanly, the menu renders, and identity output is
  honest about its execution-layer policy.
- **`code-dev-lifecycle-tour`** — the single most novice-friendly program.
  Linear, well-paced, actionable next steps. (P1 reported it as the bright spot.)
- **Per-program budget declarations** (PR-20) — universal coverage; 115
  programs, 0 violations under `budget_lint`.
- **`call_graph` cycle detector** — clean DAG post-PR-28, longest path 5,
  ceiling 10. Catches a class of regressions the older OS couldn't.
- **`scan_pre_push.py`** + `lint_paths.py` — two strong audit guards;
  pre-commit hooks make them load-bearing.
- **Wave-by-wave commit/push discipline** — the four-wave plan landed clean,
  with reproducible commit hashes and CHANGELOG entries.

## Where it falls short

Six themes emerged:

### 1. Rename umbrella shipped half-done (F-001)

PR-26 / PR-27 / PR-28 renamed 24 program files but **the rename copied bodies
verbatim** — the `# PROGRAM:` declaration on line 1 still names the *old*
program in every renamed file. Dispatch-by-header is therefore broken for the
entire W4 umbrella.

This is the dominant issue. Every persona except P1 ran into it.

### 2. Stale wires from absorbed aliases (F-002, F-003, F-009, F-010)

PR-28 absorbed 5 verbs (`scope-check`, `self-review`, `diff`, `suggest-tests`,
`check-structure`) into `code-dev-review --mode=X` and
`code-dev-safety-audit --structure`. The stubs forward `--mode=X` as CLI args;
the router reads `W:code-dev-review-sub`. Flags are silently dropped, `--mode=all`
runs instead of the requested submode. The `diff` mode has no router branch at all.

### 3. Tool/program contract mismatches (F-005, F-006)

PR-31's `code-dev-chats.md` calls `TOOL(session, list, ...)` and
`TOOL(session, transition, --from/--to)`. Neither matches `tools/session.py`'s
actual surface. The entire `chats` family is dead-on-arrival.

### 4. Half-implemented partners (F-007, F-008)

`code-dev-state-save.md` is a body-copy of `code-dev-tag.md` — not actually
"state save" semantics. `code-dev-state-restore.md` is a 7-line stub that
doesn't restore any files. PR-27's headline "state-save / state-restore
partner" doesn't run end-to-end.

### 5. Documentation drift (F-011, F-012, F-015, F-018, F-019)

- `code-dev-plan.md` declares blanket `output-cap: 2000` while per-mode block
  has `tactical: output-cap 6000`. Tools accept both; users get whichever bites.
- `journal-log` vs `journal-event` vs `journal-decision` — no `# WHEN` line
  distinguishes them.
- Cheatsheet truncates at 54 chars, hiding deprecation notices.
- 3 dead cross-refs in `AXON-DOCS-SCHEMA.md` (caught by `docgen_verify` —
  failing build).

### 6. Friction-by-default in scaffolding (F-014, F-016, F-017)

`code-dev new` fires four sequential QUERYs with no defaults; `startup.md`
has an unclear audience split; `pr-ready` Gate A duplicates `preflight` Gate 0.

## Per-persona patience burn

| persona            | patience-budget | turns spent | result        |
|--------------------|-----------------|-------------|---------------|
| P1 novice-naomi    | 6               | 11          | recovered after tour |
| P2 speedrun-sam    | 8               | 8           | abandoned at W-14    |
| P3 careful-cassie  | 20              | 20+         | filed everything, didn't abandon |
| P4 recovery-rio    | 12              | 9           | blocked at W-12, no abandonment |
| P5 meta-mira       | 40              | 25          | audit complete       |

## Token-economy observations

The per-mode budget contradiction (F-011) and absorbed-alias `mode=all` fallback
(F-009) both lead to *wasted* tokens. A `code-dev scope-check` that silently
runs the full review is 3-4× the intended cost.

## Hot files

Most cited in findings:
1. [`workspace/programs/code-dev-review.md`](../../workspace/programs/code-dev-review.md) — F-002, F-009, F-010
2. [`workspace/programs/code-dev-chats.md`](../../workspace/programs/code-dev-chats.md) — F-005, F-006
3. [`workspace/programs/code-dev-state-save.md`](../../workspace/programs/code-dev-state-save.md) — F-001, F-007
4. [`workspace/programs/code-dev-state-restore.md`](../../workspace/programs/code-dev-state-restore.md) — F-001, F-008
5. [`tools/session.py`](../../tools/session.py) — F-005, F-006
6. 22 other PR-26/27/28 renamed files — F-001

## Conclusion

AXON's structure is sound; the **last-mile verification was missing**. The W4
audits checked filenames and `EXEC` targets but not the `# PROGRAM:` header
inside each file. One 24-line sweep (F-001) plus six small targeted edits
unblocks every S1 and most S2 findings.
