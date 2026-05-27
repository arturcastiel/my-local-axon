# CD·WF·C3·P4 — web findings (CLI naming conventions)

> Naming-specific prior art and conventions. Validates the Round-4 rename proposal.

## Source 1 — Heroku CLI Style Guide (public)

Key rules:
- Verbs are imperative ("create", "destroy", "scale").
- Top-level verbs are nouns ("apps", "pg", "logs"); sub-commands are verbs.
- Use **two-word** combos: `heroku apps:create` (their colon syntax).
- Avoid jargon in top-level (`pg` is their one exception, well-known).

**Mapped:** our 10 umbrellas are mostly nouns (`pr`, `state`, `journal`, `knowledge`, `flow`, `shape`, `safety`, `meta`) and a couple of action-words (`review`, `lifecycle`). Match.

## Source 2 — Microsoft Command-Line Style Guide

- Use **kebab-case** for multi-word names.
- Avoid abbreviations unless industry-standard (`pr`, `ci`, `cd` OK).
- Sub-commands inherit parent verb's flags by default.

**Mapped:** our convention (`pr update-spec`, `safety rule add`) follows. `pr` is fine as abbreviation.

## Source 3 — GNU coreutils / POSIX naming

- Avoid `-l` for "list" if it could mean `--limit`. Spell out long forms.
- `-h` always = help.

**Mapped:** flags out of scope here, but: we should reserve `-h`/`--help` everywhere.

## Source 4 — `kubectl` taxonomy paper (cncf, 2019)

- Verbs ("get", "describe", "create", "delete", "logs", "exec") form a small fixed set.
- Resources are the noun axis.
- Power comes from verb × resource matrix predictability.

**Mapped:** we do *not* adopt verb×resource fully. Our structure is verb-cluster + sub-action. Acceptable because workflow ops aren't resource CRUD.

## Source 5 — `gh` (GitHub CLI) docs

- Always pair: `gh <noun> <action> [args]`.
- Never invent a new top-level for what's clearly an action on an existing noun.

**Mapped:** drives our rename of `pr-review` → `pr review`, `pr-ready` → `pr ready`, etc.

## Source 6 — Anti-pattern catalog (clig.dev "Command Line Interface Guidelines")

Cited anti-patterns:
- **Inconsistent argument order.** ✗ today: `pr-link 3 --depends-on 2` vs `tag rewind <label>`.
- **Magic global flags.** ✗ today: none — good.
- **Surprising side effects.** ✗ today: some — e.g., `init` mutates `_meta`.
- **Multiple ways to do the same thing.** ✗ today: `combine` vs `partition merge`. The rename retires duplicates.

**Mapped:** rename plan addresses 3 of 4. Side-effect doc is separate concern.

## Source 7 — Stripe API/CLI naming patterns

- Use **resource-action** not action-resource (`payment_intents.create`, not `create_payment_intent`).
- Reserve plain English verbs for *commands*; reserve nouns for *resources*.

**Mapped:** our umbrellas are mostly nouns (resources), sub-commands are actions. Match.

## Source 8 — Search engine for prior naming choices

- `pr` is universally accepted = pull request.
- `branch` not `br` (clarity).
- `repo` not `repository` (brevity).
- `merge` not `mr` (Gitlab calls them MRs; GitHub/users still say PR).

**Mapped:** we use `pr` (universal). Avoid `mr`. ✓

## Naming-rule synthesis (final ruleset adopted)

1. Top-level = noun cluster (sometimes a verb where the noun is awkward — `review`).
2. Sub-commands = imperative verbs (`create`, `update`, `respond`).
3. Compound nouns = hyphenated (`update-spec`, `test-map`, `reviewer-track`, `all-prs`).
4. Modes = `--mode=value`, not new verbs.
5. Booleans = `--<flag>`, no `--no-<flag>` unless inverting a documented default.
6. Avoid abbreviations except industry-standard (`pr`, `ci`).
7. No two top-level verbs may share a 3-char prefix.
8. Help text first sentence MUST start with imperative verb in third person ("Create…", "Show…", "Update…").
9. The verb `dispatch` is reserved for the kernel dispatcher; never user-facing.
10. The verb `help` is reserved at every level.

## Validation: does the rename proposal comply?

| Rule | Status                                                  |
|------|---------------------------------------------------------|
| 1    | ✓ — 10 umbrellas (8 noun, 2 verbal: `review`, `lifecycle`) |
| 2    | ✓ — sub-commands are verbs                              |
| 3    | ✓ — compound nouns hyphenated                           |
| 4    | ✓ — `review --mode=…`                                   |
| 5    | ✓ — no `--no-` flags introduced                         |
| 6    | ✓ — only `pr` abbreviated                               |
| 7    | check: `state` vs `safety` share `s` only — ✓; `flow` vs nothing — ✓; `shape` vs `safety` share `sa` — ✓ (2 chars only) |
| 8    | ✓ — desc lines start with imperative                    |
| 9    | ✓                                                       |
| 10   | ✓                                                       |

→ synthesis & roadmap in `cd-wf-c4-p1-synthesis.md`.
