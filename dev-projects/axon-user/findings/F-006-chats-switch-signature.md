# F-006 — `code-dev chats switch` calls `transition` with `--from/--to` args session.py doesn't accept

**personas**: P4 · **workflow**: W-12 · **severity**: S1
**date**: 2026-05-16 · **status**: open · **depends-on**: F-005

## Reproduction

```bash
grep -A2 "TOOL(session, transition" workspace/programs/code-dev-chats.md
# TOOL(session, transition,
#      "--session {sessions-dir}/{chat-id}/_session.md --from frozen --to active")
```

`session.py transition` expects `--path` + `--state`, not `--session`/`--from`/`--to`.

## Expected

Either program matches tool, or tool extends to accept the program's args.

## Proposed edit

Edit [code-dev-chats.md L24-25](../../../../workspace/programs/code-dev-chats.md#L24):

```diff
-  TOOL(session, transition,
-       "--session {sessions-dir}/{chat-id}/_session.md --from frozen --to active")
+  TOOL(session, transition,
+       "--path {sessions-dir}/{chat-id}/_session.md --state active")
```

## Rationale

Matches the existing tool surface; no new flags needed.
