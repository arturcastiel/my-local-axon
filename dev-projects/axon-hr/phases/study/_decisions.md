# Decisions (ADRs) — study

## ADR-001 — Build scope: FULL PORT
- Date: 2026-06-18
- Decision: Port the hr-team bundle into this AXON repo self-contained —
  author the council runtime (SELECTOR → CONVENER → DELIBERATOR; M1/M2/M3),
  wire the **"HR Team"** menu mode, AND copy the 151-row profession catalog +
  the 63-file prompt pack into `workspace/`.
- Rejected alternatives: runtime-only with referenced catalogs; thin MVP;
  defer-scope-to-study.
- Owner: Dr. Artur Castiel (interactive selection, code-dev new flow).
- Implications: heaviest option; catalogs/prompts become repo assets under
  workspace/ (NOT axon/ kernel — Core Rule 9). Each new program/tool ships
  tests before ACTIVE (Core Rule 13). Plan phase enumerates the port as
  numbered PRs (mode wiring · council program · catalog port · prompt-pack
  port · standalone+workflow call surface · tests · registry/docs regen).

## ADR-002 — Runtime architecture: HYBRID (neurons + tool seam)
- Date: 2026-06-18
- Decision: Build hr-team as a markdown **program family** holding the 3-layer
  LOGIC (`hr-team` router + `hr-team-selector` / `-convener` / `-deliberator`),
  with seat execution delegated through ONE seam `run_seats(messages[]) →
  responses[]`. The seam is implemented NOW by the harness sub-agent fan-out
  (the mechanism proven on the study phase) and a thin `tools/hr_team.py`
  provides the CLI entry + houses the seam so a provider-API or MCP backend can
  replace the fan-out later WITHOUT touching the neurons.
- Rejected: (B) pure neuron-native, no Python engine — standalone only via
  axon.py dispatch, fully harness-coupled; (C) tool-native Python+LLM-API engine
  — forces a provider/API-key choice now, re-implements council logic in Python.
- Rationale: only option that is simultaneously AXON-native, immediately
  runnable (fan-out engine demonstrated), CLI-callable, and future-portable;
  serves the stated goal "flexible neuron, standalone AND workflow-embeddable";
  the seam quarantines the one harness-coupled part so D5 (provider) stays deferrable.
- Implications: tools/hr_team.py is a thin tool (CLI + seam + advisory_only
  emit) needing a contract test; the 3 sub-program neurons need router + contract
  tests (Core Rule 13). The seam interface is itself a plan-phase spec item.

## ADR-003 — Menu surfacing: HARNESS SECTION [10] (not a kernel mode)
- Date: 2026-06-18
- Decision: Surface "HR Team" as one additive `menu.md` SECTION block at the
  next free number **[10]** (modeled on CODE DEVELOPMENT @ L263), plus
  dispatch-phrases for free-text routing. NO kernel mode, NO kernel-file edits.
- Rejected: true 8th kernel mode (edits axon/COMMANDS.md + menu.md mode-hints/
  MODES + mode-router.md + mode-detect.md under dev-mode); both-now-and-later.
- Rationale: matches the code-dev[8]/library-dev[9] precedent; one additive
  section keeps Core Rule 12 intact with zero kernel-enum surgery; NOT a one-way
  door — promote section → true mode in a later PR if persistent-council UX is
  validated. Composes cleanly with the D1 hybrid program family.
- Implications: plan-phase PR edits ONE menu.md section additively; council
  vocabulary must also live in name/desc/PURPOSE (find-program ignores phrases).

## ADR-004 — Port namespace: self-contained workspace/hr-team/
- Date: 2026-06-18
- Decision: Asset pack lands under a single cohesive root `workspace/hr-team/`:
  `catalog/professions/{domain}/{slug}.md` (153) · `prompts/{personas,protocols,
  tiers,modes}/` (69) · `handoff/` (optional, self-describing). The 4 neurons stay
  in `workspace/programs/` per convention; `tools/hr_team.py` + `tests/` as usual.
- Rejected: split (catalog→workspace/domains/, prompts→workspace/prompts/);
  addons/hr-team/ command pack (needs requirements.md + help/ scaffolding the
  bundle lacks; 'addon' undersells a core deliberation primitive).
- Rationale: keeps the 1071 internal cross-links in one tree (minimal
  path-rewriting); port/update/remove as a unit; no pollution of shared trees;
  doc_index/registry pick up workspace/ paths automatically.
- Implications: plan PR copies the pack with path rewrites localized to the
  hr-team/ root + the {W:myaxon-dev-projects} placeholder in H1; watch slug
  collisions against existing workspace identifiers during the catalog copy.

## ADR-005 — Verdict schema + budget model: FULL SPEC FIDELITY
- Date: 2026-06-18
- Decision: (1) Canonical verdict = HANDOFF §4.3 object; `advisory_only:true`
  and `verdict_distribution` MANDATORY on every verdict (enforced by the
  contract test + the deliberator neuron); worked examples are normalized TO
  this, not treated as authoritative. (2) Budget model = the §16 tier system
  (6 tiers micro→full) driving council size × rounds, with the Convener
  tier-selection heuristic ported and the §16.7 floor (no micro/low for
  irreversible / multi-domain / release-blocker decisions). (3) Record ONE real
  council run (worked-example-01 smoke test) as the regression fixture.
- Cost reframe: under ADR-002 (hybrid fan-out), v1 cost = SESSION sub-agent
  token spend (size × rounds), NOT the bundle's $10.7k/mo provider-API figure
  (that applies to the future API backend). The tiers ARE the fan-out-size knob.
- Rejected: essentials-only (flat cap, defer tiers); schema-only (no budget).
- Rationale: tiers are mostly ported prompt-pack data (6 tier files + the
  convener heuristic) — full fidelity costs little beyond wiring; a recorded
  fixture is needed for the contract test regardless.

## ADR-006 — Provider/model + diversity: HARNESS MODEL + INTRA-HARNESS DIVERSITY
- Date: 2026-06-18
- Decision: v1 seats execute on the harness's own models via the ADR-002 seam —
  no external provider/API key. §14.1 model-diversity is satisfied by (1)
  persona/role/mode/protocol diversity [primary], plus (2) OPTIONAL per-seat
  variation of harness model tier (Haiku 4.5 / Sonnet 4.6 / Opus 4.8) + reasoning
  effort [genuine intra-harness model diversity, cheap]. The manifest records each
  seat's model_variant + an honest model_diversity flag.
- Rejected: force cross-provider diversity now (pulls API backend forward,
  contradicts ADR-002); single-model flag-only (leaves the free tier lever unused).
- Rationale: honest consequence of the hybrid engine; keeps provider choice
  deferred; the harness's own tiers give real model diversity (the spec's
  gold-standard mitigation) at near-zero cost. Cross-provider diversity → future
  API backend item.

## ADR-007 — Protocols + routing vocabulary
- Date: 2026-06-18
- Decision (protocols): port ALL 7 protocol files; selector exposes 6 as
  default-selectable (round-robin, weighted-vote, consensus, debate, delphi,
  adversarial); prediction-market shipped-but-flagged-advanced (matches bundle).
- Decision (routing): EXTEND `find-program` with a one-line EXTRACT so it also
  reads `# dispatch-phrases` — unifying smart-dispatch + in-mode routing
  vocabulary repo-wide. Ships as a SEPARATE small PR with its own test, NOT
  bundled with the hr-team build (keeps reviews decoupled).
- Rejected (routing): local workaround (duplicate council vocab into hr-team
  name/desc/PURPOSE) — leaves the vocab gap for every other program.
- Rationale: protocol files are free data; the find-program extension is a
  genuine repo-wide self-improvement that removes a latent routing footgun.
- Note: find-program is shared infra → the extension PR must not regress
  existing ranking (test pins current top-results + the new phrase hits).

## ADR-008 — Persistence & audit: 3 MODES + DEFERRED REDACTION
- Date: 2026-06-18
- Decision (location): audit bundles write to `my-axon/hr-team/councils/{call-id}/`
  — private runtime data under my-axon (NOT axon/, Core Rule 9; NOT coupled to a
  dev-project dir), guarded by a `write-myaxon-audit` capability. call-id =
  `YYYY-MM-DDTHHMMSSZ-{slug8}-{hash8}`. (Overrides H1's {W:myaxon-dev-projects}
  placeholder, which wrongly tied audit to a dev-project.)
- Decision (modes): v1 = full-audit (default) + decisions-only + no-logs.
  redacted-audit is a flagged STUB deferred to a follow-up PR (needs a real
  secrets/PII redaction pass + heavy tests).
- Rejected: full-audit-only (no v1 cost/noise knob); all-4-incl-redaction
  (ships a half-tested redaction guarantee).
- Rationale: 3 write-volume modes are near-free + useful; deferring redaction
  avoids an under-tested scrub guarantee — honest given the spec's own non-goal
  ("assume extraction / no secrets in prompts") as long as redaction is flagged
  absent, not silently missing.

## ADR-009 — Build sequencing: ACTIVE-WITH-TESTS, BOTTOM-UP (no lingering STUBs)
- Date: 2026-06-18
- Decision: every PR lands its neuron/tool `status:ACTIVE` WITH its router +
  contract tests in the same change (Core Rule 13). Bottom-up order so a
  consumer's dependencies always exist first:
    PR1 hr-team-selector · PR2 hr-team-convener · PR3 hr-team-deliberator
    PR4 hr-team (router) · PR5 tools/hr_team.py (seam + CLI)
    PR6 menu [10] + dispatch-phrases + dispatch-index rebuild
    PR7 asset port (workspace/hr-team/catalog + prompts + handoff)
    PR-X (separate) find-program dispatch-phrases extension (ADR-007)
- Rejected: STUB-first then promote — creates a window where HR Team is visible
  in the menu but inert (R_NO_ORPHAN_TOOLS + liveness 'feature goes missing' trap).
- Rationale: Core Rule 13 is a hard floor; bottom-up keeps every PR ACTIVE +
  green with no inert window; router next-suggests resolve cleanly because its
  layers already exist. Exact PR numbering/boundaries finalized in the plan phase.




## ADR-010 — Plan open-items resolution (8 items closed)
- Date: 2026-06-18 · authored interactively with owner
- #1 ASSET-PORT ORDERING → pull a minimal slug-only _REGISTRY fixture forward into
  PR-001 (tests/fixtures/hr-team/_REGISTRY.min.md) so selector slug-validation is
  REAL-tested from PR-001; full 151-row catalog (PR-007a) supersedes it.
- #2 PR-007 SPLIT → split into PR-007a (catalog: 151 rows + H1-fix + cross-link
  resolver + slug-uniqueness tests — the risk) · PR-007b (prompts: 69 files clean
  copy) · PR-007c (handoff docs, optional). Risk isolated to 7a.
- #3 fixture-mode flag → LOCKED `W:hr-team-fixture-mode` across PR-001/002/003.
- #4 synapse roles → RESOLVED by check: validator ROLES set includes both
  `composer` (selector) and `router` (router) — no fallback needed.
- #5 liveness grandfather → NOT NEEDED: strict bottom-up means PR-004 router
  references tools/hr_team.py before PR-005 makes it ACTIVE; no liveness-allow line.
- #6 cross-link count → RESOLVED: PR-007a resolver test PINS its measured value
  (direct parse = 1038 edges; registry headline 1071, synth 1077 — measure, never headline).
- #7 W:council-transcript → RICH per-round/per-seat: {profession, model_variant,
  round_index, raw {reason,answer,confidence}, dissent_class}. PR-002 writer ↔
  PR-003 reader contract pinned now (feeds deliberator + §10 audit bundle).
- #8 PR-008 phrase weight → LOCKED: match find-program's existing desc-tier weight
  (no arbitrary +25); regression test pins no-ranking-change on control queries.

## ADR-011 — PR-009 documentation + wiki: FULLEST scope (owner: "more is better, quality matters")
- Date: 2026-06-18
- Decision: comprehensive doc suite (may split PR-009a docs / PR-009b regen):
  * workspace/wiki/hr-team.md — full reference (overview · why · 3-layer arch ·
    M1/M2/M3 invocation · modes/protocols/tiers/personas · persistence/audit ·
    advisory_only + Moffatt legal posture · cost/tier guidance · troubleshooting/FAQ),
    modeled on _template.md + the richest existing pages (code-dev/library-dev).
  * workspace/wiki/hr-team-catalog.md — 151-profession catalog guide + how to author a row.
  * workspace/wiki/hr-team-recipes.md — integration recipes (standalone CLI · workflow
    embed · the H1-H4 patterns) + the 6 worked examples surfaced as tutorials.
  * workspace/wiki/INDEX.md — add hr-team* entries.
  * workspace/wiki/getting-started.md — HR-Team discovery blurb.
  * Regenerate AXON-DOCS.md + DOC-INDEX.md (tools/doc_index.py); CHANGELOG entry.
  * Satisfy tests/test_wiki.py + tests/test_freshness_wiki.py.
- Timing: authored alongside the build, merged LAST (after runtime + assets land).
- Rationale: owner directive — maximize documentation quality + coverage.
