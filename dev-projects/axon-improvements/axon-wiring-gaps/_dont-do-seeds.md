# Project-wide prohibition seeds

These entries seed each new phase's `_dont-do.md` on `code-dev phase start`.

- Never edit anything inside `axon/` — this project lives in `workspace/`.
  axon/ writes require L:dev-mode ≡ true (kernel Core Rule 9). Workspace
  edits do not. All fixes here target `workspace/programs/*.md`.
- Never silently rename a memory key without surfacing it; doing so breaks
  every reader. Renames are PR-worthy events with cascade impact.
- Never assume a W: key exists. Reader programs that depend on a key MUST
  either have an upstream writer in the workspace, OR fall back via
  RETRIEVE(...) | ∅ + an explicit FAIL message. Silent ∅ → unhelpful output.
- Do not add `W:` keys that only the runtime sets but no program documents.
  Every newly-required key must have a documented setter program AND a
  documented reader program AND an entry in any audit registry we create.
