# F-013 — `pr_drift.py` token heuristic silently passes criteria with no ≥4-char tokens

**personas**: P3 · **workflow**: W-05 · **severity**: S2
**date**: 2026-05-16 · **status**: open

## Reproduction

`tools/pr_drift.py` extracts tokens with `re.findall(r"[a-z][\w_\-]{3,}", item.lower())`.

For acceptance criteria like:
- "Fix bug in Y" → no 4+ char tokens (`fix`, `bug`, `Y` all short) → empty list → `continue` → criterion treated as **met** by default
- "Add x" → same
- "Rename a → b" → only "rename" qualifies; matches accidentally

## Observed

Short, generic acceptance criteria slip past drift detection.

## Expected

When token-extraction returns empty, the criterion is flagged as **un-checkable**,
not silently met.

## Proposed edit

In `tools/pr_drift.py` after the empty-token check:

```diff
- if not toks:
-     continue
+ if not toks:
+     unmet.append({"criterion": it, "reason": "no checkable tokens"})
+     continue
```

3-line change.

## Rationale

Prevents false-positives in `pr-drift`. Single source of truth: a criterion that
can't be checked must surface, not auto-pass.
