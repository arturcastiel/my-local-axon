#!/usr/bin/env bash
# O2-stranger-test.sh — record ONE cold-start stranger session into E:stranger-test-run.
# Run this WITH a real NON-AUTHOR present (TNO colleague / junior dev / AI researcher).
# You (the author) must NOT coach during the session — that bias is exactly what this gate removes.
# Read-only except for appending the observation record. No git, no kernel, no build.
set -uo pipefail

REPO="/home/arturcastiel/projects/new-axon/axon"
REC="$REPO/my-axon/memory/episodic/stranger-test-run.md"
mkdir -p "$(dirname "$REC")"
[ -f "$REC" ] || printf '# E:stranger-test-run — cold-start observation log (masterplan #13 gate)\n\n' > "$REC"

cat <<'EOF'
────────────────────────────────────────────────────────────
  O2 · COLD-START STRANGER TEST   (masterplan #13 — the gate)
────────────────────────────────────────────────────────────
  PROTOCOL (set up, then stay SILENT):
   1. Sit a NON-AUTHOR at a fresh terminal. Screen-record if you can.
   2. Tell them ONLY: "This is an OS for AI agents. Boot it and try to
      get it to do one useful thing." Hand them nothing else.
   3. They start from:  "Read startup.md and boot AXON"   (or open the menu).
   4. DO NOT coach, hint, or answer questions. Watch + time silently.
   5. Note: time-to-first-task · first confusion point · abandonment point.
   6. Stop when they complete a real task OR give up (~10-15 min cap).
────────────────────────────────────────────────────────────
EOF

read -rp "Press ENTER when the session is FINISHED to log it (Ctrl-C to cancel)... " _

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
read -rp "Stranger's role (e.g. TNO colleague / junior dev / AI researcher): " role
read -rp "Did they reach a first REAL task?  (y/n): " reached
read -rp "Time-to-first-task (e.g. 3m20s, or n/a if never): " ttft
read -rp "FIRST point of confusion (one line): " confusion
read -rp "Abandonment point (or 'completed' if they finished): " abandon
read -rp "Most useful verbatim quote from them: " quote
echo "Free notes (finish with a single '.' on its own line):"
notes=""
while IFS= read -r line; do [ "$line" = "." ] && break; notes+="$line"$'\n'; done

{
  echo "## stranger-test · $ts"
  echo "- role: ${role:-?}"
  echo "- reached_first_task: ${reached:-?}"
  echo "- time_to_first_task: ${ttft:-?}"
  echo "- first_confusion: ${confusion:-?}"
  echo "- abandonment: ${abandon:-?}"
  echo "- quote: \"${quote:-}\""
  echo "- notes:"
  printf '%s' "$notes" | sed 's/^/    /'
  echo "---"
} >> "$REC"

echo
echo "✓ Logged to E:stranger-test-run → $REC"
echo "  Sessions recorded so far: $(grep -c '^## stranger-test' "$REC")"
echo "  Tell AXON 'stranger done' → it reads this, folds the findings into the plan,"
echo "  and unblocks (or kills) the onboarding tier (PR-014) based on what was observed."
