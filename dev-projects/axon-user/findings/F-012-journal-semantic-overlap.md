# F-012 — journal-log / journal-event / journal-decision semantic boundaries undocumented

**personas**: P3 · **workflow**: W-07 · **severity**: S2
**date**: 2026-05-16 · **status**: open

## Reproduction

Read each of:
- [code-dev-journal-log.md](../../../../workspace/programs/code-dev-journal-log.md#L1)
- [code-dev-journal-event.md](../../../../workspace/programs/code-dev-journal-event.md#L1)
- [code-dev-journal-decision.md](../../../../workspace/programs/code-dev-journal-decision.md#L1)

None of the three explains *when* to choose which over the others.

## Observed

Cassie's scenario: "discovered that lib X has a breaking change in 2.0".
Candidates: `journal-log` (implementation note), `journal-event` (state-change),
`journal-decision` (architectural choice). All three plausible.

## Expected

Each program's HELP line distinguishes its use case in one sentence.

## Proposed edit

Add to each program's `# desc:` (or a short `## WHEN` block after HELP):

- **journal-log**: "free-form daily implementation notes — append-only to 04-log.md"
- **journal-event**: "atomic state-change emitted by other programs — internal, rarely user-typed"
- **journal-decision**: "ADR — durable architectural choice with rationale + alternatives"

Three 1-line edits.

## Rationale

Reduces user friction; no new behavior, just inline disambiguation.
