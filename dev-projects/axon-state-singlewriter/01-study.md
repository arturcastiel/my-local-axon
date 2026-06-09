# Phase 1 — STUDY · axon-state-singlewriter

## Goal
Single L:-writer + checkpoint captures JSON W: state without conflating snapshots (F43/F44).

## Current state (the finding, grounded)
F43 — memory.py and session_save.py both write L: keys + .rollback sidecars with DIVERGENT atomicity/newline behavior. F44 — checkpoint._read_working snapshots only .md, silently losing JSON W: state (intent-queue, crucible-last) on restore; snapshots live in working/ and get conflated with real W: json keys.

## Design
(1) Extract one atomic L:-write+rollback helper (the memory.py implementation); session_save delegates to it. (2) checkpoint captures .json W: keys too, and writes snapshots to working/.snapshots/ so list/_read_working stop conflating them; migrate existing snapshots.

## Methodology
1) PR: shared L:-writer helper; session_save delegates; test both write identical format. 2) PR: checkpoint .json capture + snapshot relocation + a migration for existing working/*.json snapshots; test restore round-trips intent-queue/crucible-last. Gate each.

## Risk
Storage-layout change + existing-snapshot migration — the migration must not orphan current snapshots. Gate-protected; add round-trip tests.

## Confidence
7/10 — clear design; the migration step needs care.

## Gate to PLAN
Owner confirms STUDY (or adds requirements). Per the discipline, PLAN numbers the PRs before any code.
