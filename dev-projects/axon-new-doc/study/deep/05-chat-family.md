## AXON CHAT family — command reference

The CHAT family lets a user manage saved conversation threads ("chats") grouped into project folders. Every chat is a markdown file persisted to disk so any thread can be resumed.

### Two execution kinds (critical)
- **Agent-interpreted neurons** (`.md` AXON-LANG programs): `mode-chat`, `new-chat`, `open-chat`, `switch-chat`, `chat-folder`, `list-chats`, `chat-input`, and the internal `_chat-checkpoint`. These are NOT python scripts. They are stepped through by the host agent running the AXON OS and are invoked as AXON commands (e.g. you type `new-chat research/paper`). They do **not** appear in `tools/REGISTRY.json` and cannot be called via `python3 axon.py <name>`.
- **Supporting tools** (python, runnable via `python3 axon.py <tool>`): `session` (per-chat `_session.md` checkpoint/recovery), `programs-registry`, `lint-path-vars`, `index-update`. These back the neurons but are not the chat commands themselves.

### Where chats are stored (THE path)
- Programs reference the store ONLY through the path variable `W:myaxon-chats`.
- `W:myaxon-chats` is defined in `my-axon/MYAXON.md` as `/home/arturcastiel/projects/axon-sections/my-axon/chats/` (reached through the repo `my-axon` symlink).
- The literal `workspace/chats/` is the **old, pre-migration** location. It survives only in docs/diagrams (`axon/programs/help/mode-chat.md`, `tools/docgen.py`, `workspace/AXON-DOCS.md`) and in `workspace/programs/migrate-workspace.md`, which literally `mv workspace/chats my-axon/`. Treat any `workspace/chats` reference as stale.

### Command table
| Command | Kind | Mode flag | What it does |
|---|---|---|---|
| `mode-chat` (or `1`) | neuron | `!NORM \| read-only` | Renders the CHAT-mode dashboard: folder/chat counts (via `SCAN(W:myaxon-chats)`), active chat + goal, inference level, command list. |
| `new-chat [folder/]name` | neuron | `!NORM \| SPAWNED → RUNNING` | Parses `folder/name` (default folder `general`), GUARDs against duplicate, `MKDIR`s folder if new, checkpoints the current chat, WRITEs a new chat file, activates it, updates `INDEX.md`. |
| `open-chat [name]` | neuron | `!NORM \| SPAWNED → RUNNING` | Thin wrapper: passes `W:chat-target` through and `EXEC(switch-chat)`. |
| `switch-chat [name]` | neuron | `!NORM \| SPAWNED → RUNNING` | Finds target by stem (`SCAN depth=2`), checkpoints current, READs target, restores `## CONTEXT` keys into `W:`, restores goal/pinned, marks target active in `INDEX.md`. |
| `chat-folder new\|list [name] [desc]` | neuron | `!NORM \| SPAWNED → RUNNING` | `list`: SCAN depth=1 dirs + per-folder chat counts. `new`: MKDIR + append a §FOLDERS row to `INDEX.md`. |
| `list-chats` | neuron | `!NORM \| read-only` | Groups all chats by folder, reads only the 6-line header of each chat for goal/last-active/status, sorts by last-active DESC, flags the active one. |
| `chat-input` | neuron | `!NORM \| SPAWNED → RUNNING` | Free-text turn handler: requires an active chat, appends the user message to the chat file, agent replies scoped to the chat goal. Lives in `workspace/programs/` (not the OS layer). |
| `_chat-checkpoint` | internal neuron | declared `read-only` (but mutates) | Not user-invokable. Snapshots non-transient `W:` keys into the chat's `## CONTEXT`, sets Last-active/Status=paused, prepends a `## HISTORY` line. |

### Chat file format (single source of truth: `new-chat.md` write template)
A chat is `{W:myaxon-chats}{folder}/{name}.md` with this shape:
```
# CHAT: {name}
Folder:      {folder}
Created:     {date}
Last-active: {iso-timestamp}
Status:      active            # active | paused | archived
Goal:        {one-sentence goal}

## CONTEXT
# key: value pairs — a snapshot of W: keys, restored on switch-chat

## PINNED
# pinned notes, surfaced on switch

## HISTORY
# - {iso[:16]} {session summary}   (most recent prepended)
```
Notes: there is NO `CHAT-FORMAT.md` file (it is only named as a SCAN exclusion). The store also holds an `INDEX.md` with `Active:` / `Active-folder:` keys plus §FOLDERS and §CHATS tables, written incrementally by new-chat / switch-chat / chat-folder (no template exists; current `INDEX.md` is empty). `chat-input` additionally appends structured `{role, text, time}` records.

---

## Verified examples (REAL captured output — tool-run, read-only)

**1. Confirm chat programs are NOT runnable tools (they are neurons)**
```
$ python3 axon.py find-program chat
{"error": "Unknown tool 'find-program'. Run: python3 axon.py help"}
```
`find-program` is itself a program, not a registered tool — this is the tell that the chat commands are agent-interpreted neurons, not `axon.py` tools.

**2. The only chat program in the workspace registry is chat-input**
```
$ python3 axon.py programs-registry query --area chat
{"ok": true, "data": {"count": 1, "programs": [{"name": "chat-input",
 "file": "workspace/programs/chat-input.md", "status": "ACTIVE", "area": "chat",
 "description": "Process a free-text user message as a continuation of the active chat goal",
 "tools": ["clock"], "last_modified": "2026-05-26T06:24:42.170428+00:00Z"}]},
 "error": null}
```
The other seven chat neurons live in the OS layer `axon/programs/` and are not scanned by the workspace-programs registry.

**3. TRAP 1 proof — path variable W:myaxon-chats is defined, no rot**
```
$ python3 axon.py lint-path-vars list
{
  "ok": true,
  "defined_count": 24,
  "violations": []
,
  "hint": "all path variables are defined"
}
```
`lint-path-vars` parses WORKSPACE.md / MYAXON.md live and checks every `W:ws-*` / `W:myaxon-*` reference in the programs. Zero violations -> `W:myaxon-chats` (used by all chat programs) resolves cleanly to `my-axon/chats/`.

**4. The store today — empty, only INDEX.md**
```
$ ls -la /home/arturcastiel/projects/axon-sections/my-axon/chats/
-rwxrwxrwx 1 arturcastiel arturcastiel 0 May 16 06:54 INDEX.md

$ python3 axon.py session list --dir /home/arturcastiel/projects/axon-sections/my-axon/chats/
[]
```
No chat files or sessions exist yet; the format is therefore established purely by the new-chat write template.

**5. Supporting tool surface (help, non-mutating)**
```
$ python3 axon.py session --help
usage: session.py [-h] [--path PATH] [--dir DIR] [--chat-id CHAT_ID]
                  [--program PROGRAM] [--turn TURN] [--anchor ANCHOR]
                  [--summary SUMMARY] [--state STATE]
                  {start,checkpoint,transition,recover,auto-recover,status,list}
PR-9 _session.md manager
```

---

## Labeled session-transcript (agent-interpreted neuron — illustrative, NOT tool output)
The following is how `new-chat` then `list-chats` render when stepped through by the AXON OS agent. Output strings are taken verbatim from the `→` lines in `new-chat.md` / `list-chats.md`; runtime values are placeholders because executing them would mutate the store (out of scope for read-only study).

```
user> new-chat research/adjoint "Review adjoint gradient method"

[AXON executes new-chat.md]
▶ new-chat  ·  research/adjoint
─────────────────────────────────────────────────
Chat created: research/adjoint
Goal: Review adjoint gradient method

This is now your active chat. All work this session is tracked here.
Next: just start working · list-chats — see all chats · switch-chat — move to another

user> list-chats

[AXON executes list-chats.md]
▶ list-chats  ·  Active: adjoint
─────────────────────────────────────────────────
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CHATS  ·  research/adjoint active
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
── RESEARCH ──────────────────────────────
▶ adjoint                 Review adjoint gradient method
   last: 2026-06-17
  new-chat [folder/]name — create chat
  open-chat [name]       — resume a chat
  switch-chat            — interactive switch
  chat-folder new [name] — create a folder
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
Behaviorally this writes `my-axon/chats/research/adjoint.md` using the format template above and sets `W:active-chat=adjoint`, `W:active-chat-folder=research`.

---

## Gotchas / known defects (flag before relying on these)
- `_chat-checkpoint.md` is tagged `!NORM | read-only` but actually mutates the chat file (UPDATE `## CONTEXT`, UPDATE Last-active/Status, PREPEND `## HISTORY`). The read-only flag is wrong and would cause the pressure-gate to be skipped (KERNEL-SLIM.md:321).
- `chat-input.md` persists the assistant turn with `{role:"assistant", time:...}` but **no `text:` field** (lines 50-53), so assistant replies are not saved — likely a bug.
- Help text (`axon/programs/help/mode-chat.md:18`) still says chats live in `workspace/chats/[folder]/[name].md` — stale; the real path is `my-axon/chats/`.
- `chat-input` uses a modern synapse-contract header while the other seven use the legacy `# PROGRAM:` header; only `chat-input` is in the workspace registry.
