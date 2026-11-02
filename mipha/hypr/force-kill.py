#!/usr/bin/env python3
"""Confirm before killing the process behind the focused Hyprland window."""

import fcntl
import json
import os
from pathlib import Path
import signal
import subprocess


def windows(command):
    return json.loads(subprocess.check_output(["hyprctl", "-j", command], text=True))


def main():
    # Repeated shortcut presses should not stack confirmation dialogs.
    with (Path(os.environ["XDG_RUNTIME_DIR"]) / "hypr-force-kill.lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return

        target = windows("activewindow")
        pid = target.get("pid", 0)
        address = target.get("address")
        if not isinstance(pid, int) or pid <= 1 or not address:
            return

        # A pidfd keeps this tied to the same process even if its PID is reused.
        try:
            process = os.pidfd_open(pid)
        except ProcessLookupError:
            return
        try:
            name = " ".join((target.get("class") or target.get("title") or "app").split())[:80]
            choice = subprocess.run(
                ["wofi", "--dmenu", "--prompt", f"Force kill {name}? Unsaved work will be lost.",
                 "--width", "760", "--height", "180", "--lines", "2"],
                input="Cancel\nForce kill\n", text=True, capture_output=True,
            )
            if choice.returncode != 0 or choice.stdout.strip() != "Force kill":
                return

            # The original window must still belong to this process.
            if not any(window.get("address") == address and window.get("pid") == pid
                       for window in windows("clients")):
                return
            try:
                signal.pidfd_send_signal(process, signal.SIGKILL)
            except ProcessLookupError:
                pass
        finally:
            os.close(process)


if __name__ == "__main__":
    main()
