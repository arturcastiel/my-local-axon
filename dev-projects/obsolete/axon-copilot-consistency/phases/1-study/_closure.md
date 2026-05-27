# Phase 1 — Study — CLOSURE

slug:            1-study
schema-version:  v4
status:          CLOSED
opened:          2026-05-20
closed:          2026-05-20
artifacts:       phases/1-study/01-study.md, phases/1-study/_audit.md
audit-score:     8.4 / 10  (ceiling 9.2 without L4 Copilot-reproduction)

---

## Scorecard

Two-document study. **01-study.md** populated all four research axes (A1
codebase audit, A2 Copilot extension points online, A3 tool-calling on
Copilot Opus, A4 diff vs Claude Code). **_audit.md** self-graded the draft
(6.2/10), made 7 corrections (C-1..C-7), closed coverage gaps via L1+L2+L3,
and lifted the score to 8.4/10.

Headline outputs:
- 5 codebase tensions identified (T1-T5) — 1 novel (T1 self-contradiction in
  `.github/copilot-instructions.md`), 4 refinements.
- 4 hypotheses confirmed (H1' self-contradiction, H2 auth friction, H4
  truncation), 1 rejected (H3 precedence).
- 4 new hypotheses added (H5 truncation-aware design, H6 MCP exposure for
  ambiguity reduction, H7 env-var injection, H8 autopilot opt-in).
- Refined defense-layer asymmetry: Claude Code 7/10 layers → Copilot today
  4/10 → Copilot achievable in 2026 7/10. **Gap is closeable.**
- 6 PRs drafted for phase-2 (CC-201..CC-206).

## User-locked decisions

| # | Question | Decision |
|---|---|---|
| 1 | Sibling project vs extending `-anchor`? | **Sibling** (`axon-copilot-consistency`). `-anchor` covers persona drift; this project covers command comprehension + tool-call gap. Both projects coexist. |
| 2 | Phase-1 research scope | **All four axes** (codebase + online ext-points + online tool-calling + Claude-Code diff). |
| 3 | Required confidence to close phase 1 | **>8/10**. Lifted to 8.4 via L1+L2+L3. |

## Outcome

Phase-2 PR queue drafted at **6 PRs** (mix of small + medium). See
`phases/2-design/_meta.md` for per-PR specs.

## Lessons

1. **Truncation is a real, currently-active bug.** `github/copilot-cli` issue
   #2111 (open as of March 2026) cuts instruction files at ~160 lines.
   AGENTS.md is the safer load-balance destination — it's "primary"
   precedence in Copilot CLI and shorter (72 lines now).
2. **Conflicting instructions produce non-deterministic behavior.** Validated
   by GitHub Docs verbatim. The fix for T1 must REMOVE the contradiction,
   not "clarify both clauses" — the model can't reason its way out of two
   contradictory directives.
3. **MCP is the structural anchoring lever AXON hasn't pulled.** Doesn't
   bypass authorization, but converts "describe a shell command" into
   "call a named tool" — which is what Claude Code's Bash tool already does
   in practice on Claude Code.
4. **Default mode matters.** Copilot CLI's default standard interactive mode
   asks per-call. Autopilot mode runs free with grants. The cheapest fix for
   the user is `--allow-tool axon_*` patterns once MCP exposure ships.
5. **In-harness reproduction is the only path past 9/10.** Studies authored
   inside one harness inevitably mis-weight the other. Future phase-1 reviews
   should require a sibling reproduction in the studied harness before
   trusting the score.
