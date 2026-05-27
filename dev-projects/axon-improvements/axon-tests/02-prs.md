# PR list — AXON Test Battery (axon-tests)

> Ordered. No PR depends on a later one.
> Complexity scale: S ≤ 1 day · M ≤ 3 days · L ≤ 1 week · XL > 1 week.
> "Doc anchor" = AXON-DOCS page each PR's tests pin (Guarded-by block).

---

## Wave A — Foundations (PR-001 .. PR-006)

### PR-001 — Wire the full pytest suite into CI
- **Scope:** `.github/workflows/ci.yml`
- **What:** Replace the path-only `test` job with `pytest tests/ -v
  --maxfail=1 --durations=20`. Keep `lint-paths` job. Add a
  `python -m pip install -r requirements.txt` step. Cache pip.
- **Depends-on:** none
- **Complexity:** S
- **Tests added:** none new — exercises the existing 315.
- **Doc anchor:** AXON-DOCS-TESTING § "Running"
- **Why:** Closes F-1 (CI runs ~3 % of tests). Highest-leverage fix.

### PR-002 — Add `pytest-cov` with coverage gates
- **Scope:** `pyproject.toml` (or `pytest.ini`), `requirements.txt`,
  `.github/workflows/ci.yml`, `tests/conftest.py`
- **What:** Configure `pytest-cov`; fail CI when
  `tools/rules/` < 100 % line/branch or `tools/` < 80 % line.
  Other paths advisory only. Upload coverage artifact.
- **Depends-on:** PR-001
- **Complexity:** S
- **Tests added:** 1 meta-test ensuring coverage config is present.
- **Doc anchor:** AXON-DOCS-TESTING § "Coverage" (new section)
- **Why:** Closes F-3.

### PR-003 — Install `scan_pre_push.py` as a real hook
- **Scope:** `scripts/install-hooks.sh` (new), `tools/scan_pre_push.py`
  (no logic change), `axon/HOWTO.md`, `SETUP.md`
- **What:** Add a one-time installer that copies/symlinks
  `.githooks/pre-push` (calling `python3 tools/scan_pre_push.py`) and
  configures `git config core.hooksPath .githooks`. Document running
  the installer in SETUP.md.
- **Depends-on:** none
- **Complexity:** S
- **Tests added:** 2 — installer idempotence, hook executes scan_pre_push.
- **Doc anchor:** AXON-DOCS-GOVERNANCE § "Pre-push gates" (new)
- **Why:** Closes F-2.

### PR-004 — Doc co-output template + advisory linter
- **Scope:** `workspace/templates/axon-docs-page.md` (new),
  `tools/docgen_verify.py` (extend), `workspace/AXON-DOCS-TESTING.md`
- **What:** Define the canonical AXON-DOCS-* page shape with a
  required `## Guarded by` section listing test ids. Extend
  `docgen_verify` to warn (Phase 2) and later fail (PR-018) on doc
  pages without that block. Add the template to the v4 scaffold.
- **Depends-on:** none
- **Complexity:** M
- **Tests added:** 4 — template renders, verify warns on missing
  block, verify passes on full block, ignores non-AXON-DOCS files.
- **Doc anchor:** AXON-DOCS-SCHEMA § "Doc-page convention" (new)
- **Why:** Closes F-12 framing; sets the rhythm for every later doc PR.

### PR-005 — `tools/workflow_test.py` (state-machine harness)
- **Scope:** `tools/workflow_test.py` (new),
  `tests/fixtures/workflows/` (new dir), `tools/REGISTRY.json`
- **What:** A subprocess-replay harness that loads a
  `<wf>.flow.jsonl` (sequence of {input, expected_state, expected_files})
  and runs it against `python3 axon.py …`. Returns JSON pass/fail.
  Register tool. Separate from mock-model behavioural harness.
- **Depends-on:** PR-001
- **Complexity:** M
- **Tests added:** 6 — happy path, missing-fixture, state mismatch,
  file-assertion mismatch, JSON output shape, tool registry entry.
- **Doc anchor:** AXON-DOCS-TESTING § "Workflow harness" (new)
- **Why:** Enables PR-013, PR-014, PR-015.

### PR-006 — Rules-test scaffold + meta-enforcer
- **Scope:** `tests/test_rules/` (new dir), `tests/test_rules/conftest.py`,
  `tests/test_rules_meta.py` (new)
- **What:** Scaffold one stub file per rule module (no real tests
  yet, just placeholders). Add `test_rules_meta.py` with:
  (a) every `tools/rules/r*.py` has a matching `test_rules/test_*`
  (b) every `rule_id` in registry appears in ≥1 assertion
  (c) every rule module declares `phase`, `severity`, `rule_id`.
  Meta-test fails CI if a new rule lands without a test file.
- **Depends-on:** PR-001
- **Complexity:** S
- **Tests added:** 3 meta-tests + 9 stub files.
- **Doc anchor:** AXON-DOCS-GOVERNANCE § "Rule predicates" (new)
- **Why:** Closes F-4 framing; sets contract for PR-011.

---

## Wave B — Safety-critical surfaces (PR-007 .. PR-011)

### PR-007 — Identity-gate test suite
- **Scope:** `tests/test_identity_gate.py` (new),
  `tests/fixtures/identity/` (new), `workspace/AXON-DOCS-GOVERNANCE.md`
- **What:** Cover `axon/programs/identity.md`:
  · gate fires on each canonical trigger phrase (≥8 phrases),
  · honours `L:disclose-execution-layer` (true/false/unset),
  · falls back silently when `L:host-model` is unset,
  · refuses to name a model not declared by the harness,
  · refuses on banned subject forms ("As an AI", "I'm a model" …).
- **Depends-on:** PR-001, PR-004 (doc template)
- **Complexity:** M
- **Tests added:** ~12
- **Doc anchor:** AXON-DOCS-GOVERNANCE § "Identity gate"
- **Why:** Closes F-9. Safety-critical.

### PR-008 — Boot contract test suite
- **Scope:** `tests/test_boot_contract.py` (new),
  `tests/test_workflows/test_w08_boot.py` (uses PR-005 harness),
  `axon/BOOT.md` extensions
- **What:** Assert:
  · step-1 STORES (`L:cognition-frame`, `W:reasoning-mode`),
  · G-10 HALTs with the right message on missing ws-programs,
  · G-11 routes correctly for CLAUDECODE / COPILOT / generic,
  · my-axon detection: missing → query; present → MYAXON.md ops
    evaluated; absent + skip → degraded mode warning,
  · banner + menu render reach output.
- **Depends-on:** PR-005
- **Complexity:** M
- **Tests added:** ~10
- **Doc anchor:** AXON-DOCS-WORKFLOWS § "W-08 Boot" (new)
- **Why:** Closes F-7. Every session depends on this.

### PR-009 — Dev-mode write gate test suite
- **Scope:** `tests/test_rules/test_r9_axon_write.py` (full file from
  the PR-006 stub), `workspace/AXON-DOCS-GOVERNANCE.md`
- **What:** Cover R9 positive + negative + 8 edge cases (WRITE vs
  APPEND vs READ; path normalisation; symlink; `./axon/x`; dev-mode
  ON; dev-mode OFF; user-explicit "please write to axon/" still
  blocked; programs writing to axon/ blocked).
- **Depends-on:** PR-006
- **Complexity:** S
- **Tests added:** ~10
- **Doc anchor:** AXON-DOCS-GOVERNANCE § "Rule R9 — axon/ write gate"
- **Why:** Most-quoted Core Rule (rule 9). Closes F-4 for R9.

### PR-010 — Workspace-backup test suite
- **Scope:** `tests/test_workflows/test_w15_workspace_backup.py`,
  `tests/test_workspace_backup_tool.py` (new),
  `workspace/AXON-DOCS-GOVERNANCE.md`
- **What:** Assert the three preconditions on autonomous git push:
  · op is inside `my-axon/`,
  · op was triggered by `workspace-backup` program,
  · remote is `origin` of the `my-axon/` repo.
  Each violated precondition → autonomous-push violation, no push.
  Plus: boot tail-call only fires when `myaxon-backup-enabled.md =
  true`, status file updated correctly, error path surfaces in menu.
- **Depends-on:** PR-005
- **Complexity:** M
- **Tests added:** ~8
- **Doc anchor:** AXON-DOCS-GOVERNANCE § "Autonomous push rule"
- **Why:** Closes F-10. Only autonomous git op kernel permits.

### PR-011 — Rules engine: full rule-by-rule tests
- **Scope:** `tests/test_rules/test_r3_arithmetic.py` … `test_r_w_budget.py`
  (8 files; r9 already done in PR-009, r_drift_gate migrated from
  test_tools_kernel)
- **What:** Per `helpers/rules-crosswalk.md` § "Implication":
  positive + negative + per-rule edge cases. Migrate
  `TestDriftGate` from `test_tools_kernel.py` to `test_r_drift_gate.py`.
- **Depends-on:** PR-006, PR-009
- **Complexity:** L
- **Tests added:** ~60–80
- **Doc anchor:** AXON-DOCS-GOVERNANCE § "Rule predicates" table —
  add one Guarded-by row per rule.
- **Why:** Closes F-4 fully.

---

## Wave C — Breadth (PR-012 .. PR-017)

### PR-012 — Verifier integration tests
- **Scope:** `tests/test_verify_integration.py` (new), folds existing
  `TestVerify` cases in.
- **What:** End-to-end: feed `verify.py` real program files that each
  trigger exactly one rule; assert rule_id is in the violation list
  and severity matches.
- **Depends-on:** PR-011
- **Complexity:** S
- **Tests added:** ~9 (one per rule)
- **Doc anchor:** AXON-DOCS-GOVERNANCE § "Verifier flow"

### PR-013 — Catalogued workflows W-01..W-07 e2e tests
- **Scope:** `tests/test_workflows/test_w0[1-7]_*.py`,
  `tests/fixtures/workflows/w0[1-7].flow.jsonl`,
  `workspace/AXON-DOCS-WORKFLOWS.md` (add Guarded-by per row)
- **What:** One e2e per catalogued workflow, mock-model harness for
  behavioural flows, `workflow_test.py` for state-machine ones.
- **Depends-on:** PR-005
- **Complexity:** L
- **Tests added:** ~21 (3 per workflow)
- **Doc anchor:** AXON-DOCS-WORKFLOWS (every W-NN row).
- **Why:** Closes F-6 for catalogued half.

### PR-014 — Implicit workflows W-09..W-15 e2e tests
- **Scope:** `tests/test_workflows/test_w09_*..test_w15_*`,
  fixtures, `workspace/AXON-DOCS-WORKFLOWS.md` (add W-09..W-15 rows)
- **What:** Boot (W-08) is in PR-008; backup (W-15) in PR-010;
  identity (W-14) in PR-007. This PR handles W-09 menu→program,
  W-10 code-dev new, W-11 code-dev load, W-12 review umbrella,
  W-13 freeze→safety chain.
- **Depends-on:** PR-005, PR-013
- **Complexity:** L
- **Tests added:** ~18
- **Doc anchor:** AXON-DOCS-WORKFLOWS (new W-09..W-15 rows).
- **Why:** Closes F-6 fully.

### PR-015 — Compiler & dispatch coverage expansion
- **Scope:** `tests/test_compiled_regression.py` (extend),
  `tests/test_dispatch.py` (extend),
  `tests/test_compile_optimizer.py` (new)
- **What:** Edge cases for compiler (idempotence, identical-prompt
  collisions, missing source), dispatch (low-confidence,
  prefer-compiled override, fallback=ask path, feedback adjustment).
- **Depends-on:** PR-001
- **Complexity:** M
- **Tests added:** ~15
- **Doc anchor:** AXON-DOCS-COMPILER (Guarded-by appended)
- **Why:** Closes F-8.

### PR-016 — Programs behavioural tier-A coverage
- **Scope:** `tests/fixtures/programs/<name>/` populated for menu,
  identity, code-dev (root), code-dev-new, code-dev-load,
  code-dev-study, code-dev-plan, code-dev-pr, code-dev-resume,
  workspace-backup; matching `expected.md` per program.
- **What:** Use the existing mock-model harness; one fixture per
  program; minimal `responses.jsonl` + golden `expected.md`.
- **Depends-on:** PR-005
- **Complexity:** L
- **Tests added:** harness parametrises ~10 programs
- **Doc anchor:** AXON-DOCS-TESTING § T3 (extend)
- **Why:** Closes F-5 / F-11 for tier-A. Tier-B/C tracked as a future
  phase, not in this project.

### PR-017 — Tool-level coverage gaps
- **Scope:** `tests/test_tools_kernel.py` (extend),
  `tests/test_tools_core.py` (extend)
- **What:** Fill known thin areas surfaced by PR-002 coverage
  report — at minimum: cron tick, prompt-log non-blocking BG,
  turn-log append, output-layer footer render. Each PR-002 hot-spot
  ≤ 80 % gets a case.
- **Depends-on:** PR-002
- **Complexity:** M
- **Tests added:** ~15
- **Doc anchor:** AXON-DOCS (per affected subsystem)

---

## Wave D — Closure (PR-018 .. PR-021)

### PR-018 — Make `docgen_verify` doc-block blocking
- **Scope:** `tools/docgen_verify.py`, `.github/workflows/ci.yml`,
  `tools/axon_audit.py`
- **What:** Flip the PR-004 advisory to blocking in CI for
  AXON-DOCS-*.md files. Add `axon-audit` check that flags any
  `tools/rules/` rule whose Guarded-by table row is empty.
- **Depends-on:** PR-004, PR-011, PR-013, PR-014
- **Complexity:** S
- **Tests added:** 4
- **Doc anchor:** AXON-DOCS-GOVERNANCE § "Doc co-output gate"
- **Why:** Closes F-12 fully.

### PR-019 — Mandatory-test pre-push hook
- **Scope:** `scripts/install-hooks.sh` (extend from PR-003),
  `.githooks/pre-push` (new content)
- **What:** Add a fast `pytest tests/test_smoke.py` (≤ 5 s) gate to
  the existing pre-push so any push runs at least the smoke
  contract locally before hitting CI.
- **Depends-on:** PR-003, PR-001
- **Complexity:** S
- **Tests added:** 1 `tests/test_smoke.py` (covers identity, boot,
  rules registry, verify rules list, prefs load).
- **Doc anchor:** AXON-DOCS-GOVERNANCE § "Pre-push gates"

### PR-020 — CONTRIBUTING.md + AGENTS.md "tests are mandatory" clause
- **Scope:** `CONTRIBUTING.md`, `AGENTS.md`, `.github/PULL_REQUEST_TEMPLATE.md`
- **What:** Codify the rule in plain English. PR template forces the
  author to check: (a) tests added, (b) coverage not regressed,
  (c) doc page updated with Guarded-by.
- **Depends-on:** PR-018
- **Complexity:** S
- **Tests added:** 0 (docs)
- **Doc anchor:** README.md, AXON-DOCS § index

### PR-021 — Final docs sweep + README badge
- **Scope:** `workspace/AXON-DOCS-TESTING.md` (full rewrite, replaces
  the current 36-line stub), README badge for CI / coverage,
  `AXON-DOCS.md` index update.
- **What:** Reference doc that lists every test tier, every workflow
  with its Guarded-by, every rule with its test file. Adds badges.
- **Depends-on:** all prior PRs in this list
- **Complexity:** M
- **Tests added:** 0 (docs)
- **Doc anchor:** AXON-DOCS-TESTING (the page itself)

---

## Tally

- **Total PRs:** 21
- **New test cases (approx):** ~200 (≈ 60 rules + 45 workflows + 90 other)
- **Net new files:** ~30
- **Mandatory gate established by:** end of PR-019
