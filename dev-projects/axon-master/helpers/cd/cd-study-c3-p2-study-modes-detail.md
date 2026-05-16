# CD·STUDY·C3·P2 — study modes: full design

> Per-mode spec with inputs, prompt skeleton, output structure, and acceptance criteria.

## Common contract (all modes)

**Inputs:**
- `--target <path-or-glob>` (optional; defaults vary)
- `--input <file>` (mode-specific data, e.g. coverage.json)
- `--diff [--since <duration|commit|last>]` (optional incremental)
- `--checkpoint` / `--resume`
- `--output engineering|executive|machine` (default: engineering)
- `--budget tokens=N` (optional)
- `--target-token-cap N` (hard cap; HALT)

**Outputs:**
- File: `study/<mode>.md` (or `study/<mode>-<query-hash>.md` for dataflow)
- Index update: `study/_index.md` append-only entry
- Journal: `journal event study.<mode> ...`

**Headers (every study file starts with):**
```
# study/<mode>.md
> mode: <mode>
> target: <target>
> generated: <ISO-8601>
> codebase-rev: <git-rev or mtime-hash>
> token-usage: <in/out>
> status: complete|partial
```

---

## Mode 1 — `overview`

**Default target:** entire codebase root.
**Reads:** top-level dirs, `README*`, `package.json` / `pyproject.toml` / etc.
**Output sections:**
- Subsystems table (name, path, one-liner, language, LOC est)
- Hot files (top-10 by size + root configs)
- Architecture sketch (1 paragraph)
- Open questions

## Mode 2 — `subsystem`

**Required:** `--target=<folder>`.
**Reads:** every file under target up to budget.
**Output sections:**
- Purpose
- Public surface (exported symbols / endpoints)
- Internal modules
- Data flows in/out
- External dependencies
- Tests
- Open questions

## Mode 3 — `security`

**Reads:** routes, controllers, auth, input handlers, secrets handling, env reads, deps with known CVE patterns.
**Output sections:**
- Auth surface (each entry-point + auth scheme)
- Input handling (each user-input source + sanitization)
- Secrets handling (env reads, encryption-at-rest, transport)
- OWASP-top-10 findings (per category)
- Severity rollup (counts per CRIT/HIGH/MED/LOW)
- Recommended PRs

## Mode 4 — `performance`

**Default target:** marked hot paths or `--target=<folder>`.
**Reads:** loops, IO, DB queries, allocations.
**Output sections:**
- Hot paths (sorted by qualitative risk)
- IO patterns (N+1 query candidates, blocking IO, sync-in-async)
- Big-O smells (nested loops, recursion)
- Caching opportunities
- Profiling hooks present
- Recommended PRs

## Mode 5 — `dependencies`

**Reads:** dependency manifests (requirements.txt, package.json, Cargo.toml, go.mod).
**Output sections:**
- BOM table (name, version, license, source)
- Outdated (vs latest stable)
- Vulnerabilities (CRIT/HIGH counts — heuristic if no scanner output supplied)
- License risk
- Transitive risk (any pinned-vs-floating)
- Removal candidates (unused deps)

**Optional input:** `--input <snyk-json|safety-json>` → integrate real CVE data.

## Mode 6 — `tests`

**Reads:** `test_*` / `*.test.*` files, optional coverage JSON.
**Output sections:**
- Test inventory (per module)
- Coverage (overall, per-file deltas if --diff)
- Untested modules (top-10)
- Slow tests (top-5 if coverage report has timing)
- Test patterns (parametrization, fixtures, marks)
- Recommended PRs

## Mode 7 — `api-surface`

**Reads:** exported symbols, public class/method signatures, route definitions.
**Output sections:**
- Public symbols (table; name, kind, signature, since-version)
- Stability annotations (stable / experimental / deprecated)
- Breaking changes since `--diff --since=<ref>`
- Semver verdict (patch/minor/major)
- Recommended changelog entries

## Mode 8 — `data-model`

**Reads:** schemas (SQL, Pydantic, Protobuf, OpenAPI), migrations, ORM models.
**Output sections:**
- Entities + fields (table)
- Relationships (FK, joins)
- Migrations (chronological)
- Invariants (declared constraints)
- Risk markers (nullable PKs, missing FKs, etc.)

## Mode 9 — `dead-code`

**Reads:** every source file; analyze references.
**Output sections:**
- Unreached exports
- Unreached internal symbols
- Files with no references
- Feature flags long-resolved
- Comment-blocked code

**Caveats:** LLM heuristic; HUMAN confirms before deletion.

## Mode 10 — `naming`

**Reads:** source files; identifier extraction.
**Output sections:**
- Inconsistent casing
- Synonyms used for the same concept
- Jargon / undefined acronyms
- Single-character non-loop vars
- Misleading names

## Mode 11 — `observability`

**Reads:** logging calls, tracing spans, metrics emissions, exception handlers.
**Output sections:**
- Log coverage (per module)
- Trace coverage
- Metrics catalog
- Silent failure modes
- Sampling / cardinality risks
- Recommended instrumentation PRs

## Mode 12 — `error-handling`

**Reads:** try/except/throw/catch/Result/Option patterns.
**Output sections:**
- Error taxonomy (custom exceptions / error types)
- Catch-and-swallow sites
- Retry patterns
- Circuit-breaker presence
- Recommended PRs

## Mode 13 — `dataflow`

**Required:** `--from <source>` `--to <sink>`.
**Reads:** caller graph + literal-tracking.
**Output sections:**
- Source point (file:line)
- Path (each hop: file:line + function)
- Transformations applied along the way
- Sink point
- Sanitization gaps (relevant if `--from` is user input)
- Confidence (HIGH/MED/LOW)

**Tips:** can be re-run with refined `--from` to chase a value.

## Mode 14 — `history`

**Optional input:** `--input <git-log-numstat>` (HUMAN provides).
**Reads:** git log JSON / numstat output, or HUMAN-paste fallback.
**Output sections:**
- Top-N most-churned files (last N days)
- Top-N most-modified by single author
- Risk = churn × complexity (heuristic)
- Frequently-co-edited file pairs (suggests architectural coupling)
- Recommended areas for `subsystem` deep-dive

## Acceptance criteria (per mode)

- Output respects token cap.
- Output has correct header.
- `_index.md` updated atomically (write to temp, rename).
- `journal event` emitted.
- Re-running with same inputs produces ≥ 80% identical output (idempotence target).
- Diff mode emits ONLY the deltas, not full re-walk.

## Recipes (canonical compositions)

In `workspace/study-recipes/`:

- `new-repo-onboarding.md` → overview, history, dependencies, api-surface, tests
- `pre-release-audit.md` → security, dependencies, tests, dead-code, observability
- `refactor-prep.md` → subsystem, naming, dead-code, tests, dataflow
- `brownfield-dd.md` → overview, history, dependencies, security, architecture, data-model
- `perf-hunt.md` → history, performance, dataflow, tests
- `quarterly-health.md` → overview, history, dependencies, tests (all in --diff)
- `bug-triage.md` → dataflow, error-handling, tests

→ implementation roadmap: `cd-study-c3-p3-implementation.md`.
