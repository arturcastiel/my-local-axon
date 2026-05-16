# CD·PLAN·I3·S — risk + sequencing study (iteration 3)

> Iteration 3 lens: real-world execution. What goes wrong AT IMPLEMENTATION time? What's the order of operations DAY-BY-DAY?

## Execution-time risks (per PR)

### PR-1 (T1 tests)
- Risk: introduces test failures across many programs at once.
- Day-1 reality: agent writes tests; HUMAN runs; tests fail on legitimate drafts.
- Mitigation: ship in two commits — (a) test framework + 1 sample program passing; (b) extend to all programs with `status: draft` opt-out applied to failing ones.

### PR-2 (gate)
- Risk: gate blocks legitimate recompiles of programs we haven't yet rewritten.
- Day-1 reality: someone runs `compile.py code-dev-pr` and gets blocked.
- Mitigation: `--override` flag with log entry. Plus: ship gate in WARN mode for first 24h, then flip to BLOCK after one full pass. Configurable via `workspace/preferences/compile.toml` field `gate-mode: warn|block`.

### PR-3 (migrator)
- Risk: real-world v1 file has fields not in spec.
- Day-1 reality: axon-master has `STUDY DIRECTIVE` block — non-standard. Migrator must preserve unknown fields verbatim.
- Mitigation: migrator preserves all unknown sections under `## CUSTOM` block; never deletes.

### PR-4 (governance schema)
- Risk: precedence doc written but plan code doesn't actually follow it.
- Day-1 reality: integration drift between doc and code.
- Mitigation: precedence is enumerated in `tools/rules.py` as `PRECEDENCE = [...]` constant; doc generated from that constant. Single source of truth.

### PR-5 (redact)
- Risk: redaction breaks a real log message during execution.
- Day-1 reality: a JWT-looking string in legitimate test code gets redacted.
- Mitigation: redact emits a sidecar `<file>.redactions.log` with original→redacted mapping (kept in `my-axon/memory/local/` — gitignored). Recoverable.

### PR-6 (cheatsheet)
- Risk: low.
- Day-1 reality: HUMAN reads, suggests edits.
- Mitigation: none needed.

### PR-7 (catalog)
- Risk: catalog drifts from reality.
- Mitigation: each entry has `last-reviewed: <date>` field; quarterly review cadence (G.safe.09).

### PR-8 (study modes)
- Risk: existing `code-dev-study` is invoked by other programs; mode dispatch breaks call sites.
- Mitigation: backward-compat — no-mode call = `--mode=standard`; all existing call sites unaffected.

### PR-9 (sessions)
- Risk: writing `_session.md` mid-flow corrupts state.
- Mitigation: atomic write (PR-3 helper); journaling.

### PR-10 (strict)
- Risk: false-positives block merges.
- Mitigation: `--strict-explain` flag lists each gate result.

### PR-11 (plan reads rules)
- Risk: rules filter all options → empty plan.
- Mitigation: if filter > 80% of options, HALT + QUERY user.

### PR-12 (rename harness)
- Risk: snapshot captures current state with bugs frozen in.
- Mitigation: snapshot is auditable + user-approved before lock-in.

### PR-13 (usage logging)
- Risk: provider API doesn't expose cache fields → log has nulls forever.
- Mitigation: design accepts nulls; metric set is best-effort.

### PR-14 (routers)
- Risk: stubs silently break dispatch on old verbs.
- Mitigation: PR-12 harness must run pre/post.

### PR-15 (compaction recovery)
- Risk: synthetic test doesn't reflect real compaction.
- Mitigation: real test in next live session (deferred to W3 verification).

### PR-16 (plan modes)
- Risk: mode dispatch repeats PR-8 pattern.
- Mitigation: reuse pattern from PR-8.

### PR-17 (_index.md staleness)
- Risk: timestamps drift across timezones.
- Mitigation: UTC always; ISO 8601.

## Sequencing constraints (DAG with edges)

```
PR-1  ──┬─→ PR-3 (need T1 green before migrator edits resume)
        └─→ PR-12 (snapshot harness uses T1 internals)
PR-2  ──┬─→ PR-3 (gate must precede any compiled-program edit)
        └─→ all PRs that recompile programs
PR-3  ──┬─→ PR-9  (atomic-write helper from PR-3 used by sessions)
        ├─→ PR-17 (study/_index.md skeleton from migrator)
        └─→ PR-8  (study modes runs after _meta.md is v4.1)
PR-4  ──┬─→ PR-10 (strict needs rules schema)
        └─→ PR-11 (plan reads rules)
PR-5  ── (independent)
PR-6  ── (independent)
PR-7  ──→ PR-15 (catalog informs recovery test cases)
PR-8  ──→ PR-16 (plan modes pattern after study modes)
PR-9  ──→ PR-15 (recovery needs session model)
PR-10 ──→ PR-22 (W3 governance audit)
PR-11 ──→ PR-16 (plan modes need rule integration)
PR-12 ──→ PR-14 (routers gated by snapshot)
PR-13 ──→ PR-21 (W3 aggregator)
PR-14 ──→ PR-20 (W3 budget blocks on routers too)
```

## Wave-1 day-by-day (illustrative execution path)

| Step | PRs       | Why this order                                        |
|-----:|-----------|-------------------------------------------------------|
| 1    | PR-1      | Need T1 baseline before any program edit              |
| 2    | PR-2      | Need gate before any compiled-program edit            |
| 3    | PR-3      | Schema unblocks W2 broadly                            |
| 4    | PR-4      | Governance unblocks plan/pr-ready                     |
| --   | --        | MUST-set done; can branch to W2 work in parallel      |
| 5    | PR-5      | Safety hardening (parallel-safe)                      |
| 6    | PR-7      | Catalog (parallel-safe)                               |
| 7    | PR-6      | Cheatsheet last (links to W1 outputs)                 |

## Parallelism analysis
- After PR-1 + PR-2 done: PR-3 and PR-4 can run in parallel (different file sets).
- PR-5, PR-6, PR-7 fully parallel-safe.
- W2 starts can run in parallel after MUST-set:
  - PR-8 ⊥ PR-13 ⊥ PR-12 (different files).
  - PR-9 → PR-15 sequential.
  - PR-10 → PR-22 sequential (cross-wave).

## Rollback strategy per PR

| PR  | Rollback                                              |
|-----|-------------------------------------------------------|
| 1   | Revert test files; programs not touched               |
| 2   | Revert `compile-write.py`; gate disabled              |
| 3   | `migrate_meta.py --restore` per project; backups kept |
| 4   | Revert governance files; `--strict` stub harmless     |
| 5   | Revert redact; logs uncensored                        |
| 6   | Delete cheatsheet                                     |
| 7   | Delete catalog file                                   |
| 8   | Mode dispatch falls back to no-mode                   |
| 9   | `_session.md` files harmless; ignore                  |
| 10+ | Per-PR explicit                                       |

## Cross-cutting test orchestration

Decision: tests live by AREA not by PR.
- `tests/test_programs_md.py` — T1 (PR-1).
- `tests/test_compiled_regression.py` — gate + audit (PR-2).
- `tests/test_migrator.py` — migrator (PR-3).
- `tests/test_governance.py` — rules + strict (PR-4 + PR-10).
- `tests/test_redact.py` — redact (PR-5).
- `tests/test_session.py` — sessions (PR-9, PR-15).
- `tests/test_rename_safety.py` — harness (PR-12).
- `tests/test_dispatch.py` — corpus + quality (PR-18/19).
- `tests/test_plan.py` — plan modes (PR-11/16).
- `tests/test_study.py` — study modes (PR-8/17).

Pattern: one test file per area; PRs append to existing files when possible.

## HUMAN tasks vs AGENT tasks (explicit)

**AGENT writes**:
- All code in `tools/`, programs in `workspace/programs/`, docs, tests.
- This plan itself, all helpers.

**HUMAN runs**:
- `pytest` and any compilation/build.
- `migrate_meta.py` (after dry-run review).
- `git push` (only on explicit consent).
- `code-dev-*` program invocations against live state.
- Reviews and merges PRs.

**HUMAN decides**:
- When to invoke `--override` on gate.
- When to populate `safety/rules.md`.
- When backup retention bumps.
- Token-ceiling per project.
- Backup remote URL (already set; reuse).

## Open questions for I4
1. Should PR-2's WARN→BLOCK flip be time-based (24h) or test-based (one full audit pass)?
2. What's the format of `_session.md` for "active" state — single line `state: active` or richer?
3. How does PR-3 migrator handle a project whose `STUDY DIRECTIVE` block (custom) is critical to its workflow? Preserve as `## CUSTOM`? Or split out?

→ audit: `cd-plan-i3-a-audit.md`.
