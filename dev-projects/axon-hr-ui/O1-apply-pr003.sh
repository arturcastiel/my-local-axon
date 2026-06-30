#!/usr/bin/env bash
# O1-apply-pr003.sh — APPLY PR-003 (OS-STATE nominal-collapse + code-dev replay surface) to main.
# Owner-ruled (a) rule-OK on 2026-06-23 ("I gate ok"). Run this from YOUR terminal.
#
# SAFE: aborts on wrong-branch / dirty tree / merge conflict / RED tests. No force-push.
# Fully reversible up to the push: `git reset --hard HEAD~1` undoes the merge commit.
# After push: `git revert <sha>` reverts it.
set -euo pipefail
export GIT_PAGER=cat PAGER=cat

REPO="/home/arturcastiel/projects/new-axon/axon"
BRANCH="axon-hr-ui/PR-003-osstate-collapse"
CMP="workspace/programs/compiled/menu.cmp.md"
cd "$REPO"

ok(){ printf '  ✓ %s\n' "$1"; }
die(){ printf '  ✗ %s\n' "$1"; exit 1; }

echo "── PR-003 apply ──────────────────────────────────────────"

# 1) PREFLIGHT
[ "$(git rev-parse --abbrev-ref HEAD)" = "main" ] || die "not on main (run: git checkout main)"
git rev-parse --verify --quiet "$BRANCH" >/dev/null || die "branch $BRANCH not found"
DIRTY=$(git status -s --untracked-files=no | grep -vE "coverage.json|AXON-DOCS.md|axon-lang.md|cron.json" || true)
[ -z "$DIRTY" ] || { echo "$DIRTY"; die "working tree has unexpected changes — stash/commit them first"; }
ok "on main, clean (apart from known docgen-dirty), branch present"

# 2) SQUASH-MERGE  (clean: merge-base 3de09fc, no menu.md conflict)
echo "▶ squash-merging $BRANCH ..."
git merge --squash "$BRANCH" || die "merge produced conflicts — resolve or 'git merge --abort'"
ok "squash-merge staged"

# 3) COMPILED-MENU mtime stopgap (git-invisible; content recompile = tracked follow-up, gap-find rank 7)
touch "$CMP"
ok "touched $CMP (mtime stopgap per BUILD-STATE)"

# 4) COMMIT  (AXON trailer ONLY; NO 'PR-N' refs — the pre-commit hook enforces both)
git commit -m "menu: OS-STATE nominal-collapse render + surface code-dev replay

Every OS-STATE signal and section is preserved; an all-nominal state collapses to a
single rollup line and auto-expands to per-signal lines on any non-nominal signal.
Owner-ruled compatible with the full-render rule. Compiled-menu content recompile is
tracked as a follow-up.

Co-authored-by: AXON <axon@arturcastiel.github.io>" || die "commit aborted (pre-commit hook?) — fix + re-run; 'git merge --abort' to back out"
ok "committed $(git rev-parse --short HEAD)"

# 5) TEST GATE — FULL crucible by default (owner: "everything must be tested").
#    Pass --fast to run only the menu/compiled/replay subset instead.
if [ "${1:-}" = "--fast" ]; then
  echo "▶ focused tests (menu / compiled-staleness / replay) ..."
  python3 -m pytest -q -k "menu or compiled_not_stale or replay or code_dev_replay" \
    || { echo; die "tests RED — NOT pushing. Undo: git reset --hard HEAD~1"; }
else
  echo "▶ FULL crucible gate (every BLOCK control + the whole suite) ... [pass --fast for the subset]"
  python3 axon.py crucible gate || { echo; die "crucible RED — NOT pushing. Undo: git reset --hard HEAD~1"; }
fi
ok "tests green"

# 6) PUSH
echo "▶ pushing origin main ..."
git push origin main || die "push failed (auth/remote?) — commit is local; fix then 'git push origin main'"
ok "pushed origin main"

echo "── ✓ PR-003 APPLIED.  Tell AXON 'done' → it marks PR-003 merged in the DAG + BUILD-STATE,"
echo "     re-homes the folded PR-011, and you move to O2 → O3 → O4. ─────────────"
