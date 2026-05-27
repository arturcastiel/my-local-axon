#!/usr/bin/env bash
# Run all consistency checks for axon-master.
# Exit 0 only if all pass.
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
fail=0
echo "[dag]      $(python3 "$DIR/_dag-check.py" 2>&1)" || fail=1
python3 "$DIR/_dag-check.py" >/dev/null 2>&1 || fail=1
echo "[schema]   $(python3 "$DIR/_schema-check.py" 2>&1 | tail -1)"
python3 "$DIR/_schema-check.py" >/dev/null 2>&1 || fail=1
echo "[workflow] $DIR/_workflow-audit.md (regenerate manually until PR-0 ships gen script)"
exit "$fail"
