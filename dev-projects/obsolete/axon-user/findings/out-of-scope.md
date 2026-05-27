# Out-of-scope feature requests

Personas may ask for new features. They are recorded here for posterity
and **not actioned**. The axon-user project is improve-only.

| date       | persona | request                                                                  | reason out-of-scope                                  |
|------------|---------|--------------------------------------------------------------------------|------------------------------------------------------|
| 2026-05-16 | P5      | Add a `test_programs_md::test_header_matches_filename` rule              | new test = scope expansion; manual fix (U-1) suffices |
| 2026-05-16 | P4      | `chats list --project <slug>` cross-project flag                         | new feature surface; current spec is project-scoped   |
| 2026-05-16 | P4      | Real `state-save`/`state-restore` round-trip (snapshot _meta + phases/)  | new feature; PR-27 partner promise withdrawn (U-4)    |
| 2026-05-16 | P2      | Smart-default `slug` inferred from codebase dirname                      | new behavior; defer to future code-dev-new redesign   |
| 2026-05-16 | P1      | Three-step "quick boot" guide separate from full kernel                  | new doc; cheatsheet + tour already serve this role    |
| 2026-05-16 | P3      | `pr_drift` AST-aware acceptance matching (vs token-presence heuristic)   | new feature; F-013 token-empty fix is the improvement |
