# CD·WF·C3·P2 — concrete rename proposal

> Builds on Round-3's umbrella plus the name-collision catalog. Every existing program gets either: kept-as-is, renamed, or retired.

## Naming axioms (proposed)

1. **Verb-first.** Every user-typed command starts with a verb-or-noun-acting-as-verb (`pr`, `review`, `state`, `journal`, `flow`, `safety`, `shape`, `knowledge`, `lifecycle`, `meta`).
2. **Single-word subcommands** when possible (`create`, `update`, `respond`, `ready`, `list`, `show`, `archive`, `sync`, `import`, `export`, `replay`).
3. **Hyphens only for true compound nouns** (`update-spec`, `suggest-reviewer`). Never for `verb-noun` (always two words: `pr respond`).
4. **No two top-level verbs share a prefix** ≥ 3 chars (avoids dispatch ambiguity).
5. **Shared sub-verb lexicon** across all top-level verbs: `list, show, create, update, delete, archive, sync, export`.
6. **Modes use `--mode=`** not separate verbs (`review --mode=diff` not `code-dev-diff`).
7. **Sub-routers** are top-level verbs with no required subcommand → they print help.
8. **Avoid jargon in top-level** (`whatif` → `dry-run`; `dont-do` → `safety rule`).

## Renames (compact table)

| Today                              | After rename                              | Why                              |
|------------------------------------|-------------------------------------------|----------------------------------|
| `code-dev-status`                  | `code-dev state show`                     | sub of state, "show" lexicon     |
| `code-dev-next`                    | `code-dev state next`                     | sub of state                     |
| `code-dev-resume`                  | `code-dev state resume`                   | sub of state                     |
| `code-dev-handoff`                 | `code-dev state handoff`                  | sub of state                     |
| `code-dev-metrics`                 | `code-dev state metrics`                  | sub of state                     |
| `code-dev-tag`                     | `code-dev state save <label>`             | clearer verb                     |
| `code-dev-tag rewind`              | `code-dev state restore <label>`          | symmetric with save              |
| `code-dev-undo`                    | `code-dev state undo`                     | sub of state                     |
| `code-dev-log`                     | `code-dev journal log`                    | sub of journal                   |
| `code-dev-decision`                | `code-dev journal decision`               | sub of journal                   |
| `code-dev-event`                   | `code-dev journal event`                  | sub of journal                   |
| `code-dev-search`                  | `code-dev journal search`                 | sub of journal                   |
| `code-dev-since`                   | `code-dev journal search --since`         | flag, not verb                   |
| `code-dev-replay`                  | `code-dev journal search --patterns`      | flag, not verb                   |
| `code-dev-pr` (create flow)        | `code-dev pr create`                      | shared "create" lexicon          |
| `code-dev-pr-update-spec`          | `code-dev pr update-spec`                 | compound noun retained           |
| `code-dev-pr-link`                 | `code-dev pr link`                        | sub of pr                        |
| `code-dev-pr-respond`              | `code-dev pr respond`                     | sub of pr                        |
| `code-dev-pr-review`               | `code-dev pr review`                      | sub of pr — distinct from `review` |
| `code-dev-pr-ready`                | `code-dev pr ready`                       | sub of pr                        |
| `code-dev-pr-github`               | `code-dev pr sync` (or `pr github`)       | "sync" matches gh/gt/sl lexicon  |
| (new)                              | `code-dev pr list`                        | aggregator (G-I1)                |
| (new)                              | `code-dev pr show N`                      | per-PR detail view               |
| (new)                              | `code-dev pr archive N`                   | end-of-life                      |
| (new)                              | `code-dev pr import --from <path>`        | bridge from library-dev/manual   |
| (new)                              | `code-dev pr export N`                    | offline review packet (G-I11)    |
| (new)                              | `code-dev pr stack {new|restack|push|list}` | stacked PRs (G-I2)            |
| (new)                              | `code-dev pr drift N`                     | spec drift (G-I9)                |
| (new)                              | `code-dev pr suggest-reviewer N`          | CODEOWNERS (G-I5)                |
| `code-dev-review`                  | `code-dev review` (router/default)        | unchanged top-level, modes added |
| `code-dev-scope-check`             | `code-dev review --mode=scope`            | mode                             |
| `code-dev-self-review`             | `code-dev review --mode=self`             | mode                             |
| `code-dev-suggest-tests`           | `code-dev review --mode=tests`            | mode                             |
| `code-dev-diff`                    | `code-dev review --mode=diff`             | mode (retire-stub)               |
| (new)                              | `code-dev review --mode=coverage`         | coverage delta (G-I3)            |
| `code-dev-plan`                    | `code-dev flow plan`                      | sub of flow                      |
| `code-dev-plan-master`             | `code-dev flow plan --epic`               | flag, not verb                   |
| `code-dev-merge`                   | `code-dev flow merge`                     | sub of flow                      |
| `code-dev-cascade`                 | `code-dev flow cascade`                   | sub of flow                      |
| `code-dev-changelog`               | `code-dev flow changelog`                 | sub of flow                      |
| `code-dev-test-map`                | `code-dev flow test-map`                  | sub of flow                      |
| (new)                              | `code-dev flow finalize`                  | release/tag composer             |
| `code-dev-phase-new`               | `code-dev shape phase new`                | sub of shape                     |
| `code-dev-phase-start`             | `code-dev shape phase start`              | sub of shape                     |
| `code-dev-partition merge/split`   | `code-dev shape partition merge/split`    | sub of shape                     |
| `code-dev-combine`                 | (retired → `shape partition merge`)       |                                  |
| `code-dev-divide`                  | (retired → `shape partition split`)       |                                  |
| `code-dev-link`                    | `code-dev shape link`                     | distinct from `pr link`          |
| `code-dev-study`                   | `code-dev knowledge study`                | sub of knowledge                 |
| `code-dev-shadow`                  | `code-dev knowledge shadow`               | sub of knowledge                 |
| `code-dev-impact`                  | `code-dev knowledge impact`               | sub of knowledge                 |
| `code-dev-explain`                 | `code-dev knowledge explain`              | sub of knowledge                 |
| `code-dev-reviewer-track`          | `code-dev knowledge reviewer-track`       | sub of knowledge                 |
| `code-dev-explain-reviewer`        | `code-dev knowledge reviewer-track --history` | flag                         |
| `code-dev-freeze`                  | `code-dev safety freeze`                  | sub of safety                    |
| `code-dev-hold thaw`               | `code-dev safety thaw`                    | symmetric verb                   |
| `code-dev-dont-do`                 | `code-dev safety rule {add|list|...}`     | renamed to "rule"                |
| `code-dev-preflight`               | `code-dev safety preflight`               | sub of safety                    |
| `code-dev-audit`                   | `code-dev safety audit`                   | sub of safety                    |
| `code-dev-check-structure`         | `code-dev safety audit --structure`       | flag                             |
| `code-dev-new`                     | `code-dev lifecycle new` (also accept `code-dev new`) | sub of lifecycle      |
| `code-dev-init`                    | `code-dev lifecycle init`                 | sub                              |
| `code-dev-load`                    | `code-dev lifecycle load`                 | sub                              |
| `code-dev-tour`                    | `code-dev lifecycle tour`                 | sub                              |
| `code-dev-whatif`                  | `code-dev meta dry-run` (alias: `whatif`) | clearer industry-wide name       |
| `code-dev-help`                    | `code-dev help` (router/default)          | unchanged                        |
| (new)                              | `code-dev meta cheatsheet [verb]`         | tldr-style                       |
| (new)                              | `code-dev meta board`                     | ASCII Kanban (G-I8)              |
| (new)                              | `code-dev meta all-prs`                   | cross-project view (G-M2)        |
| (new)                              | `code-dev meta context use <slug>`        | project switcher (G-M1/G-I10)    |

## Net surface

- **Top-level verbs (final):** 10 (`lifecycle`, `state`, `journal`, `pr`, `review`, `shape`, `safety`, `knowledge`, `flow`, `meta`) + 1 dispatcher (`code-dev`).
- **Sub-commands (final):** ~55 (vs 57 today). NEW capabilities: ~12. Retired: ~12 (folded into flags or stubs). Renamed-only: ~30.
- **Stub period:** 1 release. After, ~12 file deletions.

## Shared sub-verb lexicon (after rename)

| Verb     | Used by                                       |
|----------|-----------------------------------------------|
| `list`   | pr, meta (all-prs), safety (rule list), shape (phases), journal? |
| `show`   | pr, state, knowledge, meta                   |
| `create` | pr, shape (phase new — still uses "new")     |
| `update` | pr (update-spec)                              |
| `delete` | (rarely used; archive preferred)              |
| `archive`| pr                                             |
| `sync`   | pr                                             |
| `export` | pr                                             |
| `import` | pr                                             |
| `next`   | state                                          |
| `save` / `restore` | state                                |
| `freeze` / `thaw`  | safety                              |

## Discoverability win

Today a user must memorize 57 program names. After rename:
- Memorize 10 verbs.
- Each verb's `--help` lists ~5–11 subcommands.
- Free-text dispatch picks the right verb in one hop.

→ category proposal (umbrella names + descriptions) in `cd-wf-c3-p3-categories.md`.
