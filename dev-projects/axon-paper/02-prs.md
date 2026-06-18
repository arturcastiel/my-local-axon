# PR List — AXON Paper
Updated: 2026-06-18  ·  Total PRs: 22 (4 Track V + 18 Track F)
Status: DRAFT — pending user satisfaction score

---

## TRACK V — SOSP 2026 VISION PAPER (deadline July 1, 2026)

## PR-V01 — Fix benchmark claim in AXON-DOCS.md
- **Status:** not-started
- **Complexity:** S
- **Scope:** workspace/AXON-DOCS.md line 27
- **Depends on:** none
- **Shared with:** PR-001 (Track F) — same PR, counted once
- **Why:** "40-70%" is overstated; real measured data is 23-44% avg 30%; paper will cite this file directly
- **Spec:** 03-prs/PR-V01.md (not written yet)

## PR-V02 — Draft formal harness engineering definition
- **Status:** not-started
- **Complexity:** M
- **Scope:** phases/study/04-category-definition.md (new file)
- **Depends on:** none
- **Shared with:** PR-005 (Track F) — same PR, counted once
- **Why:** Primary contribution of vision paper; must be settled before PR-V03 and PR-008 (Track F §3)
- **Spec:** 03-prs/PR-V02.md (not written yet)

## PR-V03 — Vision paper draft (1-2 pp ACM double-column)
- **Status:** not-started
- **Complexity:** M
- **Scope:** paper/vision-sosp26.md (new file)
- **Depends on:** PR-V01, PR-V02
- **Why:** "Harness Engineering: A Kernel-First Architecture for Governance-Stable AI Agents" — problem statement, formal definition, AXON mechanism overview, 1-2 competitor comparison points
- **Spec:** 03-prs/PR-V03.md (not written yet)

## PR-V04 — Anonymize + final claims check + submit
- **Status:** not-started
- **Complexity:** S
- **Scope:** paper/vision-sosp26-anon.md (anonymized copy)
- **Depends on:** PR-V03
- **Why:** Double-blind requires stripping author identity, AXON GitHub URL, TNO affiliation; cross-check all claims against 8-confirmed/17-killed ceiling
- **Spec:** 03-prs/PR-V04.md (not written yet)

---

## TRACK F — FULL PAPER (ICSE 2027 / COLM 2027)

## PR-001 — [= PR-V01, shared — see above]

## PR-002 — Add drift init to BOOT.md step 3
- **Status:** not-started
- **Complexity:** S
- **Scope:** axon/BOOT.md
- **Depends on:** none
- **Flag:** kernel-adjacent — human-approve before merge (kernel-floor constraint)
- **Why:** Organic drift trace data for paper §4; fail-closed gate strengthens governance claim
- **Spec:** 03-prs/PR-002.md (not written yet)

## PR-003 — Read + summarize AgentSpec arXiv 2503.18666
- **Status:** not-started
- **Complexity:** M
- **Scope:** phases/study/02-agentspec.md (new file)
- **Depends on:** none
- **Why:** D2 open question from study; §5 comparison cannot be written without it
- **Spec:** 03-prs/PR-003.md (not written yet)

## PR-004 — Research identity inversion in AutoGen/LangGraph/CrewAI/Semantic Kernel
- **Status:** not-started
- **Complexity:** M
- **Scope:** phases/study/03-identity-research.md (new file)
- **Depends on:** none
- **Why:** A4 open question; determines whether "identity inversion" claim is unique or requires scoping
- **Spec:** 03-prs/PR-004.md (not written yet)

## PR-005 — [= PR-V02, shared — see above]

## PR-006 — Paper §1: Introduction + problem statement
- **Status:** not-started
- **Complexity:** M
- **Scope:** paper/axon-paper.md §1
- **Depends on:** PR-V01
- **Why:** Governance gap, Gartner 40%, 3 unsolved problems; frames the entire paper
- **Spec:** 03-prs/PR-006.md (not written yet)

## PR-007 — Paper §2: Related work + citation table
- **Status:** not-started
- **Complexity:** L
- **Scope:** paper/axon-paper.md §2
- **Depends on:** PR-003, PR-004
- **Why:** All 7 confirmed academic citations + framework survey; includes self-cite of vision paper after SOSP acceptance
- **Spec:** 03-prs/PR-007.md (not written yet)

## PR-008 — Paper §3: Harness engineering category
- **Status:** not-started
- **Complexity:** L
- **Scope:** paper/axon-paper.md §3
- **Depends on:** PR-V02
- **Why:** Expands vision paper definition to full treatment; differentiates from prompt/context/orchestration engineering
- **Spec:** 03-prs/PR-008.md (not written yet)

## PR-009 — Paper §4: AXON architecture deep-dive
- **Status:** not-started
- **Complexity:** XL
- **Scope:** paper/axon-paper.md §4
- **Depends on:** PR-V01, PR-V02
- **Why:** Layer model, 5 differentiators, mechanisms; corrected benchmark numbers; multiscale analogy available
- **Note:** May split into §4a (mechanisms) + §4b (kernel rules) during build if context overflows
- **Spec:** 03-prs/PR-009.md (not written yet)

## PR-010 — Paper §5: Comparison table + analysis
- **Status:** not-started
- **Complexity:** L
- **Scope:** paper/axon-paper.md §5
- **Depends on:** PR-003, PR-004, PR-008
- **Why:** AXON vs. AIOS/MemGPT/AgentSpec/AutoGen/LangGraph on 6 dimensions; gated on D2 + A4 research
- **Spec:** 03-prs/PR-010.md (not written yet)

## PR-011 — Benchmark 5 more programs + grow dataset
- **Status:** not-started
- **Complexity:** M
- **Scope:** benchmark.py record ×5; benchmark export
- **Depends on:** PR-V01
- **Why:** Expands 3→8 data points; evaluation needs statistical basis matching computational science standards
- **Spec:** 03-prs/PR-011.md (not written yet)

## PR-012 — Paper §6: Evaluation
- **Status:** not-started
- **Complexity:** M
- **Scope:** paper/axon-paper.md §6
- **Depends on:** PR-011
- **Why:** Token reduction table (quantitative) + axon-paper development as recursive case study (qualitative)
- **Spec:** 03-prs/PR-012.md (not written yet)

## PR-013 — Paper §7-8: Discussion + Conclusion
- **Status:** not-started
- **Complexity:** M
- **Scope:** paper/axon-paper.md §7-8
- **Depends on:** PR-012
- **Why:** Open questions, limitations, OSS roadmap framing, scope statement
- **Spec:** 03-prs/PR-013.md (not written yet)

## PR-014 — OSS README + getting-started guide
- **Status:** not-started
- **Complexity:** M
- **Scope:** README.md, docs/getting-started.md
- **Depends on:** none
- **Why:** C4 critical gap; required before OSS release which is the #1 acceptance lever
- **Spec:** 03-prs/PR-014.md (not written yet)

## PR-015 — CONTRIBUTING.md + kernel edit policy + harness adapter template
- **Status:** not-started
- **Complexity:** M
- **Scope:** CONTRIBUTING.md, docs/harness-adapter.md
- **Depends on:** none
- **Why:** External contributor governance; needed for OSS release
- **Spec:** 03-prs/PR-015.md (not written yet)

## PR-016 — Refresh AXON-DOCS.md via axon-docs-gen
- **Status:** not-started
- **Complexity:** S
- **Scope:** workspace/AXON-DOCS.md
- **Depends on:** PR-V01
- **Why:** M4 staleness; lands after benchmark correction so both edits are in sync
- **Spec:** 03-prs/PR-016.md (not written yet)

## PR-017 — Shadow index rebuild for 5 stale projects
- **Status:** not-started
- **Complexity:** S
- **Scope:** my-axon/dev-projects/* (shadow dirs)
- **Depends on:** none
- **Why:** C1 gap; all 5 active projects have stale shadow index
- **Spec:** 03-prs/PR-017.md (not written yet)

## PR-018 — Manifesto — "Harness Engineering: The Missing Layer"
- **Status:** not-started
- **Complexity:** M
- **Scope:** paper/manifesto.md
- **Depends on:** PR-008
- **Why:** Blog/arXiv short form; feeds §1 framing; publishable independently of full paper
- **Spec:** 03-prs/PR-018.md (not written yet)

## PR-019 — arXiv LaTeX formatting + submission metadata
- **Status:** not-started
- **Complexity:** S
- **Scope:** paper/arxiv-submission.md
- **Depends on:** PR-013
- **Why:** Venue-ready artifact; ICSE 2027 or COLM 2027 submission
- **Spec:** 03-prs/PR-019.md (not written yet)

## PR-020 — Final review vs. confirmed-claims ceiling + style check
- **Status:** not-started
- **Complexity:** S
- **Scope:** review pass over paper/*
- **Depends on:** PR-019
- **Why:** Anti-fabrication gate: cross-check all claims against 8-verified/17-killed list; style check against computational science register
- **Spec:** 03-prs/PR-020.md (not written yet)
