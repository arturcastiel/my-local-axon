#!/usr/bin/env bash
# ship.sh — the ONE file the owner runs to VERIFY and SHIP staged AXON work.
#
# Strategy: AXON pre-stages every PR as a COMPLETE, crucible-green branch (code +
# recompiles + tests — nothing non-deterministic left). You run THIS, once, to ship it.
#
#   bash ship.sh                 → VERIFY ONLY: full crucible gate, read-only. Safe default.
#   bash ship.sh <branch> [...]  → for EACH branch: preflight → squash-merge → crucible → push.
#                                  Stops at the first RED (reverts that merge), never pushes red.
#
# SAFE: aborts on wrong-branch / dirty tree / conflict / RED crucible / push failure.
# No force-push. Reversible before push. Re-runnable (idempotent on already-merged branches).
set -uo pipefail
export GIT_PAGER=cat PAGER=cat
REPO="/home/arturcastiel/projects/new-axon/axon"; cd "$REPO"
ok(){ printf '  ✓ %s\n' "$1"; }
die(){ printf '  ✗ %s\n' "$1"; exit 1; }

verify(){
  echo "▶ crucible gate (full suite + every BLOCK control) ... [a few minutes]"
  local out; out="$(python3 axon.py crucible gate 2>&1)"; echo "$out" | tail -8
  echo "$out" | grep -q '"passed": true'
}

# ── preflight (always) ──
[ "$(git rev-parse --abbrev-ref HEAD)" = "main" ] || die "not on main (git checkout main)"
DIRTY=$(git status -s --untracked-files=no | grep -vE "coverage.json|AXON-DOCS.md|axon-lang.md|cron.json" || true)
[ -z "$DIRTY" ] || { echo "$DIRTY"; die "unexpected working-tree changes — stash/commit first"; }
ok "on main, clean (apart from known docgen-dirty)"

# ── VERIFY ONLY (no branch args) ──
if [ "$#" -eq 0 ] || [ "${1:-}" = "verify" ]; then
  verify && { ok "GREEN — repo verified, safe to ship onto"; exit 0; } || die "RED — see failures above; nothing shipped"
fi

# ── SHIP each branch ──
git fetch origin main --quiet 2>/dev/null || true
for BR in "$@"; do
  echo "── shipping $BR ──────────────────────────────────────────"
  git rev-parse --verify --quiet "$BR" >/dev/null || die "branch $BR not found"
  if git merge-base --is-ancestor "$BR" HEAD; then ok "$BR already merged — skipping"; continue; fi
  git merge --squash "$BR" || die "$BR: conflicts — resolve or 'git merge --abort'"
  subj="$(git log -1 --format=%s "$BR" | sed -E 's/[[:space:]]*PR-[0-9]+[a-z]?[: -]*//g')"
  git commit -m "$subj

Co-authored-by: AXON <axon@arturcastiel.github.io>" \
    || die "$BR: commit aborted (pre-commit hook?) — fix, or 'git merge --abort' to back out"
  ok "committed $(git rev-parse --short HEAD)"
  verify || { git reset --hard HEAD~1; die "$BR: crucible RED — merge REVERTED, not pushed"; }
  ok "crucible green"
  git push origin main || die "$BR: push failed (auth/remote) — commit is local; retry 'git push origin main'"
  ok "$BR shipped → origin/main"
done
echo "── ✓ done. Tell AXON 'shipped' → it updates the DAG + BUILD-STATE for what landed. ──"
