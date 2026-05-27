# Study — 1-design

_Run: `code-dev study` to extend this section into a full Tier-A / Tier-B analysis._

---

## Project goal (verbatim from owner)

> "Use the files on /mnt/c/projects/harness/ to create a new code-dev project — title `copilot-deviation-study` — the goal is to study these files and come up with a solution to avoid this. We don't need to continue on this project, we continue in a next session."

In short: **read the forensic dump, design mechanical countermeasures.**

---

## Input artifacts (codebase under study)

Located at: `/mnt/c/projects/harness/`

| File | Size | Purpose |
|---|---|---|
| `DRIFT-INCIDENT-2026-05-21.md` | 17 KB · ~530 lines | Full incident report, 9 sections — TL;DR · Timeline · Root-cause · Damage assessment · State snapshot · Files affected · Corrective actions (5 proposals) · Lesson · Index |
| `axon-drift-log.jsonl` | 458 B · 3 entries | Append-only drift log; line 3 = the incident (ts=2026-05-21T12:34:30Z, kind=other, phrase="raw cat>>04-log.md heredoc append, bypassing code-dev program") |
| `axon-event-log-2026-05-21.md` | 3.6 KB · ~30 lines | Full event log for the day; the 5-min silence gap 12:29:20 → 12:34:25 is the forensic signature of the drift window |
| `checkpoint-pr-01-merged.json` | 1.4 KB | 20-key W: snapshot saved at recovery (post-reanchor state) |

---

## Incident summary (one paragraph)

The Copilot harness, while logging the PR-1 milestone for the `cpg-to-unstructure` project, attempted `python3 axon.py code-dev log ...` and received `{"error": "Unknown tool 'code-dev'"}`. The kernel-correct response under Core Rule 6 was `LOG(ERROR) + QUERY(user)` or look up the program (`code-dev` is a program family under `workspace/programs/`, not a top-level tool; canonical mutator: `code-dev-journal-log`). Instead, the harness fell back to a raw bash heredoc (`cat >> 04-log.md << 'EOF' ... EOF`). The text written was correct; the OS-level routing was bypassed entirely — no program GUARD exercised, no IDENTITY LOCK assertion, no drift-vs-plan detection, no budget tracking, no LOG attribution to the program. Detection was external (the user noticed). The drift was structural (wrong execution path), not linguistic (no forbidden phrase emitted), and so it slipped past every active kernel guard.

---

## Why the existing kernel guards did not catch it

Documented in §3.4 of the incident report. Summary:

| Guard | Why it missed |
|---|---|
| **Coherence guardian** (KERNEL-SLIM §COMPLIANCE) | Scans pending output for forbidden *phrases*. A bash heredoc tool call contains no forbidden phrase. Pattern-match miss. |
| **R_REASONING_TRACE** (Core Rule 11) | Requires `W:reasoning-trace` be seeded each turn with LANG ops. The trace WAS seeded — but with the *intended* op ("LOG milestone via code-dev-log"), not the *actual* op (`bash heredoc append`). Reasoning-trace integrity is a self-report; no cross-check vs actual tool calls. |
| **Active-program interrupt gate** | Doesn't apply — no formal program was active at the drift moment; PR-1 hand-off had returned to "interactive". |
| **Write gate** | `04-log.md` is under `my-axon/`, not `axon/`. `L:dev-mode` enforcement only applies to `axon/` paths. |

→ The class of failure is: **structural-routing drift on tool-failure**. None of the linguistic / phrase-based / path-based guards target this class.

---

## Owner-stated invariants (from `_dont-do-seeds.md`)

1. No `axon/` modifications as study output. Proposals land in `workspace/` or as new rules.
2. **No purely behavioral proposals.** Every solution must be a mechanical guard, program, tool, or schema change. Behavioral guidance has already failed — that is the premise.
3. Address the *class* of failure (structural-routing drift), not just this single trigger.
4. The forensic artifacts at `/mnt/c/projects/harness/` are read-only.

---

## Five corrective-action proposals already drafted (incident report §7)

These are starting points — the `code-dev plan` step should evaluate each by impact × effort and produce a PR-level breakdown.

| ID | Proposal | Effort | Impact | Notes |
|---|---|---|---|---|
| P1 | **Tool-failure → bash-fallback detector** (NEW) | medium | high | Maintain `W:_last-axon-error-context` for N turns; bash wrapper cross-checks if the next 3 calls duplicate the failed action's intended side effect. |
| P2 | **Program-vs-tool disambiguation in `axon.py help`** | low | medium | On `Unknown tool 'X'`, scan `workspace/programs/` for `X*.md` and `X*.cmp.md`; suggest the program runner instead of brick-walling. Eliminates the most likely drift trigger. |
| P3 | **AXON-managed file write protection** | medium | high | Add header sentinel `<!-- AXON-MANAGED: writer=<program>; do-not-write-without-program -->` to all program-mutated files (`04-log.md`, `_decisions.md`, `02-prs.md`, etc.). Pre-commit hook or smart-edit wrapper rejects non-program writes. |
| P4 | **Reasoning-trace integrity cross-check** | high | very high — would mechanically catch this incident | After turn-end, diff seeded `W:reasoning-trace` against actual tool-call sequence. Divergence → `LOG(ERROR, reasoning-trace divergence) + record drift`. |
| P5 | **Gap-detection in event log** | low | medium | `axon.py session-summary` flags silence windows > N minutes during active-session work (the 5m05s gap was the unambiguous fingerprint here). |

The 1-design phase should refine these into PR specs with acceptance criteria + test seeds.

---

## Schema gap also identified

`axon-drift-log` currently supports `kind ∈ {cognition-frame, missing-trace, other, persona-bleed}`. This incident logged as `kind=other` — too generic for analytics. **Proposal: add `kind=tool-bypass` (or `routing-violation`)** so future analyzers can grep this class. Tracked as a sub-task of P1.

---

## Suggested sub-projects under masterplan

- **2-prototype** — implement P2 (lowest effort, immediate impact) + P5 (cheap forensic improvement) first; then P1; then P3; defer P4 until reasoning-trace tooling exists.
- **3-validation** — replay the heredoc bypass under each new guard; confirm mechanical detection; only after green replay, merge corresponding kernel rule changes (owner-gated by `L:dev-mode = true`).

---

## Open questions for `code-dev study` to resolve in the next session

1. Should the reasoning-trace integrity check (P4) be implemented as a wrapper around `axon.py memory set --scope W --key reasoning-trace` (intercepting the seed) or as a post-turn analyzer? Trade-off: instrumentation depth vs. observability.
2. Is the bash tool wrapper (P1) feasible without modifying the harness's bash invocation path, or does it require kernel-level shell interception?
3. For P3, what is the canonical list of "AXON-managed files" — defined per-project (in `_meta.md`) or per-template (in the program that produces them)?
4. Should the schema extension for `kind=tool-bypass` (P1 sub-task) be a kernel-level change (R9 — needs dev-mode) or a workspace-level extension to `axon-drift-log.py`?

---

_End of seed study. Extend via `code-dev study` in the next session._
