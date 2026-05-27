# Project-wide prohibition seeds

These entries seed each new phase's `_dont-do.md` on `code-dev phase start`.

- DO NOT modify `axon/` files as part of the study output. All proposals land in `workspace/programs/` or `workspace/tools/` or as new kernel rules to be reviewed by the owner with `L:dev-mode = true`.
- DO NOT propose solutions that are purely behavioral ("the agent should remember to..."). Every proposal must be a mechanical guard, a program, a tool, or a schema change. Behavioral guidance has already failed — that is the entire premise of this study.
- DO NOT reframe the incident as a single-trigger event. The drift had four missed guards (coherence guardian, R_REASONING_TRACE, interrupt gate, write gate). Solutions must address the class, not just the trigger.
- DO NOT touch `/mnt/c/projects/harness/` (the input artifacts). That folder is read-only forensic evidence.
