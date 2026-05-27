# CD·GAP·C3·P1 — governance composition (U-5)

> Multiple gates exist (safety/rules, dont-do, study staleness, plan filters, pr-ready strict). They overlap. This designs the precedence + composition model so they don't contradict.

## Gates inventory

| Gate                                        | Owner           | Scope                       | Mode                |
|---------------------------------------------|-----------------|-----------------------------|---------------------|
| `safety/rules.md` (programmatic)            | project         | any program output           | hard veto / annotate |
| `dont-do.md` (heuristic)                    | project         | suggestion lists             | filter              |
| `study staleness` flags (R5)                | project         | pr-ready, plan input         | warn                |
| `_index.md` study presence                  | project         | plan, pr-ready, study        | require / warn       |
| `pr ready --strict`                         | project         | PR merge readiness           | hard veto           |
| Kernel-level: `L:dev-mode`                  | kernel          | writes to axon/              | hard veto           |
| Memory operational-safety (e.g. push gate)  | user-memory     | any agent action             | hard veto           |
| AGENT contract / Copilot instructions       | repo            | every turn                   | persona/process     |

## Conflict scenarios

1. `safety/rules.md` says "no new deps". User asks `plan` to add Redis.
   - Plan filters; annotates rejected option.
2. `dont-do.md` says "avoid mocks in integration tests". `pr` flow generates mock fixtures.
   - Should filter/warn — but suggestion vs hard?
3. Study staleness flag warns "auth study 90d old"; user runs `pr ready --strict`.
   - Strict mode escalates warn → block.
4. User memory says "no push without explicit yes"; `pr publish` would push.
   - User memory blocks at the agent layer (we never call git push without "yes").
5. Two rules contradict: rule-A "minimize deps", rule-B "use vetted libs over hand-rolling".
   - Need explicit precedence or QUERY user.

## Precedence model (proposed)

Top → bottom (higher = wins):

1. **Kernel rules** (axon/KERNEL-SLIM.md core rules) — non-negotiable.
2. **User-memory operational-safety rules** — non-negotiable.
3. **`safety/rules.md`** — project hard rules.
4. **`pr ready --strict` constraints** — gate-mode escalators.
5. **`_index.md` required studies** — block if absent (in strict).
6. **Study staleness flags** — warn (block in strict).
7. **`dont-do.md`** — soft preferences; filter & annotate.
8. **Plan heuristics / model preference** — lowest.

When two rules at the same level disagree:
- `safety/rules.md` rules tagged `priority: <int>` — higher wins.
- Untagged rules: HALT with QUERY listing the conflict.

## Composition format

`workspace/programs/code-dev-plan-master.cmp.md` (and similar) must:
- Load all active rule files.
- Build a *constraint set*.
- Pass it into the planner.
- Annotate each candidate option:
  - `accepted` (no conflict)
  - `filtered` (failed hard veto) — log reason
  - `flagged` (soft conflict) — keep but warn
  - `conflict` (rules contradict) — HALT or escalate

Output section appended to each plan:
```markdown
## Governance trace
- Loaded: safety/rules.md (7 rules), dont-do.md (12 entries), _index.md (3 stale)
- Filtered options: 2 (R-3 no-new-deps, R-7 no-vendored-binaries)
- Flagged options: 1 (auth study stale > 60d)
- Conflicts: 0
```

## Strict-mode escalator

`--strict` (or `code-dev rules strict on`) flips:
- Soft warn → hard block.
- Stale > 60d → hard block.
- Conflicts → HALT (no auto-resolve).
- Logs every decision to `_actions.log`.

## Where strict mode applies

- `pr ready --strict` — main consumer.
- `plan` can be invoked with `--strict` for production-track plans.
- `code-dev study --strict` — refuse stale baseline.

## Rule lifecycle

```
add    → code-dev rules add "<text>" [--priority N]
list   → code-dev rules list
edit   → code-dev rules edit <id>
remove → code-dev rules remove <id>
audit  → code-dev rules audit    # find contradictions, dead rules, unused
```

`audit` cross-references rules to PRs/plans they affected (via `_actions.log`).

## File schema for `safety/rules.md`

```yaml
---
schema: rules-v1
---

- id: R-1
  text: "No new top-level dependencies without justification."
  priority: 100
  scope: plan, pr
  added: 2026-05-16

- id: R-2
  text: "All public APIs documented before merge."
  priority: 90
  scope: pr
  ...
```

## Acceptance criteria

- `safety/rules.md` schema documented.
- Precedence model in `workspace/AXON-DOCS-GOVERNANCE.md` (NEW).
- `code-dev rules audit` detects synthetic contradictions in test fixtures.
- `plan` and `pr ready` emit governance-trace section.
- Strict mode is an explicit flag, not implicit.

## Open questions
- Should rules be lintable / parsable, not free-form? (Probably yes — adopt the YAML schema above.)
- Should multiple `safety/rules.md` files be supported per project (e.g. per-area)? — Defer to v5.
- Inheritance across projects (shared rules at workspace level)? — `workspace/safety/rules.md` global + project override. Add to v5.

→ session / chat / handoff deep dive: `cd-gap-c3-p2-session-model.md`.
