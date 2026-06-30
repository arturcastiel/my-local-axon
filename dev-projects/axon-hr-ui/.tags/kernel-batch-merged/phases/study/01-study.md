# Study — axon-hr-ui
> Discovery synthesis from hr-team councils A / B / C · 2026-06-22 · **advisory_only**
> Consolidated, prioritized plan → `../../masterplan.md`
> Grounding context the councils critiqued → `../../councils/_context.md`

This study captures the raw council findings. The owner-facing plan lives in masterplan.md.
Everything here is advisory — no recommendation has decision-making force.

## Council A — Discovery
_Where are code-dev + workflows weak, over-engineered, or under-built? (7 seats × 3 rounds · adversarial)_

**Summary.** Council A (Discovery) deliberated over 3 rounds / 21 entries (8 seats: harness-designer, agentic-workflow-designer, agent-observability-engineer, ui-architect, auditor, completer-finisher, challenger) on where AXON's code-dev harness and workflow system are weak, over-engineered, or under-built. The deliberation converged hard on UNDER-INTEGRATION and CONTRACT/LEGIBILITY debt rather than over-engineering: the harness's 88-program surface and node-order rigidity are largely defended, while the phase-manifest, gate-labeling, and synapse-metadata layers are where operators actually get hurt. Severity migrated downward across rounds for several R1 claims (god-node centralization, node-order rigidity, phase-manifest "aspirational") as seats verified them against the live tree and retracted; severity stayed high or rose for the phase-registry split-brain, the advisory-gate-labeled-as-enforced mismatch, and the synapse-infer/validate contract gaps. The five most-supported, surviving defects: (1) phase-manifest split-brain — code-dev-phase-new writes masterplan.md+DAG.json but never _phases.json (the done/back/skip gating SSOT), and phase_model.py has no add/insert subcommand; (2) the forward study->plan->pr->log->audit ladder never advances _phases.json, so the node-order gate guards a usually-empty/frozen manifest; (3) "SHADOW GATE (enforced)" is a prose label over an advisory LOG+STORE that only fires on stale>0 and is silent on the empty-index case — a verified prose/contract mismatch; (4) synapse-infer concatenates ASSERT bodies with no dedup (11x-repeated preconditions, truncated dead synapse 'code-dev-phase-') and synapse-validate rubber-stamps it; (5) the adaptive-free-text loop terminates only on a hard 25-step cap because goal.rejection.met() has no production writer — a bandaid, not a fix. The adaptive->fixed promote/replay loop is built but operator-undiscoverable (one seat disputes, claiming it IS surfaced post-run). The home-screen mode-menu render bug was reported HIGH across rounds but the challenger and observability seats verified in R3 that it is FIXED (menu renders all modes; the council was quoting a fix-scar comment) — preserved as dissent. Over-engineering critiques of node-order rigidity did NOT survive challenge in any round.

**Verdict distribution** (dissent-preserving):
- `0.72` — Harness is under-integrated / under-finished (contract+legibility debt), NOT over-engineered — fix the wiring/labeling seams  ·  seats: agentic-workflow-designer, agent-observability-engineer, ui-architect, auditor, completer-finisher, harness-designer(R3)
- `0.16` — Most over-engineering targets survive challenge and should be left alone; only a small set of concrete wiring/aliasing defects are real  ·  seats: challenger, harness-designer(R2)
- `0.12` — Several R1 high-severity claims were misreads of intentional design / stale repo state and should be downgraded or retracted  ·  seats: harness-designer(R2), completer-finisher(R2-retraction), agent-observability-engineer(R3-retractions)

**Ranked findings (14):**

- **A#1 · Phase-registry split-brain: code-dev-phase-new writes masterplan.md + DAG.json but never _phases.json, and phase_model.py has no add/insert subcommand**  _[state-model · high]_
    - Rationale: Highest support x severity. Independently surfaced/sharpened by auditor (R3), completer-finisher (R3), agent-observability-engineer (R2/R3), ui-architect (R2), harness-designer (R3), and challenger (R3) as 'the real fragmentation.' _phases.json is the actual SSOT for the done/back/skip node-order gate, but custom phases can never reach it, so a phase-new project emits an unresolvable PHASE SPLIT-BRAIN warning and the gate guards a frozen ladder.
    - Proposal: Add `phase_model.py add --project --id --name --after <dep>` (deriving deps from the same predecessors input) and call it from code-dev-phase-new.md immediately after the DAG add-node step; recompute order+deps on insert. Pick ONE phase authority so single- and multi-phase projects share one SSOT.
    - Support: 6 of 8 seats (auditor 0.85, completer-finisher 0.83, agent-observability-engineer 0.82, harness-designer 0.62, ui-architect 0.79, challenger 0.78)

- **A#2 · Forward study->plan->pr->log->audit ladder never advances _phases.json — only done/back/skip mutate it, so the node-order gate usually guards an empty/frozen manifest**  _[workflows · high]_
    - Rationale: Verified by auditor (R2/R3), completer-finisher (R3), challenger (R3), agent-observability-engineer (R3), ui-architect (R3). The phase_model advance()/done()/stale_downstream() functions are fully coded but never invoked by the ACTIVE ladder programs, leaving the manifest a read-only artifact. This is the mechanism that makes the node-order gate (defended as good design) operate on stale state.
    - Proposal: Make phase advancement a side effect of the ladder: have each forward sub-program call TOOL(phase-model, done, --phase <self>) on its own DONE() gated by the existing output-completeness check (not forced), so completing 'plan' actually advances the manifest. Then the gate guards real state.
    - Support: 5 of 8 seats (auditor 0.85, completer-finisher 0.83, agent-observability-engineer 0.82, ui-architect 0.79, challenger 0.78)

- **A#3 · 'SHADOW GATE (enforced)' is a prose label over an advisory LOG+STORE that only fires on stale>0 and is silent on the empty/unindexed-source case**  _[state-model · high]_
    - Rationale: Verified prose/contract mismatch raised by auditor (R1/R2/R3), agent-observability-engineer (R1/R2/R3), challenger (R2/R3), completer-finisher (R3), ui-architect (R2), agentic-workflow-designer (R2 'enforcement theater'), harness-designer (R2). The gate over-claims enforcement, never HALTs, and is invisible on the highest-risk case (fresh-but-unindexed / empty index = source read raw). Severity split high/medium across seats.
    - Proposal: Either (a) relabel to 'SHADOW GATE (advisory · fail-open)' to stop overstating, or (b) make it real behind L:shadow-gate-enforce: route source READs through a TOOL(shadow, read) that HALTs/redirects on stale/unindexed targets. Regardless, make the panel state-complete: render a line in EVERY case including 'SHADOW NOT BUILT — run: code-dev shadow build' for total==0.
    - Support: 7 of 8 seats; severity high (auditor, observability, ui-architect, agentic-workflow-designer) / medium (challenger, completer-finisher)

- **A#4 · synapse-infer concatenates ASSERT bodies with zero dedup (11x-repeated precondition, truncated dead synapse 'code-dev-phase-', stale counts); synapse-validate only checks parse-ability and rubber-stamps it**  _[tooling · high]_
    - Rationale: Auditor's anchor finding across all 3 rounds (0.82-0.85), corroborated by completer-finisher (R2/R3), agentic-workflow-designer (R2), ui-architect (R3), harness-designer (R2 flagged as unverifiable against snapshot — see dissent). The validator accepts ~20% garbage by design; the truncated next-suggests name 'code-dev-phase-' ships and breaks dispatch.
    - Proposal: One-line generator fix at synapse_infer.py:276 — join over an order-preserving de-duplicated list (dict.fromkeys / sorted(set)). Add a synapse-validate semantic lint: WARN when any precondition conjunct appears >2x; FAIL on next-suggests/next-conditional names that don't resolve to a real programs/*.md (reject truncated '<known>-' prefixes). Recompute inputs/outputs counts each pass.
    - Support: 5 of 8 seats (auditor 0.85, completer-finisher 0.83, agentic-workflow-designer 0.74, ui-architect 0.79); 1 seat (harness-designer) flags as unverifiable

- **A#5 · Adaptive-free-text loop terminates only on the hard 25-step cap — goal.rejection.met() is implemented in predicate.py but has no production writer, so it is permanently false**  _[workflows · high]_
    - Rationale: agentic-workflow-designer traced this precisely across R2/R3 (predicate.py:400-402 implements the function; nothing ever writes ctx['goal']['rejection']['met']); the steps>25 short-circuit is the only real exit (the OR's right operand stays broken). Corroborated by completer-finisher and agent-observability-engineer (uniform deliberation cost, ceiling not goal logic). Challenger argues the in-loop steps>25 short-circuit means it is 'genuinely fixed' — see dissent.
    - Proposal: Add a writer to the adaptive tick: after each program fires, evaluate the rejection criterion and STORE the result to W:goal.rejection.met so the predicate gate can actually exit; OR make the predicate engine raise on an unresolvable state reference in a termination criterion instead of safe-null-bypassing. Surface 'step N/25 · acceptance: not met' and a --max-steps param.
    - Support: 3 of 8 seats high (agentic-workflow-designer 0.74, completer-finisher 0.79, agent-observability-engineer 0.82); challenger dissents on severity

- **A#6 · Adaptive->fixed promote/replay loop is built but operator-undiscoverable; no menu surface and the source file even carries a stale 'invoked by NOTHING' scar comment**  _[workflows · medium]_
    - Rationale: agent-observability-engineer (R1/R3), harness-designer (R3), agentic-workflow-designer (R2/R3) all flag the rigidity escape-hatch as undiscoverable. Direct DISPUTE: challenger (R2) states it IS surfaced after every adaptive run, rebutting observability's R1, and notes the 'invoked by NOTHING' comment is itself stale (the same file invokes promote). Net: the code works; the operator-visibility is the gap.
    - Proposal: Add a 'workflow promote <run-id>' verb to the WORKFLOWS menu block and the v4 power-user table in WORKFLOW.md sec 11, backed by code-dev-workflow-promote.md reading the trajectory ledger; emit a numbered post-run offer ('↪ promote this trajectory to a reusable fixed draft? [P]'). Delete the stale 'invoked by NOTHING' comment.
    - Support: 4 seats flag (agent-observability-engineer, harness-designer, agentic-workflow-designer); challenger disputes discoverability claim

- **A#7 · Canonical programs self-identify by their own deprecated aliases (code-dev-knowledge-shadow STOREs 'code-dev-shadow'; safety-audit; state-save mislabel), corrupting the state they report**  _[code-dev · medium]_
    - Rationale: completer-finisher (R1), challenger (R1/R2), agent-observability-engineer (R2). One seat (observability R3) retracted the state-save instance specifically (it STOREs its correct name; 'code-dev-tag' is a separate program), so the invariant holds but the specific count is narrower than R2 claimed.
    - Proposal: Fix IDENTITY LOCK STORE and all DONE() labels to the canonical program name. Add an axon-audit/synapse-validate invariant: a program's STORE(W:active-program,X) must equal its own PROGRAM header name (or declared canonical), failing CI otherwise; extend test_programs_tier_a.
    - Support: 3 seats (completer-finisher, challenger, agent-observability-engineer); 1 partial retraction on the state-save instance

- **A#8 · Ladder checkpoint/resume contract is write-once: programs STORE active-phase=':pre-write' but never transition to ':done' or clear it, so the resume badge lies after clean runs and is absent for 3 of 5 phases**  _[state-model · high]_
    - Rationale: agent-observability-engineer's sharpened R2/R3 anchor (0.82-0.83). The :pre-write marker is never overwritten on the success path, so the menu resume badge is unreliable. Compounded by the 'resume' verb being overloaded across an ACTIVE meta program and a DEPRECATED code-dev alias (ambiguous recovery path).
    - Proposal: Make :pre-write a true write-ahead marker: every program that writes '{name}:pre-write' before a mutation MUST overwrite it with '{name}:done' (or CLEAR W:active-phase) on the success path. Collapse 'resume' to one canonical entrypoint that emits the exact disambiguated command.
    - Support: 1 seat sustained high across 2 rounds (agent-observability-engineer 0.82-0.83)

- **A#9 · Canonical gate s6 loops audit->plan over the entire chain for ANY open finding; no severity-gated intermediate fix node**  _[workflows · medium]_
    - Rationale: auditor (R2), completer-finisher (R1). Non-critical findings trigger a full re-loop of the whole ladder, which is disproportionate; the rejection-criterion already declares critical-issues>0 as the real bar.
    - Proposal: Add a severity-gated branch: route open-findings>0 to s2/full re-loop only when audit.critical-issues>0; for non-critical findings, route to an intermediate fix node (e.g. a dedicated code-dev-fix synapse or s3 pr-create) instead.
    - Support: 2 seats (auditor 0.83, completer-finisher 0.74)

- **A#10 · 88-program surface has no operator-surfaced taxonomy/grouping; ladder onboarding relies on WORKFLOW.md prose; 18 alias stubs create a 3-hop dispatch chain that obscures ACTIVE programs**  _[onboarding · medium]_
    - Rationale: agentic-workflow-designer (R1/R2/R3), agent-observability-engineer (onboarding), completer-finisher (R1 alias dead-output). Operator orientation failure across the surface; the alias stubs also carry dead post-DONE output and stale 'removed next release' promises.
    - Proposal: Add a 'code-dev start' entry-point program rendering current project state + the 5-phase ladder as a numbered checklist with the recommended next step. Add a status filter to code-dev help/list-programs: 'ACTIVE (70) | ALIAS (18) | default ACTIVE only' and collapse aliases. Strip unreachable post-DONE ## OUTPUT blocks from alias stubs.
    - Support: 3 seats (agentic-workflow-designer, agent-observability-engineer, completer-finisher)

- **A#11 · Enforcement posture is invisible: response/shadow/node-order gates are advisory unless the Stop-hook is installed, but nothing surfaces 'advisory' at boot/menu**  _[code-dev · medium]_
    - Rationale: agentic-workflow-designer (R2/R3 'enforcement theater'), harness-designer (R2 'enforcement-mode visibility when default-off'). Distinct from the shadow-label finding: this is the global posture (KERNEL-SLIM self-documents gates are advisory without the hook). Genuinely uncertain mechanism per harness-designer.
    - Proposal: Add a boot-time enforcement posture check that surfaces at menu render: 'ENFORCEMENT: advisory (hook not installed) — run scripts/enable-enforcement.sh to enable mechanical gates.' Run verify.py status in health-check and warn when posture is advisory.
    - Support: 2 seats (agentic-workflow-designer, harness-designer)

- **A#12 · kv-store rejects bare scalar strings with an opaque json.loads error and no --raw escape**  _[tooling · medium]_
    - Rationale: completer-finisher (R1 and R3, stable). A concrete first-run papercut: storing a literal string fails with a raw exception.
    - Proposal: Add a --raw flag (store value verbatim as a string) or auto-fallback: try json.loads, on failure store the literal string with a one-line note; replace the bare exception with 'value is not valid JSON; wrap in quotes or use --raw'.
    - Support: 1 seat, stable across 2 rounds (completer-finisher 0.74-0.83)

- **A#13 · code-dev.md dispatcher carries synapse-infer scar tissue: an 11x-repeated 'project != null | FAIL' precondition conjunct and ~25x duplicated FAIL boilerplate**  _[code-dev · medium]_
    - Rationale: agent-observability-engineer (R1), completer-finisher (R3 confirmed 'live legibility papercut'). A downstream symptom of finding #4 (no dedup), but also independently fixable at the dispatcher.
    - Proposal: Collapse the per-route 'project != null | FAIL(...)' into one PROJECT-GUARD gate evaluated once before the ROUTE table; routes assume project loaded. Fix at the generator (dedup) so the scar doesn't regenerate.
    - Support: 2 seats (agent-observability-engineer, completer-finisher)

- **A#14 · _axon_paths god-node (degree 95) couples ~59% of the codebase; gate subsystems (shadow/phase/crucible) lack an orchestration layer; rule registry collects but doesn't compose**  _[code-dev · medium]_
    - Rationale: harness-designer's R1 thesis (0.65), but the SAME seat RETRACTED it in R2 (0.42), reframing _axon_paths as exemplary separation-of-concerns and gate centralization as intentional. Preserved at reduced rank because no other seat re-raised it and the originating seat reversed. See dissent.
    - Proposal: If pursued: extract _axon_paths into a versioned namespace with 3-5 typed public APIs; add a gate manifest (YAML) + 'axon gate run' single entry point. NOTE: originating seat now recommends NO change.
    - Support: 1 seat R1 (harness-designer 0.65), self-retracted R2 (0.42)

**Dissent (preserved):**
- Mode-menu render bug (modes [1]-[4] vanish, orphaned ELSE at L233) was reported HIGH by agent-observability-engineer (R1/R2), ui-architect (R2), and auditor (R3) — but challenger (R3) and agent-observability-engineer (R3, self-retraction) verified against the live tree that menu.md renders all modes via explicit IF/ELSE (R3: L67-80; challenger: L244-257) and that the council was quoting a fix-scar comment (L106) as if it were a live bug. Net council position: this HIGH finding is DEAD / a fixed bug; only a CHANGELOG-comment cleanup remains. Preserved because it was high-support before verification killed it.
- Over-engineering critique of node-order / fixed-mode rigidity: challenger (R1/R2/R3) and harness-designer (R2/R3) and completer-finisher (R2) explicitly hold that the node-order advance-guard is correctly WARN/--allow-deviation gated, surfaces its own escape hatch, and is already complemented by adaptive/hybrid modes + the promote loop. Their recommendation: DO NOT add dependency-graph syntax or loosen the gate; new syntax would add churn for marginal gain. This rebuts the R1 proposals from harness-designer and agentic-workflow-designer to add depends_on/retry_if syntax and input-hash memoization.
- harness-designer (R2, conf 0.42) dissents that several R1 high-severity findings were misreads of intentional design or stale repo state: _axon_paths centralization is exemplary separation-of-concerns (not a god-node defect), phase-manifest is substantively implemented (not aspirational), and the synapse-infer precondition claim is UNVERIFIABLE because synapse_infer.py was absent from that seat's repo snapshot — possibly resolved by refactor. This directly contests rank #1, #4, and #14.
- challenger (R2/R3) dissents on the adaptive-free-text loop (rank #5): argues it is 'genuinely fixed' by the in-loop steps>25 short-circuit (PR-5.1), not special-cased — contradicting agentic-workflow-designer's position that goal.rejection.met() remains a broken OR-operand. Both agree the hard cap works; they disagree on whether the undefined predicate is a residual defect or acceptable.
- challenger (R2) disputes the 'promote/replay is orphaned/undiscoverable' framing (rank #6): claims it IS surfaced after every adaptive run, rebutting agent-observability-engineer's R1. The disagreement is about operator-visibility surfacing, not whether the code exists (both agree it is wired).
- completer-finisher (R2, conf 0.79) RETRACTED its own R1 'three-incompatible-file-schemes / aspirational phase-layout' framing AND the challenger's R1 'manifest never written' claim, affirming _phases.json is now the enforced SSOT for done/back/skip. This refines (does not negate) the split-brain findings #1/#2 — the manifest IS used for those verbs, just not for forward-ladder advancement or phase-new registration.
- Severity spread on the shadow-gate label (rank #3): auditor, agent-observability-engineer, ui-architect, and agentic-workflow-designer rate it HIGH (enforcement theater / silent on highest-risk case); challenger and completer-finisher rate it MEDIUM (a prose/label fix). Reported verbatim rather than averaged.

---

## Council B — UI ideation
_Concrete UI/UX ideas for the AXON terminal shell. (6 seats × 2 rounds · debate)_

**Summary.** Council B ("UI ideation") ran 12 entries across 2 rounds with 6 seats (product-designer/haiku, interaction-designer/sonnet, design-systems-architect/opus, information-architect/haiku, data-visualization-engineer/sonnet, challenger/opus). Within the hard constraint that AXON renders as TEXT re-emitted every turn under the UserPromptSubmit reanchor hook, the transcript triangulates on one diagnosis from multiple angles: AXON's menu/state output is a stateless, ~151-line full re-emit with no priority hierarchy, no mode-awareness, and no canonical component grammar. The dominant convergent proposals are (a) collapse/suppress OS-STATE when nominal and escalate non-nominal lines, (b) signal mode transitions — especially the autonomous_mode/autonomy_breaker boundary — as a distinct visual break, (c) gate menu sections on orchestrator/precondition state, and (d) promote buried action items (reminders, igap) into an ATTENTION block. Two genuine cross-cutting tensions remain unresolved and are preserved: (1) ADD richer surfacing/layered headers (product-designer, information-architect, interaction-designer) vs. CUT to a panel budget and cache TOOL() calls (challenger), and (2) encode state visually with ASCII bars/sparklines/badges (data-visualization-engineer) vs. ban all bars/glyphs as per-turn token tax that drifts and corrupts on reflow, using deterministic numeric tokens instead (challenger, design-systems-architect partly aligned via ASCII-only/72-col constraint). The design-systems-architect frames a frozen component grammar (GRAMMAR.md referenced by ID in the reanchor hook) as the carrier all other fixes presuppose; the challenger independently endorses naming ~4 canonical components, giving the grammar idea the broadest cross-seat backing. Confidence ranged 0.61-0.81; data-viz (0.78-0.81) and information-architect (0.73-0.75) highest, design-systems-architect (0.61-0.62) and challenger (0.64-0.66) lowest.

**Verdict distribution** (dissent-preserving):
- `0.5` — Both add-and-cut needed: layer/gate signal (progressive disclosure, ATTENTION block, gated sections) under a component grammar AND impose a panel budget / cache TOOL() calls  ·  seats: product-designer, interaction-designer, information-architect
- `0.25` — Frozen component grammar (GRAMMAR.md, ASCII-only, 72-col, named-by-ID in reanchor hook) is the root carrier; all other fixes presuppose stable atomic primitives  ·  seats: design-systems-architect, challenger
- `0.17` — Primary defect is OS-STATE flat rendering; fix is concrete two-tier severity-sorted reflow with visual encoding, not abstract grammar  ·  seats: data-visualization-engineer
- `0.08` — Binding constraint is re-emission cost, not under-surfacing; cut panels, suppress green lines, ban ASCII bars/glyphs, cache state  ·  seats: challenger

**Ranked findings (12):**

- **B#1 · OS-STATE nominal-collapse with severity-escalated rendering**  _[menu-ui / state-model · high]_
    - Rationale: Highest support×severity: every seat touched the OS-STATE flat-list problem. The merged proposal — emit only non-nominal lines, sort blockers (x/!) above warnings (~) above a single nominal rollup line — reconciles the add and cut camps because it reduces lines while preserving signal. data-viz, challenger, product-designer, information-architect, interaction-designer all proposed a variant.
    - Proposal: When all signals nominal, collapse OS-STATE to one badge/rollup line (e.g. 'OS: nominal (health·infer·cov·mem·backup·drift·igap all ok)' or '[ OS OK | inf:L4 | mem:12W | backup:fresh ]'). When any signal fires, render a CRITICAL rail of non-nominal lines first, warnings next, and collapse the stable lines to a single 'N items nominal — expand: status' line. Sort rows by severity tier at render time.
    - Support: 5 seats (product-designer, interaction-designer, information-architect, data-visualization-engineer, challenger); confidence 0.64-0.81

- **B#2 · Mode-transition / autonomy boundary visual signaling**  _[state-model / menu-ui · critical]_
    - Rationale: Carried the only unrebutted CRITICAL severity from r1 (interaction-designer: autonomous_mode/autonomy_breaker boundary not signaled) and was independently re-raised as CRITICAL by product-designer (r2) and data-viz (r2). The autonomy/gate state is the highest-stakes surface the user is actually inside and is currently invisible at transition.
    - Proposal: Wrap every autonomous_mode grant_on/grant_off (and every menu emit) with a distinct boundary. Two convergent forms offered: (a) a full-width dashed rule + centered banner '--- AUTONOMOUS MODE ---' at transitions via a new _axon_response:emit_boundary; (b) a fixed 3-slot status bar prepended to every emit '[MODE:GUIDED | AUTO:OFF | GATE:OPEN]'. Recommend the persistent status bar as default with the dashed boundary reserved for the transition turn itself.
    - Support: 3 seats marked critical (interaction-designer, product-designer, data-visualization-engineer); unrebutted; confidence 0.68-0.81

- **B#3 · Frozen component grammar referenced by ID in the reanchor hook**  _[state-model / tooling · high]_
    - Rationale: Framed as the carrier all other fixes presuppose (design-systems-architect, both rounds) and independently endorsed by the challenger ('component grammar is the carrier — make it the convergence point'). This cross-camp agreement (opus architect + opus challenger) is notable given they disagree on add-vs-cut. Severity high; directly addresses run-to-run drift, the text-OS-specific failure mode.
    - Proposal: Add a boot file (GRAMMAR.md) defining ~4 ASCII-only primitives — StateLine (`<sev> <key>: <value>`), Panel (titled, fixed line-order, collapsed = one header+count line), KVTable/Table (3 fixed columns for capability/autonomy only), Badge (closed token set) — with a 72-column hard cap and no Unicode box-drawing (use '— PANEL —' headers). Change the reanchor hook to name these components by ID rather than re-describe 'output format'.
    - Support: 2 seats, both opus (design-systems-architect lead, challenger concurs); confidence 0.61-0.66; NOTE low absolute confidence despite high strategic weight

- **B#4 · Gate menu sections on orchestrator / precondition state (collapse, don't omit)**  _[menu-ui · high]_
    - Rationale: Repeated by information-architect (both rounds) and product-designer (r2) for CODE DEVELOPMENT / WORKFLOWS sections. Reduces the 151-line scroll while preserving CORE RULE 12 (section visibility) by replacing unmet-precondition content with a one-line stub. Directly buildable against W:code-dev-project / W:active-gates / W:current-phase.
    - Proposal: In render_menu, query orchestrator gates per section before emitting. Render CODE DEVELOPMENT only if codebase_loaded/gate unlocked AND phase in scope; otherwise emit a one-line stub. Same for WORKFLOWS. Promote phase-matching sections to top when W:active-phase is set; highlight 'Resume' as first affordance.
    - Support: 2 seats (information-architect both rounds, product-designer r2); confidence 0.68-0.75

- **B#5 · ATTENTION / action-items block — conditional, suppression-gated**  _[menu-ui · medium]_
    - Rationale: information-architect and product-designer want reminders/igap promoted to a primary ATTENTION surface; the challenger explicitly conditions support on a suppression gate ('don't promote above OS STATE without a suppression gate, cap at top-2 ranked items'). Merged proposal incorporates that constraint, resolving the tension.
    - Proposal: Render an ATTENTION block immediately after OS-STATE ONLY when it has content. Cap at the top 2 orchestrator-ranked action items as StateLines (unread reminders, igap closure, active gate blocks), remainder reachable via 'more'. Sort by urgency/gate-criticality.
    - Support: 3 seats with a constraint negotiated (information-architect, product-designer pro; challenger conditional); confidence 0.64-0.75

- **B#6 · Mode-menu demotion to a single active StateLine that always shows the exit path**  _[menu-ui / workflows · medium]_
    - Rationale: product-designer, information-architect, and challenger all flagged the 7-mode equal-weight list as redundant when the user is already in a mode. The challenger adds the load-bearing constraint: never hide the exit path. Merged form satisfies both progressive-disclosure and safety.
    - Proposal: Replace the full 7-mode list with one line: 'MODE: code-dev (exit: <cmd> · switch: <cmd>)' showing the active mode plus its two escape commands inline; render the full reachable-mode list only on the mode-switcher screen or 'menu --full'.
    - Support: 3 seats (product-designer, information-architect, challenger); confidence 0.66-0.75

- **B#7 · Typed failure disambiguation in fail_render (gate-blocked vs logic-failed)**  _[code-dev / workflows · high]_
    - Rationale: interaction-designer raised this at high severity in both rounds and no seat rebutted it. Distinguishes a governance/gate halt (recoverable by unlock) from a program logic failure, which are currently visually identical.
    - Proposal: Define two fail_render header formats selected by a fail_class argument. GATE: '[ BLOCKED ] code-dev-plan halted at phase 2 — autonomy_breaker: requires explicit user unlock'. LOGIC: '[ FAIL ] ...'. Optionally a third DEGRADED class.
    - Support: 1 seat across both rounds (interaction-designer), unrebutted; confidence 0.71-0.74

- **B#8 · Persistent active-program / phase-progress strip across re-emits**  _[code-dev / state-model · critical]_
    - Rationale: interaction-designer (r2, critical) and product-designer/data-viz proposed pinning a one-line program/phase strip so the user stays oriented during multi-turn programs (solves 'disappearing satisfaction scores'). Marked critical by interaction-designer but encoding contested (see dissent), so ranked below the grammar that would standardize it.
    - Proposal: Define a one-line ActiveProgramStrip emitted only when W:current-program is set, pinned as the first line after the reanchor header: '[ code-dev-plan · PHASE 3/7 · satisfied ]'. Persist phase/score via W:active-* keys. Use deterministic numeric tokens (PHASE 3/7), not ASCII bars, to survive reflow.
    - Support: 3 seats (interaction-designer critical, product-designer, data-visualization-engineer); confidence 0.68-0.81

- **B#9 · Typed input-prompt label before the cursor**  _[menu-ui · high]_
    - Rationale: interaction-designer (r2) — a one-line PromptTypeLabel from a closed vocabulary signals expected response class before the user types. Single-seat but high severity and cheaply buildable; no rebuttal.
    - Proposal: Render one line above the input cursor from a closed set: [GATE: confirm y/n], [SELECT: 1-N], [INSTRUCT: free text], [ANSWER: ...]. Maps directly onto the four interaction modes already present.
    - Support: 1 seat (interaction-designer); confidence 0.74

- **B#10 · Cache boot-time TOOL() calls via a boot snapshot**  _[tooling · medium]_
    - Rationale: challenger (r1) — every boot fires ~10 live TOOL() calls; read from W:boot-last-snapshot (already referenced) refreshed by a boot/cron tick instead. Reduces per-turn cost. Single-seat, orthogonal to the rendering debate, broadly compatible with all camps.
    - Proposal: Extend the existing W:boot-last-snapshot so one boot/cron tick writes health/inference/coverage/drift/etc., and the menu reads the snapshot rather than recomputing live each emit.
    - Support: 1 seat (challenger); confidence 0.66

- **B#11 · Onboarding progressive-disclosure gate (suppress full menu until first mode set)**  _[onboarding · medium]_
    - Rationale: interaction-designer and information-architect both proposed gating the full 151-line menu behind a first-run check (W:current-mode / onboarding_version), emitting a ~10-line BootPrompt for new/cleared sessions. Two seats, low-risk.
    - Proposal: In onboarding:main / render_menu, check W:current-mode (or onboarding_version key). If unset, emit only a 10-line BootPrompt (version, 3-line orientation, mode picker); otherwise render the standard (collapsed) menu.
    - Support: 2 seats (interaction-designer, information-architect); confidence 0.73-0.75

- **B#12 · Capability/autonomy policy as the single Table primitive (highest-stakes surface)**  _[state-model / menu-ui · high]_
    - Rationale: design-systems-architect (both rounds) — the capability/autonomy table is the highest-stakes surface and is currently unstyled; reserve the one Table primitive for it exclusively with a deterministic badge mapping. Depends on the grammar (rank 3) landing first.
    - Proposal: Ship one CapabilityTable: fixed 3 columns ACTION | MODE-GATE | STATE, ASCII pipes, max 4 rows visible, remainder collapsed to '+N gates'. Deterministic badge map: grant→[●grant], green-only→[◐green], auto→[▶auto], human→[■HUMAN] (or ASCII equivalents per width constraint).
    - Support: 1 seat (design-systems-architect, both rounds); confidence 0.61-0.62

**Dissent (preserved):**
- ENCODING DISSENT (unresolved): challenger (opus, 0.64) holds that ALL ASCII progress bars, score-gap glyphs, sparklines, and box-drawn tables must be banned — they are a per-turn token tax that drifts and corrupts on narrow-terminal reflow — and should be replaced by deterministic numeric tokens the model reproduces verbatim (e.g. 'PHASE 3/7 · satisfied', ranked plain lists). This directly contradicts data-visualization-engineer (sonnet, 0.81), who holds the OS-STATE flat list is the single highest-leverage defect and proposes concrete visual encodings: 4-5 char ASCII confidence/score bars in the suggestions footer, a 3-char drift sparkline 'DRIFT:▁▃█ +2.1', and severity glyphs. design-systems-architect partially sides with the challenger via an ASCII-only / 72-col / no-box-drawing grammar constraint. NOT SUPPRESSED — the visual-encoding proposals remain on the table as a minority position.
- ADD-vs-CUT DISSENT (unresolved): challenger (opus, both rounds) holds the binding constraint is re-emission cost and the fix is fewer panels + a panel budget (default ~25-line view, opt-in 'menu --full') + suppression, explicitly rejecting product-designer's r2 'three-tier persistent header' as the wrong direction ('reject the reductive cut strategy' / countered by 'too much surfacing'). product-designer (haiku, 0.68) holds the inverse: signal depth is load-bearing and overload should be solved by LAYERING not deletion, via a fixed 6-10 line persistent header. The majority (information-architect, interaction-designer) treats these as complementary (cache AND gate), but the framing disagreement between the two opus/haiku poles is preserved, not collapsed into the 'both' position.
- GRAMMAR-PRIMACY DISSENT: data-visualization-engineer (sonnet, 0.81) explicitly rebuts the design-systems-architect's component-grammar frame, arguing 'a grammar without a concrete visual encoding for the STATE panel's severity is empty' — i.e. the grammar is necessary but not the highest-leverage intervention; the concrete OS-STATE two-tier reflow is. Preserved against the architect+challenger position that the grammar is the root carrier.
- CONFIDENCE CAVEAT: the two proposals with the broadest strategic weight (component grammar, rank 3) carry the LOWEST seat confidence in the council (design-systems-architect 0.61-0.62, challenger 0.64-0.66), while the narrower OS-STATE encoding proposals carry the highest (data-viz 0.78-0.81). This inverse relationship between cross-seat support and per-seat confidence is preserved and not averaged away.

---

## Council C — User perspectives
_How real users — novice→power — experience AXON. (6 seats × 2 rounds · debate)_

**Summary.** Council C mapped how real users experience AXON (onboarding, discoverability of the 88 code-dev programs / 160 tools, learning curve, ceremony fatigue, abandonment). The transcript splits sharply on epistemics: two seats (ux-researcher, andragogy-designer) refused round 1 because the "AXON context" field was injected as the literal string "undefined," then re-entered in round 2 once on-disk evidence (hooks, fixtures, BOOT.md, menu.md, KERNEL-SLIM) was treated as the factual floor. The challenger seat held throughout that the only observed user is the author (Dr. Castiel), so the first-time / returning / power-user personas are constructed, not evidenced — a position partially conceded by product-manager, cultural-anthropologist, and andragogy-designer in round 2. Across seats the most-supported EVIDENCED pains are machine-enforced ceremony (per-prompt reanchor hook / AskUserQuestion friction / identity lock) and structural onboarding front-loading (boot defers value until ~step 4-5; full menu renders every boot). The most-supported but UNMEASURED pains are catalog overwhelm (88-182 programs, no in-session discovery beyond list-programs) and the two-repo split. Several seats flag that the charge's own counts are disputed (88 claimed vs ~30 core actual per andragogy-designer; program total cited variously as 182/237). Banned-phrase note: distributions are reported verbatim; no consensus language asserted.

**Verdict distribution** (dissent-preserving):
- `0.5` — AXON has structural/evidenced user pain that warrants fixes now (onboarding front-loading, machine-enforced ceremony, discoverability gap)  ·  seats: product-manager, technical-writer, cultural-anthropologist
- `0.33` — Pain is real but largely UNMEASURED/untested risk; the sole evidenced user is the author, so validate with a real cold-start study before investing  ·  seats: challenger, andragogy-designer
- `0.17` — Cannot deliver grounded findings without system context (round 1 refusal), later resolved by treating on-disk artifacts as the factual floor (round 2 participation)  ·  seats: ux-researcher

**Ranked findings (8):**

- **C#1 · Boot ceremony is front-loaded: value deferred until step 4-5, full menu renders every boot**  _[onboarding · high]_
    - Rationale: Highest cross-seat support. The boot sequence defers value delivery past completion and Core Rule 12 mandates a full menu render on every boot, creating plausible ceremony fatigue for first-time and returning users. Challenger marks the abandonment claim itself unevidenced, so severity is bounded by lack of measurement.
    - Proposal: Add a fast-boot / 'boot-lite' / 'express-onboarding' path: for returning users (W:boot-count>1) surface a single status line and 'type menu to expand'; for first-time users auto-run an onboarding quickstart card showing the 3-5 most common programs in natural language, deferring boot steps 2-3 until after the first command.
    - Support: product-manager (R1 high, R2 high), technical-writer (R1 high), cultural-anthropologist (R1 high, R2 high), andragogy-designer (R2 high), ux-researcher (R2 high); confidence 0.68-0.82

- **C#2 · No in-session discoverability for the program catalog beyond list-programs (88 / 160 tools / disputed total)**  _[menu-ui · high]_
    - Rationale: Multiple seats report catalog overwhelm and that discovery requires already knowing to call list-programs. Challenger and andragogy-designer flag the overwhelm claim and the counts as unverified (88 claimed vs ~30 core; total cited as 182/237), so the fix should be paired with empirical confirmation of whether the menu renders the full catalog or dispatch.py's TF-IDF router is the real entry path.
    - Proposal: Wire program suggestions into the orchestrator rank()/dispatch path: surface top-3 programs matching the current goal at every step (not just boot), add a search-programs / 'what can I do with my project?' natural-language entry, and add a task-type prompt at code-dev entry (new feature / bug / review / refactor) that branches to 5-8 relevant programs. First confirm actual catalog size via freshness refresh.
    - Support: product-manager (R1 high, R2 medium), cultural-anthropologist (R1, R2 high), ux-researcher (R2 medium), challenger (R1 medium, R2 medium — disputes magnitude), andragogy-designer (R2 medium — disputes counts)

- **C#3 · Machine-enforced ceremony is the single hardest-evidenced user pain (per-prompt reanchor hook, AskUserQuestion friction, identity/cognition lock)**  _[workflows · high]_
    - Rationale: Challenger names the axon-reanchor.sh hook firing on every UserPromptSubmit as the one machine-enforced, on-disk evidenced pain. Challenger R1 and cultural-anthropologist independently flag AskUserQuestion ceremony-against-consent as the one evidenced workflow pain. Product-manager and ux-researcher flag the AXON-LANG/identity/Core-Rule-11 cognition lock as systematic reasoning friction. Strongest evidence base of any cluster, though scoped to the author's own sessions.
    - Proposal: Make reanchor adaptive (suppress re-injection when AXON identity is already in-context; fire only every Nth turn); bind blanket-consent to direction questions so AskUserQuestion is routed to autonomous execution when L:inference-mode>=8 or a standing 'don't ask' directive exists; scope the AXON-LANG reasoning mandate to the internal cognition layer and add a workflow mode selector (collaborative vs autonomous) at code-dev entry.
    - Support: challenger (R1 high, R2 high), cultural-anthropologist (R1, R2 medium), product-manager (R2 high), ux-researcher (R2 high)

- **C#4 · First-run onboarding is misrouted/orphaned and the real getting-started artifact is unreachable**  _[onboarding · high]_
    - Rationale: Technical-writer (opus) gives the most concrete on-disk findings: menu.md omits the [1]CHAT/[2]BUILD/[3]RUN/[4]MEMORY mode lines users are told to press (truncated Mode-menu block); the real Day-1 welcome (onboarding.py) is orphaned and never shown on first boot; BOOT.md step 4 nudges quickstart instead of the better, test-guarded getting-started.md, which is unreachable from menu/faq/quickstart.
    - Proposal: Restore the [1]-[4] mode render lines at the top of the Mode-menu block; gate boot on L:first-run-complete to show onboarding on first session; fork the first-run nudge so 'start' runs getting-started and 'tour' runs quickstart; add a wiki program and list getting-started in the menu DISCOVER section.
    - Support: technical-writer (R1 opus 0.82, R2 opus 0.70); reinforced by cultural-anthropologist R2 (mode selectors above the fold) and challenger R1 (task-first on-ramp)

- **C#5 · The three personas (first-time / returning / power) are invented; the only observed user is the author — validate before investing**  _[onboarding · high]_
    - Rationale: Challenger's core thesis, partially conceded by product-manager, cultural-anthropologist (design monoculture / founder cognitive model), and andragogy-designer (untested risk, not demonstrated pain). This is both a finding and a process caveat: it caps the confidence of every other finding in this council, since the evidence is one user who is also the architect.
    - Proposal: Run one real cold-start 'stranger test': a non-author (TNO colleague / junior dev / AI researcher) boots from startup.md or menu.md with no coaching, screen-recorded; measure time-to-first-task, points of confusion, abandonment. Add an install-time distinct-install counter / opt-in telemetry so a second user can be detected before further onboarding investment.
    - Support: challenger (R1 high, R2 high), andragogy-designer (R2 critical), cultural-anthropologist (R2 high), product-manager (R2 — partial concession), ux-researcher (R2 medium)

- **C#6 · Two-repo / multi-tree split (axon vs my-axon vs workspace) creates ownership confusion and git friction**  _[state-model · medium]_
    - Rationale: Raised by product-manager (R1, R2), challenger (R2, framed as owner-facing and evidenced), and andragogy-designer (R2, documented contradictorily in SETUP.md). Challenger notes it is owner-facing rather than a first-time-user blocker, lowering severity.
    - Proposal: Hide the split behind a single AXON-native 'save'/'sync' verb that commits my-axon without hand-managing two git trees; add a 'defer backup' option to my-axon-init; refactor SETUP.md to one versioned flow fronted by a decision tree; add a one-line 'where to add things' guide to the menu.
    - Support: product-manager (R1 medium, R2 medium), challenger (R2 medium), andragogy-designer (R2 high)

- **C#7 · Returning-after-gap users must reconstruct AXON's state model; no re-entry summary**  _[state-model · medium]_
    - Rationale: Cultural-anthropologist (R1, R2) and challenger raise re-entry ceremony / state opacity; users cannot tell what AXON remembers. Lower support count than top findings.
    - Proposal: Add a re-entry summary block to the menu boot (last session date, active project, synapse entry count, shadow-file last-updated) and a 'Resume from step N' card for workflows >50% complete in a prior session; add a persistent 'current context' panel exportable as plain text.
    - Support: cultural-anthropologist (R1 medium, R2 medium); related to product-manager fast-boot and challenger sync findings

- **C#8 · Output/status layer appended to every response adds persistent overhead with no default off-switch**  _[menu-ui · low]_
    - Rationale: Single-seat finding (product-manager R2), low severity, included for completeness.
    - Proposal: Disable L:output-layer for the first 5 turns of a new session and surface a one-time 'type status to enable' prompt.
    - Support: product-manager (R2 low)

**Dissent (preserved):**
- challenger (both rounds, opus, conf 0.62/0.60): The first-time / returning / power-user personas are invented. On the evidence in the repo there is exactly ONE observed user — the author, who is simultaneously creator, only power user, and protagonist of the only real session log. The menu-overwhelm and abandonment claims are plausible but UNMEASURED; the only machine-enforced, on-disk evidenced pain is the per-prompt axon-reanchor.sh hook. Do not redesign the menu on a hunch — instrument first.
- andragogy-designer (R2, conf 0.73): AXON has untested risk, not demonstrated pain. The charge's program count is inflated (88 claimed vs ~30 actual in core), making the discoverability claim partly untestable until counts are verified via freshness refresh.
- ux-researcher (R1, haiku, conf 0.80) and andragogy-designer (R1, haiku, conf 0.95): Declined to deliver findings — the AXON context was injected as the literal string 'undefined,' and fabricating pain points would violate the grounding rule; requested system documentation / a bounded scope before proceeding. (Challenger R2 explicitly judged these refusals 'the wrong call,' since concrete evidence — installed hooks and pytest fixtures — existed on disk and should not anchor R2; preserved here as a process dispute.)
- cultural-anthropologist (R1, conf 0.52; R2, conf 0.67): Findings are grounded in the charge's structural facts plus general cognitive-load research, NOT in AXON system artifacts (none were available to this seat in R1). R2 reframes author-as-only-user as itself an anthropologically significant datum: a design monoculture calibrated to a single cognitive model.
- product-manager (R2): Partial concession to challenger — but argues a system built for eventual distribution (public GitHub README, quickstart, AGENTS.md) that only one person has navigated is evidence that first-time pain is undiscovered, not imagined.

---

## → Consolidation
Council D synthesized the above into 15 ranked initiatives. See `../../masterplan.md`.

---

## Addendum — 2026-06-23 · AXON-COLDBOOT onboarding study (mid-build discovery)
Council A's "first-time pain is undiscovered" thread (product-manager R2 dissent) was made falsifiable:
the **AXON-COLDBOOT** harness (boot-friction Layer 0 + cold_stranger Layer 1) spawns a context-naive agent
against a scrubbed checkout and grades the boot transcript. New study findings:

- **F1 — newcomer boot halts at the my-axon gate (HIGH).** A first boot (no my-axon/) reaches the my-axon
  detection step, renders `[F]resh/[C]lone/[S]kip`, and QUERYs the user — stopping before the banner+menu
  ever render. A newcomer can sit at a setup prompt without seeing the home screen. → node PR-T0-bootflow.
- **F2 — boot front-loading is measurable.** Layer 0 reports the boot read-set (~57 KB: startup.md +
  KERNEL-SLIM.md) and the first menu-command line — a concrete discoverability metric, not a vibe.
- **F3 — the cold-start signal was masked by harness bugs.** A frozen-credential 401 and a 529 transient
  initially looked like cold-start failures; once fixed, 3/3 reached runs PASS — confirming boot itself is
  sound, and isolating F1 as the real onboarding gap.

Consequence: the onboarding tier (PR-014) keeps its owner stranger-session gate (GATE-STRANGER), but its
MECHANICAL half is now built (PR-014a-coldboot) — the council's "build it WITH PR-014 as a wired preflight"
recommendation is satisfied.
