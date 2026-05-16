# C2·P4 — Web findings (compiler, scheduler, checkpoint patterns)

> Targeted at gaps surfaced in C2·P1 (compiler optimization rigidity, snapshot fragmentation, soft-fail philosophy).

---

## A. DSL COMPILER PATTERNS

### Constant folding (validates C2-C2)
> "Constant folding evaluates constant expressions at compile time rather than computing them at runtime ... by calculating values in advance, the compiler can replace expressions with the computed results."
- Standard since the 1970s; well understood.
- **For AXON**: O11 is uncontroversial. Implement directly — no research needed.

### Peephole optimization (relevant to O7 robustness)
> "Peephole optimization examines a small, sliding window of instructions and replaces patterns with optimized equivalents."
- AXON's O7 is essentially peephole + fusion.
- The C2·P1 finding (O7 requires exact shape) is a known peephole limitation. Fix: pre-normalize the window before pattern-matching.

### DSL-guided iterative compile-validate-correct loop
> "An LLM generates DSL code, the DSL's compiler or parser validates that code, and any resulting errors are fed back into the model for correction."
- Maps to AXON's `compile → benchmark → verify → recompile` loop.
- AXON does this but the feedback to author is a one-shot warning, not iterative. Could become a compile session that loops until clean.

### Rule-based DSL transformation
> "Express transformation rules as source-to-target DSL pattern pairs, with interprocedural analysis supporting pattern matching ... mediated in the DSL's formal grammar."
- This is exactly what `compiler/GRAMMAR.md` does.
- **For AXON**: validate that the grammar engine itself supports interprocedural matching across PHASE boundaries (likely it doesn't — see C2-C3 cross-phase optimization).

### Cited
- [Constant folding · Wikipedia](https://en.wikipedia.org/wiki/Constant_folding)
- [Constant Folding and Constant Propagation · OpenGenus](https://iq.opengenus.org/constant-folding-and-propagation/)
- [Compiler Design — Peephole Optimization · TutorialsPoint](https://www.tutorialspoint.com/compiler_design/compiler_design_peephole_optimization.htm)
- [AI Coding Agents and DSLs · Microsoft Azure](https://devblogs.microsoft.com/all-things-azure/ai-coding-agents-domain-specific-languages/)
- [DSL-Guided Transcompilation · Emergent Mind](https://www.emergentmind.com/topics/dsl-guided-transcompilation)
- [Building Your Own Custom DSL · Medium](https://medium.com/@robertdennyson/building-your-own-custom-dsl-a-comprehensive-guide-9be7bb70524d)

---

## B. CHECKPOINT / RESUME PATTERNS

### Microsoft Agent Framework — explicit checkpointing
> "Microsoft's Agent Framework has the most explicitly designed checkpointing system ... workflows executing in supersteps that use the Pregel computation model ... `.with_checkpointing(checkpoint_storage=checkpoint_storage)` ... FileCheckpointStorage provides persistent checkpoint storage using JSON files."

**For AXON**: AXON's CHECKPOINT shorthand already maps well. The Pregel "superstep" model offers a useful framing — every program phase is a superstep, every CHECKPOINT is a superstep boundary. Could be made explicit.

### LangGraph checkpointing
> "Explicitly introduces a checkpoint mechanism for conversational or workflow graphs."
- AXON's per-program phase tracking is similar, but not graph-shaped. Adopting LangGraph's "thread + checkpoint id" model could simplify resume across long sessions.

### Multi-agent stateful restore
> "Achieving stateful restore in multi-agent systems requires pausing all agents, recording their states and messages, then resuming all."
- AXON is single-active-program today (active-phase, paused-program). When AXON spawns subagents (e.g. cycle work), there's no unified checkpoint capturing both.
- **For AXON**: matters once SPAWN/HANDOFF are first-class for multi-agent flows.

### "Still Not Durable" (industry critique)
> "Microsoft Agent Framework and Strands Agents repeat the same mistake."
- Even named frameworks ship checkpointing that's not truly durable (e.g. in-memory only, lost on crash).
- **For AXON**: if AXON's checkpoint goes to disk (W: → file), it's already more durable than these. Worth verifying.

### Cited
- [Checkpoint/Restore Systems · eunomia](https://eunomia.dev/blog/2025/05/11/checkpointrestore-systems-evolution-techniques-and-applications-in-ai-agents/)
- [Checkpointing and Resuming Workflows · Microsoft Learn](https://learn.microsoft.com/en-us/agent-framework/tutorials/workflows/checkpointing-and-resuming)
- [Best Practices: Checkpointing Preemptible Workloads · Run:ai](https://run-ai-docs.nvidia.com/self-hosted/workloads-in-nvidia-run-ai/using-training/checkpointing-preemptible-workloads)
- [Still Not Durable · Diagrid Blog](https://www.diagrid.io/blog/still-not-durable-how-microsoft-agent-framework-and-strands-agents-repeat-the-same-mistake)
- [Kubernetes Scheduling with Checkpoint/Restore · INESC-ID](https://www.dpss.inesc-id.pt/~rbruno/papers/vspisakova-jsspp25.pdf)

---

## C. CROSS-CUTTING TAKEAWAYS

1. **Constant folding (O11) is uncontroversial** — implement; no risk.
2. **Peephole pre-normalization fixes O7** — small refactor, high payoff.
3. **Pregel "superstep" framing** could clean up AXON's CHECKPOINT semantics.
4. **Multi-agent unified checkpoint** matters once subagents are first-class — flag for cycle 4.
5. **Iterative compile-validate-correct loop** could become a `compile --auto-fix` mode.

---

## D. NEW BACKLOG ITEMS DERIVED

| ID    | Item                                                  | Impact | Effort | Score |
|-------|-------------------------------------------------------|--------|--------|-------|
| W2-01 | Pre-normalize peephole window before O7 fusion        | 3      | 2      | 1.5   |
| W2-02 | Adopt Pregel-style "superstep" framing in PROCESS.md  | 2      | 2      | 1.0   |
| W2-03 | `compile --auto-fix` (iterative LLM correction loop)  | 4      | 4      | 1.0   |
| W2-04 | Multi-agent unified checkpoint (when SPAWN goes first-class) | 3 | 5    | 0.6   |
| W2-05 | Confirm AXON checkpoint is disk-durable (vs in-memory) | 3      | 1      | 3.0   |

---

## E. POSITIONING NOTE

C1·P4 found that AXON's symbolic kernel + cognition layer is its moat vs LangGraph/CrewAI/AutoGen.
C2·P4 reinforces: AXON's checkpoint discipline (file-backed W:, append-only E:) appears stronger than the named frameworks shipping today. The Diagrid critique ("Still Not Durable") suggests this is a real industry gap AXON could highlight.

---

## F. FOR CYCLE 3

- C3 should empirically verify AXON's checkpoint durability (W2-05).
- C3 should also measure baseline token-cost of CHECKPOINT calls (snapshot writes).
