# Phase 2 — PR list · axon-architecture

> Ordered by wave (leverage ÷ effort; security + enforcement-keystone first). **AUTO** = non-kernel,
> fail-closed autonomous loop (gate green → merge). **OWNER** = kernel-file merge or host-wiring (prepare
> + hand off). Every AUTO PR ships tests (Core Rule 13) + must pass the crucible gate. F-refs = study
> findings (`01-study.md` / `/tmp/arch_findings.md`). Themes A–G from the study.

## Wave 0 — Security (Theme D) — CRITICAL, first
- **PR-1 · MCP read-only invocation schema** · AUTO · F13,F14
  - `mcp_server.handle_call`: per-tool subcommand allowlist; reject `--out`/`--workspace`/path-bearing
    flags; constrain `dispatch-stats`→{summary,savings}, `usage`→{top,suggest,aggregate}. Independently
    harden `dispatch_stats.cmd_precision` to refuse writes outside workspace. Tests: arbitrary-write +
    prune are rejected; allowed read subcommands still pass.

## Wave 1 — Enforcement becomes mechanical (Theme A) — CRITICAL keystone
- **PR-2 · CI runs `crucible gate` on PRs** · AUTO · F04,F27,F49
  - Add a `crucible-gate` job to `.github/workflows/ci.yml` that runs `python3 tools/crucible.py gate`
    (and a changeset pass on the PR diff), failing on exit 1. The single change that makes the changeset
    rule-set mechanical at merge. Test/conformance: every BLOCK control in crucible.json maps to the job.
- **PR-3 · `verify.py status` + honest severity surface** · AUTO · F17,F45
  - New `verify.py status`: per rule → declared severity, activation flag, on-disk value, EFFECTIVE
    severity (SILENT/WARN/BLOCK) under current halt-mode. Tests.
- **PR-3K · KERNEL relabel: advisory vs mechanical** · OWNER (kernel) · F02,F09,F24,F48
  - Reword `KERNEL-SLIM.md` claims ("enforced mechanically (BLOCK)", write-gate, R3) to match reality
    until the hook exists; point to `verify.py status`. Prepare + hand off.
- **PR-4 · Hook keystone wrappers** · OWNER (host-wiring) · F02,F09,F10,F51,F52
  - Author `tools/hooks/{reanchor_store,enforce_pretooluse,verify_stop}.py` (+ tests) so the
    `.claude/settings.json.proposed` becomes installable; an `enable-enforcement.sh`. AUTO to write+test
    the wrappers; OWNER to install/activate + flip flags.

## Wave 2 — Liveness / anti-orphaning (Theme B) — CRITICAL
- **PR-5 · Liveness resolver** · AUTO · F07
  - One tool unioning all 6 invocation surfaces (program TOOL(), tool imports, axon.py dispatch,
    crucible.json cmds, pre-commit, mcp SAFE_TOOLS) → per-tool reached/orphan. Tests.
- **PR-6 · Full-tree orphan BLOCK control** · AUTO · F06,F26,F37
  - Wire the resolver as a crucible control + extend `registry_drift` with an invocation-orphan class;
    WARN + explicit shrinking allowlist of today's orphans; BLOCK on NEW. Tests.
- **PR-7 · Declarative rule manifest (wires the 8 dead rules)** · AUTO · F03,F38
  - One `rules_manifest` (rule_id → modules/phase/severity/runners) consumed by registry.py + crucible.py
    + lint_summary.py + neuron_audit.py; parity test: every `r_*.py` is referenced by ≥1 runner. Wires
    r_identity_lock / r_override_attempt / r_cognition_language / r_inference_mode_lock / r_fail_format /
    r_phase_tracked / r_neuron_role / r_reservoir_output into a real gate.
- **PR-8 · Behavioral golden-transcript tests** · AUTO · F05,F28
  - Seed ≥1 real `responses.jsonl`+`expected/` per core program into `_mock_model.py`; make
    `test_behavior.py` FAIL (xfail-strict) on an empty target; parametrized "every ACTIVE non-CI tool is
    invoked by ≥1 program" test.
- **PR-9 · Triage the named orphans** · AUTO · F36,F61,F62,F63
  - memory-sync / axon-eval / a2a / skill-adapter / apply-memory-slot / axon-memory-sync: wire each into a
    real path or reclassify OPTIONAL/DEPRECATED. Drive the allowlist (PR-6) down.

## Wave 3 — Path/state single source of truth (Theme C) — CRITICAL
- **PR-10 · One `resolve_workspace()` (no getcwd; fail-loud) + lint** · AUTO · F11,F40,F55,F68
  - Fix the 8 cwd-default tools to use `_axon_paths`; add `lint_workspace_defaults` CI job that fails on
    `os.getcwd()`/literal-"workspace" argparse defaults. Tests.
- **PR-11 · Unify dev-mode owner (fix write-gate-always-off)** · AUTO · F08,F46
  - `_axon_io` + enforce + verify + memory read ONE dev-mode path; test asserts the identical resolved
    path. Closes the silently-off write-gate.
- **PR-12 · One canonical `read_longterm_value`** · AUTO · F18,F39
  - Extract one reader (strip + casefold `value:` sentinel); route all 8 divergent call sites through it;
    delete copies. Tests for `value: true` / whitespace / case.
- **PR-13 · Phase-ledger into workspace/ + git-track; reconcile with _phases.json** · AUTO · F12,F42,F67
  - Migrate ledger under workspace/memory/episodic/, git-track it; have phase_model.advance/done append a
    ledger row so the two owners can't drift; path-lint that no workspace resolves above workspace/.
- **PR-14 · Consolidate dual L:-writers + checkpoint JSON-W: capture** · AUTO · F43,F44
  - session_save routes through the shared atomic L:-write helper; checkpoint captures `.json` W: keys
    (intent-queue, crucible-last) + writes snapshots to a sibling dir. Tests.

## Wave 4 — Severity model (Theme E) — MAJOR
- **PR-15 · WARN non-fatal** · AUTO · F15,F16
  - `verify.py` `passed = not blocks`; strict-halt escalates only opt-in rules; document at the Violation
    dataclass. Test: an unconditional-WARN rule does not fail the gate in default config. Unblocks
    default-WARN→opt-in-BLOCK rules (removes the silent-until-flag contortion).

## Wave 5 — Module boundaries (Theme F) — MAJOR
- **PR-16 · Rename `tools/rules.py` → `rules_loader.py`** · AUTO · F01 (+ REGISTRY path + docs).
- **PR-17 · `tools/__init__.py` package + absolute imports** · AUTO · F21 (delete the 49 sys.path
  bootstraps; careful repo-wide import gating).
- **PR-18 · Shared `_axon_registry` accessor + generated count-docs** · AUTO · F22,F56,F57,F58,F59,F60
  - One accessor for the 22 REGISTRY parsers; regenerate REGISTRY.md/CONTEXT.md/AGENTS.md counts + extend
    doc_counts patterns so the count-docs are gated.
- **PR-19 · `_axon_lib` uses public APIs** · AUTO · F20 (drift/events/auto_audit expose public fns).

## Wave 6 — Sprawl / dead-code / dispatch bugs (Theme G) — MAJOR (batchable)
- **PR-20 · Delete dead programs/forks** · AUTO · F19,F29,F30 (43 alias/stub + 9 pr-review stubs +
  workspace/tools/ forks; migrate callers first).
- **PR-21 · Fix dispatch bugs** · AUTO · F31,F32,F33 (de-dupe code-dev.md `review`; fix journal
  event/search misroute; collapse three-hop alias hops). Real bug fixes.
- **PR-22 · Retire/repair compile subsystem + quarantine** · AUTO · F34,F69.
- **PR-23 · DAG assembly into dag.py (`bootstrap-from-prs`)** · AUTO · F35.
- **PR-24 · Kernel content-hash stamp + dual-checkout drift detect** · AUTO (boot.py) / OWNER (kernel
  header) · F50.
- **PR-25 · OS `axon/programs/` registry + drift gate** · AUTO · F65,F66.
- **PR-26 · Bound loop-receipt (gc wiring + reverse-scan)** · AUTO · F53,F54.

## Theme coverage check
A→PR2,3,3K,4 · B→PR5,6,7,8,9 · C→PR10,11,12,13,14 · D→PR1 · E→PR3,15 · F→PR16,17,18,19 ·
G→PR20,21,22,23,24,25,26. **No theme unmapped; all 14 CRITICALs land in Waves 0–3.**

## Execution policy
- AUTO PRs: branch → implement + tests → `crucible gate` green → push → MR → merge by NUMBER (grep
  "Merged!" + retry on 405) → sync main → cleanup branch. One at a time (serialized merges).
- OWNER PRs (PR-3K kernel, PR-4 install, PR-24 kernel header): prepare on a branch + gate + hand off.
- Brand-free commit messages (no "claude"/PR-N tokens); `Co-authored-by: AXON` trailer.

## Gate to PHASE 03 — PR-specs
On PLAN DONE: write `03-prs/PR-01.md …` specs IN ORDER (PR-1 first), then implement. No code before its spec.
