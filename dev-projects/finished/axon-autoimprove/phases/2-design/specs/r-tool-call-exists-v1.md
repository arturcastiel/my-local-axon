# R_TOOL_CALL_EXISTS Spec (v1)

> glossary: AXON-GLOSSARY v2
> closes:   FA-16 (orchestrator references non-existent TOOL subcommands), B-10 (orchestrator-broken-tool-refs)
> resolves: D-A27 (lint rule for full TOOL call shape), D-AUTO-004 (where the rule lives)
> sibling:  `tools/rules/r_tool_exists.py` (checks name) — this spec adds shape check on top

## Purpose

Today, `workspace/programs/orchestrator.md` calls three TOOL subcommands
that do not exist:

| Site                           | Call                                                  | Real subcommands                                  |
|--------------------------------|-------------------------------------------------------|----------------------------------------------------|
| `orchestrator.md:53`           | `TOOL(usage, recent)`                                 | `record / aggregate / top / suggest / prune / find-program` |
| `orchestrator.md:54`           | `TOOL(pattern, clusters)`                             | `top / cluster / suggest` (note: singular)        |
| `orchestrator.md:146`          | `TOOL(dispatch, fire, ...)`                           | `match / index / feedback / stats / correlate`    |

`tools/rules/r_tool_exists.py` already verifies the **tool name** is in
the ACTIVE/OPTIONAL registry. It silently accepts any subcommand — so
these three calls pass the lint and only fail at the agent's runtime
dispatcher, where the failure is recoverable (each call has a `| {}` or
`| []` fallback) and therefore invisible. The orchestrator has been
silently degraded since the rename of those subcommands.

This spec installs `R_TOOL_CALL_EXISTS` — a second STATIC rule that
verifies the **subcommand** of a `TOOL(name, action, ...)` call resolves
to a real argparse subparser inside `tools/<name>.py`.

## Non-goals

- NOT a runtime guard. The rule fires at program-load time only (same
  phase as `r_tool_exists`).
- NOT a type-checker for TOOL arguments. Only the first positional
  (subcommand) is validated. Flag values (`--workspace foo`) are out of
  scope.
- NOT a coverage tool. Tools without subparsers (single-action tools
  like `clock`) are skipped, not warned.
- NOT a rewrite of the tool inventory. Subcommands are discovered by
  AST-parsing each `tools/<name>.py`, not by maintaining a hand-curated
  registry. Same source-of-truth rule as `r_tool_exists`.

## Contract — `tools/rules/r_tool_call_exists.py` v1

### Rule shape (matches existing rules)

```python
phase    = "STATIC"
severity = "BLOCK"
rule_id  = "R_TOOL_CALL_EXISTS"

def check(ctx) -> Optional[Violation]:
    ...
```

### Detection algorithm

1. Read `ctx["program_text"]` line-by-line, skip comments and
   output-literal lines (`→ "..."`) — same skip rules as
   `r_tool_exists.py`.
2. Regex-match the **first two positional args** of each TOOL call:
   ```
   TOOL\(\s*([a-zA-Z_][\w-]*)\s*(?:,\s*["']?([a-zA-Z_][\w-]*)["']?)?
   ```
   Capture group 1 = tool name; group 2 = subcommand (may be absent).
3. If group 2 is absent → skip (no subcommand asserted; existing
   `r_tool_exists` covers the name check).
4. If group 2 is `--flag` shape (starts with `-`) → skip (the tool has
   no subparsers; the call passes a flag as the first positional).
5. Resolve `tools/<name_normalized>.py` where
   `name_normalized = name.replace("-", "_")` (e.g. `dispatch-stats` →
   `dispatch_stats.py`). If the file is absent → defer to
   `r_tool_exists` (don't double-report).
6. Use a cached AST scan (`_subcommands_of(tool_name)`) to collect the
   set of registered subparser names. Source pattern:
   ```python
   ast.Call(func=ast.Attribute(attr="add_parser"), args=[ast.Constant(value=<name>)])
   ```
7. If the tool's subparser set is **empty** → skip (single-action tool;
   subcommand assertion is a no-op).
8. If the captured subcommand is **not** in the set → emit a Violation
   with the close-match suggestion:
   ```
   reason = (
     f"TOOL({name}, {sub}) — '{sub}' is not a subcommand of {name}. "
     f"Did you mean: {top3_difflib_matches}?"
   )
   ```

### AST scan cache

```python
# module-level, cleared per process
_SUBCOMMAND_CACHE: dict[str, frozenset[str]] = {}

def _subcommands_of(tool_name: str) -> frozenset[str]:
    if tool_name in _SUBCOMMAND_CACHE:
        return _SUBCOMMAND_CACHE[tool_name]
    path = AXON_ROOT / "tools" / f"{tool_name.replace('-', '_')}.py"
    if not path.exists():
        _SUBCOMMAND_CACHE[tool_name] = frozenset()
        return _SUBCOMMAND_CACHE[tool_name]
    tree = ast.parse(path.read_text("utf-8"))
    names = set()
    for node in ast.walk(tree):
        if (isinstance(node, ast.Call)
            and isinstance(node.func, ast.Attribute)
            and node.func.attr == "add_parser"
            and node.args
            and isinstance(node.args[0], ast.Constant)
            and isinstance(node.args[0].value, str)):
            names.add(node.args[0].value)
    out = frozenset(names)
    _SUBCOMMAND_CACHE[tool_name] = out
    return out
```

Cache is process-local. Tests clear it via a `clear_cache()` helper.

### Registry integration

Append `r_tool_call_exists.check` to `tools/rules/registry.py`
`_collect_rules()`:

```python
from . import r_tool_call_exists
return [
    ...,
    r_tool_exists.check,
    r_tool_call_exists.check,   # NEW
    ...,
]
```

Both rules fire on the same context. `r_tool_exists` blocks first when
the **name** is unknown; `r_tool_call_exists` blocks when the name is
known but the subcommand is wrong. They never double-report (rule 5
above defers).

## Storage

- No persistent state. The AST cache is process-local.
- No new files in `workspace/` or `MYAXON_ROOT/`.

## Integration

### Programs touched

`workspace/programs/orchestrator.md` ships three fixes alongside the
rule (so the rule fires green on main):

1. Line 53: `TOOL(usage, recent)` → `TOOL(usage, top, "--window", "1d")`
   (closest semantic match; `recent` was historically `top` with a
   default window).
2. Line 54: `TOOL(pattern, clusters)` → `TOOL(pattern, cluster)`
   (typo — pluralized at some rename).
3. Line 146: `TOOL(dispatch, fire, ...)` → `TOOL(dispatch, match, ...)`
   piped to the agent's own execution layer. `dispatch fire` was a
   planned action that never landed; `match` returns the synapse, the
   orchestrator already loops with the candidates, and the agent fires
   the chosen one through normal program-call semantics.

Rationale lives in the PR-AUTO-212 body, not in the spec — the spec only
mandates that orchestrator be made green.

### Programs intentionally untouched

Any program that uses TOOL calls with no subcommand (e.g.
`TOOL(clock)`) — these are skipped by rule step 3.

### Lint surface

`docgen-strict` (CI) loads each program via the existing
`tools/rules/registry.py:run_static` path. The new rule runs there
unchanged.

## Test plan — `tests/test_r_tool_call_exists.py`

Hermetic, monkeypatching `r_tool_call_exists.AXON_ROOT` to a tmp dir
with synthesised `tools/<name>.py` files.

| # | Test | Asserts |
|---|------|---------|
| 1 | `test_valid_subcommand_passes` | `TOOL(usage, top)` against synthesized usage.py with `top` subparser → no violation |
| 2 | `test_invalid_subcommand_blocks` | `TOOL(usage, recent)` → Violation with rule_id `R_TOOL_CALL_EXISTS`, severity BLOCK |
| 3 | `test_suggestion_in_reason` | Violation reason includes a "Did you mean: top, ..." hint via difflib |
| 4 | `test_no_subcommand_skipped` | `TOOL(clock)` → no violation even though clock.py has no subparsers |
| 5 | `test_flag_first_positional_skipped` | `TOOL(axon-audit, "--section", "X")` — second arg starts with `-` → skipped |
| 6 | `test_single_action_tool_skipped` | Tool file with no `add_parser` calls → any subcommand passes (skipped) |
| 7 | `test_unknown_tool_defers_to_r_tool_exists` | `TOOL(nonexistent, foo)` → no violation from THIS rule (delegated) |
| 8 | `test_hyphen_in_tool_name_resolves` | `TOOL(dispatch-stats, precision)` → resolves to `dispatch_stats.py` |
| 9 | `test_output_literal_line_skipped` | Line `→ "TOOL(usage, recent)"` → not linted (doc example) |
| 10 | `test_ast_cache_isolation` | Two consecutive checks with cache cleared in between use fresh AST scan |

## PR map

- **PR-AUTO-212** — adds `tools/rules/r_tool_call_exists.py`, registers
  it, fixes the three orchestrator lines, ships the 10 tests.
  Single PR — rule and fixes ride together so main never has a red
  static check.

## Closes / Resolves

- FA-16  — orchestrator references non-existent TOOLs (fixed in
  orchestrator + future regressions blocked at static phase).
- B-10   — same.
- D-A27  — "we need a lint rule for full TOOL call shape" — resolved.
- D-AUTO-004 — "where does the rule live? new file under tools/rules/
  or extend verify.py?" — **resolved**: new file alongside the existing
  `r_tool_exists.py`. Symmetry with the existing rule is the deciding
  factor; `verify.py` is a runtime check, this is a STATIC lint.

## Open questions

None. The deferred design choice (D-AUTO-004) is resolved above.

## Out of scope for v1

- Validating flag *values* (e.g. `--window 7d` shape).
- Validating TOOL calls inside `.py` files (rule is .md-program-scoped
  via the existing `program_text` context key).
- A `--fix` mode that rewrites mistaken subcommands automatically.
