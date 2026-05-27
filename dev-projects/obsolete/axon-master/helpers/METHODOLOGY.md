# METHODOLOGY — AXON Master deep study

## Goal
Produce the most useful possible understanding of AXON so the project can:
1. Run **faster** (fewer tool calls, less I/O, better caching).
2. Be **more useful** (more workflows, better routing, fewer dead ends).
3. **Bridge gaps** (places where the agent has to guess instead of execute).
4. **Spend fewer tokens** (compression, dispatch to compiled, semantic search).

## Cycle structure
Each of 4 cycles runs the same 4 phases. Cycles differ in *focus*:

| Cycle | Lens                                                |
|-------|-----------------------------------------------------|
| 1     | Broad survey — what exists, how it fits             |
| 2     | Depth on compiler/scheduler/memory/processes        |
| 3     | Token economy + dispatch + caching                  |
| 4     | Synthesis — consolidate to 01-study.md + top-10 backlog |

## Phase contract
| Phase | Inputs              | Output                          |
|-------|---------------------|---------------------------------|
| 1     | source files        | dense map (file paths + facts)  |
| 2     | phase-1 map         | workflow brainstorm             |
| 3     | phases 1+2          | improvement backlog (impact ×effort) |
| 4     | external sources    | web findings + applicability    |

## Quality bar
- **Specificity**: cite file paths, line numbers, function names. No hand-waving.
- **Density**: no padding. Every line is a fact, an inference, or a recommendation.
- **Traceability**: every recommendation links to a finding it solves.
- **Actionability**: every improvement names a concrete change (file, function, behavior).

## Anti-patterns (do not produce)
- "Consider improving X" without saying how
- Unsourced claims about token usage
- Long prose where a table would do
- Recommendations the kernel already implements (re-read CORE RULES first)

## Process
1. C1 phases 1-3 spawn in parallel (independent reads of repo).
2. C1 phase 4 (web research) runs after phase 3 so it can target known gaps.
3. C2-C3 phase 1 reuses C1 maps; doesn't re-read.
4. C4 reads all helpers + writes 01-study.md.

## Output destination
- Per-phase helpers: `helpers/c{N}-p{M}-*.md`
- Final synthesis: `01-study.md`
- Backlog (after plan phase): `02-prs.md`
