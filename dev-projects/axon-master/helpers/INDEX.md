# helpers/ — AXON Master study artifacts

Each cycle produces 4 helper files (one per phase). All are inputs to the
final synthesis (`01-study.md`). Naming convention:

  `c{N}-p{M}-{topic}.md`

where N = cycle (1-4), M = phase (1-4).

| Phase | Purpose                                           |
|-------|---------------------------------------------------|
| 1     | Read & map AXON repo (kernel/programs/tools/etc.) |
| 2     | Brainstorm workflows AXON could enable            |
| 3     | Improvement backlog (faster · useful · gaps · tokens) |
| 4     | Web research — libraries, prior art, comparable systems |

## Index

### Cycle 1 (broad survey)
- [c1-p1-kernel-map.md](c1-p1-kernel-map.md) — kernel/core surface, identity, gates, lang ops, boot
- [c1-p1-programs-map.md](c1-p1-programs-map.md) — workspace programs by family + dep graph
- [c1-p1-tools-map.md](c1-p1-tools-map.md) — registry, CLI surface, overlap, orphans
- [c1-p2-workflows.md](c1-p2-workflows.md) — workflow brainstorm
- [c1-p3-improvements.md](c1-p3-improvements.md) — improvement backlog (impact × effort)
- [c1-p4-web-findings.md](c1-p4-web-findings.md) — agent OS / caching / kernel patterns

### Cycle 2 (depth — compiler, scheduler, memory, processes)
- [c2-p1-deep-internals.md](c2-p1-deep-internals.md) — compiler, scheduler, memory, processes
- [c2-p2-workflows.md](c2-p2-workflows.md) — refined workflows from C1 gaps
- [c2-p3-improvements.md](c2-p3-improvements.md) — deeper improvements
- [c2-p4-web-findings.md](c2-p4-web-findings.md) — symbolic-language & DSL prior art

### Cycle 3 (token economy + dispatch)
- [c3-p1-token-hotspots.md](c3-p1-token-hotspots.md) — where tokens leak today
- [c3-p2-workflows.md](c3-p2-workflows.md) — workflows that exploit caching
- [c3-p3-improvements.md](c3-p3-improvements.md) — token-economy backlog
- [c3-p4-web-findings.md](c3-p4-web-findings.md) — caching, compaction, dispatch prior art

### Cycle 4 (synthesis)
- consolidates into ../01-study.md

## Cross-links
- Final report: `../01-study.md`
- Backlog (filtered): `../02-prs.md` (after `code-dev plan`)
