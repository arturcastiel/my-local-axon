# Phase prohibitions — 1-design

_(seeded from _dont-do-seeds.md on phase start)_

- Never edit anything inside `axon/` — this project lives in `workspace/`.
- Never silently rename a memory key without surfacing it.
- Never assume a W: key exists without a documented upstream writer.
- Do not add `W:` keys that only the runtime sets but no program documents.
