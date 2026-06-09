# PR-W3 — fix the stale self-review neuron reference in 4 canonical workflows

- **Status:** in-progress
- **Phase:** 2-harmonize  ·  **Complexity:** S  ·  **dev-mode:** no (workspace/domains/ + tests/)  ·  **Depends on:** none
- **Source:** MR !141's `check-stale` surfaced 4 missing-neuron findings — `code-dev.canonical` /
  `cpp-code-dev` / `python-code-dev` / `library-dev.canonical` s4 reference `code-dev-self-review`, which is
  not a neuron. The real s4 self-review neuron is **`code-dev-review-self`** ("Agent reads PR diff vs spec
  acceptance criteria; reports gaps") — the workflows carried a word-order drift.

## Fix
- Rename `name: code-dev-self-review` → `name: code-dev-review-self` in the 4 workflows (the existing neuron).
- NOT in scope (deliberately): the 5th check-stale finding `adaptive-free-text.s1 → synapse-suggest` is a
  TOOL-backed synapse (false-positive) → W2's tool-aware check-stale refinement. The 8 check-templating hits
  (`library-dev.canonical` reuses `code-dev-*` neurons) all resolve to EXISTING neurons → cross-domain reuse
  that works at runtime; a domain-purity decision, not a runtime bug → deferred (assess in W2).

## Acceptance
1. 0 `code-dev-self-review` remain; all 4 workflows reference the existing `code-dev-review-self`. [test_workflow_stale_neurons.py]
2. Existing workflow schema/suite/reference validators stay green; `crucible gate` passed:true.

## Changes
- `workspace/domains/code-dev/workflows/`{code-dev.canonical, cpp-code-dev, python-code-dev}`.yml` ·
  `workspace/domains/library-dev/workflows/library-dev.canonical.yml` · `tests/test_workflow_stale_neurons.py`
