#!/usr/bin/env python3
"""DAG integrity check for axon-master plan.

Verifies:
  1. Every file 03-prs/pr-*.md has a node in DAG.json.
  2. Every node in DAG.json has a corresponding file.
  3. Every `**Depends-on**:` token in each pr-*.md is a known node.
  4. Topo order is a valid topological sort of edges.
  5. acyclic == true.

Exit 0 on pass, 1 on fail. Run from project root.
"""

import json, os, re, sys
from pathlib import Path

ROOT = Path(__file__).parent
DAG = ROOT / "DAG.json"

def fail(msg):
    print(f"FAIL: {msg}")
    sys.exit(1)

def main():
    if not DAG.exists():
        fail(f"missing {DAG}")
    d = json.loads(DAG.read_text())
    nodes = set(d["nodes"])
    files = {p.stem for p in ROOT.glob("pr-*.md")}

    if missing := nodes - files:
        fail(f"nodes without files: {sorted(missing)}")
    if extra := files - nodes:
        fail(f"files without nodes: {sorted(extra)}")

    topo = d["topo"]
    if set(topo) != nodes:
        fail(f"topo != nodes (diff: {set(topo) ^ nodes})")
    pos = {n: i for i, n in enumerate(topo)}
    for a, b in d["edges"]:
        if pos[a] >= pos[b]:
            fail(f"topo violates edge {a} -> {b}")

    dep_re = re.compile(r"\*\*Depends-on\*\*:\s*(.+)", re.IGNORECASE)
    id_re = re.compile(r"\bPR-(v?\d+(?:\.\d+)?)\b", re.IGNORECASE)
    for p in ROOT.glob("pr-*.md"):
        for line in p.read_text().splitlines():
            m = dep_re.search(line)
            if not m: continue
            for tok in id_re.findall(m.group(1)):
                node = f"pr-{tok.lower()}"
                if node not in nodes:
                    fail(f"{p.name}: unknown dep '{node}'")
            break

    if not d.get("acyclic"):
        fail("DAG.json says acyclic: false")

    print(f"OK: {len(nodes)} nodes ↔ {len(files)} files, topo valid, acyclic.")

if __name__ == "__main__":
    main()
