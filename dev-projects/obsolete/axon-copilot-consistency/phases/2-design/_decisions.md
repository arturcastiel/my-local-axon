# Decisions (ADRs) — 2-design

## D-002 · 2026-05-20 · 6-PR queue split: T1-fix and load-balance are separate PRs
Decision: PR-CC-201 (T1 self-contradiction removal + size-down) and PR-CC-202
(AGENTS.md load-balance) ship as **two separate PRs**, not one.

Why:
- T1 fix is small, self-contained, immediately measurable (Copilot tool-call
  rate). It should ship even if AGENTS.md restructuring takes longer to land.
- Load-balancing AGENTS.md is structurally larger and benefits from landing
  *after* T1 fix establishes a clean baseline.
- Splitting also makes phase-4 validation cleaner — we can measure the T1 fix
  in isolation before adding the AGENTS.md change as a second intervention.

Consequence:
- PR-CC-201 lands first and must hit G-2 (tool-call rate ≥ 95%) on its own.
- PR-CC-202 lands second; its acceptance criteria includes "G-2 maintained
  AND drift-rate (`-anchor` G-1) reduced".

## D-003 · 2026-05-20 · MCP MVP scope = read-only 5 tools
Decision: PR-CC-203's MCP server exposes only 5 read-side tools at MVP:
`axon_boot`, `axon_log_read`, `axon_health`, `axon_menu`, `axon_reanchor`.

Why (per phase-1 audit F-2):
- Write-side tools (run, compile, ingest, etc.) carry larger risk surface
  and benefit from per-tool authorization landing first via the read-side
  tools.
- The user-experience win we're chasing is *ambiguity reduction*, not
  full feature parity. Read-side tools cover the boot/observe/diagnose loop
  which is where S2 hurts most.
- Subsequent PRs (phase-3 follow-up) can add write-side tools after MVP
  proves out and we have data on Copilot's MCP-tool-call rate.

Consequence:
- Phase-2 spec for PR-CC-203 is bounded; phase-3 may yield PR-CC-203.1
  for write-side expansion.

## D-004 · 2026-05-20 · Reproduce-in-both is a HARD constraint, not best-effort
Decision: every PR in phase-2 lists explicit acceptance transcripts from
*both* Claude Code AND Copilot CLI. Reviewer cannot sign off without both.

Why (per phase-1 lesson #5):
- This project's `_audit.md` ceiling without L4 was ~9.2/10 because
  reproduction in the studied harness wasn't possible from inside the
  authoring harness.
- Phase-3 implementation will hit the same trap unless the rule is binding.
- Symmetric to `-anchor`'s implicit rule (which only required Claude Code
  reproduction); we generalize.

Consequence:
- Phase-3 PRs may take longer to land (two reproduction sessions each).
- The slowdown is the price of confidence — phase-1 estimated 6.2 vs 8.4
  score swing came from this very gap.
