# Project profile — graphify-obsidian-integration

linter:        ruff (Python tools) + AXON gate lints (F-series, R_*); markdown is prose
changelog:     workspace/AXON-DOCS-DEPRECATIONS.md (decisions) + project 04-log.md
reviewers:     [owner]   # owner resumes after study
cross-repo:    [/mnt/c/projects/copilot-tests/axon-graphify-obsidian-handoff]   # read-only source material
test-cmd:      python3 -m pytest tests/   # HUMAN runs — agent never executes (Code Dev Rule)
build-cmd:     (n/a — AXON is a markdown+python OS; no compile step)

## Upstream tool under evaluation
- graphify (PyPI `graphifyy`, handoff pinned >=0.8.36,<0.9.0) — single maintainer @safishamsi.
- Obsidian (vault config only; no runtime dependency on AXON).
