# Project profile — reservoir-eng

linter:        black + ruff
test-cmd:      pytest tests/   # AXON runs in feature branches
build-cmd:     (none — interpreted)
source-repo:   /home/arturcastiel/projects/Claude-for-reservoir-engineering
upstream-libs: pyResToolbox (mwburgoyne), pyrestoolbox-mcp (gabrielserrao)

## Codebase notes
- AXON root   : /home/arturcastiel/projects/axon-development/axon
- Shares MCP-client dependency with axon-ascent (lever #1)
- Domain      : petroleum reservoir engineering (PVT, DCA, matbal, nodal, relperm, sim)
