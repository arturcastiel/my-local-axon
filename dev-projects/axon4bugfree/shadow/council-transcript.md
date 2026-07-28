# HR Council — evaluate the graphify markdown-blind finding + set the goal
task: AXON's code graph is Python-only (markdown-blind). AXON is a markdown-programmed OS
      (178 program .md + markdown kernel). Owner: "if it is markdown-blind it is worthless for us."
      Judge if true; recommend the improvement GOAL.
protocol: 5 sealed parallel seats (fresh-per-seat, no cross-talk) → main-loop deliberation → verdict.

---

## SEAT 1 — STATIC-ANALYSIS / COMPILER
- VERDICT "worthless as-is": **PARTIALLY-TRUE** — graphify is correct+useful for the external/Python
  tools layer it was scoped to (honest "0 callers" fact); it is HALF-BLIND, and the missing half (the
  178-program topology) is the half that matters for a markdown OS. "Worthless for us" overstates a real gap.
- HARD MEASUREMENT (grep over all 178 programs): TOOL() 719 calls **100% statically resolvable** (bare
  tool name, bounded ~60-tool vocab); EXEC 210 (92% bare-name→program path); STORE 536 (98.3%);
  RETRIEVE 615 (99.2%). Only wrinkle: 55 multi-line TOOL calls + ~8% braced/dynamic dispatch (fatal to
  line-grep, trivial for a bracket-balanced tokenizer).
- FEASIBILITY of a markdown-layer extractor: **EASY** (~200-350 LOC stdlib). Folds into the EXISTING
  graph.json node-link schema; the confidence enum (EXTRACTED/INFERRED/AMBIGUOUS) already carries static
  vs dynamic edges. New relations invokes/execs/writes/reads; new nodes _origin:markdown. Fail-degrade to
  an AMBIGUOUS edge, never a crash. THIS ARTIFACT IS ALSO the P2 writer/reader generator.
- GOAL: build a deterministic stdlib markdown-layer extractor that parses every program's
  TOOL/EXEC/STORE/RETRIEVE into graph.json (program→tool invokes, program→program execs, program↔key
  writes/reads; EXTRACTED static / AMBIGUOUS dynamic) so the graph sees AXON's own program topology.
- CONFIDENCE: 85. Risk: the ~8% dynamic-dispatch tail is exactly the highest-fanout hub edges —
  EXTRACTED-only could give false connectivity/dead-key confidence at the busiest nodes; caps P2/P8
  strength until the runner (P6) exists.

## SEAT 3 — ARCHITECT (OS/platform)
- VERDICT "worthless as-is": **PARTIALLY-TRUE** — half-blind, not worthless; graphs the Python plumbing
  correctly (real fan-out, just produced a TRUE self-insight) but measures the plumbing, not the OS.
  Owner's "worthless" = useful provocation, literally false.
- ONE unified graph, unambiguously — the value is the SEAM between layers (program→tool→python-symbol,
  program→key→program). Two graphs reproduce today's blindness. Emit markdown nodes/edges into the SAME
  graph.json code_graph already produces, joined on REGISTRY.json (tool name → tools/*.py script).
- KEYSTONE (one sentence): make the markdown neuron layer first-class in AXON's own graph — extract
  program→tool + program→state-key edges into the unified graph so the OS sees itself invoke+wire its neurons.
- ⚠ CORRECTS THE STUDY: the study's keystone call (P6 runner) is WRONG. Graph-awareness (static
  extraction) and the P6 runner (behavioral/dynamic) are SEPARABLE. The DSL is statically parseable TODAY
  via a registry join — NO interpreter required (the study's own P2 note concedes "the generator must
  parse .md, not the code graph"). Graph-awareness is the CHEAP unblocker of P2/P8; the runner is a bigger
  DIFFERENT goal this de-risks. "Sequencing the cheap unblocker behind the expensive one is the study's
  one strategic error."
- MINIMAL first version: one deterministic static pass over the 194 .md — regex TOOL(name,…), resolve
  name→tools/*.py via REGISTRY.json, write program nodes + program→tool "invokes" edges into graph.json;
  kills the "0 callers" blind spot + proves concept; add program→key edges next to unblock P2.
- CONFIDENCE: 82. Risk: node-identity/join fidelity (dynamic/interpolated tool names, aliases, TOOL()
  names not in REGISTRY) dangle edges → the first pass MUST report join coverage (matched vs unresolved)
  as a quality signal.

## SEAT 4 — SKEPTIC / RISK AUDITOR (dissents on the SOLUTION)
- NEW EVIDENCE (reframes the debate):
  1. THREE graph systems already exist + overlap: code_graph.py (in-house AST, Python-only, GATE-ELIGIBLE);
     graphify_bridge (external multi-lang, NEVER gated, fail-degrades); codemap graph.json (Obsidian export).
  2. The codemap graph ALREADY has 11,060 markdown `document` nodes + 2,102 rationale nodes / 23,521.
     So AXON is NOT wholesale markdown-blind — it has a markdown-INCLUSIVE graph today.
  3. BUT its edges are contains/calls/references/rationale_for/imports — **ZERO AXON-LANG dataflow edges**
     (no STORE/RETRIEVE/EXEC/TOOL). Markdown-VISIBLE but AXON-LANG-BLIND (file-level + wikilinks, not parsed ops).
  4. memory_key_lint.py ALREADY extracts the real AXON-LANG layer (STORE/RETRIEVE/TOOL(memory,set)),
     builds the reader/writer bipartite relation, and GATES on unguarded orphan reads (the dominant defect
     class) — with regex + burn-down baseline and **NO graph at all**.
- VERDICT "worthless": OVERSTATEMENT — a true scope limit not worthlessness. (Fair kernel: it answers the
  mechanic's Q "what breaks if I change a TOOL" not the author's Q "what breaks if I change a PROGRAM",
  which is the #1 question for an OS made of programs.)
- THE TRAP (strongest case AGAINST a markdown graph): bugs are killed by specific INVARIANTS (unguarded
  orphan read, dangling TOOL/EXEC target, dead program ref), NOT a general-purpose INDEX. Those are
  ~200-line grep-LINTS that GATE with the proven ratchet+baseline (memory_key_lint = existence proof). A
  graph gives queryability, not gating — and would be a FOURTH graph duplicating the 11k-node codemap one,
  or a hand-written AXON-LANG parser that bit-rots vs GRAMMAR.md/COMPILER.md. "We lack a graph" is being
  confused with "we lack coverage."
- SKEPTIC'S GOAL (needs NO graph): extend the memory_key_lint pattern into 2-3 more AXON-LANG grep-lints
  that GATE — dangling TOOL()/EXEC() targets + dead-program refs, each with a burn-down baseline; reuse the
  existing codemap graph.json only for non-gating human navigation.
- CONFIDENCE: 70. THE ASSUMPTION MOST LIKELY WRONG: that AXON's defects are LOCAL (per-file invariants a
  lint sees). If dominant bugs are TRANSITIVE/multi-hop (A EXECs B which RETRIEVEs a key only some callers
  of A seed), grep can't answer that — a real AXON-LANG call/dataflow graph becomes the right tool, not a
  shiny object.

## SEAT 2 — DEVELOPER-TOOLING / DX LEAD
- VERDICT "worthless": **PARTIALLY-TRUE (leans FALSE)** — genuine missing half (no AXON-LANG semantic
  edges) but the graph is a working partial asset (gate-eligible Python self-analysis + 11k md nodes for
  navigation + real external-repo value). Highest-value missing slice (key connectivity) already covered
  more cheaply by regex lints.
- VERIFIED: codemap graph.json has 11,060 md nodes but `calls`(4,869)/`imports` are Python↔Python only —
  NO program→TOOL edge, NO STORE→RETRIEVE edge = "the real missing half". memory_key_lint + 
  program_tool_conformance are markdown-native BY DESIGN (regex over .md), serve the who-calls-what /
  who-writes-which-key self-analysis WITHOUT the graph. F-H8/F-H10 survived on a SCOPE GAP (lints don't
  scan the kernel = P1), not a missing graph. Where blindness bites: codemap-ask `callers --symbol {md}`
  resolves over Python-only edges → ∅.
- HIGHEST-ROI GOAL: ship the Tier-1 markdown-native lint sweep — P1 (kernel-scope the conformance lints) +
  P2 (GENERATE the writer/reader key-map + connectivity lint) + P3/P5 — retires the dominant reader/writer +
  stale-mirror classes NOW at 1-file blast, WITHOUT rebuilding the graph.
- SEQUENCE: GOAL comes BEFORE any markdown-graph investment. Graph-awareness = multi-PR whose only marginal
  payoff is P2/P8 precision the regex generator already largely delivers — spend later, gated on a residual gap.
- CONFIDENCE: 80. Risk: P2's own 67% naive-FP rate across 424 keys — if the regex generator is too noisy,
  a typed-edge graph may become the ONLY path to low-noise connectivity, pulling the graph goal EARLIER.

## SEAT 5 — TEST / QA ENGINEER
- VERDICT "worthless": **PARTIALLY-TRUE** — graph is markdown-blind (owner right on the fact) but it's a
  Python blast-radius tool, not the md layer's test harness; that layer already has md-aware conformance
  lints. Markdown-blindness + weak md testability are DIFFERENT problems; a md graph would NOT have caught
  run-3's bugs (static contract drift, pre-runtime).
- MOST RELIABILITY: **(c) prevention lints** — mechanically prevent the most of run-3's ACTUAL classes,
  already exist in partial form; fix = widen scope (P1) + generate key-map (P2), not new capability. A md
  GRAPH catches only the connectivity subset (phantom keys), never a dead CLI interface (needs the argparse
  probe the lint already does), at far higher build cost. A md RUNNER (P6) tests behavior but wouldn't have
  caught F-H8/F-H10, is the biggest build, and turns 170 LLM-interpreted programs into NONDETERMINISTIC
  behavioral tests (flake risk — QA red flag).
- GOAL: close recurring static-drift classes at the gate — P1 (kernel-scope) + P2 (generate reader/writer
  key-map) + P3 (generated count artifacts vs brittle text-pins); invest in md-parsing PREVENTION LINTS;
  sequence P6 runner later as a behavioral ceiling, not the reliability fix.
- CONFIDENCE: 85. Risk: lints retire KNOWN recurring classes but are blind to NOVEL semantic/behavioral
  bugs — only P6 exercises real behavior. If run-4 failures shift from contract-drift to logic bugs, lint
  yield plateaus and P6 becomes the true ceiling.

# ═══ PLAN-REVIEW COUNCIL (round 2 — is the plan ready / better alternative?) ═══

## REVIEW SEAT — ALTERNATIVE GENERATOR — YES, a better AMENDMENT (Wave 2 only)
Accepts the council SEQUENCE (gate→graph→runner); rejects graph-first (B loses). But Wave 2 is
under-measured. VERIFIED by main loop:
- MY PLAN SAID "3 parsers." REALITY: ~17 .py files with own AXON-LANG regex (main-loop grep: 32 with
  opcode-regex + re usage) — and they DISAGREE on the alphabet: memory_key_lint._STORE = `STORE\((W|L):`
  (VERIFIED line 61) — BLIND to the E: scope simulate.py parses `(W|L|E)` (VERIFIED). "Gate is only as
  correct as its parser" → building gates on sand.
- MOST of PR-005's "new" gates ALREADY EXIST (all VERIFIED):
  · dangling TOOL() → program_tool_conformance already emits unknown-tool/unknown-subcommand.
  · dead EXEC/dead-program → deps.py:161 already computes `missing_exec` — but NOT in crucible (VERIFIED
    False). WIRING job, not new code.
  · phantom keys → memory_key_lint already gates.
  · dead keys → memory_key_lint has collect_writers()(:77) + collect_reads()(:96) — reverse query.
AMENDMENT (keeps sequence, restructures Wave 2):
  1. FLIP to a behavior-PRESERVING library refactor FIRST: extract ONE canonical tokenizer tools/axonlang.py
     from the strongest existing impls (program_tool_conformance template-strip + simulate's full opcode+E:
     set); migrate consumers with ZERO behavior change, proven by their existing tests+baselines. Scope ≥
     deps/simulate/memory_key_lint/program_tool_conformance. Reduce-surface becomes the PR that CAN'T get cut.
  2. REUSE deps.py check for the EXEC/dead-program gate → promote into crucible w/ baseline. Don't reimplement.
  3. ADD dead-key (written-never-read) to memory_key_lint WITH ITS EXISTING noise discipline (W:_* dynamic
     exemption + allowlist + baseline) — critical: the 8% dynamic-dispatch tail is the highest-fanout hubs,
     so naive EXTRACTED-only written-never-read = FALSE BLOCK at the busiest keys (re-creates the 67% noise).
  4. DEFER the join-coverage metric + relation-emission to the graph wave (PR-007) — gates use conservative
     skips of un-attributable sites (as all existing lints do), not coverage thresholds; coverage machinery
     for a decision-gated graph is speculative infra.
CONFIDENCE 68. Flip risk: if the ~17 parsers are too semantically coupled to unify without behavior change,
the plan's "one clean new extractor, leave legacy alone" is pragmatic — but points 2-4 survive regardless.

## REVIEW SEAT — READINESS AUDITOR — READY-WITH-GAPS (corroborates the alternative)
COVERAGE COMPLETE (G1-G5 all trace, deps acyclic); REGISTRY join clean (188 tools; 91/94 invoked names
resolve, only my-tool/name/semantic-search dangle); multi-line tokenizer justified (60 multi-line TOOL);
PR-007 genuinely not-done (code_graph emits only Python calls/imports). But NOT ready as written — 4 gaps:
- GAP 1 (PR-002): REBUILDS an existing tool — tools/doc_counts.py (PR-14.1) already has check/fix/counts,
  already wired as gate+auto-heal in freshness.py:152,207. CONTEXT.md/ARCHITECTURE locked to LIVE registry
  (test_onboarding_counts.py:3), not hard-typed 188. Real residual = EXTEND doc_counts patterns to their
  richer phrasing + wire fix. As written = a SECOND count tool (the duplication PR-006 exists to prevent).
- GAP 2 (PR-005 b/c): overlaps deps.py's existing `check` (missing_exec) — reconcile, don't rebuild.
- GAP 3 (PR-006): undercounts parsers — ≥6 (memory_key_lint, program_tool_conformance, deps, docgen,
  audit_axon_lang, exec_args_lint); reconciles only 2. (Alternative seat counted 17.) Under-scoped.
- GAP 4 (PR-005 d) — THE DESIGN RISK: raw written-never-read = 92 candidate dead keys; memory_key_lint's
  docstring records the naive rule = 67% noise (223/333); W:_* argument keys (read via run --input,
  statically invisible) are DELIBERATELY exempted (line 13). PR-005 carries none of that forward → would
  either baseline ~90 keys (gutting the gate) or silently re-derive the exemptions. MUST inherit
  memory_key_lint's tuned discipline (= alternative seat point 3).
MINOR: stale grounding pins (live = 791 TOOL / 287 EXEC, not 797/226); "zero kernel .md" imprecise
(program_tool_conformance already scans axon/programs/; the true gap is axon/*.md top-level — PR-001's own
scope names it correctly); PR-003 "tools/hooks/" conflates agent-lifecycle hooks vs git .pre-commit-config.
CONFIDENCE 84. Gaps are scope/framing corrections + GAP-4 noise risk — fixable with scope edits, not a re-plan.

## REVIEW SEAT — DEPENDENCY / RISK HUNTER — YES-WITH-CHANGES (one HARD STOP)
Ran the real lint code against the real kernel files. Ranked risks:
- RISK 1 🚩 PR-003 AUTO-BLESS = HARD STOP, DO NOT SHIP. VERIFIED: program_integrity.py docstring — manifest
  "deliberately separate from the autogen REGISTRY so a generator can never auto-bless drift"; cmd_bless
  re-blesses ALL covered files; doctrine_preflight uses it as a PRE-EXECUTION injection guard (poisoned
  routine can't validate); control is WARN 245/245 blessed, promotes_on "0 unblessed for a wave → BLOCK"
  (on the verge). Auto-bless = security theater + neuters the injection guard. The recompile half writes
  compiled mirrors which ARE covered power-files → creates the pressure that "justifies" auto-bless (the two
  halves couple around the gate they undermine). MITIGATION: split — ship RECOMPILE-ONLY; hook runs
  program_integrity check → BLOCKS the commit with the exact `bless` command for the human. NO auto-bless.
- RISK 2 PR-001: NOT a flood (3 live violations) but all 3 are FALSE POSITIVES from prose (filename
  `tools/drift.py` matched as accessor; TOOL(context,check) in a fenced PLANNED-tool block; drift.confidence_
  modifier in prose). program-tool-conformance is BLOCK all-scopes; conformance_baseline is at 0 (ratchet =
  only-shrink, Wave F requires empty). Baselining 3 unfixable FPs breaks the ratchet. MITIGATION: HARDEN the
  prose-naïve extractor (strip fenced + inline-code spans; bound accessor var-tracking) BEFORE widening scope
  → then live kernel is genuinely 0. Don't baseline the FPs.
- RISK 3 PR-005/006: crucible runs SERIALLY (39 controls); program_tool_conformance ~8s (subprocess argparse
  probes); PR-005 dangling-TOOL re-probes the same surface = double-gating + duplicate cost until PR-006
  dedups (which ships after). Fresh baselines (both currently 0) re-open the mask-a-real-bug surface.
  MITIGATION: fold PR-006 dedup INTO PR-005 (build the check as a CONSUMER of the relation, not a 2nd
  prober); baselines ship empty or annotated fixable-not-FP.
- RISK 4 LOW: no collision with baselined ws-name/ws-log (different lint, different namespace). WATCH:
  PR-006's unified extractor must PRESERVE the path-var (W:ws-*) vs memory-key (W:*) namespace distinction.
VERDICT: SAFE to start W1 YES-WITH-CHANGES — PR-002 clean, PR-001 safe WITH hardening, but PR-003 must be
re-planned recompile-only BEFORE it ships. CONFIDENCE 88.
