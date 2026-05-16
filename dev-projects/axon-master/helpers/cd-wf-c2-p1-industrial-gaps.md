# CD·WF·C2·P1 — industrial workflow gaps

> What a 5–20 person engineering team would expect from a "structured AI dev workflow tool" — and what code-dev is missing today.

## Industrial baseline (what mature teams have)

| Capability                       | Typical owner today    | code-dev today |
|----------------------------------|------------------------|:--------------:|
| Issue tracking                   | Linear / Jira / GitHub | — (not scope)  |
| PR lifecycle                     | GitHub / GitLab        | partial        |
| Stacked PRs                      | Graphite / Aviator     | absent         |
| Code review                      | GitHub PR + bots       | partial        |
| ADR / RFC                        | repo `/decisions/`     | partial        |
| Changelog                        | scriptable / manual    | yes            |
| CI/CD integration                | GH Actions             | absent         |
| Coverage delta                   | codecov                | absent         |
| Audit log of dev decisions       | rare                   | partial        |
| Reviewer assignment              | CODEOWNERS             | absent         |
| Bisect / regression hunting      | git bisect             | absent         |
| Release automation               | release-please         | partial (changelog only) |
| Phase / epic progress dashboard  | Linear / Jira boards   | absent         |
| Cross-project state              | per-tool               | partial        |
| Onboarding flow                  | docs + tour            | partial (tour) |
| Cheatsheet                       | docs / tldr            | absent         |

## Industrial gaps — high impact

### G-I1. No PR aggregator (`pr list`)
A team has 10 in-flight PRs across 3 phases. Today: read each `_meta.md.pr-N`. Mature teams have a single command.
- Effort: small (new program reading meta + filesystem).
- Round-3 has this as `pr list`.

### G-I2. No stacked-PR model
Mature workflows (Graphite, Aviator) require stacking. code-dev's `pr-link --depends-on` is flat.
- Effort: medium (new model + `pr stack` verb family).
- Mentioned in cd-c4-p3-improvements top-15 (D-A1) and Round-3 (`pr stack`).

### G-I3. No coverage delta on review
Industrial review always shows test coverage change. Today: human eyeballs.
- Effort: medium (depends on `pytest --cov` or equivalent in HUMAN's build).
- Round-3 proposed `review --mode=coverage`.

### G-I4. No CI/CD signal integration
GH Actions runs lint/test on PRs but `pr-ready` ignores it.
- Effort: medium (HUMAN runs `gh run list`; pipe into pr-ready).
- HUMAN-only git rule still respected: code-dev reads `gh run list --json` output but doesn't push.

### G-I5. No reviewer-assignment heuristic
Today: HUMAN picks reviewers. Mature teams use CODEOWNERS.
- Effort: small (parse `.github/CODEOWNERS`, suggest based on file paths).
- New program: `code-dev pr suggest-reviewer N`.

### G-I6. No regression bisect aid
`git bisect` is great but lacks context. code-dev could record "this PR is suspected" and walk human through bisect.
- Effort: small (new program: `code-dev bisect`).

### G-I7. No release-automation linkage
`changelog` exists but doesn't tag releases or sync to GitHub Releases.
- Effort: medium (HUMAN does release; code-dev composes the announcement + tag message).

### G-I8. No phase dashboard
Industrial: Linear/Jira boards. Today: read 04-log.md.
- Effort: small (ASCII Kanban in `code-dev meta board`).

## Industrial gaps — medium impact

### G-I9. No PR-spec drift detector
PR-3's spec said "add caching"; PR-3's diff also adds logging. Mature teams catch this in review.
- Effort: medium (semantic diff between spec and actual diff).
- New program: `code-dev pr drift N`.

### G-I10. No multi-project state
A developer has 3 active projects. `W:code-dev-project` is singular.
- Effort: small (add `code-dev context use <slug>`, store stack).

### G-I11. No exportable PR packet
Reviewers offline (airplane, low connectivity) want a single bundle: spec + diff + tests + ADRs.
- Effort: small-medium (compose markdown + zipped diff).
- New program: `code-dev pr export N`.

### G-I12. No retro / postmortem support
After a phase ships, teams retro. Today: free-form in chat.
- Effort: small (new program: `code-dev retro phase N`, prompts known questions).

### G-I13. No metric of "workflow throughput"
"How long from `pr create` → `pr archive` on average?"
- Effort: small (compute from `_actions.log` timestamps).
- New program: `code-dev metrics throughput`.

### G-I14. No safety net for spec churn
A PR's spec is rewritten 8 times; reviewers see only the last version. No history.
- Effort: small (append-only spec versioning).

## Industrial gaps — lower priority

### G-I15. Slack / Teams notifications — out of scope unless requested.
### G-I16. GUI / web dashboard — out of scope.
### G-I17. Multi-actor concurrent edit — single-actor kernel rule.
### G-I18. Auto-merge bots — HUMAN-only git rule.
### G-I19. Linting plugins — external tooling.
### G-I20. Dependency-graph viz — partial via `impact` but not visual.

## Priority scoring (1–5, 5 = highest impact-to-effort)

| Gap   | Impact | Effort | Score |
|-------|:------:|:------:|:-----:|
| G-I1  | 5 | 1 | 5.0 |
| G-I8  | 4 | 1 | 4.0 |
| G-I10 | 4 | 1 | 4.0 |
| G-I5  | 4 | 2 | 2.0 |
| G-I6  | 3 | 1 | 3.0 |
| G-I11 | 4 | 2 | 2.0 |
| G-I13 | 3 | 1 | 3.0 |
| G-I12 | 3 | 1 | 3.0 |
| G-I9  | 4 | 3 | 1.3 |
| G-I3  | 5 | 3 | 1.7 |
| G-I2  | 5 | 4 | 1.3 |
| G-I4  | 4 | 3 | 1.3 |
| G-I7  | 3 | 3 | 1.0 |
| G-I14 | 3 | 2 | 1.5 |

**Top-7 by score:** G-I1, G-I8, G-I10, G-I6, G-I13, G-I12, G-I11.

→ CI/CD specific gaps in `cd-wf-c2-p2-ci-cd-integration.md`.
→ team collab specifics in `cd-wf-c2-p3-team-collab-gaps.md`.
