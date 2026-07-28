## PR-B1 — agent_memory gc-gate uses the canonical _longterm reader
Scope: tools/agent_memory.py _read_gate → delegate to _longterm.read_longterm_value (first-line only); delete the every-line scanner. Test: multi-line 'false\nvalue: true' must read false. Severity HIGH-consequence.
