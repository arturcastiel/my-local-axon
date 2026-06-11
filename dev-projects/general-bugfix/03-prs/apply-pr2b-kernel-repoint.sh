#!/usr/bin/env bash
# apply-pr2b-kernel-repoint.sh — PR-2 kernel half, executed BY THE OWNER.
#
# Repoints the 13 kernel-program path-var refs (axon/programs/ chat/plan/mode family)
# from the never-defined W:ws-chats / W:ws-plans / W:ws-episodic to the real
# W:myaxon-* keys, then — with the lint at 0 violations — promotes lint-path-vars
# from WARN to BLOCK, gates, and merges the held mode-wiring branch (one MR carries
# both halves so chat/plan dispatch and working paths land together).
#
# Kernel edits are the inviolable floor: no grant covers them, so YOU run this.
# Fails loudly at every step; nothing merges unless the full gate is green.
#
# Usage:  bash apply-pr2b-kernel-repoint.sh
set -euo pipefail

REPO=/home/arturcastiel/projects/new-axon/axon
BRANCH=general-bugfix/pr-2-mode-wiring
cd "$REPO"

echo "══ 1/6 · switch to $BRANCH"
git checkout -- workspace/AXON-DOCS.md 2>/dev/null || true
git checkout "$BRANCH"
git pull origin "$BRANCH" --ff-only

echo "══ 2/6 · kernel repoint (13 files, token-exact, idempotent)"
python3 - <<'PYEOF'
import pathlib, re, sys

FILES = ["_chat-checkpoint","chat-folder","list-chats","mode-chat","mode-memory",
         "mode-plan","new-chat","plan-add","plan-done","plan-list","plan-new",
         "plan-view","switch-chat"]
MAP = {"W:ws-chats": "W:myaxon-chats",
       "W:ws-plans": "W:myaxon-plans",
       "W:ws-episodic": "W:myaxon-episodic"}

changed = 0
for f in FILES:
    p = pathlib.Path(f"axon/programs/{f}.md")
    if not p.exists():
        sys.exit(f"ABORT: {p} missing")
    s = orig = p.read_text(encoding="utf-8")
    for old, new in MAP.items():
        s = re.sub(re.escape(old) + r"(?![\w-])", new, s)
    if s != orig:
        p.write_text(s, encoding="utf-8")
        changed += 1
print(f"repointed {changed} kernel file(s)" if changed else "already applied — skipping")
PYEOF

echo "══ 3/6 · lint must now be CLEAN repo-wide (precondition for BLOCK)"
python3 tools/lint_path_vars.py check

echo "══ 4/6 · promote lint-path-vars WARN → BLOCK"
python3 - <<'PYEOF'
import json
p = "tools/crucible.json"
d = json.load(open(p, encoding="utf-8"))
for c in d["controls"]:
    if c["id"] == "lint-path-vars":
        if c["severity"] == "BLOCK":
            print("already BLOCK — skipping")
            break
        c["severity"] = "BLOCK"
        c["note"] = ("define-vs-use lint for W:ws-*/W:myaxon-* path variables vs WORKSPACE.md/"
                     "MYAXON.md. Promoted WARN→BLOCK after the conversational repoint cleared "
                     "all 24 baseline refs (workspace half autonomous, kernel half owner-applied) "
                     "— an undefined path-var now blocks merge.")
        print("promoted to BLOCK")
        break
else:
    raise SystemExit("ABORT: lint-path-vars control not found")
open(p, "w", encoding="utf-8").write(json.dumps(d, indent=2) + "\n")
PYEOF

echo "══ 5/6 · full crucible gate, commit, push, merge (one MR, both halves)"
GATE=$(python3 axon.py crucible gate)
echo "$GATE"
python3 - "$GATE" <<'PYEOF'
import json, sys
g = json.loads(sys.argv[1])
if not g.get("passed"):
    sys.exit(f"ABORT: gate not green — blocking: {g.get('blocking_failures')}")
print("gate GREEN —", g["total"], "controls; warnings:", g.get("warnings"))
PYEOF

git add axon/programs/ tools/crucible.json
git add tests/coverage.json workspace/AXON-DOCS.md workspace/audit/axon-lang.md 2>/dev/null || true
MSG_FILE=$(mktemp)
cat > "$MSG_FILE" <<'EOF'
general-bugfix: kernel — repoint chat/plan path keys + promote the path-var lint to BLOCK

Human-applied kernel half of the conversational repoint: the 13 chat/plan/mode
kernel programs read W:ws-chats / W:ws-plans / W:ws-episodic — keys with ZERO
definitions, so every chat and plan silently targeted nonexistent dirs. All
repointed to the real W:myaxon-* keys (MYAXON.md is the definer).

With the full baseline cleared (workspace half landed previously), the
define-vs-use path-var lint is promoted WARN→BLOCK: an undefined path
variable now blocks merge. This MR also carries the mode-wiring half
(new-chat/plan-new dispatch) so routing and working paths land together.

Co-authored-by: AXON <axon@arturcastiel.github.io>
EOF
python3 tools/lint_commit_trailer.py --stdin < "$MSG_FILE"
git commit -F "$MSG_FILE"
git push origin "$BRANCH"

DESC="Kernel half of the conversational repoint (owner-applied): 13 chat/plan/mode kernel programs repointed from the never-defined ws-chats/ws-plans/ws-episodic keys to the real myaxon-* keys; lint-path-vars promoted WARN→**BLOCK** with the baseline at 0. Also carries the held mode-wiring half (new-chat/plan-new dispatch + menu modes token fix) so routing and working paths land together. Full gate green.

Co-authored-by: AXON <axon@arturcastiel.github.io>"
glab mr create --source-branch "$BRANCH" --target-branch main \
  --title "general-bugfix: conversational repoint (kernel half) + path-var lint to BLOCK" \
  --description "$DESC" --yes
sleep 8
IID=$(glab mr list --source-branch "$BRANCH" 2>/dev/null | grep -oE '^!\w+' | head -1 | tr -d '!')
glab mr merge "${IID:?no MR found}" --squash --remove-source-branch --yes

echo "══ 6/6 · sync main + verify the promoted gate bites"
git checkout main
git pull origin main
python3 tools/lint_path_vars.py check
python3 axon.py log --level INFO --source general-bugfix \
  --msg "PR-2 complete (owner script) — kernel repoint merged, lint-path-vars now BLOCK" || true

echo ""
echo "✓ DONE — conversational subsystem repointed end-to-end; path-var lint is BLOCK."
echo "  Next: say 'continue' in an AXON session for Wave 2 (PR-3 phase-model unification)."
