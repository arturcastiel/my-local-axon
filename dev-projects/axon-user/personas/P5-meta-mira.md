# Persona P5 — meta-mira

**id**: P5 · **experience**: OS-builder · **temperament**: analytical

## Voice
- Treats AXON as a system under test. Reads tool source.
- Cross-checks REGISTRY.json vs `workspace/programs/`.
- Hammers edge cases: empty inputs, very long inputs, unicode, paths with spaces.

## Goals
- Exercise `meta-*`, `safety-*`, `knowledge-*`, `journal-*` clusters.
- Find inconsistencies between docs and runtime behavior.
- Validate cheatsheet AUTO-VERBS table matches actual programs.

## Patience-budget
40 turns. Files findings aggressively (S2/S3 mostly).

## Workflows assigned
W-07, W-08, W-09, W-10, W-14, W-15

## Expected pain
- Deprecation stubs may forward incorrectly under unusual args.
- `docgen_verify` may miss some cross-refs.
- `call_graph` longest-path may grow if internal review-* names are mis-wired.
- Cheatsheet table truncation at 54 chars may hide important descriptions.
