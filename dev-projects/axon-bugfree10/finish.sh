#!/usr/bin/env bash
# axon-bugfree10 — run-once finisher (HUMAN executes this).
# Does: attended grant (human hatch) -> verify -> push branch -> open MR.
# Self-guards: aborts if the grant isn't authorized or the tree isn't committed/clean.
set -uo pipefail
REPO=/home/arturcastiel/projects/new-axon/axon
BRANCH=fix/axon-bugfree10-kernel
cd "$REPO"

echo "==================================================================="
echo " axon-bugfree10 finisher"
echo "==================================================================="

# --- 1. GRANT (attended human act; AXON_HUMAN_GRANT is the sanctioned human hatch) ---
echo "[1/5] granting interactive autonomy (attended)..."
AXON_HUMAN_GRANT=1 python3 tools/autonomous_mode.py off >/dev/null 2>&1 || true
AXON_HUMAN_GRANT=1 python3 tools/autonomous_mode.py on \
  --repo artur.castiel-tno/axon \
  --ops commit,push,pr-create,merge-squash \
  --mode interactive \
  --note "attended owner grant: axon-bugfree10" >/dev/null

AUTH=$(python3 tools/autonomous_mode.py check --op push --repo artur.castiel-tno/axon \
       | python3 -c "import sys,json;print(json.load(sys.stdin).get('authorized'))")
echo "      push authorized: $AUTH"
[ "$AUTH" = "True" ] || { echo "ABORT: grant not authorized (push=$AUTH)"; exit 1; }

# --- 2. SAFETY: tree must be clean & committed (no red/uncommitted push) ---
echo "[2/5] checking working tree is clean + committed..."
DIRTY=$(git status --porcelain | grep -vE 'workspace/scheduler/cron.json' | wc -l)
if [ "$DIRTY" -ne 0 ]; then
  echo "ABORT: uncommitted changes present — AXON has not finished commit+green yet."
  git status --short | head; exit 1
fi
if [ -f /tmp/axon-bugfree10/GREEN_OK ]; then
  echo "      green marker present: $(cat /tmp/axon-bugfree10/GREEN_OK)"
else
  echo "ABORT: green marker /tmp/axon-bugfree10/GREEN_OK missing — AXON has not confirmed all-green."
  exit 1
fi

# --- 3. PUSH ---
echo "[3/5] pushing $BRANCH -> origin..."
git push -u origin "$BRANCH"

# --- 4. OPEN MR ---
echo "[4/5] opening merge request..."
if command -v glab >/dev/null 2>&1; then
  glab mr create --source-branch "$BRANCH" --target-branch main \
    --title "axon-bugfree10: 91 confirmed bugs (kernel v1.1.13 gated + tools)" \
    --description "Study(HR-swarm)+deep-plan+fix. Kernel floor changes are owner-gated (v1.1.13, blessed). See dev-projects/axon-bugfree10/RESUME.md." --yes || \
  git push -o merge_request.create -o merge_request.target=main origin "$BRANCH"
else
  git push -o merge_request.create -o merge_request.target=main origin "$BRANCH"
fi

# --- 5. DONE ---
echo "[5/5] pushed + MR opened."
echo "==================================================================="
echo " NEXT: review the MR on ci.tno.nl and MERGE it (the kernel portion"
echo "       is never grant-delegable, so the merge click is deliberately yours)."
echo " Then tell AXON: 'merged' — and it runs code-dev audit."
echo "==================================================================="
