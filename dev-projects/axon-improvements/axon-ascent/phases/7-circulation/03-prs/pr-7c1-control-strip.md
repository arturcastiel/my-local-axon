---
glossary:   AXON-GLOSSARY
audience:   tier-A
version:    1
---

# PR-7c1 — control-strip (intent queue · anchor render · sparing tip)

**Phase**: 7-circulation
**Depends-on**: R_PROJECT_ANCHOR (shipped, c4a8508) · the queue concept · OUTPUT-LAYER
**Blocks**: PR-7c2 (the anticipation layer drives this strip)
**Wave**: surface · **Reversibility**: reversible (additive; default-compact)
**Domain**: system · **dev-mode required**: no · **Status**: merged (tno/main 1f074fd; kernel footer 35c6e54)

## Goal
Statement:  A compact, **adaptive** output strip that fixes rapid-fire ordering-blur
            and keeps the work thread visible — composed of: (1) an **intent queue**
            (stacked directives enqueued in order, surfaced as in-flight / next /
            depth, popped on completion); (2) the **R_PROJECT_ANCHOR focus line**
            (`focus · step · queue-depth`); (3) a **sparing rotating tip**.
Acceptance: `tools/intent_queue.py` exists + registered, with `add` / `done` /
            `list` / `render`; `render` emits one strip whose **density adapts**
            (full when queue deep or context complex; one line for a single thread;
            empty when idle) honoring OUTPUT-LAYER compact|full|minimal; the queue is
            FIFO + stable; the tip surfaces at most 1-in-N renders, never every turn.
Rejection:  full strip every turn (noise); tip every turn; queue not ordered/stable;
            any default-on auto-injection landing without the OUTPUT-LAYER (kernel) wire.

## Blast radius (I-05)
Affected:   `tools/intent_queue.py` (new) · `workspace/tools/intent-queue.md` (doc shim) ·
            `tools/REGISTRY.json` (+1 entry) · `tests/test_intent_queue.py` (new).
Kernel touch: ONLY the auto-injection of the strip into the response footer —
            `axon/OUTPUT-LAYER.md` (human-merge, shared with 7c2). The tool + on-demand
            `render` are autonomous; the always-on footer is the kernel half.

## Tests (mandatory)
- enqueue preserves order; `done` pops the right item; `list` is stable.
- `render` density: deep queue → full; single item → one line; empty → "".
- tip cadence: not present on consecutive renders (≤ 1-in-N).
- adaptive verdict matches the OUTPUT-LAYER mode input.

## Rollback (I-04)
`rm tools/intent_queue.py workspace/tools/intent-queue.md tests/test_intent_queue.py`;
`git checkout tools/REGISTRY.json`; revert the OUTPUT-LAYER footer block (kernel).

## Notes
Rides R_PROJECT_ANCHOR (the anchor) + the existing queue concept — **do not duplicate**;
extend if a queue primitive already exists. Adaptive density is the whole point: silence
/ brevity is the default, fullness earned by complexity. PR-7c2 decides that density by
confidence. Split: ship the tool (autonomous) now; the footer auto-inject is a kernel draft.
