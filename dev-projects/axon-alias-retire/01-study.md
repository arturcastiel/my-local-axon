# Phase 1 — STUDY · axon-alias-retire

## Goal
Retire the 18 backward-compat ALIAS programs WITHOUT breaking old-name usage (F30).

## Current state (the finding, grounded)
F30 — 18 status:ALIAS programs forward to canonical (EXEC), code-dev.md routes through them (three-hop). Deleting them outright BREAKS anyone using the old names; there are no program-execution tests to catch a broken dispatch.

## Design
A deprecation CYCLE, not a delete: (1) build a program-dispatch test harness so a broken EXEC target is caught (closes the F05 execution-test gap for dispatch); (2) repoint code-dev.md routes to canonical; (3) keep aliases as loud WARN-deprecated for one release; (4) delete after the cycle.

## Methodology
Tests FIRST (the safety net F30 lacks), THEN repoint, THEN deprecate-warn, THEN delete next release. Each step gated. This is the riskiest project — the test harness is the gating prerequisite.

## Risk
Breaks old-name usage (program-layer, LLM-interpreted, no current execution test) — mitigated by the dispatch-test harness + a deprecation window. Do NOT skip the harness.

## Confidence
6/10 — needs the execution-test harness built first; highest risk of the five.

## Gate to PLAN
Owner confirms STUDY (or adds requirements). Per the discipline, PLAN numbers the PRs before any code.
