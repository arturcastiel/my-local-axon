# Build DAG — AXON Memory

```
AM1 ──▶ AM2 ──▶ AM3 ──▶ AM4
 │                       
 └──▶ AM5 (parallel — needs only AM1)
                         
AM6 (last — needs tiers AM1 + capture AM3 to have content to render/enforce)
```

- **Critical path:** AM1 → AM2 → AM3 → AM4.
- **AM5** (todos/reminders) depends only on AM1's store/load + privacy roots; can run in
  parallel with AM3/AM4.
- **AM6** (cross-harness) goes last — it renders/enforces what AM1+AM3 produce.
- **Then → cluster-N** absorbs the graph-declaration layer (memory-reads/writes + neuron-audit).

Rationale: build the substrate (AM1) and the scalability keystone (AM2 recall) before the
judgment-heavy capture (AM3). GC (AM4) needs bindings, which AM3/AM1 establish. Cross-harness
(AM6) is meaningless until there is memory to surface.
