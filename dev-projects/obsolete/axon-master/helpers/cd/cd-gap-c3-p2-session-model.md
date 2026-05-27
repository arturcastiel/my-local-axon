# CD·GAP·C3·P2 — session / chat / handoff model (U-6)

> The "session" concept is currently scattered: `my-axon/chats/`, `code-dev handoff/freeze/thaw/tag/resume/undo`, kernel-level compaction, identity boot. Unify it.

## What exists today

| Concept              | Where                                          | Status              |
|----------------------|------------------------------------------------|---------------------|
| Boot anchor          | `startup.md` → `axon/KERNEL-SLIM.md`           | implemented         |
| Identity gate        | `axon/programs/identity.md`                    | implemented         |
| Chats                | `my-axon/chats/<id>/`                          | folder exists       |
| Handoff              | `code-dev-handoff.md`                          | exists              |
| Freeze / Thaw        | programs exist                                 | exists              |
| Tag / Resume         | programs exist                                 | exists              |
| Undo                 | `tools/undo.py` + program                      | exists              |
| Checkpoint           | `tools/checkpoint.py`                          | exists              |
| Compaction recovery  | memory note + boot re-anchor                   | implemented (informal) |
| Cross-session state  | `_meta.md`, `_actions.log`, `journal/`          | exists              |

## Problems

- **No single "session" object.** A session is implied by chat-id, but never modeled.
- **Handoff vs freeze vs tag**: overlapping verbs with unclear distinctions.
- **Compaction recovery is heuristic.** No formal checkpoint at compaction-boundary.
- **Resume** restores project state but not *conversational* state.
- **Chats folder** is undocumented in user-facing surfaces.

## Proposed model: Session = first-class object

```yaml
# my-axon/chats/<id>/_session.md
schema: session-v1
id: 2026-05-16-axon-master-r6
started: 2026-05-16T13:42:00Z
project: axon-master
last-program: code-dev-study
last-checkpoint: 2026-05-16T19:01:00Z
compaction-events:
  - at: 2026-05-16T18:00:00Z
    reanchored: true
tags:
  - r6-gap-study
  - pre-plan
state: active   # active | frozen | tagged | closed
```

### Operations

| Verb       | Effect                                                                  |
|------------|-------------------------------------------------------------------------|
| `handoff`  | write transition doc; mark state=closed; produce continuation note      |
| `freeze`   | snapshot state; state=frozen; can `thaw` later                          |
| `thaw`     | restore frozen session; state=active                                    |
| `tag <l>`  | label current session for later recall                                  |
| `resume`   | reattach: load project + last session + replay continuation note        |
| `undo`     | rollback last logical action                                            |
| `checkpoint` | manual save-point (between compactions)                              |

### Distinction (proposed canonical)

- **handoff** = "stop and prepare for someone else (or future-me) to pick up". Writes doc.
- **freeze** = "pause; come back to *this exact* session later". Snapshots; reversible.
- **tag** = "label this moment; I can find it again".
- **checkpoint** = automatic; recoverable across compaction.
- **resume** = "load latest session for project X".

## Compaction recovery (formalize)

Today: memory note says "if `axon/tools/boot.py` exists, run boot after compaction".

Proposed:
- Every N turns OR before a known token-budget threshold, write checkpoint.
- Checkpoint = `_session.md` + JSON of in-flight state (open files, pending verbs, last QUERY).
- On compaction-detected (heuristic: identity-gate triggered after long gap), agent:
  1. Re-boot via `startup.md`.
  2. Read latest checkpoint.
  3. Announce: "Resumed session <id>; last action: <X>; pending: <Y>."

## Chat folder layout (proposed)

```
my-axon/chats/<session-id>/
├── _session.md           # the session object
├── _checkpoints/
│   ├── <ts>.json
│   └── <ts>-context.md   # compressed context summary
├── _transcript/          # optional, agent-saved excerpts
│   └── <date>.md
└── handoff.md            # written on handoff
```

## Integration with `code-dev resume`

```
code-dev resume:
    proj = latest_project()
    sess = latest_session_for(proj)
    if sess.state == 'frozen': QUERY "thaw frozen session?"
    if sess.state == 'closed': start new session
    load(proj._meta.md)
    print continuation note + last 3 _actions.log entries
    state = active
```

## Cross-references

- Kernel rule 4 (always log significant events) interacts with session journaling.
- F-A1 (persona drift after compaction) mitigated by checkpoint+boot.
- F-C4 (compaction loses state) mitigated by frequent checkpoints.

## Wave plan

| Wave | Deliverable                                            |
|------|--------------------------------------------------------|
| SW1  | Document distinction (handoff vs freeze vs tag) in HOWTO |
| SW2  | Define `_session.md` schema + create on first verb     |
| SW3  | Auto-checkpoint every N turns                          |
| SW4  | Compaction-recovery hardening (test fixture)           |
| SW5  | Resume integrates session restoration                  |
| SW6  | Chat-folder UX (`code-dev chats list / show / switch`) |

## Acceptance criteria

- `my-axon/chats/<id>/_session.md` exists for the current session by end of R6.
- Distinction documented in `axon/HOWTO.md` or `workspace/AXON-DOCS-SESSIONS.md`.
- Checkpoint+restore tested across a synthetic compaction event.

## Open questions
- Do we keep per-session transcripts (large)? Probably summaries only, opt-in for full.
- Session ID format: timestamp + project + slug? Yes.
- Cross-project sessions (work on two projects in one chat)? Allow; `current-project` is per-session-step.

→ documentation strategy: `cd-gap-c3-p3-documentation.md`.
