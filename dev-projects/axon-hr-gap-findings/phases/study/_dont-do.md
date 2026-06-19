# Phase prohibitions — study
# (seeded from _dont-do-seeds.md)

- DO NOT edit KERNEL-SLIM.md under any circumstances in this project
- DO NOT run `scripts/enable-enforcement.sh` autonomously — owner must confirm
- DO NOT run git write operations without AEGIS grant active
- DO NOT create test files that call real LLM APIs (use mocks or stubs)
- DO NOT merge any PR while crucible is red
- DO NOT treat the 4.1% compiled figure as system-wide coverage
- DO NOT delete or overwrite MYAXON.md — update paths inside it only
- DO NOT assume workspace/memory/working/ files are authoritative — re-derive from live sources
- DO NOT skip reading the actual source file before writing a fix (study phase is for reading)
