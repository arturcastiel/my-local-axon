# pr-5 — Secret redaction + pre-push scan

**Wave**: W1 · **Goals**: G.safe.03, G.safe.08 · **Depends-on**: none

## Why (problem statement)
`my-axon/` is intentionally a backup target (per user memory: "github.com/arturcastiel/my-local-axon.git"). Logs in `_actions.log` and journal entries can include arbitrary text the agent reads, including user-pasted secrets. F-H1 (secret push) is a HIGH-damage entry in the mitigation top-10. There is no redaction layer today and no pre-push scan. Combined with F-A2 (premature push, already a documented incident on 2026-05-15), the absence of a redactor is a real operational risk.

## Evidence (from studies)
- `helpers/cd-gap-c2-p4-failure-modes.md` → F-H1 secret push (Class H), priority #8 in mitigation top-10.
- User memory `/memories/operational-safety.md` → 2026-05-15 incident: smo-faults repo pushed without consent. Re-anchor rule active.
- `helpers/cd-gap-c1-p3-goals-extracted.md` → G.safe.03 (redact secrets in journal log), G.safe.08 (pre-push scan).
- `helpers/cd-wf-c2-p3-team-collab-gaps.md` → G-D2 "journal log --redact-secrets" identified as a near-term gap.

## Design notes
- `tools/redact.py` exposes `redact(text) -> (clean, hits)` where `hits` is a list of `{pattern, position}`.
- Patterns (regex, ordered):
  - `sk-[A-Za-z0-9]{20,}`  (Anthropic / OpenAI keys)
  - `AKIA[0-9A-Z]{16}`     (AWS access key ID)
  - `eyJ[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{20,}`  (JWT, 3 segments)
  - `[A-Z_]*TOKEN\s*=\s*['"]?[A-Za-z0-9_\-]{16,}`
  - `[A-Z_]*KEY\s*=\s*['"]?[A-Za-z0-9_\-]{16,}`
  - `password\s*[:=]\s*['"][^'"]+['"]`  (case-insensitive)
- Replacement: `[REDACTED:<pattern-name>]`. Original written to per-write sidecar `<file>.redactions.log` in **`my-axon/memory/local/`** (gitignored from BOTH `axon.git` and `my-axon.git`).
- `tools/log.py` calls `redact()` before any append to `_actions.log` or `journal/*`.
- Allow-list: `workspace/safety/redact-allowlist.md` lists fixture/template directories where patterns should be ignored (so test fixtures with example tokens are not redacted in-place).
- `tools/scan_pre_push.py` walks the staged diff (`git diff --cached`) plus the last commit; exits non-zero on any pattern hit; agent runs this **before** any `git push`. HUMAN wires it as a `pre-push` git hook in their own setup (not mandated by the PR).

## Pitfalls (from failure-mode catalog)
- **F-H1 secret push** → this PR is the primary mitigation.
- **F-A2 premature push** → orthogonal (memory rule), but pre-push scan provides a second line.
- False-positive on fixtures → allow-list mechanism.

## Interface sketch
```text
$ code-dev journal log --entry "DB_PASSWORD=hunter2_letmein_now_42"
✓ logged. Redactions: 1 (pattern=password) → sidecar my-axon/memory/local/journal-2026-05-17.redactions.log

$ python3 tools/scan_pre_push.py
✗ Secret detected in staged diff:
  workspace/programs/code-dev-pr-respond.md:42  pattern=sk-…  (Anthropic key)
  Aborting. Remove the secret or add to allowlist with justification.
exit 1
```

## Spec (canonical)
- **Files**:
  - new: `tools/redact.py`, `tools/scan_pre_push.py`, `workspace/safety/redact-allowlist.md`, `tests/test_redact.py`.
  - modified: `tools/log.py`, `tools/REGISTRY.json`.
- **Acceptance**:
  1. Test redacts each of: `sk-…`, `AKIA…`, JWT, `*_TOKEN=…`, `*_KEY=…`, `password=…`.
  2. Allow-list exempts `tests/fixtures/*` and `workspace/templates/*`.
  3. `<file>.redactions.log` sidecar written under `my-axon/memory/local/`.
  4. `tools/scan_pre_push.py` exits 1 on match; 0 on clean diff.
  5. `tools/lint_paths.py` clean.
- **Rollback**: revert `log.py` (redaction off, logs append raw).
- **Owner**: AGENT writes; HUMAN runs scan pre-push.

## Cross-refs
- Master plan: `../03-plan.md` § Wave 1 / PR-5.
- Helpers: `helpers/cd-gap-c2-p4-failure-modes.md` (F-H1), `helpers/cd-gap-c1-p3-goals-extracted.md` (G.safe.03, G.safe.08).
- User memory: `/memories/operational-safety.md`.
