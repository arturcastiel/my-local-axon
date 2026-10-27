# Project profile — fault-z-slide

linter:        ruff (confirm from each pyproject.toml)
changelog:     CHANGELOG.md
reviewers:     []   # GitHub handles, e.g. ['alice', 'bob']
cross-repo:    ['/mnt/c/projects/library-development/cpg2python', '/mnt/c/projects/library-development/cpg-fault-fieldbook']
               # cpg2python: generic ZCORN ops + validity + D1 fix · fieldbook: docs/examples (P8)
test-cmd:      (pytest per repo — HUMAN runs)
build-cmd:     (pure-Python packages — HUMAN runs any build, agent never executes)
