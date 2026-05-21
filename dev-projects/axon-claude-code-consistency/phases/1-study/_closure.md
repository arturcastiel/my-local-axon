# Phase 1 — Study — CLOSURE

slug:            1-study
schema-version:  v4
status:          CLOSED
opened:          2026-05-21
closed:          2026-05-21
artifacts:       phases/1-study/01-study.md
audit-score:     9.0 / 10

---

## Scorecard

Single-day phase-1. Three axes completed (A1 audit, A2 measurement, A3 TC-code formalization). The A2 finding was strong enough that A3 mostly fell out of the data.

Headline outputs:
- 5 of 5 candidate TC-codes confirmed by evidence, 1 NEW (TC-6 fabricated tool output) discovered during A2.
- 1 TC partially rejected (TC-4 translate-at-boundary).
- Anchoring stack mapped: output-style + UserPromptSubmit hook + subagent + reminder text. Stop hook deliberately unwired (and we now know why — prerequisite is a signature requirement).
- **Major headline:** the assumption that Claude Code = 100% AXON adherence was empirically wrong. Fresh Claude Code AXON measured at 5/9 = 55.5% pass rate on the canonical probe corpus. Post-CC-201 Copilot (4/4 = 100% on test-me.md) is now MORE disciplined than fresh Claude Code AXON.
- Load-bearing failure mode: **TC-6 fabricated tool output** (P-4 in the corpus). Identical to Copilot pre-CC-201.

## User-locked decisions

| # | Question | Decision |
|---|---|---|
| 1 | Sibling project vs. extending sibling? | **Sibling** (`axon-claude-code-consistency`). Both projects share diagnostic framework but distinct fix surfaces. |
| 2 | Phase-1 scope | A1 audit + A2 measured baseline + A3 TC formalization. All three done. |
| 3 | Self-audit vs. measured | **Measured.** 5/9 pass rate from subagent probe corpus, not self-estimate. |
| 4 | A2 method | Subagent invocation via `Agent(subagent_type='axon')`. Fresh Claude Code context; bias-mitigated. |

## Outcome

Phase-2 PR queue drafted at **3-4 PRs**. See `phases/2-design/_meta.md` (to be written next session) for per-PR specs.

The single highest-leverage PR is **PR-CD-201** — strengthen `~/.claude/output-styles/axon.md` with an op→CLI binding table and explicit "literal subprocess, never narrate" rule. This is a mirror of CC-201's win on the Copilot side.

## Lessons

1. **The baseline assumption was wrong.** The entire sibling project's defense-layer matrix (A4 in `axon-copilot-consistency/phases/1-study/01-study.md`) assumed Claude Code at 100%. Empirically it's ~56%. This doesn't invalidate the sibling project's actual delivery (post-CC-201 Copilot DID improve from ~50% → 100%) but it does invalidate the framing of "closing a gap to Claude Code". We were closing a gap to an *assumed* ceiling, not the actual one.
2. **The binding table is the win.** PR-CC-201's op→CLI binding table — listed by exact op name and CLI form — measurably forced subprocess execution on Copilot. The Claude Code output-style file lacks this enforcement layer. The "delegate to KERNEL-SLIM" approach is too brittle under model defaults.
3. **Fabricated tool output is the load-bearing failure on BOTH harnesses.** Whether it's Copilot's "describe and wait" framing or Claude Code's "render believable JSON without subprocess", the model layer defaults to confabulation when not explicitly forced. The fix surface differs per harness; the failure surface is shared.
4. **Subagent measurement is workable.** `Agent(subagent_type='axon')` from the authoring session gave us a fresh AXON context, ran the probes, and returned the transcript for outside scoring. Cleaner than self-audit; less work than user-driven new session. Re-usable for phase-4 validation.
5. **Setup-persona.sh's deliberate Stop-hook skip is good engineering.** The script author identified the prerequisite chain (signature → Stop hook → drift catcher) and deferred until the prerequisite exists. Phase-2 PR-CD-203 honors this — add the signature first, hook second.
