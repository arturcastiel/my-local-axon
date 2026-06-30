#!/usr/bin/env bash
# O1 — Core Rule 12 ruling on PR-003 (OS-STATE nominal-collapse)
# READ-ONLY decision-support. Does NOT checkout, merge, push, or modify anything.
# You run it, review the output, then tell AXON your ruling: (a) rule-OK / (b) amend-Rule-12 / (c) drop.
set -euo pipefail

REPO="/home/arturcastiel/projects/new-axon/axon"
BRANCH="axon-hr-ui/PR-003-osstate-collapse"
KERNEL="$REPO/axon/KERNEL-SLIM.md"
BASE="main"

cd "$REPO"

# Disable git's pager so the whole report prints straight through (no `:` less prompt).
export GIT_PAGER=cat PAGER=cat

line() { printf '%s\n' "────────────────────────────────────────────────────────────"; }
hdr()  { echo; line; printf '  %s\n' "$1"; line; }

hdr "0 · CONTEXT"
echo "  Repo   : $REPO"
echo "  Branch : $BRANCH"
echo "  Base   : $BASE  (HEAD $(git rev-parse --short "$BASE"))"
if ! git rev-parse --verify --quiet "$BRANCH" >/dev/null; then
  echo "  ✗ Branch $BRANCH not found locally. Aborting (nothing changed)."; exit 1
fi
echo "  Branch tip: $(git rev-parse --short "$BRANCH")"

hdr "1 · CORE RULE 12 (verbatim, from KERNEL-SLIM.md)"
# Print rule 12 block: from the line starting '12.' up to the line starting '13.'
awk '/^13\. /{if(f)exit} /^12\. \*\*Menu is ALWAYS/{f=1} f{print "  "$0}' "$KERNEL"

hdr "2 · PR-003 COMMITS ON THE BRANCH (not yet on $BASE)"
git log --oneline "$BASE..$BRANCH"

hdr "3 · FILES CHANGED vs $BASE"
git diff --stat "$BASE...$BRANCH"

hdr "4 · THE OS-STATE CHANGE (menu source diff — this is the before/after)"
# Show the menu.md (or menu source) diff specifically — the heart of the Rule-12 question.
git diff "$BASE...$BRANCH" -- 'workspace/programs/menu.md' 'workspace/programs/compiled/menu.cmp.md' \
  || echo "  (no menu.md change in range — see full diff in section 5)"

hdr "5 · FULL DIFF vs $BASE (everything PR-003 would land)"
git --no-pager diff "$BASE...$BRANCH"

hdr "6 · THE QUESTION + YOUR THREE RULINGS"
cat <<'EOF'
  Core Rule 12 forbids the menu render from "summarize, truncate, or omit sections".
  PR-003 collapses the OS-STATE block to ONE severity-escalated line when all signals
  are nominal (escalating to per-signal lines only when something is non-nominal).

  Does a nominal ROLLUP count as "summarizing a section" (a Rule-12 violation)?

    (a) rule-OK     → a complete-but-dense render is compatible with Rule 12.
                      AXON merges PR-003 (recompiles the menu) — no kernel edit.
    (b) amend       → Rule 12 must be amended to explicitly permit nominal-collapse.
                      This is a KERNEL edit (axon/KERNEL-SLIM.md) — human-only, per-change
                      confirm; AXON stages the wording, you approve + merge.
    (c) drop        → keep the full per-signal render; PR-003 is dropped (and PR-011
                      replay-surface, folded into it, is re-homed).

  → Review sections 1, 4, 5 above, then tell AXON:  a  |  b  |  c
EOF
echo
echo "  (This script changed nothing. Safe to re-run.)"
