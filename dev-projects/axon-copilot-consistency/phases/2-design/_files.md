# Changed-files registry — 2-design

| File | PR | Note |
|------|----|------|

_(Design phase — no source files changed yet. Markdown specs only,
under `phases/2-design/`. Phase-3 PRs will populate this table.)_

## Forecast (files the locked PRs WILL touch in phase-3)

| File | PR | Type | Note |
|------|----|------|------|
| `.github/copilot-instructions.md` | 201, 202, 206 | edit | T1 fix → load-balance → banner block |
| `AGENTS.md` | 202, 206 | edit | absorb load-bearing rules + banner |
| `tools/axon_mcp_server.py` | 203 | new | MCP server |
| `tools/axon_mcp_manifest.json` | 203 | new | tool schemas |
| `workspace/programs/axon-mcp-setup.md` | 203 | new | install docs |
| `workspace/programs/copilot-setup.md` | 205 | new | setup advisory program |
| `scripts/setup-copilot-axon.sh` | 205 | new | shell setup |
| `.github/instructions/code.instructions.md` | 204 | new | replaces deprecated VS Code setting |
| `.github/instructions/tests.instructions.md` | 204 | new | replaces deprecated VS Code setting |
| `.vscode/settings.json` | 204 | edit | remove deprecated keys |
| `tests/test_copilot_instructions_sanity.py` | 201, 202 | new | CI lint for line/char count + forbidden phrases |
| `tests/test_axon_mcp.py` | 203 | new | MCP server round-trip |
| `tests/test_setup_copilot_axon.py` | 205 | new | shell setup detection |
