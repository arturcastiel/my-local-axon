# F-011 — `code-dev-plan` declares blanket budget despite per-mode block

**personas**: P3 · **workflow**: W-04 · **severity**: S2
**date**: 2026-05-16 · **status**: open

## Reproduction

```bash
sed -n '1,15p' workspace/programs/code-dev-plan.md
# # budget:
# #   input-cap:    8000
# #   output-cap:   2000        ← single blanket cap
# #   cache-prefix: 2048
# # plan-modes:
# #   tactical:    {input-cap: 4000, output-cap: 6000}   ← exceeds blanket
# ...
```

## Observed

`tactical` and `decision` modes declare `output-cap: 6000/4000` which exceeds the
blanket `output-cap: 2000`. `budget_lint` accepts both blocks but doesn't compare.

## Expected

`budget_lint` errors when per-mode caps exceed blanket, OR the program drops the
blanket cap in favor of mode-specific.

## Proposed edit

Two options:

1. Extend `tools/budget_lint.py`: when `# modes:` block is present, require each
   mode's caps ≤ blanket × 4 (or remove blanket requirement).
2. Edit `code-dev-plan.md` and `code-dev-study.md` to remove the blanket
   `output-cap` line when per-mode block is present.

Recommended: option 2 (simpler, no tool change). 2-line edit each.

## Rationale

Currently the blanket cap is a lie — modes routinely exceed it. Documentation
drift fix.
