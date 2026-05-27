# Masterplan — AXON Ascent

> Source of every item below: `/home/arturcastiel/projects/axons-audit`
> (15 improvement levers in `recommendations/IMPROVEMENTS.md`, 22 competitor
> features in `recommendations/FEATURES-FROM-COMPETITORS.md`, quick wins in
> `recommendations/LOW-HANGING-FRUIT.md`). Cross-reference: `_source-audit.md`.

## Phase graph (directed, dependency-ordered)

```
1-telemetry ──▶ 2-integration ──▶ 3-safety-budget
      │                                   │
      └────────────▶ 4-eval ──────────────┴──▶ 5-benchmark
                        │
                        └──────────────────────▶ 6-ecosystem
```

Rationale for order: **telemetry first** — the refreshed baseline shows
usefulness is gated by runtime data that is all-zero, so features shipped
before telemetry can't be measured. **eval before benchmark** — SWE-bench
needs the eval harness as its runner. The rest can parallelize.

---

## 1-telemetry  ·  turn the self-improvement loop ON
> Audit: LOW-HANGING-FRUIT B/C/D/F + IMPROVEMENTS #13. Effort S+M.
> Why first: 11 axon-polish PRs left usefulness at 72.6 because dispatch/
> usage/plans/prompt-log are all zero. Activate, then everything measures.

- Fruit B — flip `L:prompt-log-enabled` + `L:turn-log-enabled` true (5 min)
- Fruit C — seed dispatch index (`compile-suggest compile --top 10`) (15 min)
- Fruit D — add `axon-audit` weekly cron (5 min)
- Fruit F — `L:auto-improve` on, dry-run, one week (2 min)
- Lever #13 — observability dashboard MVP (Flask+HTMX over workspace/log,
  workspace/audit, local/; reads what `axon-state` already reads). Effort L.
- Exit: telemetry non-zero; `gain weekly` + `dispatch-stats` produce real numbers.

## 2-integration  ·  stop being an island
> Audit: IMPROVEMENTS #1/#3/#9, FEATURES #1/#2/#3/#5 (bucket-1, "drops in
> cleanly"). Effort S each. The audit's named "fastest path to close the
> matrix gap without touching the moat."

- Lever #1 — `tools/mcp_client.py` (call any of 9,400+ MCP servers as a TOOL)
- Lever #1 — `tools/mcp_server.py` (expose AXON's 93 tools as MCP tools)
- Lever #3 — `handoff --protocol a2a` (emit valid A2A envelope, not markdown)
- Lever #9 — SKILL.md shim (`workspace/programs/skills/` + skill-adapter)
- Exit: removes the 4 biggest "AXON loses" matrix cells; kernel rules untouched.

## 3-safety-budget  ·  don't hurt the user
> Audit: IMPROVEMENTS #4/#6, FEATURES #4/#7 + plan-mode #6. Mixed S/L.

- Lever #6 — token-budget gate: `L:session-token-budget` + `L:daily-token-budget`
  + response-gate counter (kernel gate — same shape as confidence/inference gate)
- Lever #4 — Docker sandbox adapter: `workspace/sandbox/` + `L:sandbox-mode`
  (shell.py gate from axon-polish PR-1.1 is the foundation; this adds runtime
  isolation). Effort L.
- Feature #7 — adversary reviewer response gate (prompt-injection scan)
- Feature #6 — plan-mode default for code-dev (flip default to simulate→confirm)
- Exit: a runaway program can't drain the account or touch the host FS.

## 4-eval  ·  measure ourselves
> Audit: IMPROVEMENTS #5/#11, FEATURES #8/#11 + fix axon-compare #2.
> Builds DIRECTLY on axon-polish Phase-5 (16 e2e scenarios) + drift/igap/usage.

- Lever #5/#11 — `tools/axon_eval.py`: fixture (prompts + expected) → run →
  capture full trace → diff vs golden. The Phase-5 scenarios are the seed corpus.
- Feature #8 — time-travel replay: `replay <checkpoint-id>` over existing
  CHECKPOINT + E:session-log + SNAPSHOT(W:)
- Lever #2 / Fruit A — fix `axon-compare`: compute scores from its own
  web-search results, write `local/axon-compare-scores-<date>.json` (still
  hardcoded as of 2026-05-23)
- Exit: every kernel change becomes measurable; SWE-bench runner unblocked.

## 5-benchmark  ·  prove the thesis  (depends on 4-eval)
> Audit: IMPROVEMENTS #14, FEATURES #22, LOW-HANGING-FRUIT I. Effort L.

- SWE-bench Lite first (smaller), then Verified. AXON as scaffolding around a
  fixed model. New repo `axon-bench`.
- Exit: a public number that substantiates "harness scaffolding > model
  capability." The contributor-bait + marketing artefact.

## 6-ecosystem  ·  reach + distribution
> Audit: IMPROVEMENTS #7/#10/#15, FEATURES #14/#15/#16. Effort M/L.

- Lever #15 — plugin/registry: `axon install <name>` from a git-backed registry
- Lever #10 / Feature #16 — subagent registry: `SPAWN(<harness-name>)` (Claude
  Code subagent when host=Claude Code, else subprocess)
- Lever #7 / Feature #15 — background/remote exec: `remote-agent <goal>`
  (handoff-packaged, detached, EMITs completion)
- Feature #14 — browser/computer-use tool (`tools/browser.py`, Playwright, OPTIONAL)
- Exit: programs distributable; off-machine + parallel work possible.

---

## Explicitly OUT of scope (audit says skip — moat-erosion or wrong-tool)
- Multi-runtime .NET/TS (#12/#18) — use MCP server instead
- Multi-provider LLM matrix (#19) — host harness owns model routing
- Native IDE extensions (#20) — defer; MCP server makes them redundant
- Vibe-coding inline completion (#21) — would gut Core Rule 11

## Anti-pattern guard (from IMPROVEMENTS.md)
Every phase passes: "does this preserve same-behaviour-at-turn-100-as-turn-1?"
If a feature requires removing a kernel rule, it does not ship here.

---

## North Star — "make AXON alive"
> Provenance: the architecture-bones deep-think (`architecture-bones.md`) + the
> "is AXON alive?" reflection (2026-05-25). Not from axons-audit — this is the
> *why* the phases above ultimately serve.

AXON is **not a new mind** — the model thinks; AXON is the **organism around
borrowed cognition**: the body, nervous system, memory, and immune system that
*shape, persist, and discipline* a rented intelligence. "Alive" means a
self-maintaining, self-improving, self-growing system whose homeostasis runs
**without a human each turn**. The thinking is rented (and should stay so); the
*aliveness* is the self-maintenance.

Already real (much of it built this ascent): **immune system** (conformance + drift
gates), **metabolism** (the freshness orchestrator), **persistent identity** (the
AXON memory slot + projection), **proprioception** (R_PROJECT_ANCHOR anchoring).
What is missing is **circulation** — feeding the learning loops with *use* (not just
*build*) and letting a safe, well-measured cycle run on its own.

## 7-circulation · make the loop self-sustaining  (capstone — depends on 1, 3, 4)
> The true distance to "alive." Each item gates the next; safety gates the ambition.

- **Feed the loops** — the capture machinery (shadow, usage, ranker, igap, compile)
  is built but dormant; it needs real usage data. This *is* 1-telemetry, reframed as
  the organism's **food**: without it, nothing learns.
- **A trustworthy compass** — fix the saturated usefulness metric (split structural
  readiness from runtime usage; resolve `MYAXON_ROOT` so shadow/demand stop reading
  N/A) **before** any autonomous loop optimizes it. See `architecture-bones.md` §6.
- **Runtime enforcement (Bone 1)** — move guarantees from instruction-hope into
  hooks/tools the model cannot ignore (`PreToolUse` syscall gate, verify→repair) so
  self-direction is *reliable*. An immune system that says "please be healthy" is not
  alive.
- **The autonomous cycle** — measure → close-gaps → grow, driven by cron + gated
  auto-actions, no human each turn, every action reversible + audit-logged.
- **Surface — proprioception + foresight** (makes the loop *usable*; the fix for
  rapid-fire ordering-blur). Spec'd in `phases/7-circulation/03-prs/`:
  - **PR-7c1 control-strip** — intent queue (stacked directives, ordered + surfaced) +
    the R_PROJECT_ANCHOR focus line + a sparing tip; adaptive density via OUTPUT-LAYER.
    Rides shipped pieces; the tool is autonomous, the footer auto-inject is a kernel draft.
  - **PR-7c2 anticipation layer** — extend `synapse-suggest` with workflow-arc signals to
    anticipate the next step; drive the strip's density via the orchestrator
    decide-thresholds (silence is first-class); context-aware menu slices. Confidence-gated
    + measured. Mechanism ships on the existing orchestrator; accuracy ramps as the loops
    are fed. Depends on 7c1.
  - **PR-7c3 autonomous-mode verbose trace** — `L:autonomous-mode` separates the agent's
    reasoning from AXON's program/tool execution + narrates each invocation (via narrate) +
    emits a structured trace to the session-log: the reporting / training / observability
    surface for "how AXON is being used." Gated (default off). The third proprioception
    surface (7c1 = what's queued · 7c2 = what's next · 7c3 = what AXON is doing now).
- Exit: AXON sustains a measurable self-improvement cycle on its own, safely —
  homeostasis without a hand on the wheel.

## Disambiguation — what "alive" does NOT mean
- AXON does **not** reason in its own symbolic language (that claim is *compression*,
  not cognition — `architecture-bones.md` §3). It does not think; it structures thought.
- **No autonomy before the compass + runtime enforcement.** An autonomous loop on a
  saturated metric, or on instruction-hope enforcement, drifts. Always the safest way.
