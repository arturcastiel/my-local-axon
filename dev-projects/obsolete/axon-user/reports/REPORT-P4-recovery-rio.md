# REPORT — P4 · recovery-rio

**date**: 2026-05-16 · **workflows attempted**: W-06, W-07, W-12, W-13
**status**: blocked at W-12 (chats); state-save/restore (W-06) broken

## In-character summary

Where was I... right. Multi-project, multi-chat user. I lose track. I rely on
`code-dev resume`, `code-dev chats list/switch`, and the `state-*` save/restore.

Three independent S1 issues:

- **F-005 — `chats list` calls `TOOL(session, list)`** but `tools/session.py`
  has no `list` subcommand. The whole `chats` family (PR-31) doesn't run.
- **F-006 — `chats switch` calls `transition` with `--from/--to`** flags
  the tool doesn't accept. Switch fails silently.
- **F-007/F-008 — state-save / state-restore broken** (see P3 report).
  My compaction-survival workflow has no save/restore.

Compaction itself (W-13) works fine via `code-dev resume`, which delegates to
the older `code-dev-state-resume` (PR-27 rename) — but only because the
alias-stub forwards correctly. Once F-001 is fixed, this remains the most
robust recovery path.

## Top findings I filed

| id     | sev | summary                                                  |
|--------|-----|----------------------------------------------------------|
| F-005  | S1  | `code-dev chats list` — session.py has no list command   |
| F-006  | S1  | `code-dev chats switch` — transition arg mismatch        |
| F-007  | S1  | state-save copies tag, not save semantics                |
| F-008  | S1  | state-restore is a 7-line stub                           |

## Top-3 proposed edits

1. **F-005** — add `list_sessions()` (~15 LOC) to `tools/session.py` + CLI
   branch. Unblocks all of PR-31.
2. **F-006** — one-line fix in `code-dev-chats.md` to use the tool's actual
   `--path/--state` args.
3. **F-007/F-008** — accept aliasing semantics; correct headers in
   state-save, delete state-restore. Removes the false promise.

## Verdict

`chats` and `state-save/restore` are nominally PR-31/PR-27 deliverables but
neither runs end-to-end. They look great in CHANGELOG but the wires don't
connect to the tools. Surgical fixes only — no new code.
