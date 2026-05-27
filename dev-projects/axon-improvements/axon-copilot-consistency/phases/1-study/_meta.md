# Phase: 1-study
schema-version: v4
status:         active
workflow-step:  study
branch:         feature/pr-ca-102-axon-reanchor
current-pr:     (none — study output is markdown only)
created:        2026-05-20

## Working Context

Four research axes (all in scope):

1. **Codebase audit** — `workspace/harness/copilot.md`,
   `.github/copilot-instructions.md`, `.vscode/settings.json`, sibling project's
   phase-1 outputs, `startup.md` Copilot section, kernel boot sequence.
2. **Online: Copilot extension points** — Copilot CLI flags / config,
   `.github/copilot-instructions.md` spec (2026), VS Code Copilot Chat custom
   instructions slots, agent-mode tool-use rules, MCP-on-Copilot status.
3. **Online: tool-calling behavior** — known issues with Copilot Opus not
   invoking shell/Python tools, system-prompt size limits, instruction-priority
   ordering.
4. **Diff vs Claude Code** — list what CC harness gives (UserPromptSubmit hook,
   persistent output style, subagent persona) and map each to a candidate
   Copilot equivalent or workaround.

Phase ends when 01-study.md exists with all four sections populated, citations
or file paths included, and the user signs off on it.
