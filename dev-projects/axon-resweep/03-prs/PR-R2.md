# PR-R2 — Program dangling subcommands: events→log · context→status · memory→get (P2 · P3 · P4)

- **Status:** spec
- **Phase:** 1-fixes  ·  **Complexity:** S  ·  **dev-mode:** no (workspace/programs/ + tests/)  ·  **Depends on:** none
- **Why / detail:** 01-study.md P2/P3/P4. Three ACTIVE programs exit-2 at these steps; verify.py is blind to
  `choices=`-based subcommands, so they drifted unnoticed.

## Changes (call-site corrections, verified against the real argparse surfaces)
- `events` has `log`, not `list`: `stats.md` (events dashboard) · `code-dev-events-emit.md` (the dispatch on
  line 70 — its user-facing `list` subverb is the program's own vocabulary, kept; only the TOOL call fixed).
- `context` has `status`, not `report`: `gain.md` · `discover.md`.
- `memory` has `get --scope {W,L,E}`, not `retrieve`: `gain.md` (`get --scope E --key session-log`).

## Acceptance
1. No program references `TOOL(events, list` / `TOOL(context, report` / `TOOL(memory, retrieve`; the fixed
   forms (`events, log` · `context, status` · `memory, get, --scope E --key session-log`) are present.
2. The referenced subcommands exist in events.py/context.py/memory.py (verified).
3. `crucible gate` passed:true on this on-workflow changeset.

## Tests
`tests/test_resweep_program_subcommands.py` (new) — content lock per the R_TOOL_CALL_EXISTS blind spot.

## Note
The systemic fix (teach R_TOOL_CALL_EXISTS to see `choices=`-based subcommands so this class is caught at
the gate) is a candidate follow-up / phase-2 — out of scope for these call-site corrections.
