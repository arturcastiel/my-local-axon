# High-Level Plan — AXON Paper
Updated: 2026-06-18  ·  Iterations: 2  ·  AXON: 9/10  ·  User: pending
Status: DRAFT — plan confirmed (Option A dual-track), write step not yet closed

---

## Context (from Phase 1)
**Goal:** Produce a publishable academic/positioning paper that defines the "harness engineering" category, presents AXON as its reference implementation, positions it honestly against the validated academic landscape, and surfaces the pre-release improvements required before open-source publication.

**Paper genre:** Architecture + mechanism + case-study (kernel paper). Not a benchmark paper.

---

## Authorship Profile
Background: computational science (multiscale numerical methods, porous media flow, reservoir simulation). All 7 prior publications in: Journal of Petroleum Science and Engineering, Applied Mathematical Modelling, Advances in Water Resources, Journal of Computational Physics, Journal of Scientific Computing. h-index 4, 68 citations. Affiliation: Reservoir Simulation Scientist, TNO.

**Writing register:** Definition-first, measurement-backed, systematic comparison tables, scoped claims. Title convention: method + problem class + property (e.g. "A Kernel-Based Architecture for Identity-Stable AI Agent Governance"). NOT ML-blog casual.

**Multiscale analogy available:** AXON's kernel/userspace/addon layer model structurally parallels multiscale numerical methods — available as a framing device in §4. Use selectively.

**First AI publication.** Claims must be conservative, mechanism descriptions rock-solid, evaluation rigorous.

---

## Structure: Dual Track

### Track V — SOSP 2026 Vision Paper (HARD DEADLINE: July 1, 2026)
AgenticOS @ SOSP 2026, 2nd Workshop on OS Design for AI Agents.
Congress Hotel Prague, September 29, 2026.
Format: 1-2 pages ACM double-column, double-blind review.
Topics match: "novel OS abstractions for agent execution environments", "state management for agent context and memory", "agent reliability and fault tolerance".
Estimated acceptance: 45-60%.

Fast-track forcing function: locks in harness engineering definition, establishes workshop precedence, feeds Track F §2 as self-citation after acceptance.

### Track F — Full Paper (COLM 2027 or ICSE 2027)
Recommended venue: ICSE 2027 (better fit than COLM — software architecture, governance, tool ecosystems).
Estimated acceptance: 20-30% baseline → 35-45% with SOSP acceptance + OSS release + user study data + AI/systems co-author.
Inherits PR-V01 and PR-V02 from Track V (shared, do not duplicate).

---

## Acceptance levers (ordered by impact)
1. OSS release before full paper submission — removes reproducibility objection
2. SOSP acceptance first — makes "harness engineering" category peer-reviewed and citable
3. AI/systems co-author — reduces outsider discount (TU Delft / TNO connection pending)
4. User study data — 5+ developers with measured outcomes (drift events, rule catches, token savings)
5. Target ICSE 2027 over COLM 2027 — systems paper, not ML paper

**Co-author question: OPEN** — "What's your co-author picture at TNO or TU Delft?" (pending user answer)

---

## Section plan (full paper)
1. Introduction — governance gap, Gartner 40%, 3 unsolved problems
2. Related Work — AIOS, MemGPT, AgentSpec, Agent libOS, orchestration frameworks (7 confirmed citations)
3. The Harness Engineering Category — formal definition, distinction from prompt/context/orchestration engineering
4. AXON Architecture — layer model, 5 differentiators, mechanisms (corrected benchmark: 23-44% avg 30%)
5. Comparison — AXON vs. competitors on 6 dimensions; AgentSpec comparison pending PR-003
6. Evaluation — token reduction table + axon-paper recursive case study
7. Discussion + Open Questions
8. Conclusion + OSS roadmap
