# F-016 — `startup.md` audience sections (AGENT vs USER) confuse first-time agents

**personas**: P1-novice-naomi · **workflow**: W-01 · **severity**: S2
**date**: 2026-05-16 · **status**: open

## Reproduction

Read `startup.md`. Two top-level sections: "FOR THE AGENT" and "FOR THE USER".
The AGENT section starts with a Claude-Code-specific Step 0, then generic
Steps 1-3. A first-day generic agent can't tell whether Step 0 applies.

## Expected

A one-line gate at the very top: "If you're the human reader, jump to FOR THE
USER. If you're any AI agent, follow the AGENT section in order; Step 0 applies
only if your harness is Claude Code."

## Proposed edit

Prepend to `startup.md`:

```
> **Reader**: If you are a human, read **FOR THE USER** below.
> If you are any AI agent, read **FOR THE AGENT** in order. Step 0 only
> applies if your harness is Claude Code.
```

## Rationale

Reduces 1-2 turns of first-day confusion for novice agents. Zero behavior change.
