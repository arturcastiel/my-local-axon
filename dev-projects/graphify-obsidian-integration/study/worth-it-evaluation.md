# Worth-it / AXON-goals evaluation (adversarial panel, 2026-06-09)

> Owner gated autonomous execution on "first evaluate if it is worth it and if it matches axon goals."
> 4-role adversarial panel (prosecutor · defender · neutral scorer · red-team). Full output: `tasks/wsk3fv6al.output`.
> **Verdict: GO-WITH-SCOPE (overall 7/10). NOT a greenlight for the full P1+P2+P3+P-CD program as committed in §12.**

## Scores
| Phase | worth | fit | | Goal | score |
|---|---|---|---|---|---|
| P1 code spine | 8 | 7 | | deterministic + traceable | 9 |
| P-CD target repos | 8 | 7 | | anti-fabrication (R6) | 9 |
| P2 organize + Obsidian | 6 | 6 | | kernel/identity floor | 10 |
| P3 LLM overlay | 4 | 6 | | better/capable | 8 |
| | | | | expandable | 8 |
| | | | | resilient | 6 |
| | | | | **reduce-surface** | **4 ← weak point** |

## Consensus (all four roles, incl. the defender)
1. **K2 blast-radius fix = the strongest, only-live-bug win — needs NO Graphify** (stdlib `git grep -oE 'def|class'`
   makes the symbol set non-empty; kills the `\b()\b` false-positive). Ship first, alone, as PR-0.
2. **P3 is weakest** — non-deterministic, key+network+tokens, changes no gate, D2 doesn't need it. Build last, hard-walled, first to cut.
3. **Tool count must hold or fall.** AXON = 157 tools and cutting; this must not become a surface-increase project.

## Material new fact (reverses the Path-A rationale with new info)
`graphifyy`'s PyPI description: *"AI coding assistant skill for Claude Code, Codex, Cursor, Gemini CLI, Aider, Devin…"*
— it is a **competitor agent product**, single-maintainer, ~1.4 releases/day, no deprecation policy. For AXON's
**own Python corpus**, the study proved ~150 lines of stdlib `ast` give the **identical** deterministic graph (zero dep,
zero bus-factor). Graphify's differentiator (28 languages) only earns its keep for **P-CD's multi-language target repos**.

## RECOMMENDED SCOPE (the disciplined "everything", sequenced + hybrid)
- **PR-0 — K2 impact/blast-radius fix, stdlib only.** No dependency, no new tool, one test + Guarded-by doc. The agreed win. Ship + merge first.
- **Path split (hybrid):** **stdlib `ast`** for AXON-self-introspection (P1/P2) · **Graphify pinned OPTIONAL extra** for P-CD target repos only (where multi-language matters). Keep Path B build-ready as the abort lifeboat regardless.
- **P1** deterministic code-spine — only after PR-0 proves the loop. `.graphifyignore` mandatory (if graphify used); fail-DEGRADE not fail-fast; consume typed `graph.json` `links`, NEVER the MCP server for builds; build-twice byte-identical determinism gate.
- **P2** Leiden clustering + program↔tool merge (deterministic). Obsidian map = GUI-only/zero-agent-value → one-way `obsidian_sync.py` exporter (~8-10h), NEVER the 196-file frontmatter migration; first thing to cut under pressure.
- **P-CD** deferred to after P1+P2 stable; start with the impact surface ONLY; each of the 6 surfaces a separate tested PR; reuse shadow/dag/project_graph.
- **P3** last + hard-walled: advisory-only, AEGIS-gated, INFERRED/AMBIGUOUS → QUERY(user); a static check that no P3 output feeds any gate.

## Kill-criteria (abort → Path B or shelve)
(1) graphifyy yanked/abandoned OR determinism check fails (two builds not byte-identical). (2) pin can't advance safely.
(3) any INFERRED/AMBIGUOUS/lossy-MCP value found influencing a BLOCK gate (R6 breach — halt). (4) won't-do crossed
(rag-maturity treated as a target; any EXCLUDE-set item re-enters). (5) `_FORBIDDEN_FLAG_TOKENS` weakened to MCP-expose the builder.
(6) kernel floor touched. PIVOT-TO-MINIMAL (cut to K2-only) if build-time balloons on real target repos / P3, or net ACTIVE tool count rises after the first two PRs.
SUNK-COST GUARD: re-run the §3 grounding numbers (rag score, tool count, `grep graphify`) at the START of EACH phase — not once.

## Net
The deterministic spine is real and empirically de-risked (spike L4). "Empirically buildable" ≠ "should be built at this scope" (study §9).
Give the owner everything — *sequenced so the fragile/speculative bets are earned, not pre-committed*. PR-0 is the single
highest-value, lowest-risk deliverable; if scope must collapse to one thing, it ships and we stop.
