# F-001 — PR-26/27/28 renamed files retain OLD `# PROGRAM:` header

**personas**: P3-careful-cassie, P5-meta-mira · **workflows**: W-06, W-10, W-14 · **severity**: S1
**date**: 2026-05-16 · **status**: open

## Reproduction

```bash
head -1 workspace/programs/code-dev-state-save.md
# → "# PROGRAM: code-dev-tag"   (expected: code-dev-state-save)

head -1 workspace/programs/code-dev-review-scope.md
# → "# PROGRAM: code-dev-scope-check"
```

24 renamed files affected (full list in [INDEX.md](INDEX.md#the-big-one--f-001)).

## Observed

Every PR-26 / PR-27 / PR-28 rename used `shutil.copy2(old, new)` which copies
the file body verbatim. The `# PROGRAM:` declaration on line 1 still names the
**old** program. If the dispatcher or `call_graph.py` keys on the header rather
than the filename, every rename silently dispatches to the old slug.

## Expected

Line 1 of each renamed file matches `# PROGRAM: <filename-without-.md>`.

## File / line citation

- [workspace/programs/code-dev-state-save.md](../../../../workspace/programs/code-dev-state-save.md#L1)
- ...23 more in `INDEX.md`

## Proposed edit

Single sweep:

```python
for new_slug, old_header in MAPPING.items():
    p = Path(f"workspace/programs/{new_slug}.md")
    text = p.read_text()
    text = text.replace(f"# PROGRAM: {old_header}", f"# PROGRAM: {new_slug}", 1)
    p.write_text(text)
```

24 files × 1 line each. No new files, pure header fix.

## Rationale

Root-cause of W-06, W-10, W-14 failures. Cheapest possible fix unblocks ~30%
of the simulated workflows.
