# pr-9 — `_session.md` + auto-checkpoint + atomic state-files

**Wave**: W2 · **Goals**: G.sess.01, G.sess.03, G.inf.04 (full) · **Depends-on**: PR-3 (atomic_write helper)

## Why (problem statement)
There is no per-chat session record today. After compaction the agent has no concrete object to read to discover "what was I doing"; resume relies on `_meta.md` alone, which is updated coarsely (per-PR-state, not per-turn). R6 marks U-6 (unified session/chat/handoff model) as a Tier-1 gap. The 2026-05-15 persona-drift incident also stems from this absence (no journal of intra-session checkpoints to anchor against). This PR adds `_session.md` + auto-checkpoint + extends `atomic_write` to cover all state files (closing F-B2/B3).

## Evidence (from studies)
- `helpers/cd-gap-c3-p2-session-model.md` → full design: `_session.md` per chat, state enum, checkpoint cadence.
- `helpers/cd-gap-c2-p4-failure-modes.md` → F-B2 race, F-B3 corruption, F-C4 compaction loss — all in mitigation top-10 or near it.
- `helpers/cd-c4-p1-synthesis.md` → "today's biggest gap is the agent's inability to recover its own state across compaction".
- `helpers/cd-gap-c1-p3-goals-extracted.md` → G.sess.01, G.sess.03, G.inf.04.
- User memory: 2026-05-15 incident → "compaction == cold boot" rule added; needs an artifact (`_session.md`) to anchor to.

## Design notes
- `_session.md` schema per chat (file in project root, gitignored from `my-axon.git`'s shared branch):
  ```
  # _session.md — chat <chat-id>
  state: active | frozen | tagged | closed | recovered
  started: <ISO>
  last-action: <ISO>
  last-program: code-dev-…
  checkpoints:
    - {turn: 20, ts: …, summary: "…", anchor: "<pr-N | study-overview | …>"}
    - {turn: 40, …}
  pending-actions:
    - "code-dev pr-review 3 --phase=4"
  ```
- `tools/session.py`:
  - `start(chat_id)`: creates `_session.md` if absent, state=active.
  - `checkpoint(reason)`: append a checkpoint row; **always** called before `_meta.md` mutation; also called every 20 turns.
  - `transition(new_state)`: enum guard (active → frozen/tagged/closed/recovered).
  - `recover()`: on boot, if last state was active and process is new, set state=recovered + log.
- `tools/_axon_io.py` `atomic_write` extended to **`journal/*`** files. Already covers `_meta.md`, `_actions.log` via PR-3.
- Programs touched: `code-dev-handoff.md`, `code-dev-freeze.md`, `code-dev-tag.md`, `code-dev-resume.md` — all gain `transition()` calls at correct points.
- Synthetic concurrent-edit test: two `atomic_write` calls racing on same path → final file is one of the two complete contents, never interleaved.
- Opt-in initially: `_meta.session-recording: true` (default true; can be set false to silence).

## Pitfalls (from failure-mode catalog)
- **F-B2 `_meta.md` race** → atomic_write.
- **F-B3 `_actions.log` corruption** → atomic_write extended to journal/.
- **F-C4 compaction loses critical state** → checkpoint cadence + recovery hook.
- **F-A1 persona-bleed after compaction** → session anchor gives boot something concrete to read.
- Session overhead → opt-in flag in `_meta.md`; default ON but disablable.

## Interface sketch
```text
$ code-dev status
project: axon-master  · session: active (32 turns, last checkpoint @ turn 20)
last-program: code-dev-pr-review --phase=3  ·  pending: pr-3 phase=4

$ # after compaction…
$ code-dev resume
✓ session recovered (state was active, process new → state=recovered)
last action: code-dev-pr-review --phase=3 @ 2026-05-17T15:22Z
pending: code-dev pr-review 3 --phase=4
proceed? [y/N]
```

## Spec (canonical)
- **Files**:
  - new: `tools/session.py`, `tests/test_session.py`.
  - modified: `workspace/programs/code-dev-handoff.md`, `code-dev-freeze.md`, `code-dev-tag.md`, `code-dev-resume.md`; `tools/_axon_io.py` (atomic for `_actions.log`, `journal/*`).
- **Acceptance**:
  1. `_session.md` created per chat on first verb.
  2. State enum {active, frozen, tagged, closed, recovered} enforced.
  3. Auto-checkpoint every 20 turns AND immediately before any `_meta.md` mutation.
  4. Atomic write verified by concurrent-edit synthetic test (no interleaved content).
  5. `atomic_write` covers `_meta.md`, `_actions.log`, `_session.md`, `journal/*` (G.inf.04 completion).
  6. Programs touched still pass PR-1 T1.
  7. `tools/lint_paths.py` clean.
- **Rollback**: revert; `_session.md` becomes a stale orphan but causes no error.
- **Owner**: AGENT writes; HUMAN runs concurrent-edit test, exercises resume after a synthetic kill.

## Codebase grounding
- **new**: `tools/session.py` — exposes `start(chat_id) / checkpoint(state) / transition(new_state) / recover()`. State enum: `active | frozen | tagged | closed | recovered`. JSONL append to `_session.md` (one event per line under `---` frontmatter).
- **modify**: [`tools/_axon_io.py`](../../../../tools/_axon_io.py) — `atomic_write` already exists (58 lines, uses `tempfile.mkstemp` + `os.replace`). No code change needed; extend usage to cover `_actions.log` and `journal/*` writes in handoff/freeze/tag/resume programs.
- **modify**: [`workspace/programs/code-dev-handoff.md`](../../../../workspace/programs/code-dev-handoff.md), [`code-dev-freeze.md`](../../../../workspace/programs/code-dev-freeze.md), [`code-dev-tag.md`](../../../../workspace/programs/code-dev-tag.md), [`code-dev-resume.md`](../../../../workspace/programs/code-dev-resume.md) — each calls `TOOL(session, transition=<state>)` and `TOOL(session, checkpoint)`.
- **auto-checkpoint trigger**: every 20 turns counted via `W:turn-counter`, AND before any `_meta.md` mutation; intercept in handoff/freeze/tag entry blocks.
- **new**: `tests/test_session.py` — fork two processes writing concurrently, assert no torn write (compare hash after) using `multiprocessing.Process` per [`tests/test_tools_core.py`](../../../../tests/test_tools_core.py) pattern.
- **modify**: [`tools/REGISTRY.json`](../../../../tools/REGISTRY.json) — add `session` tool entry.
- **journal/**: per-project `journal/` directory created on first checkpoint; one file per ISO date.

## Cross-refs
- Master plan: `../03-plan.md` § Wave 2 / PR-9.
- Helpers: `helpers/cd-gap-c3-p2-session-model.md`, `helpers/cd-gap-c2-p4-failure-modes.md` (Class B, F-C4).
- Related: PR-15 adds compaction-recovery fixtures + AXON-DOCS-SESSIONS.md.
