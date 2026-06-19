# Project-wide prohibition seeds
# Seeded from workspace/working/axon-hr-gap-findings.md DONT-DO LIST
# These entries seed each new phase's `_dont-do.md` on `code-dev phase start`.

- DO NOT edit KERNEL-SLIM.md under any circumstances in this project
- DO NOT run `scripts/enable-enforcement.sh` autonomously — it changes settings.json
  which affects the Claude Code session; owner must confirm and run it explicitly
- DO NOT run git operations on the axon repo other than read (git log, git status,
  git diff) without the AEGIS grant being active
- DO NOT create test files that call real LLM APIs (use mocks or stubs)
- DO NOT merge any PR while crucible is red
- DO NOT treat the 4.1% compiled figure as a system-wide coverage number
  (it is project-scoped; use `coverage-gate report` for the real baseline)
- DO NOT delete or overwrite MYAXON.md — update the paths inside it only
- DO NOT assume workspace/memory/working/ files are authoritative — they may be stale;
  re-derive from live kv-store and file system
