# Study — study

_Run: code-dev study to populate this with the full synthesis._

## Goal (seed)
Incorporate the `hr-team` meta-neuron into this AXON repo as:
1. a new **menu mode "HR Team"**, and
2. a **flexible neuron** callable standalone AND embeddable by other workflows.

## Source material to ingest (handoff bundle — prior agent)
- `~/axon-hr-team/output/handoff/INDEX.md`      — 30-second navigation map (read first)
- `~/axon-hr-team/output/handoff/HANDOFF.md`     — master spec: §0–§16 + §V + §Z (~1,400 lines)
- `~/axon-hr-team/output/handoff/V-checklist.md` — 60+ machine-checkable verification checks
- `~/axon-hr-team/output/handoff/worked-examples/` — 5 end-to-end council walkthroughs
- `~/axon-hr-team/output/catalog/professions/_REGISTRY.md` — 151-row profession map
- `~/axon-hr-team/output/prompts/` — 63-file copy-paste prompt pack (personas/tiers/protocols/modes)

## What hr-team is (from handoff §1)
Meta-neuron: spawns a council of named professional specialists, runs a declared
protocol, returns a structured **advisory** verdict (ranked alternatives, dissents,
vote distribution, transcript, manifest, audit stream).
- 3-layer architecture: SELECTOR → CONVENER (opinion-neutral assembler) → DELIBERATOR.
- 3 invocation modes: M1 FULL (autonomous) · M2 FILTERED · M3 EXPLICIT.
- 3 catalogs: PROFESSIONS (151) · MODES (6 families + 20 presets) · PROTOCOLS (7).
- NOT runnable code in the bundle — §13 H1–H4 are the AXON-native integration recipes.

## Repo integration surface to map during study
- `workspace/programs/menu.md` — where the "HR Team" mode entry is wired.
- `workspace/programs/` — the council program(s) + sub-programs live here.
- `tools/REGISTRY.json` — if a tool (e.g. council runner) is registered.
- `workspace/workflows/` + workflow-runner — for embeddable/standalone callability.
- dispatch index / smart-dispatch — so natural-language requests route to it.
- Core Rule 13 — tests before ACTIVE.

## Open questions (seed — refine in study)
- Mode vs program vs tool: which AXON primitive(s) realize the 3 layers?
- How much of the 151-row catalog / 63-file prompt pack to port vs reference in place?
- Standalone invocation grammar + workflow-call contract (M1/M2/M3 surface).
