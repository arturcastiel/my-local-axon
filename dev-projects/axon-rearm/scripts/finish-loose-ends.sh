#!/usr/bin/env bash
#
# finish-loose-ends.sh — axon-rearm owner closeout (items 1–4 you accepted)
# ---------------------------------------------------------------------------
# Handles the HUMAN-ONLY loose ends AXON cannot do itself:
#   1. Commit axon/BOOT.md  (kernel floor — extracted surgically from stash@{0})
#   2. Prune 3 stale branches (force-delete + safety archive tag first)
#   3. Dispose of the 5 regenerated maintenance files (commit OR discard)
#   4. (reminder only) per-change owner confirm for KERNEL-SLIM.md edits
#
# SAFE BY DESIGN: every mutating step shows what it will do and asks y/N.
#   --dry-run   preview everything, change nothing
#   --yes       auto-confirm every step (use with care)
#
# You run this — that keeps YOU the actor for the kernel commit + destructive git.
# ---------------------------------------------------------------------------
set -euo pipefail

REPO="${AXON_REPO:-/home/arturcastiel/projects/new-axon/axon}"
TRAILER="Co-authored-by: AXON <axon@arturcastiel.github.io>"
PRUNE_BRANCHES=(fix/gate-serial-restore chore/test-council-actions perf/xdist-parallel)
REGEN_FILES=(tests/coverage.json workspace/AXON-DOCS.md workspace/_dashboards/axon-code-map.md \
             workspace/programs/REGISTRY.json workspace/scheduler/cron.json)

DRY=0; AUTOYES=0
for a in "$@"; do case "$a" in
  --dry-run) DRY=1 ;; --yes|-y) AUTOYES=1 ;;
  -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
  *) echo "unknown arg: $a"; exit 2 ;;
esac; done

c() { printf '\033[%sm%s\033[0m' "$1" "$2"; }
hdr()  { echo; echo "$(c '1;36' "━━ $* ━━")"; }
info() { echo "  $*"; }
warn() { echo "  $(c '1;33' "⚠ $*")"; }
ok()   { echo "  $(c '1;32' "✓ $*")"; }
run()  { if [ "$DRY" = 1 ]; then echo "  $(c '2' "[dry-run] $*")"; else eval "$@"; fi; }
ask()  { # ask "question"  -> returns 0 on yes
  [ "$AUTOYES" = 1 ] && { echo "  > $1 [auto-yes]"; return 0; }
  read -r -p "  $(c '1;35' "▶ $1 [y/N] ")" ans; [[ "$ans" =~ ^[Yy]$ ]]; }

cd "$REPO"
echo "$(c '1;36' 'axon-rearm · finish-loose-ends')   repo: $REPO   $([ "$DRY" = 1 ] && c '1;33' '(DRY-RUN)')"
info "branch: $(git branch --show-current)   dirty: $(git status --short | wc -l | tr -d ' ') file(s)"

# ── guard: be on main ───────────────────────────────────────────────────────
if [ "$(git branch --show-current)" != "main" ]; then
  warn "not on 'main' (on '$(git branch --show-current)'). Step 1/2 assume main. Switch first or Ctrl-C."
  ask "continue anyway?" || exit 1
fi

# ── STEP 1 — commit axon/BOOT.md from stash@{0} (surgical) ───────────────────
hdr "STEP 1 · commit axon/BOOT.md (kernel floor)"
if ! git stash list | grep -q 'stash@{0}'; then
  warn "no stash@{0} present — skipping (already handled?)."
elif ! git stash show --name-only 'stash@{0}' | grep -qx 'axon/BOOT.md'; then
  warn "stash@{0} does not contain axon/BOOT.md — skipping (manual check advised)."
else
  info "stash@{0} = $(git stash list | head -1 | cut -d: -f2-)"
  info "extracting ONLY axon/BOOT.md (the other 5 files in the stash are left untouched)."
  echo "  --- BOOT.md diff (stash vs HEAD) ---"
  git diff HEAD "stash@{0}" -- axon/BOOT.md | sed 's/^/    /' | head -60 || true
  if ask "stage axon/BOOT.md from stash@{0} and commit it?"; then
    run "git checkout 'stash@{0}' -- axon/BOOT.md"
    run "git add axon/BOOT.md"
    run "git commit -m 'docs(boot): sync orchestrator-tick / boot text (kernel-floor, owner)' -m '$TRAILER'"
    ok "axon/BOOT.md committed."
  else info "skipped step 1."; fi
fi

# ── STEP 3 (before branch prune) — dispose of regenerated maintenance files ──
hdr "STEP 3 · dispose of 5 regenerated maintenance files"
PRESENT=(); for f in "${REGEN_FILES[@]}"; do git diff --quiet -- "$f" 2>/dev/null || PRESENT+=("$f"); done
if [ "${#PRESENT[@]}" = 0 ]; then
  ok "none of the 5 regen files are dirty — nothing to do."
else
  for f in "${PRESENT[@]}"; do info "dirty: $f"; done
  echo "  Options:  [c] commit as chore(regen)   [d] discard (git checkout --)   [s] skip"
  CHOICE=s
  if [ "$AUTOYES" = 1 ]; then CHOICE=c; echo "  > choice [auto: c]"
  else read -r -p "  $(c '1;35' '▶ c / d / s ? ')" CHOICE; fi
  case "$CHOICE" in
    c|C) run "git add ${PRESENT[*]}"
         run "git commit -m 'chore(regen): refresh generated docs/dashboards/registry/cron artifacts' -m '$TRAILER'"
         ok "regen artifacts committed." ;;
    d|D) warn "discarding local changes to ${#PRESENT[@]} regenerated file(s) (they rebuild on next run)."
         ask "really discard?" && { run "git checkout -- ${PRESENT[*]}"; ok "discarded."; } || info "kept." ;;
    *)   info "skipped step 3." ;;
  esac
fi

# ── STEP 2 — prune 3 stale branches (archive tag, then force-delete) ─────────
hdr "STEP 2 · prune stale branches (all UNMERGED — content already on main via squash)"
for b in "${PRUNE_BRANCHES[@]}"; do
  if ! git show-ref --verify --quiet "refs/heads/$b"; then ok "$b already gone."; continue; fi
  sha="$(git rev-parse --short "$b")"
  merged="$(git branch --merged main --list "$b")"; state=$([ -n "$merged" ] && echo MERGED || echo UNMERGED)
  info "$b  (tip $sha, $state)"
  if ask "archive-tag + force-delete '$b'?"; then
    tag="archive/pre-prune/$b"
    run "git tag -f '$tag' '$b'"            # reversible: 'git branch $b $tag' to restore
    run "git branch -D '$b'"
    ok "deleted $b  (restore with: git branch $b $tag)"
  else info "kept $b."; fi
done

# ── STEP 4 — reminder only (not scriptable) ─────────────────────────────────
hdr "STEP 4 · KERNEL-SLIM.md edits — standing rule (no action now)"
warn "No pending KERNEL-SLIM.md edit exists, so nothing to run here."
info "Rule stands: any future PR proposing a KERNEL-SLIM.md change needs dev-mode + your"
info "per-change confirm (OD-1 prose, OD-2 lines 188/341, F1 version bump). The gate fires"
info "when such a PR appears — this script can't pre-approve it."

# ── optional cleanup — drop the now-redundant stash ─────────────────────────
hdr "CLEANUP · stash@{0}"
if git stash list | grep -q 'stash@{0}'; then
  warn "stash@{0} still holds BOOT.md + the 5 regen files. If step 1 + step 3 are done, it's redundant."
  ask "drop stash@{0}? (irreversible)" && { run "git stash drop 'stash@{0}'"; ok "stash dropped."; } \
    || info "stash kept — drop later with: git stash drop 'stash@{0}'"
fi

hdr "DONE"
info "summary:"; git log --oneline -3 | sed 's/^/    /'
info "remaining dirty: $(git status --short | wc -l | tr -d ' ') file(s)"
echo "  $(c '1;32' 'Loose ends 1–3 handled. 4 is a standing gate.  Re-run with --dry-run anytime to preview.')"
