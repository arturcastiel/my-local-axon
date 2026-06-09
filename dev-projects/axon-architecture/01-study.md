# Phase 1 — STUDY · axon-architecture

> **Method.** An orchestrated loop-until-dry audit: **137 agents, 4.25M tokens, 2,393 tool-uses, 44 min**
> over 8 architecture dimensions × adversarial-refutation × a completeness-critic round. **114 findings;
> 104 adversarially verified (82 confirmed / 22 refuted).** The synthesis agent crashed on a schema miss,
> so this synthesis is hand-done from the journal — every finding below is grounded at file:line by an
> auditor and survived an independent refutation pass. Confirmed findings are F01–F114 (`/tmp/arch_findings.md`,
> archived). **Confidence: 9/10** (deductions: ~10 late findings unverified due to the crash; semantic
> dedup is mine, not the workflow's).

## Executive summary
The single root issue: **AXON's identity is "an OS that enforces rules", but enforcement is advisory by
construction.** The kernel + 187 programs are LLM-interpreted markdown (a script the model is *asked* to
follow); the only mechanical teeth are the Python tools — and those teeth **bite no automatic surface**:
no per-turn host hook runs `verify.py`/`enforce.py`, and CI runs a hardcoded job list that **does not call
the crucible gate**. So `KERNEL-SLIM.md:87`'s "enforced mechanically (BLOCK on violation)" describes a
mechanism that does not exist on any real path. Everything else clusters into: that gap (A), the
"features go missing" disease it enables (B), path/state split-brains from unenforced "single source of
truth" contracts (C), an external attack surface (D), a broken severity model (E), no module boundaries
(F), and sprawl/dead-code/dispatch bugs (G).

The good news: the Python layer is largely *correct and fail-closed where it runs* (`enforce.py`,
`crucible.py`, `_axon_io`); the problem is almost entirely **wiring + single-source-of-truth + honest
labelling**, not broken algorithms. That makes most of this high-leverage and low-risk to fix.

---

## THEME A — Enforcement is advisory, not mechanical *(CRITICAL · the central claim is false)*
- **No per-turn gate.** `.claude/` has only `settings.json.proposed` (inert) + a README that *admits*
  "nothing mechanically runs verify.py/enforce.py per turn"; the 3 referenced `tools/hooks/` wrappers
  don't exist [F02, F09]. The **real** installer `setup-persona.sh:327` wires a UserPromptSubmit hook that
  only `cat`s a prose reminder; the Stop hook (the one primitive that can *reject* a response) is
  "intentionally not implemented" [F10, F51, F52].
- **Crucible gate runs nowhere automatic.** `.github/workflows/ci.yml` runs a hardcoded set (lint_paths,
  doc_counts, registry_drift, doc_anchors, pytest, docgen) — **never `crucible gate`** [F04, F27].
  `autonomous_mode.py` has zero references to crucible/gate/green. So R_NEW_NEEDS_TEST (Rule 13),
  R_WORKFLOW_NODE_ORDER, R_MEMORY_RESPECTED, R_DONT_DO — all routed *only* through `crucible.run_changeset`
  — fire **only if a human types the command** [F04, F49].
- **Write-gate doesn't intercept.** `host-cap-enforce="self"` on every harness contract [F24]; AEGIS
  test-execution trusts a caller-supplied `--gate` flag and never runs the gate [F25]; Core Rule 3
  (arithmetic) is a static grep that matches almost no real program [F48].
- **Effective posture: OFF.** Every silent-until-flag rule's activation file is absent in this checkout —
  R_STATE_SURFACED, R_REASONING_TRACE(BLOCK), R_WORKFLOW_NODE_ORDER, R_IDENTITY_LOCK… all inert [F23, F45].
- **Fix:** (1) finish the hook keystone (write the 3 wrappers, install `.claude/settings.json`, confirm
  PreToolUse→enforce + Stop→verify actually fire); (2) **add a CI job that runs `crucible gate` on PRs** —
  the one change that converts the whole changeset rule-set from advisory to mechanical; (3) until both
  exist, **relabel** `KERNEL-SLIM` "enforced mechanically (BLOCK)" → "agent-discipline (advisory)". Ship
  the mechanism before the claim.

## THEME B — Orphaning / liveness has no source of truth *(CRITICAL · the "features go missing" disease)*
- **Dead safety rules.** 8–11 of 30 `r_*.py` rule modules are in *neither* the runtime verifier nor the
  crucible — including `r_identity_lock`, `r_override_attempt`, `r_cognition_language`,
  `r_inference_mode_lock`. They have 100% unit coverage → false safety; the kernel's identity/anti-override
  guarantees are mechanically vacuous [F03, F38].
- **No "is it invoked?" authority.** Liveness is split across **6 disjoint surfaces** (program `TOOL()`,
  imports, `axon.py` dispatch, `crucible.json` cmds, pre-commit, `mcp_server.SAFE_TOOLS`); nothing unions
  them [F07]. The anti-orphan rule is **WARN + diff-only**, so existing orphans are grandfathered forever
  [F06, F37]; `registry_drift` (the only CI wiring gate) checks file *existence*, not invocation [F26].
- **Result:** ~74/139 ACTIVE tools are never called via `TOOL()`; ≥6 (memory-sync, axon-eval, a2a,
  skill-adapter, apply-memory-slot, …) are invoked by *nothing* yet pass tests [F36, F61–F63].
- **No behavioral test.** `test_behavior.py` is empty scaffolding that *skips*; nothing exercises a program
  end-to-end — the structural reason 3969 green tests coexist with missing features [F05, F28].
- **Fix:** one **liveness resolver** unioning all 6 surfaces → full-tree BLOCK crucible+CI control with an
  explicit shrinking allowlist; one **declarative rule manifest** (rule_id → runners/severity) replacing
  the 4 hand-maintained lists + a parity test; seed ≥1 golden-transcript behavioral test per core program.

## THEME C — Path / state split-brain *(CRITICAL · real corruption from unenforced "single source of truth")*
- **dev-mode write-gate silently always-off.** `_axon_io._DEVMODE_KEY` reads `my-axon/…/dev-mode.md`;
  the toggle writes `workspace/…/dev-mode.md`. The my-axon file doesn't exist → `_dev_mode_active()` is
  always False, and the two enforcement layers (CLI vs in-process) can disagree once dev-mode is enabled
  [F08, F46].
- **8 stateful tools default workspace to `os.getcwd()`** (phase_ledger, axon_state, phase_gate, shell,
  axon_managed, deprecation_log, memory_sync, autonomous_mode), bypassing `_axon_paths` — the *durable-state
  writers* fork the repo's memory into a phantom tree when cwd≠root [F11, F40, F68]. Already materialized:
  the **canonical phase-ledger doesn't exist** — the real one is at repo-root `memory/episodic/`, untracked
  by git [F12, F67].
- **Parser + owner duplication:** 8 divergent `L:`-value readers (BF-021 fixed only one) [F18, F39]; dual
  memory subsystems both "the single entry point" [F41]; dual phase-state systems (`_phases.json` vs ledger)
  [F42]; dual L:-writers with divergent atomicity [F43]; checkpoint silently drops JSON W: state [F44]; the
  io-chokepoint is leaky (19/151 tools route through it) [F47].
- **Fix:** one `resolve_workspace()` (no getcwd fallback — fail loud); one canonical `read_longterm_value`;
  one dev-mode owner; designate single owners for memory + phase-state; a lint that fails CI on
  `os.getcwd()`/literal-"workspace" defaults (would have caught all 8).

## THEME D — MCP allowlist is an external write/destroy surface *(CRITICAL · security)*
- `dispatch-stats` (allowlisted "read-only") exposes **arbitrary-file-write** via `precision --out <path>`
  (mkdir+write to any path) — proven end-to-end [F13]. `usage` exposes **destructive `prune`** (erases
  telemetry history) + forged-telemetry `record` [F14]. `mcp_server.handle_call` forwards `args` verbatim
  as argv with no subcommand/path filtering.
- **Fix:** per-tool read-only subcommand allowlist in `handle_call`; reject `--out`/`--workspace`/path
  flags; replace generic argv passthrough with a per-tool read-only invocation schema in REGISTRY.

## THEME E — Severity model is broken *(MAJOR · WARN doesn't exist under the default)*
- Default `halt-mode=strict` makes `verify.py:175` treat **every runtime WARN as a hard BLOCK** [F15], which
  *forces* every advisory rule into a "silent-until-flag → BLOCK" contortion [F16] and drives the flag
  proliferation: **18 `L:*-required` flags, no central manifest**, and `verify.py rules` misreports
  effective severity [F17, F45]. Three divergent flag readers compound it [F18].
- **Fix:** make WARN genuinely non-fatal (`passed = not blocks`; strict escalates only opt-in rules); add
  `verify.py status` showing each rule's declared vs **effective** severity given on-disk flags.

## THEME F — No module boundaries *(MAJOR · "one big ball")*
- `tools/rules.py` (governance loader) is **permanently shadowed** by the `tools/rules/` package — any
  `import rules` silently gets predicates, never the loader [F01]. `tools/` is a **flat non-package**;
  cross-tool imports rely on `sys.path.insert` copy-pasted ×49 (import order is load-bearing) [F21].
  `_axon_lib` reaches into siblings' private `_`-functions via a string-path loader [F20]. **22 tools**
  parse `REGISTRY.json` independently (no accessor) [F22]; REGISTRY.md/CONTEXT.md/AGENTS.md counts have
  drifted ~2× and the doc_counts regex structurally can't see them [F56–F60].
- **Fix:** `tools/__init__.py` + absolute package imports (delete the 49 bootstraps); rename the loader
  (`rules_loader.py`); one `_axon_registry` accessor; make the count-docs generated.

## THEME G — Sprawl, dead code, dispatch bugs *(MAJOR · 23% of programs are scaffolding)*
- **43/187 programs (23%) are ALIAS/STUB shims** still in the dispatch registry [F30]; 9 dead pr-review
  `p1–p9` stubs duplicate the 506-line monolith they were meant to replace [F29]; **three-hop dispatch**
  (dispatcher→alias→canonical) triples token cost [F31]; **real routing bugs** — `journal event/search`
  misroute to a deprecated alias [F32], and `code-dev.md` routes `review` to **two different programs**
  (second is dead) [F33]. The compile subsystem (4 tools, 154-entry quarantine, ratios ~1.00) is
  effectively non-functional [F34]; the quarantine list is read by **no dispatcher** [F69]. Deterministic
  DAG assembly runs as an interpreted markdown loop instead of in `dag.py` [F35]. Stale `workspace/tools/`
  forks of core modules diverge by weeks [F19]. Dual-kernel drift: two live `KERNEL-SLIM.md` both labeled
  v1.1.4 differ by 21 lines, no content hash [F50]. The OS `axon/programs/` tree (29 files, *higher*
  privilege) has no registry/drift/index at all [F65, F66]. loop-receipt grows unbounded + re-parses the
  whole file per write [F53, F54].
- **Fix:** delete dead stubs/forks; de-dupe dispatch + collapse alias hops; move deterministic logic into
  Python tools; stamp the kernel with a content hash; bound + reverse-scan loop-receipt.

---

## Prioritized roadmap (PLAN phase will number + spec these)
Ranked by leverage ÷ effort. **HIGH-leverage, do first:**
1. **CI runs `crucible gate` on PRs** [A] — converts the entire changeset rule-set advisory→mechanical. S.
2. **Liveness resolver + full-tree orphan BLOCK control** [B] — kills the "features go missing" disease at
   the root; subsumes the dead-rule + uninvoked-tool findings. M.
3. **Declarative rule manifest + parity test** [B/E] — one source for rule→runner→severity; wires the 8
   dead rules; ends the 4-list drift. M.
4. **Unify workspace + dev-mode + L:-reader resolution** [C] — one `resolve_workspace` (no getcwd), one
   dev-mode owner, one `read_longterm_value`; fail-loud; lint to enforce. Fixes the write-gate + ledger
   split-brains. M.
5. **MCP read-only invocation schema** [D] — close the arbitrary-write/destroy holes. S–M.
6. **Honest enforcement labelling in KERNEL-SLIM** [A] — stop claiming BLOCK where advisory; add
   `verify.py status`. S.
7. **WARN non-fatal severity fix** [E] — restore the advisory tier. S.

**MED — sequenced after:** behavioral golden-transcript tests [B]; the hook keystone wrappers + install
[A] (owner-gated, the activation switch); `tools/__init__.py` package + import cleanup [F]; shared
REGISTRY accessor + generated count-docs [F].

**Cleanup (LOW risk, batchable):** delete 43 alias/stub programs + 9 pr-review stubs + `workspace/tools/`
forks [G]; de-dupe `code-dev.md` dispatch + fix journal misroute [G]; retire/repair compile subsystem [G];
bound loop-receipt [G]; kernel content-hash stamp [G]; OS-programs registry/drift [G].

## Residual risks / what's still uncertain (for honesty)
- ~10 late findings (F-range tail) were unverified when the workflow crashed — treat MINORs as
  provisional until re-checked during their PR.
- Semantic dedup of the 114→~40 distinct problems is mine; the PLAN phase should re-cluster against the
  raw `/tmp/arch_findings.md` before finalizing PR boundaries.
- Some "fixes" (CI calling crucible, WARN-non-fatal) change gate behavior repo-wide — each needs its own
  green-gate proof, and the hook install is owner-gated (kernel/host-wiring).
- The dual-checkout (for-use copy 5 days behind) means fixes land in dev; propagation is a separate concern.

## Gate to PHASE 02 — PLAN
STUDY graded **9/10** → eligible to advance. PLAN will: re-cluster findings → number the PRs in waves
(HIGH-leverage first) → write `02-plan.md` (decisions) + `02-prs.md` (the ordered PR list with
requirement traceability), then `03-prs/PR-NN.md` specs IN ORDER. No implementation before specs.
