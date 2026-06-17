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

## DEEP-STUDY + RE-GRADE — study FINISHED · 2026-06-17
7 deep-readers (code-dev families ×4 + plan + chat + b-traps) ran backing tools for REAL
output (hybrid contract). Artifacts: study/deep/00..06 (~98KB command-level reference +
verified examples). RE-GRADE: cd-lifecycle A · cd-pr A · cd-safety-structure A ·
cd-journal-state A · plan B · chat A · b-traps A. All examples_ready.
Universal blocker RESOLVED: hybrid contract honored (CLI output where a tool exists;
session-transcript-from-source for agent-interpreted neurons; boundary stated).
Confirmed live: no `pr` tool, no `deep-research` program (it's a skill → wiki 'Skills' section).
Remaining gaps non-blocking (mutating/auth surfaces left un-run by design; non-deterministic
agent-runtime behavior) — not fixable by more reading. VERDICT: study FINISHED.
phase-model: study → DONE. Next: code-dev plan.

## FINDING (drift-fix input) — doc_index indexes runtime memory · 2026-06-17
PR-027's doc_index.py (and docgen) index workspace/memory/working|longterm + root memory/
(kv-store + runtime scopes), so DOC-INDEX/AXON-DOCS go stale every session as memory keys
are written (cognition-frame, host-cap-*, code-dev-cmd, etc.). Pure runtime churn, not a
content change. FIX (fold into the wiki drift-fix work): add workspace/memory/ + root
memory/ to doc_index EXCLUDE (like my-axon), and stop docgen listing volatile L:/W: keys.
(Stray workflow-agent scratch memory/A8-*.md also removed this session.)

## PLAN — tactical --budget 7 · 2026-06-17
Wave 1 (7 PRs, dependency-ordered): PR-001 wiki scaffold+template+INDEX-skeleton · PR-002
freshness/doc_index wiring (+runtime-memory drift fix) · PR-003 code-dev manual · PR-004
workflow manual · PR-005 library-dev manual · PR-006 INDEX+cross-links · PR-007 wiki test
harness (Guarded by). DAG: 7 nodes/11 edges, critical-path 001→003→006→007.
Peers deferred → 02-prs.deferred.md (goal-define, plan, chat, harness-builder, skills/deep-research).
Source material = study/deep/00-06 (verified hybrid examples). Next: code-dev pr.

## WAVE 1 COMPLETE — wiki foundation + flagship 3 · 2026-06-17
7 PRs merged (d45b744 infra · 1d04948 manuals · 5621701 index+guard):
pr-1 scaffold · pr-2 doc_index runtime-memory fix + wiki indexed · pr-3 code-dev manual
(200L) · pr-4 workflow manual (344L) · pr-5 library-dev manual (239L) · pr-6 INDEX populated
· pr-7 test_wiki.py guard (5 tests). All examples run-verified (hybrid). Every gate green.
workspace/wiki/ now ships 3 flagship manuals + INDEX + template, freshness-gated.
Next: WAVE 2 (peers: goal-define, plan, chat, harness-builder + skills/deep-research).

## ════ AXON-NEW-DOC COMPLETE — 2026-06-17 ════
Goal MET: usage-wiki for the big AXON programs. 13 PRs across 2 waves, all crucible-green.
Wave 1 (d45b744/1d04948/5621701): scaffold + doc_index-fix + code-dev/workflow/library-dev
manuals + INDEX + test_wiki guard. Wave 2 (efbe705): goal-define/plan/chat/harness-builder
manuals + skills.md (deep-research).
DELIVERED: workspace/wiki/ — 8 manual pages + INDEX + _template, freshness-gated, guarded by
tests/test_wiki.py. 39 labeled real examples (tool-runs executed + session-transcripts;
anti-mimicry honored). All 6 acceptance criteria met. Phases study→plan→pr→log→audit DONE.
Constraints satisfied: examples run-verified, freshness-gated, programs untouched.

## BUGFIXES + README LINK (owner ask, post-completion) · 2026-06-17
Owner asked to (1) link the wiki from README, (2) fix the bugs the study surfaced.
Done (axon repo, commits 4917dc8):
- README.md: Documentation section now leads with workspace/wiki/INDEX.md (user manuals)
  distinct from AXON-DOCS architecture reference.
- tools/library.py: '## Key Terms & Concepts' parse-drift FIXED (regex matches trailing
  words; key_terms was always empty). + regression test.
- tools/docgen.py: hardcoded '44 ACTIVE' → LIVE registry count (now 156); identity row
  'Never disclosed' → gated-disclosure wording (removes the AXON-DOCS contradiction). + test.
NOTE: these are sanctioned axon MAINTENANCE fixes (separate from the wiki authoring) — the
programs-untouched constraint scoped the documentation work, not surfaced-bug remediation.
Status of the 3 study bugs: doc_index drift ✓ (pr-2) · library Key Terms ✓ · docgen drift ✓.

## WAVE 3 COMPLETE — code-dev getting-started tutorial · commit c01fbd9 · 2026-06-17
Owner-requested + approved (multi-agent plan: log-miners on owner build-patterns → 3-lens
design panel → synthesis). Shipped workspace/wiki/getting-started.md: a beginner walk through
the full study→plan→pr→log→audit spine on a DEVISED example (my-first-fix, one-line README
fix) — NOT the owner's real projects (per owner steer: mine patterns, devise examples). 13
sections, 3 verified examples (2 tool-run + 1 session-transcript), two-hard-contracts up front,
gates-as-friend, code-dev next safety-net. INDEX 'Start here' section added. Gate green 32/0.
Wiki now: 9 pages (8 manuals + getting-started) + skills + INDEX, freshness-gated, test-guarded.
