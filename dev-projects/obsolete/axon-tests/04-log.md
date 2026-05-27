# Implementation Log — AXON Test Battery

## SESSION START — 2026-05-16T20:55:00+02:00
project:        axon-tests
phase:          1-study
workflow-step:  build
branch:         main

## Entries

### 2026-05-16T21:36 · phase 3 — Wave A specs
- Wrote `02-roadmap.md` (strategic tier-1 roadmap, success metrics
  + non-goals).
- Wrote Wave-A PR specs (`03-prs/PR-001.md` … `PR-006.md`) — full
  spec format: summary, entry conditions, changes (per file: what /
  how / why), architecture impact, acceptance criteria, risks,
  tests added, doc anchor, rollout, out-of-scope.
- Wrote `02-phases/phase-1-foundations.md` grouping Wave A.
- `_meta.md` → phase **3-pr-specs**, workflow-step **pr-specs**.
- Wave A is fully specified and ready for implementation. Each PR
  is small (4 × S, 2 × M) and independently mergeable in the order
  shown (PR-002 after PR-001; the rest are independent).
- Next decision point for the user:
  (a) review the Wave-A specs and request edits, then I draft Wave-B
      specs (PR-007..011), OR
  (b) implement PR-001 now (the cheapest, highest-leverage change:
      one CI file edit). Implementation = me producing the file
      changes in the real repo; human runs CI to verify.


---

## Round 5 — Design finalised + PR-001 implemented (2026-05-16)

- Drafted PR-007 .. PR-021 (15 specs) using the PR-001 template.
- Consistency-checked `Depends on:` lines against DAG.json → match ✓
- Phase advanced: 2-design (pr-specs) → 3-implement (implement).
- **PR-001 implemented**:
  - `.github/workflows/ci.yml`: replaced `test` job with `tests-full`
    running full `pytest tests/ -v --maxfail=1 --durations=20`,
    pip cache enabled, installs `requirements.txt`.
  - `requirements.txt`: prepended `pytest>=8.0` (explicit dep).
  - `CHANGELOG.md`: added `## Unreleased` section with PR-001 entry.
- No `axon/` writes — kernel rule R9 honoured (dev-mode still false).
- Per AXON contract, agent does NOT run pytest; user runs CI.

---

## Round 6 · 2026-05-16 — Implementation phase closed

Closed PR-001..PR-021 (PR-005 dropped per DEV-001). Sequential
single-PR cadence enforced. Agent never invoked pytest.

**Shipped in this round (PR-018..PR-021):**
- PR-018 — `docgen-strict` job added to `.github/workflows/ci.yml`;
  9 AXON-DOCS-*.md pages now have populated `## Guarded by` tables.
- PR-019 — `tests/test_smoke.py` (8 fast cases) + `scripts/install-hooks.sh`
  extended so pre-push runs smoke before secret scan.
- PR-020 — `CONTRIBUTING.md` merged with mandatory test+doc rule
  (DEV-003 logged); `AGENTS.md` gained the "Tests & docs are
  mandatory" section; `.github/PULL_REQUEST_TEMPLATE.md` created with
  3-tick-box check-list.
- PR-021 — `AXON-DOCS-TESTING.md` rewritten as full reference
  (taxonomy, running, coverage, adding-a-test, catalogues for every
  test file); README.md gained CI + tests-mandatory + docs-guarded-by
  + coverage badges.

**Deviations logged:** DEV-001 (PR-005 dropped), DEV-002 (structural
in place of mock-model for PR-007/008/010/013/014/016), DEV-003
(CONTRIBUTING.md merged not replaced).

**Phase advance:** _meta.md → `5-enforce`. Phase 4 (document)
co-shipped with implementation, so no separate phase needed.

**Next manual actions for user:**
1. `pip install -r requirements.txt` (gets pytest-cov).
2. `pytest tests/ -v` — expect some failures since tests were
   written blind per kernel R3 (agent must not run them).
3. Fix import/path issues surfaced by step 2; re-run.
4. `bash scripts/install-hooks.sh` to wire smoke + secret scan.
5. Decide whether to populate the TODO rows now expanded in the
   AXON-DOCS pages with real test ids as the suite stabilises.
6. Configure branch protection on `main` to require `tests-full`,
   coverage gate, and `docgen-strict`.

**Status:** project axon-tests is implementation-complete; enforcement
phase begins when human confirms green CI on `main`.
