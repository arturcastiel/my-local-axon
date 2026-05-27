# CD·WF·C2·P2 — CI/CD & build-pipeline integration

> HUMAN-only git policy stays. But code-dev can READ pipeline state to inform decisions. Today it reads almost nothing.

## What code-dev knows about CI/CD today

| Signal              | Knows? | How                |
|---------------------|:------:|--------------------|
| Lint passed locally | no     | —                  |
| Tests passed locally| no     | —                  |
| CI build status     | no     | —                  |
| Coverage %          | no     | —                  |
| Security scan       | no     | —                  |
| Deploy status       | no     | —                  |
| Required-checks list| no     | —                  |
| PR mergeable state  | no     | —                  |

## What it *could* know (read-only)

```
HUMAN runs: gh pr checks 123 --json
            gh pr view 123 --json statusCheckRollup,mergeable
            gh run list --branch feature-x --json
HUMAN pastes JSON into chat OR feeds to:
            code-dev pr sync N --from-stdin
code-dev parses → updates _meta.pr-N with:
  • check-state: pending/passing/failing
  • mergeable: clean/dirty/blocked
  • coverage-delta: +0.4%
  • last-sync: 2026-05-16T10:00:00Z
```

## Concrete proposals

### P1 — `code-dev pr sync N`
- Input: JSON from `gh pr view N --json statusCheckRollup,mergeable,reviewDecision`.
- Output: updates `_meta.pr-N.{state, last-sync}`, prints "passing 7/8, blocking: typecheck".
- HUMAN runs the gh command; code-dev parses.

### P2 — `code-dev pr ready N` gates on synced CI
- After P1, `pr-ready` requires `state==passing` OR explicit `--force`.
- Avoids the case where user types "ready" but CI is red.

### P3 — `code-dev review --mode=coverage`
- Reads coverage report (JSON from `pytest --cov --cov-report=json` or `coverage json`) from a known path.
- Diffs against baseline stored in `_meta.coverage-baseline`.
- Prints per-file delta; flags files with regression.

### P4 — `code-dev pr checks N` (alias for sync + summary)
- One-liner for "what's the CI saying?"

### P5 — Pre-commit hint card
- After `pr update-spec` or `review`, print: "BEFORE commit, run: pytest && ruff check"  (project-configurable).

### P6 — Required-checks awareness
- `_meta.required-checks: [lint, test, typecheck]` declared in project init.
- `pr-ready` cross-references with synced status.

## Where this lives in the umbrella

After Round-3 rework:
- `code-dev pr sync N`        (NEW under `pr` router)
- `code-dev pr checks N`      (NEW)
- `code-dev pr ready N`       (existing, gains gate)
- `code-dev review --mode=coverage` (NEW mode)

## What we still won't do
- `git push` (HUMAN-only)
- `gh pr merge` (HUMAN-only)
- `gh workflow run` (HUMAN-only)
- Network calls (kernel rule)

## Integration with build systems

| Build tool | How code-dev integrates                                  |
|------------|----------------------------------------------------------|
| pytest     | parse `pytest --json-report` output via `code-dev pr sync` |
| coverage.py| parse `coverage json` output                              |
| ruff/flake8| parse `--format=json` output                              |
| mypy       | parse `--no-error-summary --json` output (limited)        |
| cargo      | parse `cargo test --message-format=json`                  |
| jest       | parse `jest --json`                                       |
| go test    | parse `go test -json`                                     |

**Generic adapter:** define `tools/parse_check_results.py` that takes a JSON file + a kind hint and returns a normalized `CheckResult` (pass/fail/skip/coverage%).

## Risk: divergence between local and CI

If user runs tests locally (passing) but CI fails (env diff), `pr-ready` could mislead. Mitigation: `pr-ready` requires *fresh* `pr sync` (within last 5 minutes) when CI state matters.

## Effort estimate
- P1 + P4: small (parse known JSON shapes)
- P2: trivial (gate logic)
- P3: medium (per-tool coverage parsers)
- P5: trivial (string output)
- P6: small (schema field + check)

**Ship together as Cycle-5 "CI-aware code-dev" feature.**

→ team-collab patterns in `cd-wf-c2-p3-team-collab-gaps.md`.
