#!/usr/bin/env python3
"""PR schema completeness check for axon-master plan.

Asserts every 03-prs/pr-*.md contains the required H2 sections.
Version-bump PRs (pr-v*.md) have a relaxed requirement.
Per-PR opt-out: '<!-- skip-schema: <section-name> -->' marker.

Exit 0 on pass, 1 on fail. Run from project root.
"""

import re, sys
from pathlib import Path

ROOT = Path(__file__).parent

FULL = ["Why", "Evidence", "Design notes", "Pitfalls",
        "Interface sketch", "Spec", "Codebase grounding", "Cross-refs"]
VERSION = ["Why", "Spec", "Cross-refs"]

def main():
    fails = []
    skip_re = re.compile(r"<!--\s*skip-schema:\s*([^>]+?)\s*-->")
    for p in sorted(ROOT.glob("pr-*.md")):
        txt = p.read_text()
        required = VERSION if re.match(r"pr-v\d", p.stem) else FULL
        skipped = {m.group(1).strip() for m in skip_re.finditer(txt)}
        for sec in required:
            if sec in skipped: continue
            if f"## {sec}" not in txt:
                fails.append(f"{p.name}: missing '## {sec}'")

    if fails:
        for f in fails:
            print(f"FAIL: {f}")
        print(f"\n{len(fails)} schema violations across {len({f.split(':')[0] for f in fails})} files.")
        sys.exit(1)

    n = sum(1 for _ in ROOT.glob("pr-*.md"))
    print(f"OK: {n} PR files pass schema check.")

if __name__ == "__main__":
    main()
