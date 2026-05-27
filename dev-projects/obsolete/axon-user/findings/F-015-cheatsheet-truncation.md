# F-015 — Cheatsheet AUTO-VERBS truncates descriptions at 54 chars, cutting mid-word

**personas**: P5 · **workflow**: W-15 · **severity**: S3
**date**: 2026-05-16 · **status**: open

## Reproduction

```bash
sed -n '8,19p' workspace/AXON-DOCS-CHEATSHEET.md
# | `code-dev status`     | alias for code-dev-state-status; removed next release.|
# | `code-dev journal-log`| log implementation discoveries, modifications, and div|  ← cut
# | `code-dev pr-ready`   | branch verify + preflight + output push command (HUMAN|  ← cut
```

## Observed

`tools/cheatsheet_gen.py` line ~50 truncates at 54 chars.

## Expected

Either truncate at a word boundary, or widen to ~70 chars, or skip truncation
and let renderers handle width.

## Proposed edit

[tools/cheatsheet_gen.py L42-49](../../../../tools/cheatsheet_gen.py#L42):

```diff
- rows = ["| verb                          | what it does                                          |",
-         "|-------------------------------|-------------------------------------------------------|"]
+ rows = ["| verb                          | what it does                                                                  |",
+         "|-------------------------------|-------------------------------------------------------------------------------|"]
  ...
-     rows.append(f"| `code-dev {slug}` ".ljust(32) + "| " + verbs[slug][:54].ljust(54) + "|")
+     desc = verbs[slug]
+     if len(desc) > 76:
+         desc = desc[:73].rsplit(" ", 1)[0] + "…"
+     rows.append(f"| `code-dev {slug}` ".ljust(32) + "| " + desc.ljust(76) + "|")
```

## Rationale

Single-file UX improvement. No new feature.
