# CD·WF·C2·P3 — team collaboration gaps

> code-dev today is a **single-actor** workflow: one developer + one AI assistant. Teams of 3+ humans need extra surfaces.

## Single-actor assumptions baked in today

1. `W:code-dev-project` is one slug per user.
2. `_meta.last-program` records last action by *anyone*.
3. No actor attribution in `_actions.log`.
4. `reviewer-track` learns reviewer styles but assumes one user does the learning.
5. ADRs are project-scoped, no proposer/approver distinction.

These are fine for a solo dev. They break for a team.

## Collab gaps

### G-T1. No actor in audit log
Every `_actions.log` entry should have `actor`. Today: implicit (whoever ran it).
- Effort: small (schema field; one line in writer).
- Risk: zero.

### G-T2. No "owner of PR-N"
PR-3 in `_meta` doesn't say who's driving it. Team handoff is opaque.
- Effort: small (`owner` field; populated on `pr create`).

### G-T3. No mention-routing
HUMAN says "@bob look at PR 3". code-dev doesn't surface this on bob's `resume`.
- Effort: medium (mentions index; cross-project).
- Skip unless team feature requested.

### G-T4. No CODEOWNERS-driven suggestions
GH has CODEOWNERS. code-dev should parse and suggest reviewers per file/dir.
- Effort: small (parser + `pr suggest-reviewer`).
- High value.

### G-T5. No "two-keys" merge approval
Some teams require N approvers. `pr-ready` is single-actor.
- Effort: small (approvals counter in `_meta.pr-N`).

### G-T6. No conflict detection across in-flight PRs
PR-3 and PR-7 both touch `foo/bar.py`. No surface warns.
- Effort: medium (file-overlap scan across `pr list`).
- HUMAN: still has to resolve at git layer.

### G-T7. No async handoff message
`handoff` produces a markdown doc — but where does it go? Today: chat.
- Effort: small (`code-dev handoff --to bob` writes to a shared inbox file).
- Optional.

### G-T8. No team-level metrics
Throughput per dev, PR cycle time, review latency. None today.
- Effort: small (compute from `_actions.log` + actor field — requires G-T1 first).

## Multi-project gaps (overlap with team scenarios)

### G-M1. No project switcher (`context use`)
- Mentioned in c2-p1 as G-I10.
- Critical for any dev with > 1 active project.

### G-M2. No global "what am I working on" view
Across all projects, what PRs are open?
- Effort: small (walk all projects; aggregate).
- New: `code-dev meta all-prs`.

### G-M3. No cross-project dependency declaration
PR-3 in proj-A depends on PR-7 in proj-B. No way to express.
- Effort: medium.
- Lower priority.

## Privacy / data-scope gaps

### G-D1. No "PR contains secret" check
Code-dev doesn't scan PR diffs for secrets before pr-ready.
- Effort: small (gitleaks-style regex or `trufflehog --json`).
- HUMAN runs scanner; code-dev parses.

### G-D2. No PII / sensitivity tagging on logs
Logs go to `_actions.log` plaintext. Fine in `my-axon/` (gitignored from `axon/` repo) but if user pushes `my-axon/` to GitHub (as we just did), private snippets might leak.
- Mitigation: `code-dev journal log --redact-secrets`.
- HIGHER priority given our recent push.

## What we shouldn't try to be
- Slack / Teams replacement.
- Project tracker (Linear/Jira swap-in).
- IDE (VS Code is the IDE).
- Identity provider.

## Team-mode toggle (proposed)

```
W:team-mode ≡ true|false   (default false, single-actor)
```

When true:
- Audit log requires `actor`.
- PRs require `owner`.
- `pr-ready` consults `_meta.required-approvals`.
- `code-dev next` filters to current actor's items.

This keeps the simple-mode default while unlocking team surfaces.

## Priority for solo→team incremental upgrades

1. **G-T1 (actor in log)** — prerequisite for everything else.
2. **G-T2 (owner of PR)** — small, high value.
3. **G-T4 (CODEOWNERS suggestion)** — small, immediate value.
4. **G-T5 (multi-approver gate)** — small, useful.
5. **G-T6 (cross-PR conflict)** — medium, defer.
6. **G-T3 / G-T7 / G-T8** — only if team-mode demand emerges.

→ web findings for collaboration patterns: `cd-wf-c2-p4-web-findings.md`.
