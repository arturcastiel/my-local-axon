# F-007 — `code-dev-state-save.md` body is a verbatim copy of `code-dev-tag.md`

**personas**: P3, P4 · **workflow**: W-06 · **severity**: S1
**date**: 2026-05-16 · **status**: open · **related**: F-001

## Reproduction

```bash
diff workspace/programs/code-dev-state-save.md workspace/programs/code-dev-tag.md
# (tag.md is now a rewrite-to-stub; state-save.md is the pre-stub copy of old tag.md)
```

The PR-27 rename copied `tag.md` to `state-save.md`. The body implements
**tag/checkpoint semantics**, not the "save project state for later restore"
contract documented in PR-27's spec and `code-dev-state-restore.md`'s desc.

## Observed

There is no distinct `state-save` implementation. The save/restore round-trip
required by F-008 doesn't exist.

## Expected

Two options:
1. **Accept**: `state-save` = `tag` (alias relationship). Update PR-27 spec and
   delete `code-dev-state-restore.md` (tag has its own rewind).
2. **Implement**: `state-save` writes a full project snapshot
   (`_meta.md` + `phases/`) into `archive/state-checkpoints/<tag>/`;
   `state-restore` restores from there.

## Proposed edit (option 1 — minimal)

Edit [code-dev-state-save.md#L1-L8](../../../../workspace/programs/code-dev-state-save.md#L1):

```diff
- # PROGRAM: code-dev-tag
- # desc:    Phase 5 — capture a named milestone (snapshot project state)
+ # PROGRAM: code-dev-state-save
+ # desc:    alias for code-dev-tag — milestone snapshot of project state
```

And delete `code-dev-state-restore.md` (it's a 7-line stub anyway — F-008).

## Rationale

Option 1 keeps the umbrella rename surface (`state-save` is discoverable) without
inventing new save/restore semantics. Pure improvement, no new feature.
