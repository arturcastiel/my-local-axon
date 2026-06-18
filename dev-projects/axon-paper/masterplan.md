# Masterplan — AXON Paper

## Goal
Produce a publishable academic/positioning paper that:
1. Defines the "harness engineering" category
2. Presents AXON as its reference implementation
3. Positions against the validated academic landscape (AIOS, MemGPT, AgentSpec, Agent libOS)
4. Surfaces pre-release improvements required before open-source publication

## Phase graph (directed)

- **study**   → plan
- **plan**    → build (paper drafting)
- **build**   → audit (pre-release improvements + paper review)
- **audit**   → done (submission-ready)

## Phase descriptions

### study
Deep architectural study of AXON + market audit synthesis.
Inputs: KERNEL-SLIM.md, AXON-DOCS.md, market research report (2026-06-18), axon-audit results.
Outputs: 01-study.md with architecture map, gap analysis, competitor matrix, paper outline.

### plan
Design the paper structure. Identify what must be BUILT vs. what can be referenced.
Identify pre-release improvements (shadow index, drift init, usage log, OSS packaging).
Outputs: 02-plan.md with paper section outline + 02-prs.md with improvement PRs.

### build
Write the paper sections. Produce the manifesto. Produce the improvements list.
Each section is a PR. Paper is in paper/ directory.

### audit
Internal review pass. Verify all competitor claims are cited/sourced.
Run crucible gate. Owner signs off. Mark submission-ready.

## Output artifacts
- paper/axon-paper.md          main paper (target: arXiv, COLM 2027 or ICSE 2027)
- paper/manifesto.md           "Harness Engineering" short-form blog/post
- improvements/pre-release.md  gated improvement list before OSS release
