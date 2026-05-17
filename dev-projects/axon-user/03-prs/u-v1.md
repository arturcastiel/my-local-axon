# U-V1 — VERSION 3.6.0 → 3.6.1 + CHANGELOG (errata + planning-hierarchy)

**Wave**: U.D · **Severity addressed**: release
**Depends-on**: U-1, U-2, U-3, U-4, U-5, U-6, U-7, U-8, U-9, U-14, U-15, U-16
**Owner**: AGENT writes; HUMAN approves push · **Status**: blocked-on-U.A/U.B/U.C/U.E

## Why

Seal **both** the v2 errata (W4 verification gap) **and** the v3 planning-
hierarchy upgrade as a single patch release `3.6.1`. Plan label `1.0.1` →
OS `3.6.1`. The hierarchy upgrade is additive — no API surface broken,
no migration required for existing flat plans — so a patch release is appropriate.

## Design notes

- VERSION bumps `3.6.0` → `3.6.1` (patch — no API surface change).
- CHANGELOG.md gets a new top-block titled `## V3.6.1 — 2026-05-DD (axon-user
  errata: W4 verification gap)`.
- Plan label mapping: axon-user `1.0.1` → OS `3.6.1` documented in the block.
- The CHANGELOG entry must explicitly call out:
  - F-001 root cause (24-file header sweep)
  - Withdrawn state-restore "partner" (U-4)
  - Absorbed-alias dispatch fix (U-5)
  - Three discoverability fixes (U-9)

## Pitfalls

- **R (premature ship)**: Cannot land until **all** of U-1..U-9 are merged.
  Acceptance gate enforces this.
- **F (CHANGELOG drift)**: Errata block should not edit the V3.6.0 block in
  place; it stacks on top.

## Interface sketch

```diff
 # AXON Changelog
 ...
+## V3.6.1 — 2026-05-DD (axon-user errata: W4 verification gap)
+
+**Patch release.** Sealed from persona-driven simulation (5 personas × 15
+workflows) that surfaced an inconsistency between filenames and `# PROGRAM:`
+headers across the W4 rename umbrella, plus several smaller surface fixes.
+
+Plan label `1.0.1` in axon-user → OS `3.6.1`.
+
+### Errata PRs landed (10)
+
+- **U-1** Rename-header sweep — 24 files, line 1 corrected to match filename.
+- **U-2** `tools/session.py list` subcommand — unblocks W-12 chats.
+- **U-3** `code-dev-chats.md` switch — match session.py signature.
+- **U-4** Drop `code-dev-state-restore.md`; document `state-save → tag` alias.
+- **U-5** Absorbed-alias stubs use `STORE` + `EXEC` (no silent `--mode` drop);
+  added `diff` branch to `code-dev-review`; renamed `gaps` branch to `self`.
+- **U-6** `pr-ready` Gate A removed (preflight Gate 0 was duplicate);
+  Gate C rewired to `code-dev-safety-preflight`.
+- **U-7** Plan / study per-mode budget override documented above blanket cap.
+- **U-8** `pr_drift` flags un-checkable criteria; cheatsheet widened to 76 chars;
+  `AXON-DOCS-SCHEMA.md` dead refs fixed.
+- **U-9** `startup.md` reader-gate; `code-dev new` default first-phase;
+  `journal-*` `# when:` annotations.
+
+### Planning workflow upgrade (U.E — new in v3)
+
+- **U-10** `code-dev plan --mode=strategic` now writes `02-roadmap.md`
+  (was stdout-only). New template `workspace/templates/v4-roadmap.md`.
+- **U-11** `code-dev plan --mode=tactical` now writes one
+  `02-phases/phase-N-<slug>.md` per declared phase, in addition to the plan
+  index. New template `workspace/templates/v4-phase.md`.
+- **U-12** `code-dev pr` reads phase docs; PR template gains a
+  `Parent-phase:` header field. Backward-compatible with flat plans.
+- **U-13** `code-dev plan --mode=decision` now writes
+  `03-decisions/adr-NNN-<slug>.md` (was stdout-only). New template
+  `workspace/templates/v4-adr.md`.
+- **U-14** `tools/docgen_verify.py` extended with three new checks:
+  PR → phase link, phase → roadmap link, ADR → PR/phase link.
+- **U-15** `workspace/AXON-DOCS-SCHEMA.md` and `workspace/templates/v4-schema.md`
+  document the new hierarchy; schema label bumped v4.1 → v4.2 (additive).
+- **U-16** `code-dev-plan.md` HELP rewritten — each mode now documents
+  which file artifact it produces.
+
+- **U-V1** This block.
+
+### Withdrawn
+
+- `code-dev-state-restore` (introduced PR-27) — never reached a functional
+  implementation; superseded by the existing `code-dev-tag --rewind`.
+
+---
+
 ## V3.6.0 — 2026-05-16 (axon-master W4: ...)
```

## Spec

### Files

- `VERSION` — `3.6.0` → `3.6.1`.
- `CHANGELOG.md` — prepend the V3.6.1 block (above existing V3.6.0 block).

### Acceptance

- `cat VERSION` prints `3.6.1`.
- `head -5 CHANGELOG.md` shows the V3.6.1 block.
- All 9 U-* PRs are present in git log between origin/main and HEAD.
- `python3 tools/lint_paths.py` clean.
- `python3 tools/budget_lint.py` clean.
- `python3 tools/call_graph.py --check` clean.
- `python3 tools/docgen_verify.py` clean.
- `python3 tools/scan_pre_push.py` clean.
- HUMAN runs `pytest tests/test_programs_md.py tests/test_call_graph.py tests/test_pr_ergonomics.py` — all green.
- HUMAN gives explicit "yes, push" before `git push origin main` per
  `/memories/operational-safety.md`.

### Rollback

`git revert`. Pre-U-V1 state is the W4-final at 3.6.0 plus the 9 U-* commits.

### Owner

AGENT writes the diff. HUMAN approves the push (mandatory per session memory).

## Codebase grounding

- This PR mirrors the structure of `pr-v1`, `pr-v2`, `pr-v3`, `pr-v4` in
  `my-axon/dev-projects/axon-master/03-prs/`.
- The VERSION file lives at repo root; CHANGELOG.md at repo root. Both are
  tracked.

## Cross-refs

- [03-plan.md](../03-plan.md) §8 acceptance
- All 9 U-* detail files in this directory
- `CHANGELOG.md` V3.6.0 block (axon-master W4)
