#!/usr/bin/env python3
"""keep_awake — nudge the Windows cursor so the host doesn't sleep mid-task.

Personal dev tooling (lives in my-axon, never the public axon repo). AXON
starts this at the beginning of an autonomous multi-PR run and stops it when
it hands control back to the user.

WSL2 note: sleep happens on the WINDOWS HOST, not inside WSL, so a WSL-local
cursor move wouldn't help. This calls powershell.exe to move the REAL Windows
cursor 1px and back every `interval` seconds — registered as user activity by
Windows, which resets the idle/sleep timer. Net cursor displacement is zero.

Usage:
  python3 keep_awake.py [--interval 60] [--quiet]
Stop with SIGINT/SIGTERM (or just kill the background process).
"""
from __future__ import annotations

import argparse
import datetime
import shutil
import subprocess
import sys
import time

# PowerShell: jiggle the cursor 1px right then back. Add-Type loads the
# WinForms assembly that exposes Cursor.Position.
_PS = (
    "Add-Type -AssemblyName System.Windows.Forms;"
    "$p=[System.Windows.Forms.Cursor]::Position;"
    "[System.Windows.Forms.Cursor]::Position="
    "New-Object System.Drawing.Point(($p.X+1),$p.Y);"
    "Start-Sleep -Milliseconds 40;"
    "[System.Windows.Forms.Cursor]::Position="
    "New-Object System.Drawing.Point($p.X,$p.Y)"
)


def _nudge() -> bool:
    try:
        r = subprocess.run(["powershell.exe", "-NoProfile", "-Command", _PS],
                           capture_output=True, text=True, timeout=15)
        return r.returncode == 0
    except (OSError, subprocess.TimeoutExpired):
        return False


def main() -> None:
    ap = argparse.ArgumentParser(description="Keep the Windows host awake.")
    ap.add_argument("--interval", type=float, default=60.0,
                    help="seconds between cursor nudges (default 60)")
    ap.add_argument("--quiet", action="store_true")
    args = ap.parse_args()

    if shutil.which("powershell.exe") is None:
        print("keep-awake: powershell.exe not found — cannot reach Windows host",
              file=sys.stderr)
        sys.exit(1)

    if not args.quiet:
        print(f"keep-awake: started (interval={args.interval}s) — ctrl-c to stop",
              flush=True)
    ticks = 0
    try:
        while True:
            ok = _nudge()
            ticks += 1
            if not args.quiet:
                ts = datetime.datetime.now().strftime("%H:%M:%S")
                state = "nudged" if ok else "nudge-FAILED"
                print(f"keep-awake: {state} cursor @ {ts} (tick {ticks})",
                      flush=True)
            time.sleep(args.interval)
    except KeyboardInterrupt:
        if not args.quiet:
            print(f"keep-awake: stopped after {ticks} tick(s)", flush=True)


if __name__ == "__main__":
    main()
