# CD·GAP·C2·P2 — schema migrator (U-2)

> Resolves G-CD-A1. Designs a versioned, idempotent migrator for `_meta.md` and project layout. Covers v1→v4 (existing gap) and v4→v5 (future stacks/sync).

## Problem statement

- axon-master is **schema v1** (bare `_meta.md`).
- `code-dev resume` HALTS on v1 because expected v4 fields are missing.
- No migrator exists. Without one:
  - Old projects can never be resumed.
  - Future schema bumps (v5 for stacks, sync, spec-history) become impossible.

## Versions

| Schema | Fields (key set)                                                           | Status         |
|--------|----------------------------------------------------------------------------|----------------|
| v1     | slug, codebase, status (sparse, free-form)                                 | live in wild   |
| v4     | adds: phase, last-program, pr-N blocks, _actions.log, decisions/, journal preface | current default |
| v4.1   | adds: `study/` folder + `_index.md` (Round-5 S0.1)                          | proposed       |
| v5     | adds per-PR: `stack-id`, `stack-position`, `last-sync`, `state`, `spec-history[]` | proposed (R4-R7/R9) |

## Migrator design

### File: `workspace/tools/migrate_meta.py` (or as an AXON program `code-dev-migrate.md`)

Inputs:
- Project root path.
- Optional `--target=<version>` (default: latest).
- `--dry-run` (preview only).
- `--backup` (default ON: copy `_meta.md` to `_meta.md.bak.<ts>`).

Output:
- Rewritten `_meta.md`.
- Per-step log to `04-log.md` ("schema upgrade v1→v4 at <ts>: added fields X, Y").
- Backup file.

### Step model

```
detected = detect_version(meta_text)
target = args.target or LATEST
chain = compute_chain(detected, target)   # e.g. [v1→v4, v4→v4.1]
for step in chain:
    transform = STEPS[step]
    meta = transform(meta)
    log(step.name, fields_added, fields_removed)
write_atomic(meta)
```

### `STEPS` table

| Step       | Action                                                                                       |
|------------|----------------------------------------------------------------------------------------------|
| v1→v4      | infer `phase` (default `1-bootstrap`); set `last-program` to last entry in `_actions.log` or `unknown`; create `_actions.log` if absent; create empty `pr-1` block stub IFF prior 02-prs.md references PR 1 |
| v4→v4.1    | create `study/` folder; if `01-study.md` exists, move to `study/overview.md` + leave 1-line redirect in `01-study.md`; create `study/_index.md` |
| v4.1→v5    | for each `pr-N`: add `stack-id: null`, `stack-position: null`, `last-sync: null`, `state: unknown`, `spec-history: []` |

### Idempotence
Each step checks "is this already applied?" before mutating. Running twice = no-op.

### Rollback
- `--restore` flag reads the backup file (`_meta.md.bak.<ts>`).
- Or: `git checkout` the unmodified file (HUMAN-only git).

### Atomicity
- Write to `_meta.md.tmp`, fsync, rename. Never partial write.

## Version detection heuristic

```
def detect_version(text: str) -> str:
    has_phase  = 'phase:' in text
    has_pr_blk = re.search(r'^pr-\d+:', text, re.M)
    has_study  = exists("study/_index.md")
    has_stack  = 'stack-id:' in text
    if has_stack: return 'v5'
    if has_study: return 'v4.1'
    if has_phase and has_pr_blk: return 'v4'
    return 'v1'
```

## CLI surface

```
code-dev migrate                          # implicit: detect → latest
code-dev migrate --target=v4              # halt before v4.1
code-dev migrate --dry-run                # show plan, no writes
code-dev migrate --restore                # roll back via last backup
```

After R3 umbrella ships, lives under `meta` or `lifecycle`:
```
code-dev lifecycle migrate [--target=...] [--dry-run] [--restore]
```

## Integration with resume

```
code-dev resume:
    v = detect_version(meta)
    if v < LATEST:
        QUERY(user, "Project is schema {v}; upgrade to {LATEST}? (y/n/dry-run)")
        if yes: EXEC(code-dev-migrate --target=LATEST)
    proceed with normal resume
```

## Test plan

- `tests/test_migrator.py`:
  - synthetic v1 fixture → assert v4 fields present.
  - v4 fixture → assert v4.1 fields present.
  - idempotence (run twice = same output).
  - rollback restores byte-exact.
  - dry-run produces report and zero file changes.
- Real fixture: axon-master's `_meta.md` (v1). Migration must produce a valid v4 file that `code-dev resume` accepts.

## Edge cases / risks

| Risk                                                | Mitigation                                              |
|-----------------------------------------------------|---------------------------------------------------------|
| v1 file has malformed YAML                          | parser tolerant; HALT with QUERY if unfixable           |
| User has hand-edited `_meta.md` between steps       | per-step `mtime` check; QUERY if surprise               |
| `_actions.log` missing fields                       | seed with synthetic "migration: created" entry          |
| 01-study.md is huge (single file > 50 KB)           | move as-is; let Round-5 study modes refactor later      |
| Migrator crashes mid-chain                          | partial backup preserved; resumable via `--restore`+rerun|

## Acceptance criteria

- axon-master migrates v1 → v4.1 cleanly.
- `code-dev resume` works post-migration.
- Re-running migrator is a no-op.
- Restore returns byte-exact original.
- Tests pass.
- Documentation in `workspace/AXON-DOCS-SCHEMA.md` (NEW file).

→ test surface for code-dev programs: `cd-gap-c2-p3-test-surface.md`.
