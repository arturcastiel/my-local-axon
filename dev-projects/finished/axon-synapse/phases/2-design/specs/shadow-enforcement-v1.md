# Shadow Enforcement Spec (v1)

> glossary: SYNAPSE-GLOSSARY v1
> resolves: F-016, D-011, D-23

## Purpose

Specify how shadow coverage becomes a first-class invariant: when shadow
must exist, who enforces it, how missing shadows are remediated.

## Invariant

> Every source-touching PR has a shadow file that exists, is non-empty,
> lists changed files, cites ≥ 1 finding (or links the PR-spec when none).
> Shadow coverage at audit time MUST be 100 % for the audit to pass.

Today's reality (F-016): 0 / 119 PRs have shadow files. Migration is
required.

## Enforcement points

### Gate 1: synapse contract `requires-shadow`

Every synapse contract may declare `requires-shadow: true`. Default for:

- Any program whose role is `mutator` AND whose outputs include source
  files.
- `code-dev-pr-create`, `code-dev-finalize`, all synapses that write to
  `<codebase>/`.

The orchestrator includes a **shadow obligation signal** in its ranker
(per orchestrator-composition-v1, weight 0.10). After a `requires-shadow`
synapse fires, `code-dev-knowledge-shadow` is boosted in the next-step
ranking.

### Gate 2: workflow file `acceptance` predicate

Workflow files for code-dev declare:

```yaml
default-goal:
  acceptance-criterion: "shadow.coverage(active-phase) == 100 AND ..."
```

The workflow cannot reach `met` status without 100 % coverage.

### Gate 3: `code-dev safety-audit` extension

`safety-audit` gains a `shadow-coverage` row in its report:

```
Shadow coverage:
  Phase 1-study:      n/a  (no source-touching PRs)
  Phase 3-implement:  18 / 21 PRs (86 %)
    Missing shadow:
      PR-005  files: [tools/dispatch.py, tools/pattern.py]
      PR-012  files: [tools/shadow.py]
      PR-017  files: [workspace/programs/auto-improve.md]
  → Run: code-dev-knowledge-shadow --pr 5,12,17
```

If `shadow.coverage(phase) < 100`, audit reports overall status FAIL.

### Gate 4: `code-dev finalize` (once implemented per F-012)

Pre-condition: shadow coverage 100 %. If any PR has missing shadow, FAIL.
Suggested next: bulk shadow run.

### Gate 5: `axon-audit` (project-level)

`axon-audit` includes a "Workflow-correctness" section reporting shadow
coverage % per active project. Surfaces in the menu as a `Shadow` line
(complementing the current `Backup` line) when coverage < 100 %.

## Programs (the actual writers)

### Canonical write path

`code-dev-knowledge-shadow` (per F-007 / F-012 canonical name):
- Invocation: `code-dev-knowledge-shadow --pr <N>`
- Reads: `<project>/phases/{phase}/03-prs/PR-{N}.md` (spec)
         `<project>/phases/{phase}/04-log.md` (log entries for PR)
         git diff for PR's branch
- Writes: `<project>/phases/{phase}/shadow/PR-{N}.findings.md`
- Calls: `TOOL(shadow, init / append, ...)` for each changed file
- Output: shadow file structure:
  ```
  # PR-007 — Shadow

  PR-spec:  phases/3-implement/03-prs/PR-007.md
  Branch:   main
  Commit:   <hash>
  Files:    [tools/dispatch.py, tools/pattern.py]
  Findings cited:
    - F-005 (synapse contract blocker — informed this PR)
    - F-014 (suggestion-engine prior-art — composition path)
  ```

### Alias path

`code-dev-shadow` (deprecated alias per F-012) forwards to
`code-dev-knowledge-shadow`. Per D-014, name preserved permanently.

### Bulk write path

`code-dev-knowledge-shadow --bulk-phase <phase>`:
- Iterates every PR in the phase.
- Writes missing shadows.
- Idempotent: existing shadows refreshed only if `--force`.

## Retroactive shadowing (for the 119 existing PRs)

Phase 3 PR seed: `shadow-retroactive-bulk` — one-shot migration.

Algorithm:
1. For each project (`axon-master`, `axon-tests`, etc.):
   1. For each PR file (`03-prs/PR-*.md`):
      1. If shadow file absent → generate one from:
         - git log for the PR's commits (if any).
         - PR-spec content (changed files declared).
         - Finding cross-refs in the PR-spec.
         - Auto-shadow inference: read each declared changed file's
           current state, compute hash, write findings stub.
      1. Write shadow file with `Provenance: retroactive` marker.
2. Run `axon-audit` to confirm coverage = 100 % per project.

This is a one-time cleanup PR; subsequent PRs maintain coverage via
the orchestrator gates above.

## Shadow file schema

```
# {PR-id} — Shadow

PR-spec:        <relative path>
Branch:         <git branch>
Commit:         <sha>
Files:          [list of changed file paths]
Provenance:     authored | retroactive | auto
Findings cited:
  - F-NNN (text)
  - F-NNN (text)

## Findings per file

### {file-path}
Hash:           <git blob hash>
Role:           {role-inferred-from-shadow-tool}
Structures:     <symbols, classes, functions>
Deps:           <imports, includes>
Architecture role: <text>

#### Findings log
[append-only entries]
```

## Tools (Phase 3 deliverables)

- `code-dev-knowledge-shadow` — already exists; extend with `--bulk-phase`
  and `--from-git-diff` modes.
- `shadow-retroactive-bulk` — new program; one-shot migration.
- `shadow-coverage-report` — new tool subcommand of `shadow stats`.
- `code-dev safety-audit` extension — emit shadow-coverage section.

## Validation

`shadow-validate` (a `shadow-coverage-report` mode):

```
INPUT:  project root
OUTPUT: coverage %, list of missing-shadow PRs, list of stale-hash shadows
```

Used by `axon-audit`, `code-dev safety-audit`, workflow `acceptance` evaluators.

## Performance

Shadow check is cheap: hash compare + file existence. Per-PR check < 10ms.
Project-wide check on 119 PRs < 2 seconds.

## Backwards compatibility (D-014 / D-025) + v1.1 flip protocol (FL-10)

- Existing PRs without shadow files do NOT immediately fail audit until
  the retroactive migration completes. Grace flag
  `L:shadow-enforcement-strict` (default false).

### Grace-flag flip protocol (v1.1 — closes FL-10)

The flag flips `false → true` **only** when ALL conditions hold:

1. `shadow-coverage-report --root <project>` returns `coverage == 100`
   for every active project, **twice consecutive ≥ 5 minutes apart**.
2. `axon-audit` shows zero shadow-related open findings across projects.
3. User-confirm via explicit command: `shadow-enforce strict`. A QUERY
   surfaces with current coverage stats; user must type `yes`.

On flip:
- `L:shadow-enforcement-strict-flipped-ts` recorded with ISO timestamp.
- `EMIT axon.shadow.enforcement-strict {ts, by-user, coverage-snapshot}`.
- Subsequent PR finalize gates hard-fail on missing shadow (no grace).

### Unflip path (last-resort)

Flag may revert `true → false` only under: `L:dev-mode == true` AND
explicit user command `shadow-enforce relax --reason "<text>"`. Logged
with rationale; surfaces in axon-audit as a regression flag.

## Version + change rule

**Version: v1 (2026-05-17).** Shadow file schema versioned in
`workspace/templates/shadow-v1.md`.
