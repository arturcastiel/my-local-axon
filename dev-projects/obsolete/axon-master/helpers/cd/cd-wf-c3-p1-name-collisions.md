# CD·WF·C3·P1 — name collisions and confusing names

> Forensic catalog of every confusing, ambiguous, or collision-prone name in the current 57-program set.

## Collision classes

### Class A — Near-synonyms (same concept, different name)
Two programs with conceptually overlapping verbs.

| Pair                                  | Confusion                                    |
|---------------------------------------|----------------------------------------------|
| `code-dev-status` / `code-dev-resume` | Both report "where am I"; users guess        |
| `code-dev-next` / `code-dev-resume`   | Both produce next-step suggestions           |
| `code-dev-search` / `code-dev-since`  | Both query the journal                       |
| `code-dev-search` / `code-dev-replay` | Both surface past actions                    |
| `code-dev-tag` / `code-dev-undo`      | Both relate to checkpointing                 |
| `code-dev-freeze` / `code-dev-hold`   | Both halt activity                           |
| `code-dev-audit` / `code-dev-check-structure` | Both validate state                  |
| `code-dev-diff` / `code-dev-review`   | Diff is part of review                       |
| `code-dev-pr-review` / `code-dev-review` | Two reviews; users guess which is which  |
| `code-dev-combine` / `code-dev-partition merge` | Same op, two names             |
| `code-dev-divide` / `code-dev-partition split`  | Same op, two names             |

### Class B — Overloaded words
Same word, different meanings depending on context.

| Word        | Meaning A                                | Meaning B                          |
|-------------|------------------------------------------|------------------------------------|
| `review`    | top-level: scope+self+tests              | `pr-review`: someone else's PR     |
| `link`      | `pr-link`: declare PR dependency         | `link`: connect plan items         |
| `phase`     | `phase-new`: create phase                | `pr-ready --phase N`: gate level   |
| `study`     | `code-dev study`: codebase walk          | `01-study.md`: project file        |
| `plan`      | `code-dev plan`: assemble PR plan        | `plan-master`: epic-level plan     |
| `partition` | `partition merge`: combine PR/phase rows | `partition split`: split           |
| `meta`      | Round-3 verb "meta" cluster              | `_meta.md` schema file             |

### Class C — Inconsistent casing / hyphens
| Inconsistency                          | Examples                                       |
|----------------------------------------|------------------------------------------------|
| Hyphen vs no-hyphen for compound verbs | `pr-update-spec` vs `plan-master`              |
| Verb-noun vs noun-verb                 | `pr-update-spec` (noun-verb) vs `phase-new` (noun-verb) vs `update-spec` (would be verb-noun) |
| Singular vs plural                     | `decision` vs `decisions/` directory           |
| Underscore vs hyphen                   | All programs use hyphen ✓ (consistent)         |

### Class D — Tense and mood inconsistency
| Issue                          | Example                                  |
|--------------------------------|------------------------------------------|
| Imperative vs noun             | `freeze` (imperative) vs `study` (noun)  |
| Present vs past                | `event` (noun) vs `decided` (would-be past) |
| Gerund                         | none — good ✓                            |

### Class E — Acronym / jargon
| Term            | Confusion                                          |
|-----------------|----------------------------------------------------|
| `ADR`           | Architectural Decision Record — assumed knowledge  |
| `cascade`       | What cascades? Changes? Reviews? Both?             |
| `impact`        | Impact of what — current diff? proposed change?    |
| `shadow`        | Why shadow? (cached invariants — not obvious)      |
| `dont-do`       | Verb form; reads awkwardly in `code-dev dont-do add` |
| `whatif`        | Borderline jargon — but `--dry-run` is clearer industry-wide |

### Class F — Multi-word noun-as-verb
| Program           | Issue                                                |
|-------------------|------------------------------------------------------|
| `code-dev-tour`   | Noun used as verb (start a tour) — fine             |
| `code-dev-handoff`| Noun used as verb — slightly off                    |
| `code-dev-changelog`| Noun used as verb — same                          |
| `code-dev-cascade`| Verb already — good                                 |

## Score: top-15 most-confusing names

| Rank | Name                  | Score | Why                                                  |
|-----:|-----------------------|------:|------------------------------------------------------|
| 1    | `code-dev-review`     | 9 | Conflicts with `pr-review`; users guess               |
| 2    | `code-dev-pr-review`  | 9 | Ditto, mirror                                         |
| 3    | `code-dev-hold`       | 8 | Overlaps with `freeze`; "hold" is also a sub-verb     |
| 4    | `code-dev-status`     | 8 | Overlaps with `resume`, `next`                        |
| 5    | `code-dev-next`       | 7 | Should be part of `status`                            |
| 6    | `code-dev-since`      | 7 | Should be a flag on `search`                          |
| 7    | `code-dev-replay`     | 7 | Should be a flag on `search`                          |
| 8    | `code-dev-diff`       | 7 | Should be a mode of `review`                          |
| 9    | `code-dev-combine`    | 6 | Should be `partition merge`                           |
| 10   | `code-dev-divide`     | 6 | Should be `partition split`                           |
| 11   | `code-dev-check-structure` | 6 | Should be flag of `audit`                        |
| 12   | `code-dev-explain-reviewer`| 6 | Should be flag of `reviewer-track`               |
| 13   | `code-dev-tag`        | 5 | "save/restore" reads clearer                          |
| 14   | `code-dev-plan-master`| 5 | Master means what? Should be `plan --epic`            |
| 15   | `code-dev-dont-do`    | 4 | Awkward grammar                                       |

## Cross-reference with Round-3 retire list
Round-3 retire candidates (8): `combine, divide, hold, since, replay, diff, check-structure, explain-reviewer`.

All 8 appear in the top-15 above. **The Round-3 plan resolves the worst offenders.** Adding to retire list:
- `code-dev-pr-review` (rename to subcommand of `pr`)
- `code-dev-review` (becomes `review` verb with modes)
- `code-dev-next` (folds into `state status`)
- `code-dev-tag` (folds into `state save/restore`)
- `code-dev-plan-master` (becomes `flow plan --epic`)
- `code-dev-dont-do` (folds into `safety dont-do`)

→ rename proposal detail in `cd-wf-c3-p2-rename-proposal.md`.
