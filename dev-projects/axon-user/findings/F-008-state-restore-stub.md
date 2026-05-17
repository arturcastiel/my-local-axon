# F-008 — `code-dev-state-restore.md` is a 7-line stub with no restore logic

**personas**: P4 · **workflow**: W-06 · **severity**: S1
**date**: 2026-05-16 · **status**: open · **related**: F-007

## Reproduction

```bash
wc -l workspace/programs/code-dev-state-restore.md
# ~12 lines
```

Body only calls `TOOL(session, transition, "--from frozen --to active --tag {tag}")` —
which (a) uses unsupported flags (F-006) and (b) doesn't actually copy any
project files back from a checkpoint.

## Expected

Symmetric counterpart to `state-save`. See F-007 option 1: drop the file entirely
since `state-save` aliases `tag` and tag has built-in rewind.

## Proposed edit

`git rm workspace/programs/code-dev-state-restore.md` plus remove from
REGISTRY/snapshots.

## Rationale

Removes a vestigial stub that promises a feature AXON doesn't provide.
