# Study — HR-Team Improvements

## 1. Goal
Make `hr-team` able to ALWAYS convene a REAL advisory council — wire the dormant `run_seats` fan-out seam,
and guarantee fail-closed behaviour in EVERY checkout so a stub verdict can never be presented as real.

> **SCOPE EXPANDED (owner directive 2026-06-22):** beyond fail-closed safety, this project now also makes
> hr-team *actually usable and smart* — fix the dual-implementation split, the dead data-input path, the
> documentation-only mode system, the templated (non-cognitive) deliberation, and the reasons an AXON agent
> cannot drive a real council end-to-end. See section 7 (EXPANDED SCOPE — grounded current-state, file:line).

## 2. The finding (verified in code + cross-session)
Contract (hr-team.md → hr-team-selector → hr-team-convener → hr-team-deliberator): SELECTOR picks seats from
a registered catalog; CONVENER assembles sealed per-seat message triplets and runs them through ONE seam —
`run_seats(messages[]) → responses[]` ("v1 = harness sub-agent fan-out"); DELIBERATOR aggregates into the
§4.3 verdict object.

Code reality (tools/hr_team.py):
- **Dev checkout (new-axon, this repo), run_seats ~line 60-78:** FAIL-CLOSED — raises NotImplementedError
  unless `AXON_HR_TEAM_ALLOW_STUB=1`; the stub then stamps every seat `"STUB (no real cognition wired)"` and
  returns `variant-{a/b/c}` with synthetic confidences. The seam is still NOT wired to real cognition.
- **For-use checkout (owner cross-session test), reported `hr_team.py:50`:** FAIL-OPEN — the un-guarded stub
  ran, returned `variant-c` / `0.2533` placeholder scores, and the DELIBERATOR presented them as a real §4.3
  verdict. The SELECTOR also failed to match a good profession roster → "the LLM took over."

So: (a) the seam is unwired in BOTH; (b) the two checkouts have DIVERGED (one safe, one dangerous);
(c) there is no auto-bridge from CONVENER to actual harness sub-agents, so a faithful run of the convener
neuron produces fabricated utterances on the fail-open copy.

## 3. Evidence it's not a one-off (owner confirmation 2026-06-22)
- Owner verified the stub in code and called it "a genuine architecture/igap item, not a one-off."
- A live council in the for-use session produced synthetic verdicts; the working result there came only
  because the operator BYPASSED the stub and hand-spawned 5 real sub-agents (manual run_seats backend).
- axon-rearm's own compliance council had to do the same bypass. Logged igap (fallback-exec) 2026-06-22.

## 4. Owner decisions (resolved at seed)
- OD-A: WIRE the seam — CONVENER must hand its sealed message triplets to a real harness sub-agent fan-out.
- OD-B: FAIL-CLOSED in every checkout — propagate the guard; AXON_HR_TEAM_ALLOW_STUB is tests-only and a
  stub response may NEVER reach a verdict object surfaced to a user.
- OD-C: SELECTOR must produce a domain-matched roster (the for-use run mis-matched professions); a weak/empty
  roster is itself a fail-closed condition, not a silent fallback.

## 5. Fix vectors (→ become PRs in the plan phase)
1. **[CRIT · urgent] Propagate fail-closed guard to the for-use checkout** — close the silent-fabrication window now.
2. **Wire CONVENER → harness sub-agent fan-out** (the real run_seats backend; ADR-002 quarantine boundary kept).
3. **Conformance test:** a STUB seat response can NEVER reach a §4.3 verdict; fail-open is BLOCKED. (Core Rule 13)
4. **SELECTOR roster-quality gate:** empty/weak/mis-matched roster → fail-closed + loud, never LLM-takeover.
5. **Reconcile the two checkouts** on tools/hr_team.py (divergence is the dev-version-drift family).

## 6. Method
Conservative · test-more · redo-until-closed. PR-T4-hrteam (in axon-rearm) is the parent finding; this project
executes it. Same fail-open thesis as axon-rearm — fix it as a fail-closed exemplar.


---

## 7. EXPANDED SCOPE — grounded current-state (Explore sweep 2026-06-22, file:line-pinned)

> Source: read-only sweep of workspace/programs/hr-team{,-selector,-convener,-deliberator}.md,
> tools/hr_team.py, HANDOFF.md, tests/test_hr_team_*. These become PRs at the plan phase.

### ROOT CAUSE (new) — dual divergent implementations  [keystone]
- The interpreted NEURONS (hr-team-*.md) describe the real 3-layer council with rich DERIVE(...) cognition.
- The PYTHON tool (tools/hr_team.py main() L295-347) re-implements only a thin shadow: HARDCODES seats
  ["prompt-engineer","eval-engineer","challenger"] (L305), ignores the SELECTOR neuron, aggregates with a
  trivial WSV. An agent following the router vs calling the CLI gets DIFFERENT rosters/tiers/modes.
- Most weaknesses below descend from this split. Resolving which path is authoritative is the keystone PR.

### Fix-vector 6 — DATA INPUT for the council  [user ask: improve how to input data]
- `--context` is DEAD: parsed at tools/hr_team.py:271, never read by main(), never put in any message, never
  hashed into the manifest. Documented behaviour (HANDOFF.md:159 "delimited into user message only") unimplemented.
- Neuron path also drops context: convener user-msg (hr-team-convener.md:182) interpolates {task}+{preamble} only;
  no W:hr-team-context key read anywhere. Input is a single one-line --task string — no files/docs/prior artifacts.
- FIX: wire --context (path-or-literal) into each seat user message + manifest hash; add W:hr-team-context read by
  SELECTOR (L40-50) & CONVENER (L34-37); support multi-context / --context-files.

### Fix-vector 7 — COUNCIL MODES  [user ask: improve council modes]
- The F1..F6 6-tuple mode system is DOCUMENTATION-ONLY: zero parsing. --mode passed verbatim (tools/hr_team.py:313
  into a string; L252 into manifest). The 31 family-modifier files under workspace/hr-team/prompts/modes/families/F*/
  are unreachable. Neuron loads modes/{mode}.md (hr-team-convener.md:171-173) — no such flat file for tuples -> literal fallback.
- Mode inference rigid (flag-presence only: hr-team-selector.md:88-99); protocol vs mode conflated (L313 mislabels mode as "Protocol").
- FIX: real mode resolver — expand named preset -> 6-tuple (HANDOFF.md:603-615), parse a+b+c, validate vs F1..F6 enums,
  fill defaults, LOAD family fragments into the developer message. Let SELECTOR SUGGEST a preset from task signals
  (complexity/stakes already DERIVEd at hr-team-selector.md:159-160) instead of always default-deliberation.

### Fix-vector 8 — SMARTNESS / deliberation quality  [user ask: make it smarter]
- The smart deliberation (Balanced Position Calibration L81-99, Weighted Score Voting L103-122, SUBSTANTIVE-vs-
  PREFERENTIAL dissent + re-round L126-191, contested status) exists ONLY in hr-team-deliberator.md prose.
- The executable _build_verdict (tools/hr_team.py:173-242) does NONE of it: blindly stamps PREFERENTIAL (L202),
  hardcodes "status":"resolved" (L228), uniform 1/N weights (L176; Brier reweight DEFERRED L107), no synthesis.
- Confidence FABRICATED: stub confidence = 0.6 + (i%4)*0.08 (L77) -> the notorious 0.2533 aggregate (L192-194);
  answer = variant-{a/b/c} cycles on i%3 (L76) — the "recommendation" is an index lottery.
- FIX: port section 4.3 logic into the executable (order-sensitivity, honor seat dissent_class, set contested, add
  synthesis); real per-seat calibrated confidence; flag synthetic verdicts in warnings until the seam is real.

### Fix-vector 9 — AXON CAN'T USE IT END-TO-END  [user ask: axon can't use HR-team properly]
- Seam raises by default (tools/hr_team.py:64-71 NotImplementedError) -> agent must BYPASS and hand-spawn sub-agents,
  manually replaying convener assembly + deliberator aggregation. AXON_HR_TEAM_ALLOW_STUB=1 "succeeds" but emits
  fabricated variant-a/b/c / 0.25xx — a trap (gate exists because this shipped, tests/test_hr_team_contract.py:91-99).
- Roster/profession matching is non-deterministic prose: candidate-seats <- DERIVE(...) (hr-team-selector.md:101); no
  deterministic keyword/domain map though HANDOFF.md:231 promises a rules strategy; validation only checks slug EXISTENCE (L117-126).
- Dead/unhonored flags erode trust: --context, F1..F6 string, --seats/--rounds (L283-284), --budget/--priority all no-op.
- FIX: resolve the dual-path ambiguity (keystone); add deterministic roster keyword/domain pre-pass + domain-match
  sanity warning; honor or remove dead flags.

### Fix-vector 10 — run_seats real backend  [user ask: run_seats broken; refines original vector 2]
- Confirmed NO real backend: BACKEND="fanout" (L29) has one branch whose only non-raising path is the stub (L72-79).
  Seam shape run_seats(messages)->responses (L41) DROPS per-seat variant/effort the convener produces
  (hr-team-convener.md:124-129,188-194) — model-variant routing lost (main() passes bare 3-msg arrays L310-317).
- FIX: implement a real subagent/fanout backend that spawns harness sub-agents in parallel (sealed R1, fresh system
  re-injection per round, one-retry-on-bad-JSON), and extend the seam schema to carry variant/effort.

## 8. TEST POSTURE (gap)
- tests/test_hr_team_contract.py is the only BEHAVIOURAL suite — and it runs ENTIRELY against the stub (shape only).
- Neuron contract tests are STATIC text assertions over the .md (they lock the prose, never execute the logic).
- GAP: no test executes a real council, exercises an F-tuple parser (none exists), checks --context, or validates
  aggregation CORRECTNESS (BPC / dissent / re-round / contested). Each fix-vector PR must add executable proof (Core Rule 13).

## 9. UPDATED FIX-VECTOR COUNT
Original 5 (fail-closed safety family) + new 5 (usability/intelligence: data-input, modes, smartness, end-to-end
usability, real seam) = 10 vectors -> the plan phase turns these into a dependency-ordered PR backlog.
Keystone = resolve the dual-implementation split (fix-vector 9 root cause) — it unblocks 6/7/8/10.
UNIFICATION DIRECTION DECIDED — see section 10 ADR-001 (Neurons authoritative, CLI = fixture).


---

## 10. ARCHITECTURE DECISION — ADR-001 · Unify on NEURONS-AUTHORITATIVE (owner, 2026-06-22)

DECISION: the .md neurons (hr-team{,-selector,-convener,-deliberator}.md) are the SINGLE authoritative
runtime for the council. tools/hr_team.py is DEMOTED from a parallel pipeline to (a) a deterministic helper
library the neurons call via TOOL(), and (b) a test fixture. The hardcoded pipeline in hr_team.py main()
(seats L305, templated _build_verdict L173-242, index-stub confidence) is no longer a "real" path — it is
relabelled FIXTURE/stub, used only by tests and the audit-bundle writer.

WHY: honors AXON's program-centric OS model (programs are the runtime, tools are called by them); avoids two
sources of truth that re-diverge. The agent executing the neurons IS the council.

DIVISION OF LABOUR (the rule that keeps it testable under Core Rule 13):
- COGNITION  -> stays in the neuron, executed by the AXON agent: reading seat reasoning, qualitative
  SUBSTANTIVE-vs-PREFERENTIAL dissent judgment, roster-fit judgment, synthesis wording.
- DETERMINISTIC MATH + IO -> extracted into importable, UNIT-TESTED Python helpers the neuron calls via TOOL():
  WSV arithmetic, order-sensitivity (BPC) comparison, confidence aggregation, F1..F6 mode-tuple parse/validate,
  registry lookup + deterministic roster keyword/domain pre-pass, manifest build, audit-bundle write, verdict-schema validate.
- COGNITION SEAM -> run_seats stays the ONE boundary. Under this ADR the REAL fan-out is the neuron/agent spawning
  harness sub-agents (the convener run_seats step, hr-team-convener.md:205). The Python run_seats stays FAIL-CLOSED
  for the CLI/fixture path only; it never feeds a user-surfaced verdict.

CONSEQUENCES PER FIX-VECTOR:
- V9 (keystone) reframed: NOT "pick an authoritative path" but "DEMOTE hr_team.py to helpers+fixture; make the
  neuron path the sole runtime; relabel the hardcoded seats/verdict as fixture; route the CLI flags into W: keys
  the neurons read (the ROUTER hr-team.md marshals --task/--domain/--roster/--mode/--context -> W:hr-team-*)."
- V6 data-input: --context is parsed by the ROUTER into W:hr-team-context; SELECTOR + CONVENER neurons read it.
  A deterministic 'context-load' helper (path-or-text, hash) is added to hr_team.py and called via TOOL().
- V7 modes: a deterministic mode-resolver helper (preset->6-tuple, parse, validate, return family-fragment paths)
  goes in hr_team.py; the CONVENER neuron calls it via TOOL() and loads the fragments. No mode logic duplicated.
- V8 smartness: the DELIBERATOR neuron keeps the qualitative judgment; WSV/BPC/aggregate-confidence become tested
  helpers it calls. Kills the templated _build_verdict-as-truth and the 0.2533 stub-as-verdict.
- V10 run_seats: the real backend is the neuron's sub-agent fan-out; the Python seam stays fail-closed fixture.
  Seam schema still extended to carry variant/effort for the neuron's spawner.
- V1-5 (safety) unchanged in intent; V3 conformance test now asserts the FIXTURE stub can never reach a neuron-surfaced verdict.

PLAN ORDERING IMPLICATION: keystone V9 (demote + route flags) lands FIRST as the spine; the deterministic helpers
(V6/V7/V8 math) are independent and can land in parallel once the helper-call contract from V9 exists; V10 (real
fan-out) and V1 (propagate fail-closed to for-use) are the safety-critical co-leads.

---

## 11. RE-GROUNDING — council-driven verification (2026-06-22, supersedes stale §2/§5 premises)

> The hr-team council (5 real sub-agent seats) graded the plan and flagged factual claims to verify.
> Verification result below CORRECTS the study. Suggestion "re-verify the for-use checkout FIRST" was decisive.

### CORRECTION — the for-use "fail-open hr_team.py" premise was STALE
- VERIFIED: the for-use checkout (/mnt/c/projects/library-development/axon) is a git repo on `main`,
  HEAD 4756df4, remote ci.tno.nl/axon — but it is **289 commits BEHIND origin/main**, and
  `tools/hr_team.py` has **NEVER existed in its tracked history** (git log --all -- tools/hr_team.py → empty).
  It has 155 tools, none named hr_team. There are no hr-team programs in for-use either.
- CONSEQUENCE: there is NO active fail-open hr_team.py in for-use to "propagate a guard" to. The morning
  cross-session "for-use fail-open / fabricated council" observation is NOT reproducible against current for-use.
  Most likely it was the NEURON-path council (agent following hr-team-convener.md with no real run_seats backend)
  fabricating — OR a since-changed working tree. Either way the original §2 "for-use stub ran" locus is wrong.
- RE-FRAMED RISK: the real fail-OPEN locus is checkout-independent — the UNWIRED run_seats seam in the
  NEURON path. A faithful neuron-council that does not actually fan out fabricates utterances + a verdict
  (this is exactly what bit axon-rearm's own compliance council). The Python tool guards this (fail-closed +
  STUB-marked); the NEURON path has NO mechanical guard. That is the true urgent safety gap.
- for-use specifically just needs to SYNC (289 behind); on sync it inherits the dev fail-closed hr_team.py.

### VERIFIED — the dual path is structural (kernel-architect was right)
- tools/hr_team.py main() does: run_seats(messages) → _build_verdict → print(json.dumps(verdict)) (L319-346).
  The CLI emits a full §4.3 verdict to stdout that NEVER touches the neurons. Demoting by RELABEL is insufficient;
  PR must make main() structurally incapable of surfacing a verdict (refuse/exit or delegate to neurons).

### VERIFIED — second run_seats call-site
- hr-team-deliberator.md:64-65 re-invokes the seam on retry (DERIVE(run_seats, correction-prompt)). So "convener
  is the lone seam" is currently FALSE — the deliberator pokes it too. Must reconcile (declare sole seam or document).

### VERIFIED — dev stub is fail-closed AND marked
- BACKEND="fanout"; run_seats raises NotImplementedError unless AXON_HR_TEAM_ALLOW_STUB (L36-42); the stub marks
  every seat "STUB (no real cognition wired)" (L47). So the DEV danger is the dual path + fabricated confidence,
  NOT an unmarked fail-open. The unmarked fail-open was a property of the (now-absent) for-use state.

### COUNCIL VERDICT (real council, 5 seats, sealed R1, no stub)
- STUDY graded A− · PLAN graded B−. Loudest signal: PR-009 (real run_seats) graded D (XL mega-PR, late, hard to test).
- All 10 council suggestions ADOPTED by owner → drive the revised plan (see 02-plan.md / 02-prs.md v2).
- New PRs surfaced by re-grounding: a MECHANICAL fail-closed guard in the NEURON path (the true fix), and
  observability/provenance that a verdict came from real fan-out (the fail-closed thesis is unprovable in prod without it).
