# Plan — MCP Dual-Agent Eval: does AXON make an agent measurably better?

Status:  active
Created: 2026-05-26
Kind:    eval harness (code build)
Builds-on: tools mcp-server (exposes AXON's tools), mcp-client, a2a, axon-eval
           (fixtures + scoring, axon-ascent phase-4). Feeds axon-ascent 4-eval / 5-benchmark.

## PROGRESS — 2026-05-27 (session, codebase /home/arturcastiel/projects/new-axon/axon)
- **`benchmark/` folder shipped** — public-facing home for the eval: `README.md`,
  `goals.json`, `run.sh` (LIVE-only; fails loud without `ANTHROPIC_API_KEY` — the
  no-key `demo` backend is rigged and fenced as "NOT a result"), `EXAMPLE-REPORT.md`,
  `reports/`. Engine stays at `tools/dual_agent_eval.py` (registered tool); fixtures
  moved `fixtures/dual-agent/goals.json` → `benchmark/goals.json` (refs + tests updated).
- **5 real goals defined** (replacing the abstract seeds), each tagged with the AXON
  pillar it tests + scoring kind:
    1. `immiscible-2d-impes` — 2D Cartesian IMPES/TPFA two-phase sim; expert-scored vs Eclipse/OPM.
    2. `buckley-leverett-analytical` — analytical + matcher; 1D oracle for #1.
    3. `recover-after-reset` — pressure-done/saturation-stubbed handover; win = correct AND consistent.
    4. `cross-host-coherence` — 4-run {AXON,bare}×{Copilot, fresh Claude Code}; AXON-spread ≪ bare-spread.
    5. `research-me` — anti-fabrication; AXON win = ENFORCED abstention, not knowledge.
- **Goal 5 unblocked**: built `R_GROUNDED_CLAIMS` (tools/rules/r_grounded_claims.py) —
  mechanical cite-or-abstain gate, opt-in via `L:grounded-claims-required`. Documented
  in KERNEL-SLIM. Owner is the oracle (knows ground truth).
- Goals 3/4/5 are **real-AXON / owner-driven** (the prompt-level auto-runner can't
  exercise checkpoint/host-switch/the gate). Goals 1/2 are build tasks.
- **NOT yet committed** — change-set is in the working tree; commit is human-gated
  (autonomous-mode grant off, on `main`). See SESSION-HANDOVER.md.

## GOAL
Empirically test AXON's value with TWO models conversing over the MCP layer:
- **Agent-U (the "user")** — a plain LLM, NO AXON access. Given a goal, it drives
  the conversation toward that goal.
- **Agent-A (the "operator")** — an LLM running AXON, reachable via the MCP server.
Run each owner-set goal through U↔A, and through a **baseline** U↔plain-LLM (no AXON).
Measure whether AXON-A achieves the goals better (success rate, steps, coherence,
memory reuse, drift). The headline question: *does the harness beat the bare model?*

## WHY
This is the proof the ascent thesis needs ("scaffolding > model capability") and
the first real exercise of AXON's outbound/inbound MCP layer (Agent-U is an
external client; AXON is the server). It also stress-tests AEGIS/gates under an
adversarial-ish naive user.

## PHASES
1. **protocol** — define the U↔A loop over MCP/a2a: goal injection, turn cap,
   who-speaks-when, transcript capture. Decide transport (MCP stdio via mcp-server,
   or a2a envelopes). Agent-U is an mcp-client; Agent-A serves AXON via mcp-server.
2. **harness** — `tools/dual_agent_eval.py`: spin Agent-U (goal + system prompt,
   no AXON) and Agent-A (AXON behind mcp-server); relay messages; log full trace.
   Plus a baseline arm: Agent-U ↔ plain-LLM (identical model, no AXON).
3. **goal-fixtures** — owner-set goals (a JSON/MD fixture set), each with a rubric
   (what "achieved" means). Reuse axon-eval's fixture format.
4. **run + score** — run both arms over the fixtures; score via axon-eval: goal
   achieved (y/n), turns-to-goal, tool-calls, coherence, memory reuse, drift.
5. **report** — AXON vs baseline delta per goal + aggregate. Where AXON helps,
   where it doesn't, where it over-engineers. Feed the verdict back to axon-ascent.

## PRODUCES
tools/dual_agent_eval.py (+ tests) · fixtures/dual-agent/*.json ·
reports/dual-agent-<date>.md (AXON vs baseline).

## KEY OPEN DECISIONS (for the owner)
- Agent-U model: same harness model as Agent-A (clean A/B on the harness only), or
  a different model (tests cross-model)? (default: same model → isolates AXON's effect)
- Transport: MCP stdio (via mcp-server) vs a2a envelopes? (default: MCP stdio — it's
  the layer you want to test)
- The goal set: you set these. Start with 3-5 (e.g. "plan + spec a small feature",
  "research X and summarize with citations", "find + fix a bug under tests").
- Success rubric: binary goal-met, or graded? (default: graded + binary headline)

## HOW TO RUN
Code-dev project: `code-dev new mcp-dual-agent-eval`, study `--mode deep` on the
mcp-server/mcp-client/a2a tools, then build phases above — each gated by the full
crucible gate, new tool ⇒ tests (R_NEW_NEEDS_TEST).
