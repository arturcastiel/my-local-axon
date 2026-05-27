# CD·C1·P1 — tools called by code-dev programs

> Frequency analysis from `grep TOOL(...) workspace/programs/code-dev*.md`. Identifies which lower-level tools the code-dev surface depends on, and where caching / batching would help.

## Frequency table
| Tool              | ~Calls | Where it shows up | Purpose |
|-------------------|-------:|-------------------|---------|
| `shadow`          | 15+   | study, plan, pr, pr-review, explain, audit, log, preflight, shadow itself | content-addressed source mirror |
| `shell`           | 40+   | nearly all programs | git (branch, status, diff, log, grep, rev-parse, show-toplevel), find, linters |
| `clock`           | ~12   | all marker/log writers | ISO timestamps |
| `calculator`      | ~5    | resume, since, metrics | duration math (session age, hours since last) |
| `semantic-search` | 2     | init, plan | seed index + plan-time codebase scan |
| `document-parser` | 0 (referenced) | study (URLs/PDFs) | not directly invoked yet — deferred |
| `validator`       | 0 (referenced) | preflight gate 8 | linter dispatch through shell |
| `index`           | 0 in code-dev | — | code-dev uses its own internal indexes (`05-branches.md`, etc.) |

## Shadow — primary perf lever
**Operations** (from `tools/shadow.py`):
- `init <shadow-dir>` — seed dir, write `_meta.json`
- `check <src>` — hash match? returns `hit` / `miss` / `stale` / `branch-stale`
- `append <src>` — write findings file (YAML header + sections: summary, structures, dependencies, arch-role, findings)
- `stats <shadow-dir>` — counts: fresh / stale / branch-stale
- `list / stale / show / scan / clear` — manage entries
- `hash <src>` — git-commit-hash (preferred) or sha256 fallback
- `symbols <src>` — extract function/class names (heuristic, language-agnostic)

**Hit/miss economics:**
- HIT  = match git-hash → load `.findings.md` → ~50–300 tokens
- MISS = full source read + analyze + append findings → 1000–8000 tokens
- One-time cost; subsequent identical-commit reads are HIT-only.

**Gate programs:**
- `code-dev` main: surface stale count at session start
- `code-dev-preflight` Gate 1: warn if `stale > 0`
- `code-dev-next` Moment 6: suggest `shadow refresh` if `stale > 5`

## Shell — uncached, repeated
Every program that needs git state shells out. No caching. Within a single program call you can see 3–8 git invocations: `branch --show-current`, `status --porcelain`, `diff --stat`, `log -n …`, `rev-parse --show-toplevel`, `grep -l …`.

**Observation:** Same `git -C <codebase> branch --show-current` is called by `code-dev`, `code-dev-resume`, `code-dev-branch`, `code-dev-status`, `code-dev-preflight` Gate 0 — each session may invoke 5–10 times. **Cycle 3 candidate:** session-scoped cache keyed on `(codebase, mtime(.git/HEAD))`.

## Clock — cheap, ubiquitous
Used for: SESSION markers, log entries, ADR headers, snapshot filenames, `_events.log` entries, "since" calculations. Not a perf concern but a source of timestamp drift if AXON's clock and codebase's git commit timestamps disagree (rare).

## Calculator — duration math
- `code-dev-resume`: hours since last `SESSION START`
- `code-dev-since`: time since previous invocation
- `code-dev-metrics`: avg PR cycle time, avg rounds per PR

## semantic-search — bounded use
Only `code-dev-init` (seed index for the codebase) and `code-dev-plan` (codebase-wide search for plan generation). The shadow index is the primary substitute during PR-spec authoring.

## Sub-EXEC chains (intra code-dev)
Programs calling other programs (not tools):
```
code-dev-preflight   →  code-dev-scope-check
                     →  code-dev-self-review --check-only
                     →  code-dev-suggest-tests --check-only

code-dev-review      →  same 3 (scope / self / suggest-tests)
code-dev-partition   →  code-dev-divide | code-dev-combine
code-dev-hold        →  code-dev-freeze
code-dev-pr-ready    →  code-dev-preflight  (then emit push cmd)
code-dev-whatif      →  EXEC(target, dry-run)
code-dev (router)    →  any of 56 sub-programs
```

## Tools NOT used by code-dev (potentially should be)
| Tool             | Why it could help |
|------------------|-------------------|
| `igap`           | code-dev workflows generate many low-confidence moments (no instruction for X-language Y-pattern); they aren't surfaced to igap |
| `events` (bus)   | `_events.log` is a flat file, not wired to the kernel event bus; programs could `EMIT(pr-merged)` to trigger cascade/changelog automatically |
| `usage`          | code-dev never records usage; frequency-based compile suggestions never see code-dev workloads |
| `dispatch`       | free-text "fix the PR" doesn't dispatch to a code-dev program — kernel-level dispatch unaware of code-dev verbs |
| `auto-improve`   | no code-dev hooks; compile/tune cycles don't measure code-dev runtime |
| `cron`           | no scheduled code-dev jobs (e.g. nightly shadow refresh, weekly metrics) |
| `pattern`        | could mine `_events.log` for repeating drift signatures |

## Cross-links
- → `cd-c1-p3-gaps.md` — integration gaps with the kernel substrate
- → `cd-c2-p1-internals.md` — deep dive into shadow / preflight / pr-review
- → `cd-c3-p1-tokens.md` — token cost of repeated shell/shadow operations
