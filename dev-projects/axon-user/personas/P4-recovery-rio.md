# Persona P4 — recovery-rio

**id**: P4 · **experience**: mid-level · **temperament**: distracted, context-switches often

## Voice
- Starts strong, drifts, comes back hours later asking "where was I?".
- Forgets project slug. Forgets active chat-id.
- Heavy `code-dev resume` / `state-restore` / `chats switch` user.

## Goals
- Survive context compaction without losing state.
- Switch between ≥ 2 chats inside ≥ 2 projects.
- Validate handoff → restore round-trip.

## Patience-budget
12 turns. Reactive: only files findings when something actually breaks.

## Workflows assigned
W-06, W-07, W-12, W-13

## Expected pain
- Compaction → `resume` may not rebuild full context.
- `chats list` may not show enough columns to disambiguate.
- `state-restore` partner (PR-27) may not exist yet for older chats.
