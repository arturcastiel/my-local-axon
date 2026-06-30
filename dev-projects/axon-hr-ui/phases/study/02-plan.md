# High-Level Plan — AXON HR UI
Updated: 2026-06-22  ·  Mode: tactical  ·  Source: 01-study.md + masterplan.md (4-council deep run)  ·  advisory_only

## Context (from Phase 1)
Goal: Improve AXON's UI and the programs/workflow experience — focused on code-dev and workflows.
The councils triangulated on ONE defect class: **phase/ladder state is written but neither advanced,
truthfully labeled, nor legibly surfaced** — so gates guard phantom manifests, the menu re-emits full
nominal noise every turn, and "enforced" labels overstate guarantees that only exist with the Stop-hook.
Resolution principle (kernel-constrained): **surface state, do not enforce it**; ship truthful labels;
gate persona-driven onboarding behind a real cold-start test.

## Architecture Overview (subsystems touched)
The 15 PRs touch five AXON subsystems, ordered so data-layer fixes land before the surfaces that read them:

1. **Phase/state model** — `tools/phase_model.py`, `_phases.json` SSOT, the node-order gate, the ladder
   programs (code-dev-study/plan/pr/log/audit), and code-dev-phase-new. This is the spine: PR-001 makes
   custom phases reachable; PR-008 makes the forward ladder actually advance + surface the manifest.
2. **Menu / output surface** — `workspace/programs/menu.md` (OS-STATE panel, ActiveProgramStrip), the
   per-turn output-layer, BOOT.md. PR-003 collapses nominal noise; PR-007 adds truthful re-entry; PR-015
   (deferred) is the render-contract end-state.
3. **Tooling / data layer** — `tools/kv_store.py` (PR-004), `tools/synapse_infer.py` + synapse-validate
   (PR-005). Single-file, kernel-safe, no behavior risk.
4. **Workflow engine** — `adaptive-free-text.yml` rejection predicate (PR-009), `multiple-code-dev.yml`
   audit→fix branch + promote/replay (PR-011), the reanchor hook cadence (PR-010). Safety-sensitive:
   PR-010 must not suppress context (would disarm advisory gates).
5. **Enforcement-posture + onboarding** — verify.py-sourced boot line + SHADOW GATE relabel (PR-002),
   `code-dev start` entry-point (PR-006), the save/sync verb (PR-012), and the GATED onboarding tier
   (PR-013 stranger-test → PR-014 fast-boot/discoverability).

## Implementation Approach (by wave)
- **Wave 1 — quick-wins (PR-001..007).** Mechanical, mostly single-file, kernel-trivial, near-universally
  ratified. PR-001 is the only undisputed data-corruption bug and the natural first PR. Ship truthful
  labels (PR-002) and the OS-STATE collapse (PR-003) for immediate legibility wins.
- **Wave 2 — foundation (PR-008..009).** The compound state-truth spine. PR-008 depends on PR-001 and is
  deliberately bounded to `done()`-on-DONE side effects + an ActiveProgramStrip — NOT a full state-machine
  deepening (dissent flagged that as over-scope). PR-009 starts with a verify-the-already-fixed check.
- **Wave 3 — workflow-overhaul (PR-010..012).** After the state spine stabilizes. PR-010 is safety-critical
  (cadence, never suppression). PR-011 depends on real phase state (PR-008) and a dissent-verification.
- **Wave 4 — gate + later (PR-013..015).** PR-013 is a Phase-0 GATE: no persona-driven onboarding (PR-014)
  merges until a real stranger session is recorded. PR-015 stays deferred and internal.

## Constraints (kernel + study)
- Text-only terminal surface; AXON-LANG internal; state-surfacing is kernel-enforced; building is human-only.
- Surface-don't-enforce: PR-002 ships label (option a), NOT hard-halt (option b).
- New programs/tools require tests before ACTIVE (Core Rule 13) — applies to PR-006, PR-013, and any new tool.
- Verify three live-repo disputes BEFORE building dependent PRs: adaptive-loop already-terminates (PR-009),
  promote/replay already-discoverable (PR-011), and the mode-menu / orphaned-ELSE render claims (PR-008/014).

## Open risks carried from the councils
See masterplan.md "Risks". Most load-bearing: don't build enforcement instead of surfacing; two Council-C
seats received the context as the literal string 'undefined' in round 1, so C-sourced impact estimates carry
epistemic uncertainty (re-weight in the evaluation council).

---

## Reanchor note — 2026-06-23
Mid-build, an onboarding work-stream (AXON-COLDBOOT) was built then retro-registered into the DAG as
3 nodes (PR-014a-coldboot, PR-DAG-LEDGER, PR-T0-bootflow) — see 02-prs.md "Mid-stream additions" and
03-prs/DAG.json. Plan delta: the council's "build the cold-start preflight WITH PR-014" is now the
MECHANICAL half done (PR-014a-coldboot); PR-014 keeps its owner stranger-session gate (GATE-STRANGER).
Canonical PR status is the DAG, not this plan. Procedure for keeping this in sync: CODE-DEV-RESYNC.md.
