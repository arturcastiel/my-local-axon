# Study — AXON Paper
Updated: 2026-06-18  ·  Iterations: 3  ·  AXON: 9/10  ·  User: 10/10

---

## Goal
Produce a publishable academic/positioning paper that defines the "harness engineering" category, presents AXON as its reference implementation, positions it honestly against the validated academic landscape, and surfaces the pre-release improvements required before open-source publication.

**Paper genre decision:** Architecture + mechanism + case-study (kernel paper). Not a systems benchmark paper. Evaluation section = token reduction measurements (quantitative) + axon-paper development as recursive case study (qualitative).

**Target venue:** COLM 2027 (same as AIOS) or ICSE 2027 (same as AgentSpec).

---

## Priorities
1. **Define "harness engineering" as a coined, citable category** — the paper's primary contribution
2. **Position AXON's 5 non-replicated differentiators honestly** — using only verified claims
3. **Produce the improvements list** for pre-OSS-release (critical/high/medium tiers)
4. **Write the manifesto** (shorter blog/arXiv short form) in parallel with the paper
5. **Close the AgentSpec comparison gap** — the only major open question from study phase

---

## Constraints
- All competitor claims: cite primary sources or abstain (anti-fabrication gate from _dont-do-seeds.md)
- Model/harness names never appear in paper body (AXON identity contract)
- Paper claims may not exceed the adversarial-verify confirmed set (17/25 claims killed — ceiling set)
- "40-70% token reduction" claim CORRECTED (see verified findings below) — use real numbers

---

## Tech Stack
- AXON kernel: Markdown files (KERNEL-SLIM.md, BOOT.md, COMMANDS.md, OUTPUT-LAYER.md, core/LANG.md)
- Programs: 170 .md files, 10 compiled .cmp.md (5.9%)
- Tools: 156 ACTIVE Python tools, REGISTRY.json as source of truth
- Memory: workspace/memory/ (L:), workspace/working/ (W:), my-axon/memory/episodic/ (E:)
- Dispatch: TF-IDF cosine similarity, 168/170 programs indexed
- Tests: 308 test files in tests/
- Compiler: COMPILER.md (agent phases 1-3) + compile_write.py (deterministic Phase 4 writer)
- Drift: drift.py — real edit-distance drift detector, fail-closed gate
- Rules: rules_loader.py — 8-tier precedence hierarchy (load/trace/precedence/evaluate/audit)

---

## Key Concepts (verified against source)

### Five Non-Replicated Differentiators — VERIFIED
All five confirmed against actual AXON source files. Paper may assert all five.

1. **Model-identity inversion** — AXON-DOCS.md line 17: "AXON's identity is primary. The execution layer (host harness + model) is secondary." Layer 0 in the architecture diagram is "LLM — Identity: irrelevant." MEDIUM confidence that no competitor does this (external verification outstanding — carry to plan phase).

2. **8-tier rule precedence hierarchy** — rules_loader.py exists with load/trace/precedence/evaluate/audit subcommands. Precedence chain verified: kernel/identity → operational-safety memory → AGENTS.md → project safety/rules.md → inline --rule → dont-do.md → workflow conventions → defaults. CONFIRMED CAVEAT: rules_loader audit returned checked=0 — no project-level rules are loaded in fresh sessions. The mechanism is correct; adoption is user-driven. Paper must frame this accurately.

3. **Three typed memory scopes (W:/L:/E:)** — AXON-DOCS.md core principles table: "Memory is typed — W: (session) · L: (longterm) · E: (episodic append-only) — explicit scopes, no ambiguity." Boot sequence enforces scope routing. FULLY VERIFIED.

4. **Program compiler → .cmp.md artifacts** — compile_write.py is a real Phase-4 deterministic writer. COMPILER.md mandates 4 phases. VERIFIED NUMBERS (corrected from docs claim):
   - Docs claim: "40-70% token reduction" — OVERSTATED
   - Actual benchmark.py stats (3 runs): avg=30.3%, best=44%, worst=23%
   - Per-program token reduction: code-dev-review 44%, goal-define 39%, quality-loop 41%, loop-designer 31%, code-dev-knowledge-impact 35%, code-dev-plan 24%, code-dev-study 23%, menu 9%, code-dev 13%
   - **Paper must use: "23–44% token reduction, averaging 30%" — do not use "40-70%"**
   - Coverage: 10/170 programs compiled (5.9%). Paper framing: "flagship programs compiled; interpreted fallback available for all others."

5. **REGISTRY.json as mandatory tool source of truth** — AXON-DOCS.md: "Tools are mandatory — if a registered ACTIVE tool covers an operation, using it is not optional." 156 ACTIVE tools, REGISTRY.json verified as source of truth for health.py, boot.py, axon_audit.py. FULLY VERIFIED.

### Drift Detection — VERIFIED AND REFRAMED
- drift.py is real and functional ("Real drift detector, not vapor" — docstring)
- State at workspace/working/drift-trace.json; fail-closed gate (state=unknown → decision=halt)
- "No active trace" ≠ broken. Trace starts when programs run. Fail-closed is STRONGER than claimed — halts by default when uncertain rather than passing through.
- CORRECTED PAPER CLAIM: "drift detection is fail-closed by default — no trace = halted output, not pass-through" — this is a stronger governance claim than the original framing
- A1 gap status: CLOSED via reframing. Empirical data: run drift init on paper development workflow.

### Benchmark Claim — VERIFIED (CORRECTED)
- benchmark.py has record/list/stats subcommands — real measurement infrastructure
- 3 recorded runs: avg 30.3%, best 44%, worst 23%
- benchmark-log not in my-axon/memory/longterm/ (not persisted there — lives in benchmark.py's internal store)
- **A2 gap: CLOSED. Use real numbers in paper.**

### Compilation Coverage — VERIFIED (REFRAMED)
- 10/170 (5.9%) programs compiled — this is correct
- NOT a claim failure: compiler requires human-in-loop (AGENT phases 1-3 + compile_write.py Phase 4)
- 10 compiled are the high-traffic flagship programs (correct selection)
- **B1 gap: REFRAMED. "Flagship compilation" is the claim, not universal auto-compilation.**

### Rule Enforcement — VERIFIED (SCOPED)
- rules_loader.py exists with full precedence/evaluate/audit capability
- checked=0 in fresh sessions = no project-level rules loaded
- Write gate (enforce.py) IS mechanically enforced: check-write --target axon/KERNEL-SLIM.md returns allowed=true ONLY because dev_mode=true
- **A3 gap: SCOPED. Paper claims: "mechanism exists and enforces; adoption is user-driven per-project." Case study (axon-paper with _dont-do-seeds.md) demonstrates the mechanism.**

---

## Open Questions (carry to plan phase)
1. **D2 — AgentSpec comparison**: Full paper (2503.18666) not yet deeply read. Plan phase must assign as first paper-build PR.
2. **A4 — Model-identity inversion, no competitor**: Medium confidence. Plan phase: 1-day targeted web research on AutoGen/LangGraph/CrewAI/Semantic Kernel identity handling.
3. **Drift empirical data**: Collect naturally through paper development workflow (drift init → use AXON → accumulate trace).
4. **Formal definition of "harness engineering"**: Draft in plan phase, polish in build phase.
5. **Venue CFP dates**: COLM 2027 and ICSE 2027 deadlines — check when submitting plan.

---

## Architecture Snapshot (verified)

```
Layer 0  LLM                    Execution engine — identity irrelevant
Layer 1  axon/ (kernel)         KERNEL-SLIM + BOOT + COMMANDS + OUTPUT-LAYER + LANG
Layer 2  workspace/ (userspace) 170 programs + 156 tools + preferences + harness adapters
Layer 3  my-axon/ (runtime)     Private user data — dev-projects, memory, logs (gitignored)
Layer 4  workspace/addons/      Self-contained packages
```

Boot sequence: KERNEL-SLIM → G-01 identity frame → TOOL(boot) → TOOL(prefs) → harness detection → my-axon load → resume check → cron → EXEC(menu)

---

## Sources
- file: workspace/AXON-DOCS.md (verified 2026-06-18, shadow written)
- file: tools/drift.py (verified 2026-06-18, shadow written)
- file: tools/compile_write.py (verified 2026-06-18)
- tool: benchmark.py stats (real measurement data)
- tool: axon-audit (1a HEALTHY / 1b 100 / 1c BROKEN-shadow)
- session: market position deep-research (2026-06-18, 107 agents, 8/25 confirmed)
- session: gap analysis (2026-06-18, 5 clusters, E1-M3 closure proposals)

---

## Pre-Release Improvements (verified priority list)

### Critical (block OSS release)
- C1 Shadow index: 5/6 projects stale — run code-dev shadow per project
- C2 Drift init: no trace active — run `python3 tools/drift.py init --program <flagship>` at boot or add to boot sequence (BOOT.md step 3)
- C3 my-axon/ separation: lint-paths shows 0 violations — ALREADY CLEAN. Downgrade from Critical to DONE.
- C4 README + getting-started for OSS: not yet written

### High (before paper submission)
- H1 Usage log: 0 entries — wire usage.py recording into session flow
- H2 Prompt log: 0 entries — enable prompt-log-consent
- H3 Drift empirical data: collect through paper development workflow (organic)
- H4 AgentSpec comparison: assign as first build-phase PR
- H5 (new) Benchmark claim correction: update AXON-DOCS.md "40-70%" → "23-44% (avg 30%)"

### Medium (good-to-have)
- M1 _demands.md for active projects: no project has one
- M2 Compile 10-15 more flagship programs: improve from 5.9% → ~14%
- M3 auto-improve: run --dry-run first, collect audit trail
- M4 AXON-DOCS.md freshness: self-care shows system_doc stale — run axon-docs-gen
