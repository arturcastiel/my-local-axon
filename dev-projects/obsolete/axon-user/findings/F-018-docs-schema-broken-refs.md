# F-018 — `docgen_verify` reports 3 broken refs in AXON-DOCS-SCHEMA.md

**personas**: P5 · **workflow**: W-15 · **severity**: S3
**date**: 2026-05-16 · **status**: open

## Reproduction

```bash
python3 tools/docgen_verify.py
# {
#   "ok": false,
#   "violations": [
#     {"doc": "workspace/AXON-DOCS-SCHEMA.md", "missing": "../templates/v4-meta.md"},
#     {"doc": "workspace/AXON-DOCS-SCHEMA.md", "missing": "../programs/code-dev-migrate.md"},
#     {"doc": "workspace/AXON-DOCS-SCHEMA.md", "missing": "../templates/v4-meta.md"}
#   ]
# }
```

## Observed

Three dead links in `AXON-DOCS-SCHEMA.md`. The `templates/v4-meta.md` is in
`workspace/templates/`; the link uses `../templates/v4-meta.md` (one level too
shallow). `code-dev-migrate.md` doesn't exist (PR-28 absorbed migrate elsewhere).

## Expected

Doc cross-refs resolve.

## Proposed edit

In `workspace/AXON-DOCS-SCHEMA.md`:

```diff
- ../templates/v4-meta.md
+ templates/v4-meta.md
- ../programs/code-dev-migrate.md
+ programs/code-dev-state-restore.md      (or remove the ref if migrate is gone)
```

(verify with `python3 tools/docgen_verify.py` after.)

## Rationale

Improvement to existing doc, no new content.
