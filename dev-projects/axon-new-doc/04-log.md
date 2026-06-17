# Implementation Log — axon new documentation

## SESSION START — 2026-06-17T12:21:11.918981Z
project:        axon-new-doc
phase:          study
workflow-step:  build
branch:         main

## Entries

## STUDY — overview · 2026-06-17
Mode: overview (8-mapper workflow → synthesis). Artifact: study/overview.md (264 lines).
Mapped 7 subsystems (kernel/tools/programs/code-dev/workflows/quality-gates/state-memory).
Output: architecture map + turn-flow + per-subsystem doc targets + Documentation Landscape
(18 prioritized gaps P0–P3) + 8 ordered doc targets.
KEY FINDINGS (P0 — docs visibly wrong today):
- docgen.py hardcodes "44 ACTIVE tools" into AXON-DOCS Mermaid; live = 156 ACTIVE/174 total.
  AXON-DOCS.md self-contradicts (44 vs computed 156). doc_counts.py glob excludes
  workspace/AXON-DOCS*.md so it's ungated.
- AXON-DOCS-ARCHITECTURE.md says both 150 and 156 ACTIVE (hand-authored drift, ungated).
- docgen.py bakes an identity "never disclosed" line contradicting the harness-disclosure rule.
8 doc targets: #1 conceptual-heart newcomer · #2 boot/turn-lifecycle · #3 enforcement/governance ·
#4 layers/state/memory · #5 programs+dispatch · #6 code-dev harness · #7 workflow engine ·
#8 DRIFT-FIX CHANGESET (do early — parameterize docgen counts, extend doc_counts globs).

## GOAL SET — goal-define · 2026-06-17
Hardened (3 forks): SCOPE = flagship code-dev/workflow/library-dev + peers (goal-define/
plan/chat/harness-builder/deep-research), ~6-8 manuals. EXAMPLE BAR = real, RUN-VERIFIED
commands+output (anti-mimicry). STRUCTURE = new workspace/wiki/ tree + INDEX, freshness/
doc-index wired. Audience = end-users ("so people can start to use them").
6 acceptance criteria recorded. 3 invariants → constraints (project:axon-new-doc):
wiki-examples-run-verified, wiki-freshness-gated, programs-untouched.
Reframes the project from architecture-reference (overview's 8 targets) to USER MANUALS;
overview map feeds the manuals as source context.

## STUDY GRADES — readiness audit · 2026-06-17
8 graders studied each target program's real surface. Grades: 0 A · 4 B · 4 C.
purpose-ready 8/8 · reference-ready 5/8 · examples-ready 4/8.
  B: workflow, library-dev, goal-define, harness-builder (tool-layer examples real)
  C: code-dev (only ~7% of 87 files studied; ref NOT ready), plan (output-format trap),
     chat (empty/unscaffolded, path discrepancy), deep-research (a SKILL, no on-disk spec)
VERDICT: STUDY NOT FINISHED for the goal. Universal blocker = the "run-verified example"
CONTRACT is undecided: AXON programs are LLM-interpreted .md neurons (NOT shell-runnable,
not in REGISTRY); only backing Python tools run deterministically. Must decide: runnable
tool-commands vs labeled agent-session transcripts — gates ALL examples-readiness.
Artifact: study/study-grades.md.
