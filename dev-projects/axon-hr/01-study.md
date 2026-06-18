# Study — AXON HR Team
Updated: 2026-06-18  ·  Method: 10-finder fan-out (wf_b8436e38) + synthesis  ·  AXON: 8/10  ·  User: (pending)

## Goal
Incorporate the **hr-team** meta-neuron — an advisory-only, three-layer deliberative-council
orchestrator (**SELECTOR → CONVENER → DELIBERATOR**) — into the AXON repo at
`/home/arturcastiel/projects/new-axon/axon` as both:
1. a discoverable, menu-surfaced **"HR Team"** capability wired through `workspace/programs/menu.md`, and
2. a **flexible neuron** callable standalone (CLI / dispatch) AND embeddable by other workflows.

Scope is **FULL PORT** (ADR-001): author the council runtime as an AXON program family
(`hr-team` router + `hr-team-selector` / `hr-team-convener` / `hr-team-deliberator` sub-programs)
AND copy the self-contained asset packs into the repo — the 151-row / 12-domain / 57-family
profession catalog plus the 69-file prompt pack (5 personas, 7 protocols, 6 tiers, 31 mode-family
modifiers, 20 presets). The runtime spawns a named professional council, runs a declared protocol
over parallel-sealed rounds, and returns a structured advisory verdict (recommendation + ranked
alternatives + dissents + verdict_distribution + transcript + manifest + audit stream).
`advisory_only: true` is a **non-overridable legal-liability boundary** (Moffatt v. Air Canada
2024 BCCRT 149), not a UX label.

## Priorities
1. **Author the 3-layer runtime as AXON neurons** — `hr-team` router + selector/convener/deliberator
   sub-programs (HANDOFF §13 recipe H1). This is the main build gap: the bundle ships specs+assets but
   NO executable runtime; H1's three EXEC targets are referenced but undefined.
2. **FULL PORT the asset packs** self-contained: 153 catalog files (151 rows + `_REGISTRY.md` +
   `_CONFLICT-POLICY.md`) and 69 prompt-pack files, preserving `{domain}/{slug}.md` + `F1..F6` family
   subdir structure and selectable-via flags so the 1071 cross-links + preset composition maps stay intact.
3. **Surface "HR Team" in menu.md** — decide harness section block (workspace-only, recommended) vs
   true 8th kernel mode (4-file dev-mode edit). Recommended: a harness program family + numbered menu
   section, NOT an 8th kernel mode.
4. **Standalone-callable AND workflow-embeddable** — dispatch-phrases + dispatch-index rebuild for
   free-text routing; H2 `tools/hr_team.py` + `tools/REGISTRY.json` entry for CLI; H4 sub-EXEC pattern
   with the `advisory_only` assertion guard for embedding.
5. **Enforce the 5 non-negotiable invariants** end-to-end (advisory_only · role-lock per seat ·
   `{reason,answer,confidence}` JSON · parallel sealed Round 1 · dissent-preserving verdict_distribution)
   plus mandatory Challenger seat, 5-item de-biasing block, fresh per-round system re-injection.
6. **Satisfy AXON registration/gate machinery in the same change** — Core Rule 13 (R_NEW_NEEDS_TEST)
   tests for every new tool/program; regenerate `workspace/programs/REGISTRY.json` + `tools/REGISTRY.json`
   + `DOC-INDEX.md` + dispatch-index; clear orphan/liveness/changeset/freshness gates; run the bundle's
   60+-check V-checklist before declaring verified.

## Constraints
- **advisory_only:true is NON-OVERRIDABLE** (Moffatt v. Air Canada 2024 BCCRT 149 — deployer owns
  AI-output liability): in SELECTOR output, every persona, and every verdict object; not a flag/UX label.
  Embedding workflows must keep the H4 guard `IF result.advisory_only ≠ true → FAIL`.
- **3-layer separation** (SELECTOR/CONVENER/DELIBERATOR) must not collapse into one prompt.
- **Parallel sealed Round 1** mandatory — no seat sees another's R1 before submitting; system prompt
  RE-INJECTED FRESH every round (prior outputs are transcript data, not first-person memory).
- **Challenger seat DEFAULT MANDATORY** on every council; prompt-injection red-teamer mandatory when
  context may contain untrusted text; M3 explicit rosters do NOT bypass Challenger/budget/safety checks.
- **Dissent preserved** — verdict_distribution emitted even with a clear majority; dissents classified
  SUBSTANTIVE vs PREFERENTIAL; opinion-neutral wording (no "consensus"/"clearly" unless unanimous).
- **No write/action/tool authority for the council** — the only write is the per-call audit bundle.
- **Core Rule 13 (R_NEW_NEEDS_TEST, BLOCK)** — every new `tools/*.py` and `workspace/programs/*.md`
  ships a test in the SAME change or is `status:STUB`. ACTIVE-without-test → crucible + CI reject.
- **Core Rule 12** — `menu.md` must render in full; it is kernel-area; keep every section intact.
- **Kernel edits** (true 8th mode touches `axon/COMMANDS.md` + `menu.md` + `mode-router.md` +
  `mode-detect.md`) require `L:dev-mode`; KERNEL-SLIM core stays per-change confirm. Prefer harness route.
- **REGISTRY.json files are AUTO-GENERATED** (programs_registry.py / doc_index.py / dispatch_index.py) —
  never hand-edit; regenerate + commit. `workspace/programs/REGISTRY.json` is already dirty in git.
- **Cost is real** — default 4×3 council ≈ $0.54 GPT-4o / $3.57 Opus-tier; >100 calls/day Opus ≈
  $10.7k/mo. §16 tier system (micro/low) + budget guardrails are the mandated mitigation, and only work
  if the Convener tier-selection heuristic (in `personas/convener.md`) is ported and wired.
- **Orphan/liveness** — a new ACTIVE tool must be INVOKED somewhere or it trips R_NO_ORPHAN_TOOLS + liveness BLOCK.

## Tech Stack
AXON OS — interpreted-markdown "neuron" programs in `workspace/programs/*.md` (PROGRAM/desc/synapse
header + `!NORM` flag + phase-tracking/CHECKPOINT/DONE/FAIL), kernel in `axon/` (KERNEL-SLIM.md,
COMMANDS.md, mode-router.md, mode-detect.md). Python 3 tooling: `tools/*.py` dispatched via `axon.py` /
`tools/run.py` through `tools/_axon_registry.py` against `tools/REGISTRY.json`; gates via
`tools/crucible.py` (R_NEW_NEEDS_TEST, R_NO_ORPHAN_TOOLS, liveness, changeset, freshness); pytest under
`tests/` (`test_<name>.py`). Auto-generated registries: `workspace/programs/REGISTRY.json`,
`workspace/DOC-INDEX.md`, dispatch index `workspace/memory/longterm/dispatch-index.json`. Source asset
pack: Markdown + YAML front-matter (no executable code), provider-agnostic. Bundle declares
`axon_kernel_version_min 1.1.6` (verify vs live kernel). Current branch `main`.

## Key Concepts
- **Meta-neuron** — advisory deliberative-consultation primitive: spawns a council of named specialists,
  runs a protocol, returns a structured advisory verdict. Shipped as v1 spec + catalog + prompt-pack.
- **Three-layer pipeline** — SELECTOR (who sits / mode / protocol / budget / safety+catalog+circular-call
  checks) → CONVENER (fixed fragment-assembly + round mechanics + announce-then-act) → DELIBERATOR
  (schema-validate, Balanced Position Calibration, Weighted Score Voting, dissent classification, verdict).
- **Three invocation modes** — M1 FULL (`--task` only; SELECTOR decides; ~4×3), M2 FILTERED
  (`--domain/--family/--roles`; ~4×1 or 4×3), M3 EXPLICIT (`--roster/--mode/--protocol` pinned; SELECTOR
  validates+warns, never silently fixes; ~6×3 high-stakes). VYJ-7 pre-invocation checklist routes the mode.
- **Fragment assembler** (HANDOFF §9.2) — fixed order PERSONA → GUARDRAIL → SKILLS → MODE → PROTOCOL →
  FORMAT → TASK; split system / developer / user; invalid JSON → one retry → seat-failure event.
- **Weighted Score Voting** — `weighted_score = Σ weight_s·confidence_s·indicator(answer)`, init 1/N,
  Brier-updated. Dissent: SUBSTANTIVE (re-round or "contested") vs PREFERENTIAL (recorded only).
- **Profession catalog** — 151 rows / 12 domains (science 34, ai-ml 20, energy 18, software 14,
  medicine 11, business 10, ops 9, design 8, humanities 8, legal 8, process 6, education 5) / 57 families;
  L0–L6 YAML schema; 1071 cross-links (453 see-also + 453 compose-with + 165 conflicts-with), 100% resolved.
- **Prompt pack** — 5 personas (CONVENER the only `default:true`, holds the v1.1.0 tier heuristic),
  7 protocols (round-robin, weighted-vote, consensus, debate, delphi, adversarial, + optional
  prediction-market), 6 mode families × 31 modifiers, 20 presets, 6 tiers (micro→full, auto-escalation).
- **Persistence/audit** — per-call bundle `councils/{call-id}/` = transcript.md, decision.md,
  manifest.json, checksums.sha256, events.jsonl. call-id = `YYYY-MM-DDTHHMMSSZ-{slug8}-{hash8}`.
- **AXON menu surfacing** — the 7 modes (1–7 + D) are a HARDCODED kernel enum; multi-command harnesses
  (code-dev[8], library-dev[9]) are numbered menu SECTIONS, not modes → "HR Team mode" = a harness program
  family with a menu slot (true 8th mode = optional larger kernel edit).
- **Dual routing** — smart-dispatch (TF-IDF over name+desc+`# dispatch-phrases`, threshold 0.65) vs
  in-mode find-program (scores name+desc+PURPOSE+tools, does NOT read phrases) → council vocabulary must
  live in BOTH the phrases line and name/desc/PURPOSE.

## Integration Map (concrete AXON files)
- **`workspace/programs/menu.md`** — mode-hints dict opens line 107 (close ~115); Mode-menu block
  lines 241–257; active-mode badge lines 209–214; CODE DEVELOPMENT section starts line 263 (template to
  copy); library-dev=[9] is current max. **Recommended:** add a standalone "HR TEAM" section block at
  next free number **[10]** modeled on CODE DEVELOPMENT — no mode-hints/Mode-menu edits, avoids kernel enum.
- **`workspace/programs/hr-team.md`** (NEW) — router neuron (H1). Synapse: domain `deliberation/hr-team`,
  family `[council,advisory,decision-support]`, role `router (mutator)`, `invocation_source:[program,workflow]`.
  First line `!NORM | advisory-only | no-write-actions`. Pipeline EXEC selector→convener→deliberator,
  STORE(W:hr-team-result). Model on `library-dev.md` (simplest) or `code-dev.md`.
- **`workspace/programs/hr-team-selector.md` / `-convener.md` / `-deliberator.md`** (NEW) — the actual
  3-layer runtime (main build gap; H1 references these EXEC targets but the bundle does not define them).
- **`tools/hr_team.py` + `tools/REGISTRY.json` entry** (NEW, H2) — argparse CLI (`--task` required, +
  context/domain/family/roles/roster/mode/protocol/size/priority/persistence/budget/persona/auto-escalate);
  main() emits JSON incl `advisory_only:true`. REGISTRY entry keyed `hr-team`, `tests[...]`.
  `tools/REGISTRY.json` is the SINGLE source of truth (NOT `workspace/tools/REGISTRY.md`, a stale mirror).
- **`tests/test_hr_team_router.py` + `tests/test_hr_team_contract.py`** (NEW, MANDATORY same-change) —
  router test = static assertions over hr-team.md (mirror `tests/test_code_dev_router.py`); contract test =
  import hr_team, assert advisory_only + `{reason,answer,confidence}` schema + verdict_distribution.
- **`axon/COMMANDS.md` + `mode-router.md` + `mode-detect.md`** — ONLY if a true 8th kernel mode is chosen
  (all require `L:dev-mode`). Default plan: do NOT touch; rely on menu section + dispatch-phrases + find-program.
- **`workspace/memory/longterm/dispatch-index.json`** — rebuild via `tools/dispatch_index.py rebuild`
  after adding hr-team.md + its `# dispatch-phrases` (e.g. "convene the HR team · ask the council · run it
  past the council"). find-program does NOT read phrases → carry council vocabulary in name/desc/PURPOSE too.
- **Workflow embedding** (H3/H4) — fixed-mode step `program:hr-team` {task, protocol, mode, persistence}
  → {verdict:W:hr-team-result, audit_path}; OR sub-EXEC with guard `IF result.advisory_only ≠ true → FAIL`.
- **Auto-generated artifacts to regenerate + commit** — `workspace/programs/REGISTRY.json`
  (`programs_registry.py generate`), `workspace/DOC-INDEX.md` (`doc_index.py`), `tools/REGISTRY.json`,
  dispatch-index, then mcp__axon doc-counts/freshness.
- **Gate validation before merge** — `crucible.py changeset` + `crucible.py gate` (pytest, changeset-rules,
  program-tool-conformance, liveness, cron-conformance), `registry_drift.py check`, `liveness.py check`,
  then the bundle's `V-checklist.md` (60+ checks / 13 groups incl. G13 tier discipline).

## Port Inventory (FULL PORT — verified against disk)
- **CATALOG (153 files, ~1.3 MB)** — `~/axon-hr-team/output/catalog/professions/` → workspace/
  (proposed `workspace/hr-team/catalog/professions/`). 151 rows under 12 domain subdirs + `_REGISTRY.md`
  + `_CONFLICT-POLICY.md`. Preserve `{domain}/{slug}.md` + slug-only cross-links (global slug uniqueness;
  watch collisions with existing workspace identifiers).
- **PROMPT PACK (69 files, ~508 KB)** — `~/axon-hr-team/output/prompts/` → `workspace/prompts/`
  (does NOT exist yet — create). personas(5) / protocols(7) / tiers(6) / modes/families(31, F1–F6) /
  modes/presets(20). Keep selectable-via / default-in-family / composition maps exact.
- **HANDOFF DOCS (7 items, ~280 KB)** — recommended for a self-describing port: HANDOFF.md (1573 lines,
  §13 H1–H4 at ~1039–1124), INDEX, BUNDLE-README, V-checklist, manifest.json, checksums.sha256,
  worked-examples/ (6 present: 01-improve-a-prompt[smoke test], 02, 03, 04[cross-domain stress],
  05-delphi, 06-tiered-inline[the 3+-tier example G13 requires]).
- **TOTAL: 222 asset files (~1.8 MB); 232 incl. handoff (~2.1 MB).** Manifest's 247 OVER-COUNTS (~+15,
  likely counts phases/study scratchpads) — do NOT quote 247/234. checksums.sha256 is relative to the
  original tree — regenerate or drop bundle-verification once re-rooted.
- **PATH REWRITING required after re-root** — internal refs point at `output/prompts/…`, `output/handoff/…`,
  `phases/study/…`; H1 uses `{W:myaxon-dev-projects}` placeholder; bundle lives OUTSIDE the repo. Rewrite
  refs or set up workspace-var mapping. Audit write path must resolve + write-myaxon-audit capability granted.
- **VERSION note** — component front-matter says 1.0.0 but bundle is 1.1.0 (tiers + convener heuristic are
  the 1.1.0 layer — keep together or escalation breaks). No consolidated `rows.json` — loading must parse
  151 YAML front-matters or generate an index during the port.
- **OPTIONAL/out of scope** — `phases/study/` audit trail (research scratchpads) unless provenance wanted.

## Open Questions (for the PLAN phase to resolve)
1. **Menu surfacing fork (biggest):** harness SECTION block (workspace-only, recommended, [10]) vs true
   8th KERNEL MODE (edits 4 kernel files, `L:dev-mode`). Direction fork — settle before building.
2. **Port target namespace:** `workspace/hr-team/{catalog,prompts}/` vs split into
   `workspace/domains/` + `workspace/prompts/` vs `workspace/addons/hr-team/` command pack.
3. **TOOL vs RUNNER program vs BOTH:** where does the actual model-calling council engine live, and how
   does parallel R1 fan-out run (sub-agents? per-seat model calls? MCP)? H1/H2 are skeletons.
4. **Provider/model target** + §14.1 model-diversity / LOW_DIVERSITY mitigation (model_variant optional in L6).
5. **Canonical verdict schema + budget model** — worked examples disagree (6k vs 190k vs 420k tokens;
   ex01/04 dash-style lacks advisory_only; ex02/03/05 VERDICT_DISTRIBUTION YAML). Pin ONE schema
   (advisory_only mandatory on ALL) + ONE budget model; record a real run as the regression fixture.
6. **6 or 7 protocols** (prediction-market optional)? Extend find-program to also read `# dispatch-phrases`?
7. **Persistence wiring** — does `{W:myaxon-dev-projects}` resolve here; provision `councils/` audit dir;
   support redacted-audit/no-logs/decisions-only in v1?
8. **ACTIVE vs STUB sequencing** — ship sub-programs ACTIVE-with-tests now, or scaffold as STUB
   (R13-exempt) and promote once the engine is wired.

## Architecture Snapshot
(Populated in Phase 2 after codebase analysis — the integration map above is the seed.)

## Sources
- `~/axon-hr-team/output/handoff/HANDOFF.md` (master spec, §0–§16 + §V + §Z, 1573 lines)
- `~/axon-hr-team/output/handoff/INDEX.md` · `BUNDLE-README.md` · `V-checklist.md` · `worked-examples/` (6)
- `~/axon-hr-team/output/catalog/professions/_REGISTRY.md` + 151 rows + `_CONFLICT-POLICY.md`
- `~/axon-hr-team/output/prompts/{personas,protocols,tiers,modes}/` (69 files)
- This repo: `workspace/programs/menu.md`, `workspace/programs/{code-dev,library-dev,…}.md`,
  `tools/REGISTRY.json`, `tools/crucible.py`, dispatch/dispatch_index, `tests/test_code_dev_router.py`
- Bundle integrity: `sha256sum -c` → 233/233 OK (from `output/` base)
