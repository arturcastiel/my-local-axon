# Project-wide prohibition seeds — axon-copilot-consistency

Seeded into each phase's `_dont-do.md` on `code-dev phase start`.

- **Never** commit changes to `axon/` without `L:dev-mode ≡ true`. Kernel writes
  go through the write gate. This project will touch `workspace/harness/` and
  `.github/` — those are NOT axon/ and are permitted, but kernel edits are not.
- **Never** test interventions only inside Claude Code. Every claim about
  "Copilot now does X" must be reproduced **inside Copilot itself** before it's
  accepted as a finding. (Sibling project lesson — phase-1 of `-anchor` was
  authored in Copilot, hence the trust gap.)
- **Never** propose interventions that depend on Copilot features we have not
  verified exist in 2026. Web-search citations or first-hand reproduction
  required. No "Copilot probably supports …" reasoning.
- **Never** assume the Copilot CLI and the Copilot IDE extension share the same
  extension points. Treat them as two separate harnesses; document each.
- **Never** sign commits or PRs from this project as Copilot. AXON identity
  only. (Inherited from `axon-copilot-anchor` goal #3.)
