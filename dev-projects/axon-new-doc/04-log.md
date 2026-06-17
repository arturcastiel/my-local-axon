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
