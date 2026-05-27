# F-005 — `code-dev chats list` references `TOOL(session, list)` — session.py has no `list` command

**personas**: P4-recovery-rio · **workflow**: W-12 · **severity**: S1
**date**: 2026-05-16 · **status**: open

## Reproduction

```bash
grep -n "TOOL(session" workspace/programs/code-dev-chats.md
# 23: rows ← TOOL(session, list, "--dir {sessions-dir}") | []

grep -n "elif args.cmd" tools/session.py
# (no "list" branch)
```

## Observed

PR-31 program `code-dev-chats.md` line 23 calls `TOOL(session, list, ...)`.
`tools/session.py` exposes: start, checkpoint, transition, recover, status —
no `list`.

## Expected

`session.py list --dir <sessions-dir>` returns JSON array of
`{id, state, started, last-event, last-program}`.

## File / line citation

- [workspace/programs/code-dev-chats.md](../../../../workspace/programs/code-dev-chats.md#L23)
- [tools/session.py](../../../../tools/session.py) — no `list` handler

## Proposed edit

Add to `tools/session.py`:

```python
def list_sessions(session_dir: Path) -> list[dict]:
    out = []
    for sf in sorted(session_dir.glob("*/_session.md")):
        hdr, _ = _parse(sf)
        if hdr:
            out.append({
                "id": sf.parent.name,
                "state": hdr.get("state", "unknown"),
                "started": hdr.get("started", ""),
                "last-event": hdr.get("last-event", ""),
                "last-program": hdr.get("last-program", ""),
            })
    return out
```

Plus CLI branch in `main()`:

```python
elif args.cmd == "list":
    print(json.dumps(list_sessions(Path(args.dir)), indent=2))
```

~15 LOC added to an existing file. No new files.

## Rationale

Without this, W-12 (chats) is entirely non-functional. P4's primary workflow.
