#!/usr/bin/env bash
# apply-pr0d-kernel-patch.sh — PR-0d kernel patch + merge, executed BY THE OWNER.
#
# Kernel edits are the inviolable floor: no grant covers them, so YOU run this.
# It applies the 6-line patch to axon/programs/interactive.md (removing the
# references to the deleted compile tool), proves the crucible gate green,
# commits with the AXON trailer, pushes, squash-merges MR !162, and clears the
# tracking todos. Fails loudly at every step — nothing is force-pushed,
# nothing merges unless the gate passes.
#
# Usage:  bash apply-pr0d-kernel-patch.sh
set -euo pipefail

REPO=/home/arturcastiel/projects/new-axon/axon
BRANCH=general-bugfix/pr-0d-mirror-kill
MR=162
cd "$REPO"

echo "══ 1/7 · switch to $BRANCH"
# AXON-DOCS.md is auto-generated; a stale local copy must not block checkout.
git checkout -- workspace/AXON-DOCS.md 2>/dev/null || true
git checkout "$BRANCH"
git pull origin "$BRANCH" --ff-only

echo "══ 2/7 · apply the kernel patch (exact-match, aborts if drifted)"
python3 - <<'PYEOF'
import sys
p = "axon/programs/interactive.md"
s = open(p, encoding="utf-8").read()

if "TOOL(compile" not in s and "| `compile [file]`" not in s:
    print("patch already applied — skipping")
    sys.exit(0)

edits = [
    # 1. drop both compile command rows
    ("""| `compile [file]` | EXEC(compiler, {source: [file]}) — compile to programs/compiled/ |
| `compile [file] from [template]` | EXEC(compiler, {template: [file], params: prompted}) |
""", ""),
    # 2. programs row: no compiled split anymore
    ("""| `programs` | List all files in programs/ (source and compiled) |""",
     """| `programs` | List all files in programs/ |"""),
    # 3. intent list: compile is no longer an intent
    ("""1. Identify the intent: compile / run / create / query / configure / explain""",
     """1. Identify the intent: run / create / query / configure / explain"""),
    # 4. program-creation flow: no compile offer
    ("""After collecting: write `programs/[name].md` using the program format. Offer to compile immediately.""",
     """After collecting: write `programs/[name].md` using the program format."""),
    # 5. delete the whole template-compile guided flow (incl. the TOOL(compile,...) call)
    ("""### Compiling with a template (triggered by `compile [file] from [template]`)
1. READ the template's PARAMETERS section.
2. For each required parameter with no default: ask the user for the value (one per turn).
3. Once all required params are collected: TOOL(compile, format, --name {output}, --source {template}).
4. Report compression ratio and any warnings.

""", ""),
]

for old, new in edits:
    if old not in s:
        sys.exit(f"ABORT: expected text not found (file drifted?):\n---\n{old[:120]}...")
    s = s.replace(old, new)

open(p, "w", encoding="utf-8").write(s)
print("patch applied: 5 edits, TOOL(compile) reference removed")
PYEOF
if grep -n "TOOL(compile" axon/programs/interactive.md; then
  echo "ABORT: a TOOL(compile reference survived"; exit 1
fi

echo "══ 3/7 · targeted proof: the 3 known reds must flip green"
python3 -m pytest \
  "tests/test_programs_md.py::test_program_tool_refs[os::interactive]" \
  "tests/test_programs_md.py::test_program_kernel_rules[os::interactive]" \
  tests/test_integration.py::TestAxonAudit -q

echo "══ 4/7 · full crucible gate (merge requires green)"
GATE=$(python3 axon.py crucible gate)
echo "$GATE"
python3 - "$GATE" <<'PYEOF'
import json, sys
g = json.loads(sys.argv[1])
if not g.get("passed"):
    sys.exit(f"ABORT: gate not green — blocking: {g.get('blocking_failures')}")
print("gate GREEN —", g["total"], "controls; warnings:", g.get("warnings"))
PYEOF

echo "══ 5/7 · commit + push"
git add axon/programs/interactive.md
# gate-regenerated artifacts ride along if present
git add tests/coverage.json workspace/AXON-DOCS.md workspace/audit/axon-lang.md 2>/dev/null || true
MSG_FILE=$(mktemp)
cat > "$MSG_FILE" <<'EOF'
general-bugfix: kernel — retire compile commands from the interactive shell

Human-applied kernel patch (inviolable floor): the compiled-mirror kill removed
the compile tool; axon/programs/interactive.md still advertised the compile
commands and called the tool in its template flow. Removed: both command rows,
the compile intent, the compile offer, and the template-compile guided flow.
Clears the 3 remaining reds (one root, line 155): audit 1a Unknown-TOOL WARN,
R_TOOL_EXISTS BLOCK, and the program tool-refs check.

Co-authored-by: AXON <axon@arturcastiel.github.io>
EOF
python3 tools/lint_commit_trailer.py --stdin < "$MSG_FILE"
git commit -F "$MSG_FILE"
git push origin "$BRANCH"

echo "══ 6/7 · un-draft + squash-merge MR !$MR"
glab mr update "$MR" --ready || true
glab mr merge "$MR" --squash --remove-source-branch --yes

echo "══ 7/7 · sync main + close the tracking todos"
git checkout main
git pull origin main
python3 axon.py todo done --id ad0b772b || true
python3 axon.py todo done --id 20166489 || true
python3 axon.py log --level INFO --source general-bugfix \
  --msg "PR-0d merged (MR !162) — kernel patch human-applied via script; compiled-mirror kill COMPLETE" || true

echo ""
echo "✓ DONE — compiled-mirror kill fully merged. Step 0 complete."
echo "  Next: say 'continue' in an AXON session to start Wave 1 (PR-1 + PR-2)."
