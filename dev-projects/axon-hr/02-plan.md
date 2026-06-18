# Plan — AXON HR Team
Phase 2 (tactical) · Generated: 2026-06-18 · Method: 8-author PR-spec fan-out (wf_b174d25c) + synthesis

## Overview
axon-hr is a FULL PORT incorporation of the hr-team deliberative-council meta-neuron into AXON, built bottom-up and ACTIVE-with-tests per ADR-009 (no STUB-first windows, every PR lands status:ACTIVE with its router/contract test in the SAME change to satisfy Core Rule 13 / R_NEW_NEEDS_TEST). The deliverable is a 3-layer advisory council (ADR-002 HYBRID: markdown neurons hold logic, one swappable execution seam holds the harness coupling): a SELECTOR neuron that validates a task + M1/M2/M3 invocation and emits a council CONFIGURATION (roster + per-seat mode + protocol + tier) without calling any seat; a CONVENER neuron that assembles per-seat messages in the fixed PERSONA→GUARDRAIL→SKILLS→[de-biasing]|MODE→PROTOCOL→FORMAT|TASK fragment order, announces-then-acts, and runs parallel SEALED rounds with fresh per-round system re-injection through the single run_seats(messages[])->responses[] seam; and a DELIBERATOR neuron that schema-validates seats, runs Balanced Position Calibration + Weighted Score Voting (1/N weights, Brier hook), classifies dissent SUBSTANTIVE/PREFERENTIAL, re-rounds only on SUBSTANTIVE, and emits the canonical HANDOFF §4.3 verdict with advisory_only:true + verdict_distribution ALWAYS present. A router neuron (workspace/programs/hr-team.md) marshals the M1/M2/M3 arg surface into working memory and drives the sealed EXEC(selector)→EXEC(convener)→EXEC(deliberator) pipeline on both the standalone and workflow-embed paths, enforcing the advisory_only boundary in OUTPUT. A thin tools/hr_team.py (ADR-002 D1) houses the CLI, the run_seats seam (harness fan-out now, provider-API/MCP later — the single portability quarantine point), and the audit-bundle writer to my-axon/hr-team/councils/{call-id}/ in 3 v1 persistence modes (ADR-008). Discoverability is wired additively via a menu [10] HR TEAM section + dispatch-phrases (ADR-003/D2: a harness section, NOT a kernel mode — zero kernel edits). The profession catalog (151 rows + _REGISTRY.md + _CONFLICT-POLICY.md) and 69-file prompt pack are ported into the self-contained workspace/hr-team/ root (ADR-004) with a mandatory doc-index H1-fix on catalog rows. A fully decoupled find-program dispatch-phrases extension (ADR-007/D6) ships as its own PR outside the bottom-up chain. The council is advisory-only throughout: NO write/tool authority anywhere except the audit bundle; advisory_only:true is a non-overridable INVARIANT on every emitted verdict object.

## Waves

### Wave 1 — Runtime layers (the 3-layer council logic, bottom-up)
PRs: PR-001 hr-team-selector, PR-002 hr-team-convener, PR-003 hr-team-deliberator

ADR-009 mandates a strict bottom-up build: the layer neurons exist before anything that calls them. They form a linear data pipeline keyed entirely on working-memory handoffs — selector writes W:selector-result, convener reads it and writes W:council-transcript, deliberator reads that and writes W:deliberator-verdict. Each lands ACTIVE with a static router/contract test in the same change (Core Rule 13). They depend on no assets at author time (assets land in Wave 4) because each references the workspace/hr-team/ catalog/prompt paths and degrades to the catalog-incomplete refusal; tests assert over neuron .md text only, never loaded fragments. PR-002 and PR-003 each depend on the prior layer's output-key contract, so they are ordered within the wave, not parallel.

### Wave 2 — Router (assembles the pipeline)
PRs: PR-004 hr-team router

The router neuron drives EXEC(selector)→EXEC(convener)→EXEC(deliberator) and promotes the H4 advisory-boundary guard into OUTPUT so both standalone and workflow-embed paths enforce advisory_only:true + non-empty verdict_distribution. It depends on all three layer neurons existing so its EXEC targets and next-suggests resolve (no STUB-first window). Landing the router here also closes the liveness/orphan gap the layer neurons opened (they are invocation_source:[program], caller-less until PR-004).

### Wave 3 — Tool seam + CLI (execution substrate + portability quarantine)
PRs: PR-005 tools/hr_team.py + REGISTRY entry

The thin tool ships the CLI, the run_seats(messages[])->responses[] seam (the single harness-coupled swap point per ADR-002 D1), the audit-bundle writer (ADR-008), and the real-schema tools/REGISTRY.json entry. It depends on PR-004 for the program-file reference that satisfies the liveness orphan gate (else grandfather in liveness-allow.txt as an interim) and on PR-001..003 for the council logic the seam feeds. Ships ACTIVE with its contract test in-change; must clear the tools/ 80% coverage floor.

### Wave 4 — Discoverability wiring (menu + dispatch)
PRs: PR-006 menu [10] + dispatch-phrases + dispatch-index rebuild

Makes the council reachable through both routing surfaces additively, with ZERO kernel edits (ADR-003/D2: harness section, not a mode). Depends on PR-004 because it edits hr-team.md's header (adds # dispatch-phrases:) and verifies council vocabulary in name/desc/PURPOSE for find-program reachability; the menu insert is byte-additive at the [10] boundary (Core Rule 12).

### Wave 5 — Asset port (catalog + prompts + optional handoff)
PRs: PR-007 FULL PORT of catalog + prompt packs into workspace/hr-team/

Bulk COPY + narrow deterministic PATH-REWRITE + the mandatory catalog-row H1-fix (demote in-frontmatter '# L{0..5}' markers to '##' so doc_index._title returns the real role name) + doc-index regeneration. ADR-009 bottom-up places the port AFTER the readers (assets are inert data without a reader). The split-recommendation (7a catalog / 7b prompts / optional 7c handoff) is open for the per-PR phase. Carries the heaviest review surface (151-row transform, 1077 cross-link edges, ~222 new DOC-INDEX entries).

### Wave 6 — Decoupled shared-infra extension (parallelizable, off-chain)
PRs: PR-008 find-program dispatch-phrases corpus unification

ADR-007/D6 explicitly ships this as a SEPARATE small PR with its own test, NOT bundled with the hr-team build, to keep reviews decoupled. depends_on=[] — it touches only find-program.md + its test, can land at ANY time relative to PR-001..007. Listed last as a wave for ordering clarity, but it is genuinely independent and may be sequenced first or in parallel.

## Dependency notes
- Linear runtime DAG: PR-001 → PR-002 → PR-003 → PR-004. Working-memory key chain is the contract spine: PR-001 writes W:selector-result; PR-002 reads W:selector-result, writes W:council-transcript; PR-003 reads W:council-transcript + W:selector-result, writes W:deliberator-verdict; PR-004 reads W:deliberator-verdict, writes W:hr-team-result. These exact key names come straight from HANDOFF §13 H1 L1062-1067 and MUST be honored identically across all four specs or the EXEC chain breaks silently.
- PR-005 depends on PR-004 (program-file reference to tools/hr_team.py = liveness reachability surface #1) and on PR-001..003 (the council logic the run_seats seam feeds). The run_seats(messages[])->responses[] seam signature must be PINNED identically in PR-002 (caller), PR-004 (documented in seam NOTE), and PR-005 (implementation) — a rename in any one requires a coordinated rename across all three.
- PR-006 depends on PR-004 (it edits hr-team.md's header and verifies its name/desc/PURPOSE vocabulary). Its menu insert and dispatch-index rebuild assume hr-team.md exists; index/vocab assertions must be guarded for absence so the suite is order-robust if PR-004 is not yet merged in the test env.
- PR-007 depends on PR-004 (the asset consumer) per ADR-009 bottom-up; if the orchestrator reorders the port earlier, the consuming neurons must reference workspace/hr-team/ paths that the port actually creates. ADR-005 names worked-example-01 (in the handoff bundle) as the regression-fixture source consumed by PR-003 and PR-005 — the deliberator/tool fixtures normalize that worked example TO the §4.3 schema.
- PR-008 has depends_on=[] and is fully decoupled (ADR-007/D6) — no hr-team dependency; orderable anywhere, including first or in parallel.
- CROSS-PR ASSET-ORDERING TENSION (surface to owner, do not paper over): PR-001..005 READ the catalog _REGISTRY.md and prompt fragments under workspace/hr-team/, but the asset port is PR-007 (later in the bottom-up order). At author time those files do not exist. Resolution per spec: neurons reference the ADR-004 read paths and degrade to the catalog-incomplete refusal; static tests assert over .md text only (never the loaded registry). The PR phase must decide between (a) accept graceful-degradation + flag that end-to-end slug validation is only exercisable after PR-007, or (b) pull a minimal slug-only _REGISTRY.md forward into PR-001 as a test fixture.
- FIXTURE-MODE FLAG coordination: the circular-call refusal (§4.1) is blocked EXCEPT inside an explicit regression-fixture mode. PR-001 (selector), PR-002 (convener), PR-003 (deliberator fixture) must agree on the SAME flag name (W:hr-team-fixture-mode) to avoid drift.

## Recommended PR order
 1. PR-001 hr-team-selector (Layer-1, bottom of the chain; depends on nothing)
 2. PR-002 hr-team-convener (consumes W:selector-result)
 3. PR-003 hr-team-deliberator (consumes W:council-transcript; lands the worked-example-01 §4.3 fixture)
 4. PR-004 hr-team router (assembles the sealed EXEC pipeline; closes the layer-neuron orphan gap)
 5. PR-005 tools/hr_team.py + REGISTRY entry (CLI + run_seats seam + audit writer; reachable via PR-004's reference)
 6. PR-006 menu [10] + dispatch-phrases + dispatch-index rebuild (discoverability; edits hr-team.md header)
 7. PR-007 FULL PORT catalog + prompts (assets last per bottom-up; readers already exist — consider splitting 7a catalog / 7b prompts)
 8. PR-008 find-program dispatch-phrases extension (decoupled; orderable anywhere — may land first or in parallel since depends_on=[])

## Governance rules (plan-binding)
- ADR-009 ACTIVE-with-tests, no STUB: every PR lands its neuron/tool at status:ACTIVE WITH its router/contract test in the SAME change (Core Rule 13 / R_NEW_NEEDS_TEST is a BLOCK gate). STUB-first-then-promote is rejected — it creates an inert window that trips R_NO_ORPHAN_TOOLS + liveness 'feature goes missing'. No lingering STUBs, TODOs, or unmapped tests at any PR boundary.
- advisory_only:true INVARIANT (non-overridable): every emitted verdict/config object carries advisory_only:true; it is ALWAYS present (HANDOFF §4.1/§4.3, ADR-005). No flag, env var, code branch, or caller-JSON merge may set it to false (grep-assertable in tools/hr_team.py — Moffatt v. Air Canada legal boundary). The router asserts result.advisory_only ≠ true → FAIL on both call paths.
- Core Rule 13 / R_NEW_NEEDS_TEST: a new ACTIVE neuron or tool is shippable only with its contract test in the same change. Neuron tests are STATIC text assertions over the .md (read via Path(...).read_text()); CLI tests are subprocess + json.loads. No live council run, no network in any test.
- Core Rule 12 menu integrity: the menu [10] HR TEAM section is byte-ADDITIVE only — every pre-existing section (MODES, CODE DEVELOPMENT [8], library-dev [9], WORKFLOWS, QUALITY/SELF-IMPROVEMENT) must render byte-identical; insertion is strictly at the L276/L277 (library-dev close → WORKFLOWS header) boundary. No Mode-menu/mode-hints/kernel edits.
- REGISTRY auto-generated, never hand-edited: workspace/programs/REGISTRY.json (tools/programs_registry.py generate), workspace/DOC-INDEX.md (tools/doc_index.py export --canonical), and memory/longterm/dispatch-index.json (tools/dispatch_index.py rebuild) are regenerated by maintenance tooling AFTER the source lands, never hand-edited. Run check/freshness before commit; commit the regenerated artifacts.
- tools/REGISTRY.json uses the REAL AXON schema {script,status,category,purpose} (+ optional desc/args/health) — the HANDOFF §13 H2 sketch keys (entrypoint/capabilities/writes/requires/tests) are FOREIGN and must be translated; a literal copy breaks registry_drift/health/the loader.
- Council has NO write/tool authority except the audit bundle (ADR-008 INVARIANT): the !NORM | advisory-only | no-write-actions directive heads every hr-team neuron; the only file writes go through write_audit_bundle to my-axon/hr-team/councils/{call-id}/ (NOT a dev-project dir, NOT axon/ per Core Rule 9). run_seats is pure (no file/tool side effects).
- Mandatory Challenger seat on every roster, all tiers (HANDOFF §16.3, INVARIANT): the selector INJECTS challenger if absent — including M3/explicit rosters and the micro tier; explicit rosters do NOT bypass Challenger, budget, safety, or catalog checks.
- verdict_distribution MANDATORY on every verdict (ADR-005), present even on a unanimous winner; opinion-neutral wording enforced (forbidden 'consensus'/'clearly'/'obviously'/'the panel agrees' unless every validated seat returned the identical answer; distributions narrated verbatim).
- 3-layer separation is non-negotiable: SELECTOR composes config (no seat calls), CONVENER orchestrates (no aggregation/verdict), DELIBERATOR aggregates (no orchestration). Seat execution flows through the ONE run_seats seam (ADR-002) — no direct provider/sub-agent call in any neuron.
- Brand-string rule (commit-trailer/auto-memory): use 'Haiku 4.5'/'Sonnet 4.6'/'Opus 4.8' for model_variant prose; never a claude-* literal id in any neuron, tool, or test (a test asserts no 'claude-' leak).
- ADR-003/D2 no-kernel-edit: hr-team is a harness section/program family, NOT a kernel mode — axon/COMMANDS.md, mode-router.md, mode-detect.md, and the Mode-menu block stay untouched across the whole build.

## Cross-cutting risks
- Working-memory key-contract drift across PR-001..004: the pipeline assumes the exact keys W:selector-result / W:council-transcript / W:deliberator-verdict / W:hr-team-result. A rename in any sibling silently breaks the EXEC chain. Lock these from HANDOFF §13 H1 as the shared four-spec contract; the router test pins ordering and STORE targets.
- Asset-port ordering: PR-001..005 read workspace/hr-team/ catalog+prompts that only land in PR-007. Mitigated by graceful-degradation (catalog-incomplete refusal) + text-only static tests, but end-to-end slug/fragment validation is only exercisable post-PR-007. Surface as a real cross-PR dependency, not silently absorbed.
- run_seats seam signature coupling: PR-002 calls it, PR-004 documents it, PR-005 implements it — must be byte-identical run_seats(messages[])->responses[] with {reason,answer,confidence} responses. Pin the name now to avoid a coordinated 3-PR rename.
- Audit-path divergence: ADR-008 OVERRIDES HANDOFF §10.1's path and H1's {W:myaxon-dev-projects} placeholder — the bundle must write to my-axon/hr-team/councils/{call-id}/ via _axon_paths.under_myaxon, never a dev-project tree or axon/. Any drift scatters private runtime data and violates the locked decision.
- advisory_only escape hatch: any branch/flag/env/caller-merge that lets advisory_only become false breaks the non-overridable legal boundary; harden as a hardcoded literal + no-override grep test in tools/hr_team.py.
- Selector/Convener tier-ownership ambiguity: the tier heuristic lives in convener.md but §4.1 gives the selector framing/criteria. Resolve: SELECTOR picks roster/protocol/tier; CONVENER narrates the chosen tier and only re-applies its heuristic when the caller deferred (--size absent). Prevent double-picking; if PR-001 finalizes the tier, the convener narrates-not-overrides.
- Static-test-only coverage: neuron tests are text assertions and give no live-boot guarantee the EXEC chain fires; end-to-end coverage belongs to PR-005's CLI contract test + the recorded worked-example-01 fixture (ADR-005). Keep neuron-test assertions on stable tokens (W: keys, SUBSTANTIVE/PREFERENTIAL, '1/N', verdict_distribution, the canonical fragment chain) — not full sentences — to avoid brittleness on benign rewording.
- Liveness/orphan timing: invocation_source:[program] layer neurons are caller-less until PR-004; the ACTIVE tool is unwired until PR-005's router reference (or a liveness-allow grandfather). Bottom-up order closes these gaps; if a gate fires early, grandfather narrowly and remove the line when wiring lands.
- Maintenance-artifact regen honesty: running programs_registry/dispatch-index/doc_index in any PR can surface UNRELATED drift from sibling neurons landing first; confirm non-empty diffs are attributable to hr-team* before committing, and never hand-edit the artifacts.
- Brand-filter trap: a claude-* id anywhere (neuron prose, tool, test) trips the commit-trailer/model-name memory rule; assert no 'claude-' literal leaks.
- synapse role-enum acceptance: 'composer' (selector) and 'router' (router) are low-precedent role values; verify against tests/test_synapse_validate.py / neuron-audit's accepted enum before finalizing, with documented fallbacks ('reader' for selector, 'mutator' for router).

## OPEN ITEMS — must resolve in PR phase (code-dev pr)
- ASSET-PORT ORDERING decision: accept selector/convener/deliberator/tool graceful-degradation against absent assets (catalog-incomplete refusal), OR pull a minimal slug-only _REGISTRY.md fixture forward into PR-001. Owner-facing fork — surface a recommendation before PR-001 authoring.
- PR-007 SPLIT decision: ship as one atomic asset PR, or split into 7a (catalog: the 151-row H1-fix + slug-uniqueness/cross-link-resolver test + _REGISTRY path rewrite, all the risk) + 7b (prompts: near-pure clean-H1 bulk copy) + optional 7c (handoff). Spec recommends the split; per-PR phase confirms.
- PR-007 handoff inclusion: INCLUDE the 6 .md + manifest.json (self-documenting bundle + worked-examples that ADR-005 names as fixture source) but EXCLUDE-or-REGENERATE handoff/checksums.sha256 (stale bundle-path checksums mismatch after rewrite). Confirm and decide whether to regenerate over the ported tree.
- Fixture-mode flag name: lock W:hr-team-fixture-mode (circular-call regression bypass) consistently across PR-001/002/003 specs before authoring.
- synapse role values: verify 'composer' (PR-001 selector) and 'router' (PR-004) are accepted by tests/test_synapse_validate.py / neuron-audit; pre-register the documented fallbacks ('reader' / 'mutator') if rejected.
- Liveness grandfather: decide whether PR-005 lands before PR-004's tool reference is present (then add hr-team to liveness-allow.txt with a remove-on-PR-006 note) or strictly after PR-004 wiring.
- Exact cross-link-edge count for PR-007's resolver test: the registry advertises 1071 resolved edges but a direct YAML parse counts 1077 see-also+compose-with+conflicts-with values — pin the value the test actually MEASURES, not the registry's headline figure.
- W:council-transcript structure (per-round nesting, where each seat's raw JSON + model_variant + round index live) must be agreed between PR-002 (writer) and PR-003 (reader) as a minimal transcript contract before PR-003 authoring.
- PR-008 control-query selection: pick desc/name-driven control queries verified to have ZERO dispatch-phrase overlap (else the phrases-OFF==phrases-ON no-regression assertion correctly fails), and confirm the +25 (desc-tier) weight for phrases vs a reviewer preference for a lower weight.
- Tier-floor (§16.7) and irreversible/multi-domain/release-blocker detection is keyword-heuristic and fuzzy — spec it as a documented heuristic with the --size override; test only that the floor LOGIC is present, not its accuracy.

## Source
- Decisions: phases/study/_decisions.md (ADR-002..009)
- Study: 01-study.md
- Per-PR detail: 02-phases/phase-N-<slug>.md
- PR index: 02-prs.md
## OPEN ITEMS — ALL RESOLVED 2026-06-18 (see ADR-010/011)
All 8 plan open-items closed + PR-009 docs/wiki added (fullest). Ready for code-dev pr.
