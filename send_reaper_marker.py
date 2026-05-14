#!/usr/bin/env python3
"""
Sends a named marker to REAPER via OSC.
Usage: send_reaper_marker.py <marker_name>
"""
import sys
from reaper_osc import send_action

REAPER_ACTION_ID = "_RSxxxxxxxxxx"
TEMP_FILE = "/tmp/qlab_reaper_marker.txt"


def main():
    if len(sys.argv) < 2:
        print("Usage: send_reaper_marker.py <marker_name>", file=sys.stderr)
        sys.exit(1)

    with open(TEMP_FILE, "w") as f:
        f.write(sys.argv[1])

    send_action(REAPER_ACTION_ID)


if __name__ == "__main__":
    main()