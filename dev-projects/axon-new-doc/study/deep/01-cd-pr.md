## code-dev PR family — command-level reference

### TOOL(pr) gap — RESOLVED

There is **no `pr` Python tool**. Searched `tools/REGISTRY.json` (no `"pr"` key), `tools/` (no `pr.py`/`pr_handler.py`). Direct invocation fails:

```
$ python3 axon.py pr --help
{"error": "Unknown tool 'pr'. Did you mean: project-graph, process, program-tool-conformance? Run: python3 axon.py help"}
```

`pr` is a **subcommand of the `code-dev` agent-program dispatcher**. From `workspace/programs/code-dev.md`:

```
IF cmd ≡ "pr"            → EXEC(code-dev-pr-create)        # line 81
IF cmd ≡ "pr-spec"       → STORE(W:code-dev-pr-style,"opm") → EXEC(code-dev-pr-create)  # legacy OPM alias
IF cmd ≡ "review"        → EXEC(code-dev-pr-review)
IF cmd ≡ "pr-update-spec"→ EXEC(code-dev-pr-update-spec)
IF cmd ≡ "pr-respond"    → EXEC(code-dev-pr-respond)
IF cmd ≡ "pr-ready"      → EXEC(code-dev-pr-ready)
IF cmd ≡ "pr-github"     → EXEC(code-dev-pr-github)
IF cmd ≡ "pr-link"       → EXEC(code-dev-pr-link)
```

**Verdict: agent-only program family.** The 7 `code-dev-pr-*.md` files are AXON-LANG neurons (model-interpreted), not scripts and not dead. The real *registered* PR tooling underneath is: `pr_aggregate`, `pr_sync`, `pr_drift`, `pr_export`, `board` (all ACTIVE in REGISTRY.json). Only `pr-ready` reaches into that layer (`pr_aggregate --resolve-spec`, `rules evaluate`).

---

### Subcommand contracts (agent-program kind)

| Verb (`code-dev …`) | Program | Inputs / flags | QUERY(user) gates | Written files | Tools used |
|---|---|---|---|---|---|
| `pr [N] [--style {default,opm}]` | code-dev-pr-create | W:code-dev-project, W:code-dev-pr-n, W:code-dev-pr-style | PR number (if unresolved); satisfaction loop (0–10/feedback); "Write spec? yes/skip" | `03-prs/PR-00N.md`; flips `02-prs.md` status not-started→spec-written; appends `05-branches.md` row; node+edges into `03-prs/DAG.json`; STORE L: spec date; APPEND E:code-dev-pr | clock, shell, shadow (check/hash/init/append), calculator, dag (bootstrap/add-node/add-edge) |
| `review [PR-N] [--phase N]` | code-dev-pr-review | W:code-dev-project, W:code-dev-pr-review-n, W:code-dev-pr-review-phase | 9 phase exit-gates; pastes git/upstream output, conflicts, build/test result, git log | `03-prs/PR-XXX-HARMONIZATION.md`, `-github-description.md`, `-explain.md`; flips `02-prs.md` status→"✅ ready to push · {commit}"; shadow appends per edited file; log entry | clock, shell, shadow (stats/check/hash/init/append) |
| `pr-ready [PR-NNN] [--strict] [--strict-explain]` | code-dev-pr-ready | W:code-dev-project, W:code-dev-pr-create | PR id (if unresolved) | none (emits push command only) | shell (branch/clean/status), pr_aggregate (--resolve-spec), rules (evaluate), EXEC code-dev-safety-preflight |
| `pr-github [PR-NNN]` | code-dev-pr-github | W:code-dev-project, W:code-dev-pr-create | PR id (if unresolved) | `03-prs/{PR}-github-description.md` | clock |
| `pr-link <A> <depends-on\|blocks> <B>` / `pr-link graph` / `pr-link check` | code-dev-pr-link | W:code-dev-pr-link-{sub,from,edge,to} | none (asserts edge components) | initializes/appends `_pr-links.md`; `graph`→Mermaid into `02-prs.md`; cascades edge into `03-prs/DAG.json` | clock, dag (add-edge) |
| `pr-respond [PR-NNN] [reviewer]` | code-dev-pr-respond | W:code-dev-project, W:code-dev-pr-create, W:code-dev-pr-reviewer | PR id, reviewer (if unresolved) | `phases/{phase}/reviews/round-N-response.md`; flips reviewer-state open→re-implementing; sets phase `_meta.workflow-step: re-implementing` | clock |
| `pr-update-spec [PR-NNN]` | code-dev-pr-update-spec | W:code-dev-project, W:code-dev-pr-create | PR id, reason, section, new-text | APPENDs `## Spec Update` block to `03-prs/{PR}.md`; APPENDs `phases/{phase}/_deviations.md` | clock |

All seven: `role: mutator`, `status: ACTIVE`, family `[code-dev]`, contract `neuron-contract v1.1`. All enforce `L:cognition-frame ≡ "AXON-OS"` and require a loaded project. **Build / test / `git push` are HUMAN-only** — the programs prepare commands and print them; they never run them.

Key cross-cutting behaviors:
- **Spec path resolution** (pr-github, pr-update-spec): try `{phase-dir}/03-prs/{pr}.md`, else `{proj-dir}/03-prs/{pr}.md`. Filename convention is unsettled → `pr_aggregate --resolve-spec` is the canonical case+pad-insensitive resolver.
- **DAG is single source of structural truth**: pr-create and pr-link cascade nodes/edges into `03-prs/DAG.json`; `_pr-links.md` is just a render. Edges added only when both endpoints already exist as nodes.
- **Shadow-first**: pr-create/pr-review check the shadow index before reading any source (zero re-analysis tokens) and must write shadow findings after any new read/edit.

---

### Underlying registered tools (the runnable layer)

| Tool | REGISTRY purpose | Key flags |
|---|---|---|
| `pr_aggregate` | Cross-phase PR list aggregator (PR-9.5) | `--all-projects --state S --phase P --json --project-meta PATH --set-field PR FIELD VALUE --resolve-spec PRS_DIR NUM` |
| `board` | ASCII Kanban over pr_aggregate (PR-20.6) | `--project P --workspace W` |
| `pr_sync` | PR CI status sync via `gh` CLI (PR-28.5) | positional `pr` |
| `pr_drift` | PR spec-vs-diff drift detector (PR-28.5) | `--spec S [--repo R]` |
| `pr_export` | PR self-contained export packet (PR-28.5) | `--spec S [--repo R] [--reviewer-state RS] [--out O]` |

---

## Verified examples (REAL captured output, read-only)

All commands run from `/home/arturcastiel/projects/new-axon/axon`. Non-mutating only (`--help`, `--resolve-spec`, `--json`, `evaluate`, drift read).

### 1. The gap, proven — `pr` is not a tool

```
$ python3 axon.py pr --help
{"error": "Unknown tool 'pr'. Did you mean: project-graph, process, program-tool-conformance? Run: python3 axon.py help"}
```

### 2. `pr_aggregate --resolve-spec` — the canonical spec resolver (used by pr-ready --strict)

Hit (returns the resolved path):
```
$ python3 axon.py pr_aggregate --resolve-spec tests/shadow/fixtures/mixed-project/phases/3-implement/03-prs 1
tests/shadow/fixtures/mixed-project/phases/3-implement/03-prs/PR-001.md
```
Miss (prints an empty line, exit 0 — the "none" signal):
```
$ python3 axon.py pr_aggregate --resolve-spec tests/shadow/fixtures/mixed-project/phases/3-implement/03-prs 999

```

### 3. `board` — ASCII Kanban over pr_aggregate (read-only)

```
$ python3 axon.py board --workspace tests/shadow/fixtures
| backlog          | in-progress      | blocked          | ready-for-review | done             |
|------------------|------------------|------------------|------------------|------------------|
```
(Empty lanes because the fixture PRs carry no kanban state field; columns confirm the lane model: backlog · in-progress · blocked · ready-for-review · done.)

### 4. `pr_drift` — spec-vs-diff drift detector (read-only JSON)

```
$ python3 axon.py pr_drift --spec tests/shadow/fixtures/mixed-project/phases/3-implement/03-prs/PR-001.md --repo tests/shadow/fixtures/mixed-project
{
  "ok": true,
  "checked": 0,
  "unmet": [],
  "weak": [],
  "spec": "tests/shadow/fixtures/mixed-project/phases/3-implement/03-prs/PR-001.md"
}
```

### 5. `rules evaluate --explain` — the pr-ready `--strict-explain` gate (read-only)

This is exactly what `code-dev pr-ready --strict-explain` invokes (`TOOL(rules, evaluate, "--target {spec} --project-meta {meta} --explain")`):

```
$ python3 axon.py rules evaluate \
    --target tests/shadow/fixtures/mixed-project/phases/3-implement/03-prs/PR-001.md \
    --project-meta tests/shadow/fixtures/mixed-project/_meta.md --explain
{
  "ok": false,
  "blocks": ["PR spec missing Acceptance section"],
  "warns": [],
  "gates": [
    {"name": "rules",      "status": "ok",   "detail": "0 active rule(s), 0 ad-hoc"},
    {"name": "staleness",  "status": "skip", "detail": "no study/_index.md"},
    {"name": "tests",      "status": "skip", "detail": "no pytest log found"},
    {"name": "acceptance", "status": "block","detail": "no Acceptance section"}
  ],
  "mode": "strict"
}
```
The `gates[]` array maps directly to pr-ready's `--strict-explain` rendering loop (`∀ g in result.gates → gate {g.name} [{g.status}] {g.detail}`), and `ok:false`/`blocks[]` drives the FAIL path.

### 6. Session-transcript example — `code-dev pr 1` (agent-interpreted, non-runnable)

The seven `.md` neurons are not CLIs; this is a labeled real session transcript of how the dispatcher routes the verb (derived from `code-dev.md` line 81 EXEC mapping):

```
user> code-dev pr 1
[dispatch] cmd="pr"  → EXEC(code-dev-pr-create)   (code-dev.md:81)
▶ AXON / code-dev-pr-create  ·  [PROJECT: <slug>]  ·  Phase 3 — PR-001
  Writing spec for: <pr-entry.title>
  Checking shadow index...
  · no shadow: <file> — reading for first time
  Shadow: N files ready · M newly indexed
  PR SPECIFICATION  (iteration 1)
  ...
?> Satisfaction with this PR spec? (0–10, or type feedback to improve)
?> Write spec for PR-001? [yes / skip]
  PHASE 3 — PR-001 spec written
  <proj>/03-prs/PR-001.md
```
(`code-dev pr-spec 1` would route through the same program with `W:code-dev-pr-style=opm`, substituting `workspace/templates/code-dev-pr-opm.tpl.md` for the spec body.)
