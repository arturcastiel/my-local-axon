# Project profile — axon-ascent

linter:        black + ruff   # Python tools/ tree; markdown via axon-audit
changelog:     CHANGELOG.md
reviewers:     []
cross-repo:    ["/home/arturcastiel/projects/axons-audit"]   # findings source
test-cmd:      pytest tests/   # AXON runs in feature branches (no C++ build)
build-cmd:     (none — interpreted Python; "build" = lint + tests + coverage gates)
source-audit:  /home/arturcastiel/projects/axons-audit

## Handoff policy  (inherited from axon-development repo convention)
agent-can-run-tests:   true
agent-can-push:        feature-branches-only
agent-can-open-pr:     draft
agent-can-merge:       false
agent-can-destruct:    false
handoff-point:         after `gh pr create --draft` — wait for human review + merge

## Codebase notes
- Root         : /home/arturcastiel/projects/axon-development/axon
- Findings src : /home/arturcastiel/projects/axons-audit (external strategic audit)
- Sibling done : axon-polish (internal bug-census — complete; orthogonal axis)
- CI gates     : lint-paths, coverage, REGISTRY drift, doc-anchor, doc-counts, doc-co-output
- Moat guard   : every change must pass the audit's test —
                 "does this preserve the property that AXON behaves the same
                  way 100 turns from now as it does on turn 1?" If no → reject,
                 even if competitors have the feature.
- Hot zones    : tools/ (new integration tools), workspace/programs/ (new
                 programs + gates), axon/ kernel (dev-mode gated; budget gate only)
