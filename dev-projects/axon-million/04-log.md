# Implementation Log — AXON Million

## SESSION START — 2026-05-26

## Entries

### T · 2026-05-26 · Pillar 1 (theory) built
- Scaffolded axon-million: 3 pillars (theory → application → benchmark).
- theory/thesis.md: category (conformance layer), organism argument, falsifiable H1
  ("scaffolded model > bare model on long-horizon/stateful tasks"; H0=overhead), moat, timing.
- go-to-million.md (in axon-audit-2026): proof strategy (2 tiers), benchmark credibility
  criteria, plan-B path, goal-design, honest valuation (unpriced option, ~$0 liquid / $1-5M pre-seed gated on proof).
- Next: pillar 2 (application/wedge), pillar 3 (benchmark = plan B, needs owner goals).

### T · 2026-05-26 · Pillar 3 (benchmark) foundation built + pushed (eefcd0f)
- tools/dual_agent_eval.py: U↔operator + baseline arm, score (goal-met/turns/rubric),
  delta + aggregate → H1 verdict. Pluggable backend; 9 mock-backend tests; registered + crucible BLOCK.
- fixtures/dual-agent/goals.json: 5 seed long-horizon goals.
- Logic PROVEN now; LIVE run needs: configured model backend (API) + operator's AXON tools over MCP + owner's real goal set.
- Foundation status: pillar 1 (theory) ✓ · pillar 3 (benchmark harness) ✓ · pillar 2 (application/wedge) OPEN.

### T · 2026-05-26 · Pillar 2 (Axiom wedge) shipped + DOSSIER written (43de221)
- tools/axiom.py: `axiom check <repo>` — audits agent-instruction coherence (conflicts/dupes/precedence) + score. Read-only v1, own name, powered by AXON. 7 tests; dogfoods here. Registered + crucible BLOCK.
- Gate hardening: commit-msg lint now scrubs filename tokens before brand-scan (it false-flagged CLAUDE.md as a brand on its own commit; fixed). 11 lint tests.
- DOSSIER.md written — consolidates audit verdict + thesis + valuation + 3 pillars + artifacts + open items.
- FOUNDATION COMPLETE: all 3 pillars founded (theory ✓ · Axiom wedge ✓ · benchmark harness ✓). Full suite 4760.
- Open (human-gated): live benchmark (API + real goals), Axiom v1.1 (portability/enforcement-gaps), distribution.

### T · 2026-05-26 · Benchmark live runner shipped (2cba667)
- dual_agent_eval cmd_run: live A/B when --backend set (model backend + AXON-arm vs
  bare-arm + delta/aggregate + written report). Clean error w/o key. 16 tests.
- RUN: pip install anthropic; export ANTHROPIC_API_KEY=...; python3 tools/dual_agent_eval.py run --backend anthropic --fixtures fixtures/dual-agent/goals.json --out reports/dual-agent
- v1 AXON arm = prompt-level; rigorous = real AXON tools over mcp-client (follow-up todo).
- Now runnable: only the API key + owner's real goals stand between here and the proof number.

## 2026-05-27 — pillar-status audit (verify-before-build) + wedge v1.1
- **Pillar 1 (theory):** in progress (phase 1-theory) — thesis/moat docs.
- **Pillar 2 (wedge) = `tools/axiom.py`** — ALREADY BUILT (v1 coherence: conflicts/
  duplications/precedence over CLAUDE.md/AGENTS.md/.cursor/copilot-instructions).
  **v1.1 SHIPPED this session:** enforcement-gap scoring — per-directive "is it
  mechanically enforced?" (single-artifact co-location of distinctive tokens across
  hooks/CI/tests/lint; signal, not proof). Generalizes AXON's prose-vs-gate insight to
  any repo. On AXON itself: 36/38 traced, 2 true-positive gaps. REMAINING: v1.2
  portability (cross-host behaviour diff); a CLI report/format mode; more file types.
- **Pillar 3 (proof) = dual-agent eval** — scaffolding exists (recent commits:
  "no-key demo backend for the dual-agent eval", "axon-bridge mailbox"). NOT yet
  audited/matured — NEXT after the wedge. benchmark/ dir present.
- Discipline: axiom (wedge) lives in the canonical new-axon tree; tests green.

## 2026-05-27 — pillar 3 (proof): confidence intervals shipped
- Dual-agent eval harness was already built (tools/dual_agent_eval.py: two-arm AXON-vs-bare,
  pluggable backend, 24 tests; benchmark/goals.json real reservoir goals; no-key demo backend).
- SHIPPED: 95% Wilson CI on the across-goal win-rate + a CONSERVATIVE H1 verdict (supported only
  when CI lower bound > 0.5). No over-claiming on small n. This is the dossier's "confidence
  intervals" requirement. REMAINING: a live run with a real backend (human/API step) to produce
  actual numbers; long-horizon + cross-host goals execution; public report.
