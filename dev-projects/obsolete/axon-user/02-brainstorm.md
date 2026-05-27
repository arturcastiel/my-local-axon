# 02-brainstorm — adjustments grouped by program

Improvement-only ideas. No new programs, tools, or doc files. Cross-refs to
findings in [findings/](findings/).

## `workspace/programs/` — renamed-file headers (24 files)

**One sweep fixes the entire S1 cluster.** See F-001.

```python
import re
from pathlib import Path

MAPPING = {
    # filename : old header to replace
    "code-dev-state-save.md":          "code-dev-tag",
    "code-dev-state-status.md":        "code-dev-status",
    "code-dev-state-undo.md":          "code-dev-undo",
    "code-dev-state-resume.md":        "code-dev-resume",
    "code-dev-state-handoff.md":       "code-dev-handoff",
    "code-dev-state-metrics.md":       "code-dev-metrics",
    "code-dev-review-scope.md":        "code-dev-scope-check",
    "code-dev-review-self.md":         "code-dev-self-review",
    "code-dev-review-tests.md":        "code-dev-suggest-tests",
    "code-dev-review-diff.md":         "code-dev-diff",
    "code-dev-safety-audit-structure.md": "code-dev-check-structure",
    "code-dev-safety-audit.md":        "code-dev-audit",
    "code-dev-safety-preflight.md":    "code-dev-preflight",
    "code-dev-safety-freeze.md":       "code-dev-freeze",
    "code-dev-knowledge-explain.md":   "code-dev-explain",
    "code-dev-knowledge-impact.md":    "code-dev-impact",
    "code-dev-knowledge-shadow.md":    "code-dev-shadow",
    "code-dev-knowledge-reviewer-track.md": "code-dev-reviewer-track",
    "code-dev-journal-log.md":         "code-dev-log",
    "code-dev-journal-event.md":       "code-dev-event",
    "code-dev-journal-decision.md":    "code-dev-decision",
    "code-dev-journal-search.md":      "code-dev-search",
    "code-dev-lifecycle-tour.md":      "code-dev-tour",
    "code-dev-pr-create.md":           "code-dev-pr",
}
base = Path("workspace/programs")
for new_name, old_header in MAPPING.items():
    p = base / new_name
    text = p.read_text(encoding="utf-8")
    new_text = text.replace(
        f"# PROGRAM: {old_header}\n",
        f"# PROGRAM: {new_name.removesuffix('.md')}\n",
        1,
    )
    p.write_text(new_text, encoding="utf-8")
```

## `code-dev-review.md` — router

- Add `IF sub ≡ "diff" OR sub ≡ "all" → EXEC(code-dev-review-diff)` branch (F-010).
- Rename the `"gaps"` branch to `"self"` (or have `code-dev-self-review` stub
  STORE `"gaps"`) — current state has the stub forwarding `mode=self` while the
  router branches on `sub=gaps` (F-009).

## Absorbed-alias stubs (5 files)

- `code-dev-scope-check.md`, `code-dev-self-review.md`, `code-dev-suggest-tests.md`,
  `code-dev-diff.md`, `code-dev-check-structure.md`.
- Replace `EXEC(code-dev-review --mode=X $@)` with:
  ```
  STORE(W:code-dev-review-sub, "X")
  EXEC(code-dev-review)
  ```
- This makes the alias actually scope the review.

## `code-dev-pr-ready.md`

- Drop Gate A (branch-sync) — preflight already does it (F-014).
- Update Gate C to call `code-dev-safety-preflight` directly, removing the
  alias-stub WARN spam (F-003).

## `code-dev-state-restore.md`

- Delete the file. PR-27 promised a partner; the implementation is a stub. We
  accept `state-save = tag` semantics (F-007/F-008) so restore is `tag --rewind`.

## `code-dev-state-save.md`

- Fix `# PROGRAM:` header (F-001).
- Optional: tweak `# desc:` to say "alias for code-dev-tag" if we accept aliasing.

## `code-dev-chats.md`

- Rewrite the `switch` block to use `--path/--state` (F-006).
- Rewrite the `list` block to either:
  (a) call `TOOL(session, list, --dir ...)` once `tools/session.py` grows that command (F-005), or
  (b) directly read `_session.md` files via a small inline walker.

## `tools/session.py`

- Add `list_sessions(session_dir)` + CLI subcommand `list --dir <path>` (F-005).
- Keep `transition()` signature stable; the program-side fix (F-006) is cheaper.

## `tools/pr_drift.py`

- When `toks` is empty, append the criterion to `unmet` with
  `reason="no checkable tokens"` (F-013). 3-line edit.

## `tools/cheatsheet_gen.py`

- Widen table column from 54 → 76 chars, add word-boundary truncation (F-015).

## `workspace/programs/code-dev-plan.md` + `code-dev-study.md`

- Drop the blanket `# budget: output-cap` line when `# modes:` block exists, or
  add a comment marking the modes block as the authoritative override (F-011, F-019).

## `workspace/programs/code-dev-journal-{log,event,decision}.md`

- Add a one-line `# when:` after `# desc:` for each (F-012). No behavioral change.

## `workspace/programs/code-dev-new.md`

- Add `default="1-design"` to the `first-phase` QUERY (F-017).
- Optionally expand the slug example to mention `e.g. my-cool-app` (F-017).

## `startup.md`

- Prepend a one-block "Reader gate" disambiguating AGENT/USER paths (F-016).

## `workspace/AXON-DOCS-SCHEMA.md`

- Fix 3 dead cross-refs (F-018). Make `docgen_verify` green.

## Things explicitly NOT proposed

- No new programs.
- No new tools.
- No new tests beyond the existing suites.
- No new top-level docs.
- No new W: keys.
- The absent `# PROGRAM: == filename` test rule that *would* have prevented
  F-001 — would be a sensible new rule, but adding it counts as scope expansion.
  Filed under [findings/out-of-scope.md](findings/out-of-scope.md) for future
  consideration.
