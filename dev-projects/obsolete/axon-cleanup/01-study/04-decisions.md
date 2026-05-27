# axon-cleanup — user decisions (study-gate)

Captured 2026-05-17 after L1/L2/L3 review.

| # | Question | Decision |
|--|--|--|
| **Q1** | chromadb / semantic-memory stack | **Drop entirely** if no impact — confirm with one final grep during Wave 2 PR-0, then remove. |
| **Q2** | Dependency declaration style | **`pyproject.toml [project.optional-dependencies]`** — modern; separates core/dev/tests. |
| **Q3** | Project scope | **One project, separate waves** — axon-cleanup carries Wave 0 → 1 → 2 → 3. |
| **Q4** | `generated/compiled/` snapshot + `test_compiled_regression.py` | **Keep + CI regenerate** — CI re-runs `compile_optimizer` and asserts the committed snapshot matches. |
| **Q5** | Behavioural fixtures (5 empty dirs) | **Defer** to a follow-up project (`axon-fixtures` later). |

These decisions are load-bearing for the plan in `02-plan.md`.
Any change needs to update the plan + the affected PR specs.
