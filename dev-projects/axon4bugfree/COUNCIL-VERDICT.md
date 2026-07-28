# HR Council Verdict — graphify markdown-blindness → the GOAL
project: axon4bugfree · date: 2026-07-13 · protocol: 5 sealed seats → main-loop deliberation
seats: static-analysis · architect · skeptic/auditor · DX/ROI · test-QA (transcript: shadow/council-transcript.md)

## ON THE OWNER'S CLAIM ("if it is markdown-blind it is worthless for us")
**UNANIMOUS: overstatement — right on the fact, wrong on "worthless."**
- TRUE fact: AXON's graph has ZERO AXON-LANG semantic edges. It sees Python↔Python (`calls`/`imports`)
  and 11,060 markdown FILE nodes, but no `program→tool` (invoke), no `STORE→RETRIEVE` (key write/read),
  no `program→program` (exec). It answers the mechanic's question ("what breaks if I change a TOOL")
  not the author's ("what breaks if I change a PROGRAM") — the #1 question for an OS made of programs.
- NOT worthless: the Python-tools graph is a working, gate-eligible asset (it just produced a TRUE
  self-insight), and the dominant defect class is ALREADY partly gated by markdown-NATIVE lints
  (memory_key_lint parses STORE/RETRIEVE; program_tool_conformance parses TOOL() + probes argparse).
  Run-3's F-H8/F-H10 survived on a SCOPE GAP (those lints don't scan the kernel), NOT a missing graph.

## THE DISAGREEMENT + HOW IT RESOLVES
Split 3–2 on OUTPUT FORMAT (gate-lint vs query-graph), but the reasoning converges on a SEQUENCE:
- Seats 1+3 (static-analysis, architect): the AXON-LANG static extractor is EASY (~200-350 LOC, 98-100%
  parseable) and IS the P2 generator; emit into ONE unified graph.
- Seats 2+4+5 (DX, skeptic, QA) — the deciding majority: bugs are killed by GATED INVARIANTS, not a
  queryable index; the dominant class is LOCAL; a graph is sufficient-not-necessary and costlier; lints
  that GATE prevent recurrence. Do lints FIRST.
- The two positions are the SAME artifact (the AXON-LANG edge extractor) with two consumers. Resolution:
  gate first (prevents recurrence), graph second (enables the transitive queries), runner last (behavior).
- CORRECTS the study: the study made the P6 runner the keystone. It is NOT — static extraction needs no
  interpreter; the runner is a separate higher-ceiling goal this de-risks.

## THE GOAL (set from the verdict)
**Make AXON's self-analysis see its own AXON-LANG layer — as GATING LINTS first, a graph second, a runner last.**

Ordered, each gated on the prior proving out:

- **G1 (now · low-risk · 1-file blast) — close the scope gap.** Widen the existing markdown conformance
  lints (`program_tool_conformance`, `lint_path_vars`) to the kernel `.md` files. This is the exact gap
  that let F-H8/F-H10 survive run-3. [P1]
- **G2 (now · the core) — the AXON-LANG edge extractor, delivered as GATING LINTS.** One deterministic
  stdlib pass over all 194 `.md` extracting TOOL()/EXEC()/STORE()/RETRIEVE() into a reader/writer/invoke/exec
  relation, joined on REGISTRY.json. Gate on: phantom keys (read-never-written), dead keys (written-never-read),
  dangling TOOL()/EXEC() targets, dead-program refs — each with a burn-down baseline (the memory_key_lint
  pattern). MUST report join coverage (matched vs unresolved) as a quality signal (architect's risk).
  This is the P2 "generator" — and it retires the reader/writer drift class that dominated all 3 audits. [P2]
- **G3 (now · nuisance-killers) — generated doc-count artifacts [P3] + auto-recompile/auto-bless [P5].**
- **G4 (next · GATED on residual) — emit the SAME extracted edges into the unified graph.json** (program→tool
  invokes, program→key writes/reads; EXTRACTED static / AMBIGUOUS dynamic) as a NON-gating query layer, so
  the OS can answer TRANSITIVE questions (P8 impact, multi-hop reachability). Build this ONLY if G2's lints
  leave a real multi-hop gap (the skeptic's decisive caveat: local invariants → lints suffice; transitive
  bugs → graph needed). Do NOT build a 4th graph — extend the existing schema.
- **G5 (later · ceiling) — the markdown runner [P6]** for behavioral coverage of the 170 uncompiled programs.
  Separate, higher-ceiling, nondeterministic (QA flag); the true ceiling only if run-4 shifts from
  contract-drift to logic bugs — NOT the reliability fix.

## WHY THIS IS THE RIGHT GOAL (not just the loudest seat)
It honors the owner's real point (make AXON see its own AXON-LANG layer — the missing half is real), the
unanimous "extract the AXON-LANG edges" core, AND the 3-seat majority that gating beats indexing for bug
PREVENTION. It sequences cheap-and-gated before expensive-and-queryable — fixing the study's one strategic
error. Confidence-weighted seat support: G1/G2/G3 carry all 5 seats; G4 carries seats 1/3 (+ the DX/QA
"gated on residual" condition); G5 is unanimous-later.

## NEXT
code-dev plan — cut PR waves: Wave 1 = G1+G3 (quick sweep) · Wave 2 = G2 (the extractor-as-lint, the core) ·
Wave 3 = G4 graph-emission (gated) · G5 runner deferred.
