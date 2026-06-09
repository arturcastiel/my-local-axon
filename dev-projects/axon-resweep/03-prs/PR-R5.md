# PR-R5 — mode-router dead EXEC targets (P5)

- **Status:** spec
- **Phase:** 1-fixes  ·  **Complexity:** S  ·  **dev-mode:** no (workspace/programs/ + tests/)  ·  **Depends on:** none
- **Why / detail:** 01-study.md P5. `mode-router.md` `EXEC(new-chat)` (chat mode, no active chat) and
  `EXEC(plan-new)` (plan mode) dispatch programs that don't exist / aren't registered → dead dispatch.

## Decision — graceful routing, NOT new (unverifiable) programs
Investigation: `chat-input.md` itself GUARDS on an active chat and its FAIL says "Run: new-chat" — so the
chat subsystem (new-chat / open-chat / list-chats) is genuinely UNIMPLEMENTED, not a 1:1 rename; and
`plan-new` is a phantom — code-dev (`code-dev-plan` / `code-dev-plan-master`) is the real planner. Creating
guessed-at chat/plan-creation programs would risk shipping exactly the kind of unverified broken skeleton
this sweep exists to catch. So R5 makes the router **fail gracefully + route to what exists**:
- chat (no active): capture the goal, surface that chat-creation isn't wired, route to code-dev for tracked
  work, and `DONE` (no dead dispatch).
- plan: capture the intent, route to code-dev (the real planner), and `DONE`.

The deeper gap — the chat subsystem (new-chat/open-chat/list-chats) is incomplete, leaving `chat-input`
effectively unreachable — is logged as a follow-up (its own feature project), bigger than P5.

## Acceptance
1. `mode-router.md` contains no `EXEC(new-chat)` / `EXEC(plan-new)`; both branches terminate with `DONE`.
2. Existing program-structure + registry tests still pass (no EXEC-target / registry change beyond removal).
3. `crucible gate` passed:true.

## Changes
- `workspace/programs/mode-router.md` — chat-no-active + plan branches: graceful surface + route + `DONE`.
- `tests/test_resweep_program_subcommands.py` — assert no dead `EXEC(new-chat)`/`EXEC(plan-new)`.

## BUNDLED: gate pytest-control timeout (new finding, discovered mid-R5)
The gate ran EVERY control under a hardcoded `timeout=900` (crucible.py:93). The full pytest suite is ~592s
serial and slower under the gate's concurrent 22-control load, so it intermittently TIMED OUT → BLOCKed
clean merges (R4 squeaked under; R5 didn't). Real gate-reliability bug. Fix: per-control timeout
(`control.get("timeout", 900)`) + `"timeout": 1800` on the pytest control. Bundled here because it blocks
the gate for R5/R6 (and the gate reads the working-tree crucible.json, so this PR's own gate run benefits).
Test: `run_control` honors a per-control timeout (default 900). Follow-up: parallelize the suite (xdist) to
cut the 10min serial run.

## Follow-up (documented, not this PR)
The chat subsystem (new-chat / open-chat / list-chats) is unimplemented — `chat-input` can never run. Worth
a dedicated feature project (or explicit removal of chat mode if it's not wanted).
