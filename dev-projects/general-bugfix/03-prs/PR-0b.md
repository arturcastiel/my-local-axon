# PR-0b — program_tool_conformance: scoped flag-side conformance lint (WARN)

Status: merged
Merged: MR !160 → main (squash) · crucible green 27 controls
Branch: general-bugfix/pr-0b-tool-conformance → main
Depends-on: (none)
Phase: 3-prs
Covers: C2-flag, C4/C5 flag side, shadow-init class (T4/T6 advertised-but-absent flags)

## Goal
Tools are tested; the markdown call-sites that consume them are not — so flag sets drift
undetected (study theme §B4). A program ships `TOOL(library, gap-queries, --stdin …)` or
`TOOL(todo, list, "--tag bug")` and nothing fails until a user hits the dead path. This lint
probes each scoped call-site against the tool's REAL argparse surface — the contract cannot
drift because the check IS the tool's own parser.

## Change
- **New** `tools/program_tool_conformance.py` — extracts `TOOL(name, sub, "--flags …")`
  call-sites from the SCOPED surfaces (workflow + conversational program families; the cron
  surface is already gated by `cron_conformance`), template-strips `{…}` spans, then probes
  live: `axon.py <tool> --help` (tool exists + subcommand set) and `axon.py <tool> <sub> --help`
  (declared option strings). Violations: unknown-tool / unknown-subcommand / unknown-flag.
  Probe technique + timeout reused from `cron_conformance` (`--help` short-circuit =
  side-effect-free). `check` exits 1 (gate); `report` prints a table. Conservative parser:
  un-attributable call-sites are skipped, never false-blocked.
- **Scope** (data-driven constant, documented in the tool): `workflow-*`/`goal-*` programs +
  `workspace/workflows/*.yml` (workflow), `mode-*`/`new-chat`/`plan-*`/`chat-*`/`list-chats` +
  `library-dev-*` (conversational). NOT a 157-tool sweep.
- **Registry**: `program-tool-conformance` ACTIVE (161 → 162 tools; CONTEXT.md reconciled).
- **Crucible control** — severity **WARN** (pre-existing call-site drift is the baseline;
  PR-1 promotes the workflow scope to **BLOCK** after the `.value→.result` sweep fixes it).
- **Wiring** (R_NO_ORPHAN_TOOLS): menu META TOOLS row with the live invocation.
- **Tests**: parser/template-strip/extraction units (fixture-based, deterministic) +
  help-introspection on a static blob + one live known-good smoke.

## Guarded-by
- Crucible `program-tool-conformance` (WARN → BLOCK for workflow scope at PR-1; accessor
  side extends at PR-7).
- `R_NEW_NEEDS_TEST`.

## Out of scope
Fixing the flagged call-sites (PR-1 workflow, PR-2 conversational, PR-6 library). The
accessor/output side (PR-7 output_manifest). Cron jobs (cron_conformance, BLOCK, exists).
