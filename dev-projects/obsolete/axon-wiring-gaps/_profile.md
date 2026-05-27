# Project profile — axon-wiring-gaps

linter:        (n/a — this project edits workspace/programs/*.md, not code)
changelog:     (project changes logged in 04-log.md and per-PR specs)
reviewers:     []
cross-repo:    []   # axon.git is the sole repo touched
test-cmd:      python3 axon.py memory get --scope W --key code-dev-codebase
                # smoke check: after fix, W:code-dev-codebase populates from
                # _meta.codebase on `code-dev load <slug>`
build-cmd:     (n/a — no build, AXON programs are read at runtime)
