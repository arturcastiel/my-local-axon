#!/usr/bin/env bash
#
# publish-and-backup.sh — the two remaining tails, in one call
# ---------------------------------------------------------------------------
#   A. PUSH CODEBASE   git push origin main   (the 2 closeout commits)  [+ tags]
#   B. BACKUP MY-AXON  commit + push my-axon/  (this session's tracking work)
#
# SAFE: every push/commit shows what it will do and asks y/N.
#   --dry-run   preview, change nothing
#   --yes       auto-confirm every step
# You run it → you stay the actor for the codebase push (human-only by rule).
# ---------------------------------------------------------------------------
set -euo pipefail

REPO="${AXON_REPO:-/home/arturcastiel/projects/new-axon/axon}"
MYAXON="$REPO/my-axon"
TRAILER="Co-authored-by: AXON <axon@arturcastiel.github.io>"

DRY=0; AUTOYES=0
for a in "$@"; do case "$a" in
  --dry-run) DRY=1 ;; --yes|-y) AUTOYES=1 ;;
  -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
  *) echo "unknown arg: $a"; exit 2 ;;
esac; done

c(){ printf '\033[%sm%s\033[0m' "$1" "$2"; }
hdr(){ echo; echo "$(c '1;36' "━━ $* ━━")"; }
info(){ echo "  $*"; }
warn(){ echo "  $(c '1;33' "⚠ $*")"; }
ok(){ echo "  $(c '1;32' "✓ $*")"; }
run(){ if [ "$DRY" = 1 ]; then echo "  $(c '2' "[dry-run] $*")"; else eval "$@"; fi; }
ask(){ [ "$AUTOYES" = 1 ] && { echo "  > $1 [auto-yes]"; return 0; }
       read -r -p "  $(c '1;35' "▶ $1 [y/N] ")" a; [[ "$a" =~ ^[Yy]$ ]]; }

echo "$(c '1;36' 'axon-rearm · publish-and-backup')  $([ "$DRY" = 1 ] && c '1;33' '(DRY-RUN)')"

# ── A · push the codebase ────────────────────────────────────────────────────
hdr "A · push codebase  →  origin/main"
cd "$REPO"
br="$(git branch --show-current)"
if [ "$br" != "main" ]; then warn "on '$br', not main — skipping codebase push."; else
  git fetch origin main --quiet 2>/dev/null || warn "fetch failed (offline?) — proceeding with local view."
  ahead="$(git rev-list --count origin/main..main 2>/dev/null || echo '?')"
  behind="$(git rev-list --count main..origin/main 2>/dev/null || echo '?')"
  if [ "$ahead" = 0 ]; then ok "already up to date with origin/main — nothing to push."
  else
    info "remote: $(git remote get-url origin)"
    info "ahead $ahead · behind $behind   — unpushed:"
    git log --oneline origin/main..main | sed 's/^/    /'
    [ "$behind" != 0 ] && [ "$behind" != '?' ] && warn "origin is ahead by $behind — consider 'git pull --rebase' first."
    warn "GitLab has no .gitlab-ci.yml yet (T1-cihost) → this push is UNGATED (crucible won't run)."
    if ask "git push origin main ($ahead commit/s)?"; then
      run "git push origin main"; ok "codebase pushed."
    else info "skipped codebase push."; fi
    if git tag --list 'archive/pre-prune/*' | grep -q .; then
      if ask "also push the archive/pre-prune/* restore tags?"; then
        run "git push origin \$(git tag --list 'archive/pre-prune/*')"; ok "tags pushed."
      else info "tags kept local."; fi
    fi
  fi
fi

# ── B · back up my-axon (the session's tracking work) ───────────────────────
hdr "B · backup my-axon  →  $(git -C "$MYAXON" remote get-url origin 2>/dev/null || echo 'origin')"
if [ ! -d "$MYAXON/.git" ]; then warn "my-axon is not a git repo — skipping."; else
  cd "$MYAXON"
  n="$(git status --short | wc -l | tr -d ' ')"
  if [ "$n" = 0 ]; then ok "my-axon clean — nothing to back up."
  else
    info "$n uncommitted file(s). axon-rearm changes:"
    git status --short | grep 'axon-rearm' | sed 's/^/    /' | head -20 || true
    other="$(git status --short | grep -vc 'axon-rearm' || true)"
    [ "${other:-0}" -gt 0 ] && info "(+ $other other my-axon file/s — logs, turns, etc.; all included in backup)"
    if ask "git add -A + commit + push my-axon?"; then
      run "git add -A"
      run "git commit -m 'axon-rearm: reconcile + loose-end closeout (DAG sync, _meta/branches/log, finish-loose-ends.sh)' -m '$TRAILER'"
      mb="$(git branch --show-current)"
      if ask "push my-axon to origin/$mb?"; then run "git push origin $mb"; ok "my-axon backed up + pushed."
      else ok "my-axon committed locally (not pushed)."; fi
    else info "skipped my-axon backup."; fi
  fi
fi

hdr "DONE"
cd "$REPO"
info "codebase: $(git rev-list --count origin/main..main 2>/dev/null || echo '?') commit/s ahead of origin/main"
info "my-axon : $(git -C "$MYAXON" status --short | wc -l | tr -d ' ') file/s still dirty"
echo "  $(c '1;32' 'Both tails handled. Re-run with --dry-run anytime to preview.')"
