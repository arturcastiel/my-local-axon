# CD·PLAN·I2·S — challenge v1 (iteration 2)

> Stress-test plan v1. Adversarial reading: where would this go wrong?

## Adversarial questions

### Q1. PR-1 migrator: what if a user has TWO `_meta.md` versions to migrate (multiple old projects)?
- v1 spec only mentions axon-master. Plan must work for ANY old project, not just one.
- Resolution: migrator takes `<project-path>` as arg; default = `W:code-dev-project`. `code-dev meta migrate --all` iterates over `my-axon/dev-projects/*`.

### Q2. PR-1: what is "v4.1"? Was v4 ever real?
- Audit: searching the codebase — no schema-v4 fixture exists. The "v4" label came from internal R5 design.
- Decision: drop "v4" as a separate target. Migrator is `v1 → v4.1` directly. Documentation reflects this; v4 is never written.

### Q3. PR-2 compile gate: programs that legitimately need NO compression (e.g. tiny stubs) will fail.
- A stub at 200 bytes with no compression target = passes (small input).
- But: what if compile produces something tiny + the gate logic wraps in metadata that pushes ratio over 0.95?
- Resolution: gate has a floor — `if src_bytes < 512: skip ratio check`.

### Q4. PR-3 governance: empty rules file — does `code-dev plan` HALT on missing file or proceed with empty?
- v1 says "proceed with empty governance-trace". Confirm: this is correct. But add: warn once per session "rules.md is empty; consider adding rules".

### Q5. PR-4 redact: false positives on real code (e.g. `eyJ` appears in real JWT examples in docs).
- Resolution: allowlist file path-based (e.g. `workspace/templates/**` exempt). Plus context-aware: `eyJ` alone is fine; `eyJ[A-Za-z0-9_-]{20,}` triggers.

### Q6. PR-5 cheatsheet: hand-written or generated?
- v1: hand-written. Risk: bitrot.
- Better: hand-written **scaffold** + auto-generated COMMANDS section appended by `docgen`. Hybrid.
- Defer auto-gen to W3 (depends on docgen extension). Wave-1 ships hand-written; W3 adds the auto section.

### Q7. PR-6 T1 tests: what's the failure of "every program passes"?
- Programs may include drafts/incomplete files. Use frontmatter `status: draft` to skip — failure: T1 should respect it.
- Resolution: T1 reads frontmatter, skips `status: draft|deprecated`.

### Q8. PR-7 failure catalog: does writing it conflict with R6 helper U-4?
- U-4 catalog is internal study work; `workspace/log/failure-modes.md` is the canonical, evolving artifact. No conflict, but PR-7 should copy and reformat (drop axon-master internal labels).

## New risks discovered

### R-new-1 — Wave-1 has 7 PRs; ALL pre-requisite for Wave-2.
- If any single PR-1..7 fails review, Wave-2 entirely blocks.
- Resolution: split critical from nice-to-have.
  - **MUST for W2**: PR-1 (migrator), PR-2 (gate), PR-3 (governance schema), PR-6 (T1 tests).
  - **NICE for W2**: PR-4 (redact), PR-5 (cheatsheet), PR-7 (catalog).
- Wave-2 can start when MUST-set is green.

### R-new-2 — PR-1 (migrator) touches `code-dev resume` program.
- That's a compiled program. Edit triggers re-compile. Re-compile triggers gate. Chicken-and-egg if gate is also new.
- Resolution: PR-2 (gate) ships BEFORE PR-1 modifies resume. OR: PR-1 includes the resume edit with explicit `--override` if gate fails. Pick: ship PR-2 first; PR-1 second.

### R-new-3 — `pr ready --strict` (G.gov.05) is W2 but governance schema is W1. If users try strict in W1, it fails silently.
- Resolution: PR-3 ships a stub `--strict` that prints "strict mode requires W2 PR-10" until W2 lands. Not silent.

### R-new-4 — Migrator backup retention deletes old backups. What if user wanted them?
- Resolution: configurable via `_meta.md` field `backup-retention: 3` (default); user can set higher.

### R-new-5 — User memory says "no push without consent". Plan execution will mass-edit files; doesn't push by itself but might tempt to.
- Resolution: every PR explicitly notes "do not push; HUMAN gates push."

## Sequencing fixes
- Swap PR-1 ↔ PR-2 order: PR-2 (gate) first, then PR-1 (migrator).
- Promote PR-6 (T1 tests) ahead of PR-1 (so we have structural lint before editing programs).

### New Wave-1 order
1. PR-1' = PR-6 (T1 tests)
2. PR-2' = PR-2 (gate)
3. PR-3' = PR-1 (migrator)
4. PR-4' = PR-3 (governance schema)
5. PR-5' = PR-4 (redact)
6. PR-6' = PR-5 (cheatsheet)
7. PR-7' = PR-7 (failure catalog)

MUST set = PR-1', PR-2', PR-3', PR-4'. NICE set = PR-5', PR-6', PR-7'.

## Bundle / split decisions

- **Bundle**: PR-3 governance schema + part of G.plan.04 (plan reads rules — file-reading stub) into PR-4'. Why: tiny code change, sane to ship together.
- **Split**: PR-1 (migrator) had "atomic write helper" sub-deliverable. Split: PR-3' migrator + `_meta.md` atomic-write; `_actions.log`/`_session.md` atomic-write moves to W2 (G.inf.04 finished there).

## Output of I2·S
- 5 adversarial issues → 5 fixes.
- 5 new risks → mitigations.
- 2 sequencing fixes.
- 2 bundle/split decisions.

→ audit: `cd-plan-i2-a-audit.md`.
