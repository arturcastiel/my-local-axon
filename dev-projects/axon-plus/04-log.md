# Implementation Log — Axon Plus
## Entries
_No entries yet. Run: code-dev log_

### PR-001 — token bench + baseline · commit d5a8ce8 · 2026-06-11
- token-bench tool + BASELINE: boot-menu 32,593 · pr-cycle 8,060 · study 6,789 · chat 1,041.
- 3 gate catches fixed in-PR: orphan-tool (menu wiring), doc counts 162→163, and a REAL
  flaky-infra bug — web-search health probe ran live queries per sweep, network flake under
  gate concurrency = the session's recurring "pytest red only in crucible". Now offline,
  regression-pinned, deterministic under 3-way load.
- Owner design input during gate: semantic compression (denser op vocabulary) = compile
  TARGET design input for PR-007; 5 further levers recorded for W1 re-plan checkpoint
  (sectional reads · cache ordering · delta rendering · warm-start · registry-first).
- MERGED: squash to main, pushed 1e58fa0..d5a8ce8. Branch deleted. W0: 1/5.

### PR-002 — execution receipts · commit 81ab00e · 2026-06-11
- Dispatcher-side receipt ledger (1 edit, all 163 tools) + R_TOOL_RECEIPTS opt-in BLOCK
  rule: claimed-but-unreceipted TOOL() executions = mimicry = blocked. Goal G layer-1 live.
- Gate catches: concurrency-unsafe receipt test (line counting — same class as web-search
  probe flake), rule-test directory convention (tests/test_rules/). Crucible green 4th run.
- MERGED: squash to main, pushed d5a8ce8..81ab00e. W0: 2/5.

### PR-003 — mechanical menu-render check · commit 4fca0ab · 2026-06-11
- R_MENU_RENDERED: partial render blocks naming missing sections; skipped render blocks
  via active_program. Rule 12 mechanical. First-pass green (pr-2 conventions applied).
- MERGED: squash to main, pushed 81ab00e..4fca0ab. W0: 3/5.

### PR-004 — doc census · delivered 2026-06-11 (analysis artifact, no repo diff)
- 497 docs: 6 adjoint-class · 131 unreferenced · 0 age-stale (rot is structural).
  Artifact: census/doc-census-2026-06-11.{json,md}. Feeds PR-026/PR-027. W0: 4/5.

### PR-005 — census discrepancies · delivered 2026-06-11 (investigation, no repo diff)
- residue-lint: healthy, 27 sites real — census probe had parsed a wrong key (false positive).
- prompt-log: tool healthy; REAL finding = dead wiring (kernel declares per-turn logging,
  nothing mechanical fires it; corpus was empty forever). Routed to W5/G hooks work.
- F design consequence: adversarial verification of findings before queueing (study updated).

## WAVE 0 COMPLETE — 2026-06-11
PR-001 token bench+baseline (d5a8ce8) · PR-002 execution receipts (81ab00e) ·
PR-003 menu-render check (4fca0ab) · PR-004 doc census (delivered) · PR-005 investigation
(delivered). Floors live: anti-mimicry receipts + Rule-12 mechanical. Evidence live:
32.6k boot-menu baseline · 497-doc census · F verification discipline.

### PR-006 — menu state aggregation · commit 10bd0aa (LOCAL) · 2026-06-12
- menu-snapshot: 7 envelopes → 1 call (~300 tok); equivalence test-pinned; −1,777/session
  (7% of corrected baseline 26,480 → 24,703). Baseline health-sweep error corrected.
  Anatomy mapped: kernel 12.9k (owner) · menu.md 5.8k (compile) · boot env 3k (brief).
- Gate catches: ruff F401 (unused import) · trailer lint blocked an internal PR-N ref
  (second occurrence — lint-before-commit now hard-stops the script).
- ⚠ PUSH BLOCKED: ci.tno.nl GitLab READ-ONLY (expired license — admin action). Local
  main is source of truth, ahead 1. my-axon backup (github.com) unaffected. Autonomous
  run continues locally; pushes queue until license fixed.

### PR-007 — compile pipeline pilot · commit db0c2c8 (LOCAL) · 2026-06-12
- compile-write tool built (the missing Phase-4 writer); 6 programs compiled: review 43% ·
  impact 35% · plan 24% · study 22% · mode-detect 19% · menu 10% (~3.9k/cycle banked).
- Equivalence BY CONSTRUCTION (functional-line survival, CI) + mechanical staleness test.
- Checkpoint findings: strip 19-43% prose-heavy / 10% op-dense; next tier = sectional
  reads (8k routers) + denser op vocabulary (owner input) + kernel diet (owner-only).
- backup/v02 + bundle v02 → GitHub. W1: 2/4 done (006, 007). Next: PR-008 brief envelopes.

### PR-008 — brief boot envelope · commit d71cba4 (LOCAL) · 2026-06-12
- boot default BRIEF (count/ids), --full escape; consumer audit clean; brief contract
  test-pinned. boot envelope 2,960→593; boot-menu 24,703→22,341 (−16% wave-to-date).
- backup/v03 + bundle v03 → GitHub. W1: 3/4. Next: PR-009 program shadows, then the
  RE-PLAN CHECKPOINT closes the wave.

### PR-009 — sectional reads via compiled TOCs · commit 14e9d47 (LOCAL) · 2026-06-12
- TOC in every .cmp.md (range accuracy = CI); code-dev router: 7,568 → 1,090/routed read
  (−86%). 7 programs compiled. Re-scope per checkpoint-w1 (shadows redundant vs .cmp).

## WAVE 1 COMPLETE — 2026-06-12
boot-menu 26,480 → 22,341 (−16%, mechanical floor reached) · boot envelope −80% ·
menu probes → 1 snapshot · compile pipeline real (7/191, 10–43%/read) · routed reads −86%.
Checkpoint-w1: A-targets proposal + below-floor paths (menu-as-template, hash-attested
warm boot = autonomous candidates; kernel-in-system-prompt, kernel diet = owner-gated).
backup/v01..v04 + bundles on GitHub. Push queue: 4 (GitLab outage).

### PR-010 — convergence contracts · commit b1cc896 (LOCAL) · 2026-06-12
- loop-contract engine: define/iterate/replan/rebudget(human-wall)/report; mechanical
  CONVERGED/EXHAUSTED/REPLAN-advice; receipts per transition; goal-store integration.
- Historic gate note: the compile staleness CI fired its FIRST real enforcement on this
  PR's own menu edit — recompile forced mechanically. 8 lifecycle tests.
- backup/v05 + bundle v05. W2: 1/4. Next: PR-011 loop designer.

### PR-011 — loop designer · commit 20071a9 (LOCAL) · 2026-06-12
- 4-fork interrogation → contract → direction simulation → runnable skeleton (G-02,
  REPLAN, EXHAUSTED handoff). Dispatch-routed from natural phrasing. Compiled 32%.
- Gate caught: program OUTPUT-banner convention. backup/v06. W2: 2/4. Next: PR-012.

### PR-012 — goal-define mode · commit 1132184 (LOCAL) · 2026-06-12
- Interrogation productized (intake/organize/interrogate-with-evidence/harden+coherence);
  standalone + dispatch + study --mode=goals. Compiled 39%. Gate catches: path-var +
  program-as-tool (static scanners). backup/v07. W2: 3/4. Next: PR-013 closes the wave.

### PR-013 — constraints registry · commit c14f2e7 (LOCAL) · 2026-06-12
- CONSTRAINTS.json (3 scopes, 10 seeded laws, 4 mechanical) + constraints tool +
  goal-define auto-routing + phase-entry checklists. Gate catches: F401 + F22-literal
  (store renamed). backup/v08.

## WAVE 2 COMPLETE — 2026-06-12
Goal C live end-to-end (engine + designer: contract/iterate/replan/budget-wall +
4-fork authoring) · Goal D live (goal-define interrogation, study --mode=goals,
scoped-constraints architecture with auto-routing + checklists). 13/27 PRs (48%).
Push queue: 8 (GitLab outage). Next: Wave 3 — quality loop + discoverability.

### PR-014 — quality loop · commit 627e342 (LOCAL) · 2026-06-12
- Battery live (47 findings cycle-0: 27 residue + 19 dead-code + 1 igap); verify slots,
  shareability routing, report-only ramp, C-contract pilot (budget=3 owner-signed ramp).
- Gate catches: cron program-string form (cron-conformance). backup/v09. W3: 1/5.

### PR-015 — autonomy ramp gate · commit c7d27c5 (LOCAL) · 2026-06-15
- S-fix autonomy EARNED (3 clean cycles) + REVOCABLE (failure re-locks, human unlock).
  ramp-status/record/lock/unlock; quality-loop consults before applying. 8 tests. backup/v10.

### Push queue FLUSHED — 2026-06-15
GitLab ci.tno.nl write access restored. Ground truth (git ls-remote): server main =
local main = c7d27c5 — all 15 PRs synced. backup/v01–v10 milestone branches pushed
(server-side per-PR history). my-axon bundles v01–v10 also on GitHub. Nothing lost
across the outage. Push queue: 0.

### Self-audit workflow (w3g1myq00) — 2026-06-15
Multi-agent adversarial audit (36 agents, 6 dimensions × per-finding verifiers + 3 designs).
27 findings raised → 19 CONFIRMED (8 refuted by adversarial verify). 1 critical (define
--force autonomy bypass) + 9 high. Triage: audit/TRIAGE-2026-06-15.md. Remediation in
3 gated PRs (R1 enforcement/autonomy · R2 lossless · R3 robustness) before resuming W3
discoverability. Kernel-file items (BOOT.md, COMMANDS.md) + 2 design questions flagged
for owner. PR-016/017/018 designs saved (03-prs/PR-01X-DESIGN.md).

### Audit remediation R1+R2+R3 — merged 2026-06-15 (5166469, bf0ca6d, 6f45c86)
R1 enforcement/autonomy (critical define --force wall + receipts verify-exempt/CLI-regex +
menu-rendered dead-branch + dead receipt reuse + NaN) · R2 lossless (snapshot fallback +
boot W:tool-registry) · R3 robustness (quality_loop crashes/dedupe + constraints + token_bench).
13/19 audit defects fixed autonomously; 4 flagged for owner (BOOT.md, COMMANDS.md, ramp
integrity, compiled-staleness-runtime). backup/v11–v13 pushed. Resuming W3 PR-016.

### PR-016 — situation-trigger engine · commit 28b75e8 · 2026-06-15
- situate tool (4 detectors, ≤1 ceiling, dedup, why+command mandatory) wired into
  orchestrator + anti-orphan lock. Implemented from workflow w3g1myq00 design. 7 tests.
  Gate catch: resweep --state-json drift guard → flag renamed --signals. backup/v14.
  W3: 3/5 (PR-016 done; PR-017 footer render + PR-018 phrases remain).

### PR-017 — footer data layer · commit a1a4ab6 · 2026-06-15
- anticipate footer_candidates: {name, why, command, score} shape (D3 fix) + silence
  contract. 4 tests. ACTIVATION (BOOT.md tick-write + OUTPUT-LAYER.md render) HELD for
  owner — KERNEL-REVIEW.md K1/K2 (kernel edits not made silently). backup/v15.
- KERNEL-REVIEW.md created: K1/K2 (pr-17 wiring) + K3 (boot token recovery) + K4
  (COMMANDS.md dispatch guard) + D1/D2 design questions. One owner review surface.

### PR-018 — dispatch-phrases rollout · commit 2b14315 · 2026-06-15
- 19 programs phrased + cross-links + fixture re-pointed + pattern doc. Lift 8%→77% P@1,
  92% P@3. 3 residuals pinned top-3. reduce-surface held. backup/v16.

## WAVE 3 COMPLETE — 2026-06-15
F quality loop (PR-014 generate→verify→report + PR-015 earned/revocable ramp) ·
B discoverability (PR-016 situation engine + PR-017 footer data layer + PR-018 phrases).
PR-017 ACTIVATION (footer render) staged in KERNEL-REVIEW.md K1/K2 (kernel wiring).
Plus the self-audit remediation (R1/R2/R3, 13 defects). 22/27 PRs merged (+R1-3) ·
Wave 4 (workflow designer) next.

### K1+K2 — footer activation (kernel) · commit c8e5b59 · 2026-06-15
- BOOT.md tick-write (anticipate-fed, gated, honest silence) + OUTPUT-LAYER why+command+hint
  render. Footer activated for boot+menu. 2 wiring locks. First authorized kernel edits.
  Per-turn-chat refresh = noted KERNEL-SLIM item (per-change confirm). PR-017 COMPLETE.
  backup/v18.

### PR-026 — personal-project quarantine · commit 12d6fad · 2026-06-16
Re-scoped (owner 2026-06-16: "everything adjoint related is personal — mark, delete
later"). Original census adjoint-6 list was stale: 5 were live CHAT/PLAN OS programs
(2 restored by an earlier C4 fix in mode-router). Marked the true personal footprint —
adjoint leakage (OBJECTIVE-FUNCTION-INTERFACE, OPM template) + reservoir/OPM demo
cluster — via 7 deprecation-log entries (no sunset, owner-gated) + workspace/QUARANTINE.md
register + inline marker + tests/test_quarantine.py (6). Nothing deleted; suite green
(crucible 30/0). Deletion procedure documented (cites _reservoir-manifest.md). Keeper:
AXON-DOCS-RAG-DEVELOPMENT.md (axon's own RAG work). W5: 1/5.

### PR-027 — doc floor + navigable index · commits 9d8d804 + 0013f23 · 2026-06-16
doc_index.py (deterministic DOC-INDEX.md, 485 docs/8 areas, excl my-axon/caches/fixtures,
self-exclusion) + project_doc_floor.py (_meta hard floor, plan advisory, graceful absent
my-axon) wired into freshness check+refresh; both registered. freshness refresh reconciled
pre-existing program-corpus drift (AXON-DOCS/code-map/program-registry/coverage, +3 progs).
7 new tests. PROCESS SLIP: 9d8d804 committed on red gate (bundled verdict+commit); caught,
fixed forward in 0013f23 (3 freshness pins + onboarding counts 168→170). Gate green 30/0.
Lesson logged: verdict-check and commit must be separate steps. W5: 2/5.

### PR-024 — weak-tier strict overlay · commit 17c5e8e · 2026-06-16
tier_detect.py (host-model→tier via tier-manifest.json: pins→heuristics→default; weak
wins ties; undeclared never guessed) + weak-tier overlay (restates Rules 12/6/identity/
no-fallback + ack token) + BOOT.md STEP 2b wiring (subsystem edit, authorized). 9 tests.
opus-4-8→strong (no overlay this session). Commit-trailer hook caught an uppercase PR-N
ref in the body — reworded. Gate green 30/0. W5: 3/5 (024,026,027). Goal G: 1/2 (025 next).

### PR-025 + PR-021b — conformance scorecard + synapse generation · commit 06ec172 · 2026-06-16
PR-025 (Goal G): conformance_scorecard.py — offline deterministic grader over 3 temptation
scenarios (menu-render/mimic-vs-execute/long-output) + weak-tier ack; crucible WARN control
(liveness surface + keystone advisory). PR-021b (Goal E, critical-path tail): synapse_scaffold.py
— scaffold missing PROGRAM with neuron-contract v1.1 header, tests-or-STUB (STUB=R13-exempt;
--active adds test), auto-register; wired into workflow-new PHASE-C (fixes latent register-tool
misuse). PROCESS: wrote 021b files during 025's gate-wait → 025 gate picked them up half-wired
(registry-drift/keystone/liveness/pytest red); recovered by finishing 021b + one combined green
gate + one combined commit. Both tools registered (171→173), keystone advisory added. Gate 31/0.
W5: 4/5 (024,025,026,027). Critical path COMPLETE (021b). Remaining: PR-028 bookend.

### PR-028 — final vs-baseline measurement · commit 64c7e6d · 2026-06-16
token_bench_compare.py (pure compare + sign-off renderer) + token_bench epilog wiring +
final report. boot-menu 32593→22321 (−31.5%), total 48483→38642 (−20.3%). 6 tests.
counts 173→174. Gate 31/0.

## ════ AXON-PLUS COMPLETE — 2026-06-16 ════
All 27 DAG nodes done (25 merged + 2 complete). Wave 5 finished this session: PR-026
(quarantine), PR-027 (doc floor+index), PR-024 (weak-tier overlay), PR-025 (conformance
scorecard), PR-021b (synapse generation — critical-path tail), PR-028 (final measurement).
Commits: 12d6fad, 9d8d804+0013f23, 17c5e8e, 06ec172, 64c7e6d. Every PR crucible-green
(31 controls, 0 blocking). Goal A bookend: −20.3% total tokens (−31.5% boot-menu).
_meta status → complete. Process note: one red-gate slip (9d8d804) recovered fix-forward;
discipline correction logged (verdict-check separate from commit).

### Remaining-scope pass (owner: "act on, gate approved") — 2026-06-16
ACTED + shipped (gated, committed, pushed):
- Goal A sign-off: checkbox CHECKED in final-2026-06-16.md (owner "gate approved" = attestation).
- D1 ramp-state integrity: HMAC-signed quality.ramp.json (key in memory/local/, gitignored);
  ramp_status fail-closed on tamper/unsigned; new ramp-verify. commit 937e00b. 3 new tests.

DEFERRED with reasons (recommend fresh context — protects quality + the lossless mandate):
- Goal G real-model run: needs API/dual-agent budget; faking transcripts would violate
  anti-mimicry. Framework shipped; running it is infra/owner-gated.
- D2 runtime compiled-staleness: K4 ALREADY routes dispatch to source (runtime risk
  mitigated). Proper fix = embed SourceSHA in the compiler header + recompile 10 artifacts
  + detector/gate. MED value, compiler-internals surgery — deferred, approach documented.
- A-backlog A2–A9 (★TOP-goal A-wave, ~−15k+ more tokens): each is lossless-sensitive and
  needs capability-equivalence verification (PR-007 harness). Ordered by value: A2 warm-boot
  (−12k, needs A8 session-digest), A3 menu-template (−3.5k), A9 doc sectional-reads (−80%
  lookups), A8 session-digest, A4 compile-tail, A7 phase-packs, A5 registry-first, A6
  byte-stable-prefix. Best run as a fresh careful wave, not crammed.

### A-wave risk council + A7 ship · commit 7cdcd4e · 2026-06-16
73-agent council (per-item: 3 lenses → de-risk architect → adversary → chair, looped to
very-low) studied A2–A9 against "very-low/no risk". VERDICT: GO list EMPTY. Headline savings
(~−15k, A2 warm-boot −12k) unrecoverable at very-low risk — boot READ is the ONLY kernel-in-
context path under Claude Code, so any read-skip = identity-floor loss. Safety invariant: no
token artifact may gate/skip/substitute reading the canonical source.
DROP: A6 (boot-dep structural, permanent) · A5 (registry rows too thin) · A8 (sound but 3 live
defects, carry). DESCOPE-to-very-low: A2 (drift diagnostic, 0 saving) · A3 (~0.4k comment-strip)
· A9 (exact-match sectional) · A4 (only after D2 + pilot).
OWNER 2026-06-16: "A7 fix only, shelve rest." SHIPPED A7 lossless constraints-scope fix
(rows_for_scope project-aware superset + --project + tests; dormant gap, preventive, back-compat).
A-wave shelved; D2/Goal-G-run remain owner/infra-gated. −20.3% bookend stands.
