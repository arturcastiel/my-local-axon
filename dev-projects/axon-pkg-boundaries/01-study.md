# Phase 1 — STUDY · axon-pkg-boundaries

## Goal
Make tools/ a real package and kill the 49 sys.path.insert bootstraps (F21).

## Current state (the finding, grounded)
F21 — tools/ is a flat non-package with NO __init__.py; 49 tools do sys.path.insert to import siblings, so import order is load-bearing and there is no enforced public surface (one big ball).

## Design
Add tools/__init__.py (additive; pyproject already declares the package). Convert sibling imports `import X` → absolute `from tools.X import Y` (or relative) in CLUSTERS, deleting the per-file bootstraps as each cluster is converted.

## Methodology
1) PR: add tools/__init__.py, gate (pytest catches import-resolution breaks). 2) PRs: convert 10-15 files per batch by dependency cluster, gate each. 3) PR: delete remaining sys.path.insert + add a lint-test forbidding sys.path.insert in tools/. Always branch-first; the pytest gate is the safety net (Python, fully gate-protected).

## Risk
Import-resolution breakage — bounded: every break reds the pytest gate, so no bad merge. Batch small to localize. The hooks/ + rules/ packages already work as a model.

## Confidence
8/10 — gate-protected Python refactor; only risk is volume of churn.

## Gate to PLAN
Owner confirms STUDY (or adds requirements). Per the discipline, PLAN numbers the PRs before any code.
