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

## 2026-05-27 — pillar 2 (wedge) v1.2: portability shipped → signal triad complete
- axiom now scores all three: coherence (v1) + enforcement-gaps (v1.1) + portability (v1.2).
- Portability = static cross-host directive divergence, delegation-aware (single-source +
  delegating stubs is NOT penalised; flagged + noted). NOT a runtime behaviour diff — that
  is pillar 3's dual-agent benchmark. WEDGE is now feature-complete for a v1 product demo.
  REMAINING wedge polish: a human-readable report/format mode; more instruction-file types.

## 2026-05-27 — wedge demoable: `axiom report` shipped
- `axiom report <repo>` renders the audit as a readable "Agent Constitution Audit"
  (coherence + enforcement-gaps + portability + summary). WEDGE (pillar 2) is now
  feature-complete AND demoable end-to-end. 4 wedge PRs this session (MR !10/!11/!12/!13).
- PROOF (pillar 3): CI shipped; live run needs an API key (human/config step) = a WALL for
  real numbers. THEORY (pillar 1): docs exist (theory/thesis.md). Feeders next: axon-ascent
  (telemetry/eval) + X1 cross-host (touches ~/.claude, snapshot-first).

## 2026-05-28 — pillar 3 (proof): oracle machinery + harness integration DONE
- Designed the conclusive benchmark concern-by-concern with the owner (all 5 LOCKED) and wrote
  the full methodology: `benchmark/METHODOLOGY.md` (owner confirmed: "I like the methodology").
- BUILT + MERGED the correctness-critical oracle: `tools/proof_sandbox.py` (timeout/mem/no-net/
  scrubbed-env, fail-closed) + `tools/proof_mms.py` (Method of Manufactured Solutions: sympy-
  derived forcing, leakage-safe goal gen, convergence-order grader; reference CN solver validated
  at order ~2; bad solvers FAIL).
- SHIPPED B2.5 — wired the objective grader INTO `dual_agent_eval` (`run-mms`): present a PDE goal
  (forcing/BCs/grid, NEVER u*) → run AXON arm + bare arm → extract the operator's produced solver
  → grade with `proof_mms.grade`, REPLACING the GOAL-MET self-grade. Paired → Wilson-CI verdict.
  **The benchmark is now runnable end-to-end.** Tag `v3.8.0-dev-proof-harness-mms`.
- HARDENED leakage (safer, not a shortcut): the manufactured family now EXCLUDES eigenfunctions
  (where f = c·u* would leak u*'s shape via the forcing); a fail-closed guard rejects any such
  solution; METHODOLOGY §6.A documents the two-layer defense (the order check independently
  rejects a hardcoded-exact answer — exact ⇒ ~0 error at every N ⇒ fitted order ≈ noise, not 2).
- SHIPPED B4 preflight (`preflight`): PRICE-INDEPENDENT conclusiveness gate (best-case Wilson CI +
  N_min + CI at an assumed win-rate) + caveated $ estimate — tells you BEFORE spending whether a
  run can clear the bar (n=4 only on a near-perfect sweep; need n≥11 at win-rate 0.85). MERGED.
- SHIPPED B5 pre-registration (`prereg` + `benchmark/PRE-REGISTRATION.md`): LOCKED record with a
  fixed bar (CI lower>0.5, not weakenable), git commit + sha256 fingerprint of methodology+oracle+
  harness (pins the exact grader), embedded power projection (can't retro-frame an underpowered run
  as conclusive). Commit it BEFORE running. MERGED. Tag `v3.8.0-dev-proof-target`.
- **PROOF TARGET COMPLETE** — one command from a CI'd verdict, cost known up-front, bar locked.
- SHIPPED BREADTH (the owner's explicit ask, "conclusive on a broader spectrum"): a 2nd MMS field
  — 1D advection-diffusion / transport (reservoir-adjacent), u_t + c·u_x = α·u_xx + f, with a
  validated order-2 CN+central reference. Operator dispatch: a goal id is `operator:seed`
  (heat:0 / advdiff:1); grader is operator-agnostic; harness/preflight/prereg take `--goals`.
  Families expanded to 6 each → 12 mixed goals, ALL reference solvers order ~2 (selftest sweep).
  preflight(12) = CONCLUSIVE-CAPABLE at win-rate 0.85 (CI lower 0.552). Tag v3.8.0-dev-proof-spectrum.
  This is the MMS unlock realized: breadth across fields with ONE automatic oracle, no extra experts.
  REMAINING for the live NUMBER: B3 full-AXON-over-MCP arm (today the AXON arm is prompt-level,
  owner-steered fidelity) + HUMAN: pilot → confirm effect → scale → headline (Opus) → CI.
- PAUSED for an internal TNO discussion on HOW to run it (option A API key vs B Pro/Max subscription;
  both backends merged !25; colleague guide at /home/arturcastiel/projects/new-axon/AXON-benchmark-guide.md;
  loadable resume = todo cbe1b46d).
- WHILE ON HOLD shipped the 3rd ORACLE TYPE — Buckley-Leverett ANALYTICAL oracle (tag
  v3.8.0-dev-proof-bl-oracle, MR !26): tools/proof_bl.py — nonlinear hyperbolic transport, closed-form
  rarefaction+shock (Welge), Rusanov reference, L1/front grader; validated M={1.5,2,3,5}; wrong solvers
  fail; reservoir-native + owner-verifiable. Completes the methodology oracle set (MMS + analytical +
  property). Follow-on (todo e2ae00a9): wire BL goals into run-mms (general grader dispatch).

## 2026-06-01 — B3 shipped: full-AXON-over-MCP arm (the proof now tests the OS)
- The benchmark's AXON arm was prompt-level (a discipline system prompt) → it tested a PROMPT, not
  the OS, a mismatch with pre-registered Concern 1 ("Full AXON over MCP"). Running it as-is + calling
  it "AXON the OS wins" would have been a credibility hole (own prereg + R_GROUNDED_CLAIMS).
- BUILT + MERGED (MR !103, main 10cc5df): the headless-CLI backend `axon_mcp` mode launches
  `tools/mcp_server.py` over the CLI's native MCP (`--mcp-config` + `--allowedTools mcp__axon`) →
  Agent-A gets AXON's REAL tools (memory/checkpoint/health/audit). A distinct `axon_backend` is
  threaded through `run_mms_fixtures` so ONLY the AXON arm gets the tools; the bare arm is unchanged
  (fair control: same model, no AXON). New CLI: `run-mms --axon-arm mcp` (needs `--backend cli`).
  7 tests (config / flag-wiring / arm-routing); full suite green; gate 22/0.
- **Pillar-3 PROOF code is now COMPLETE** — oracle set (MMS heat + advdiff + Buckley-Leverett) +
  harness + preflight + prereg + the rigorous MCP arm. The ONLY thing between here and the headline
  NUMBER is the owner-gated live run: pip the SDK / use a subscription + real goals → pilot → confirm
  → scale → headline (Opus) → CI. No code piece remains.

## 2026-06-01 — preflight verdict saved → preflight-verdict.md
- GO from code+stats: n=12 conclusive iff AXON edge ≥0.85 (n_min 11); best-case n=4; ~$10/API or ~$0 subscription. Live run owner-gated (backend + pilot + prereg). See preflight-verdict.md.
