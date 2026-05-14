#!/usr/bin/env python3
"""
Sends a named marker to REAPER via OSC.
Usage: send_reaper_marker.py <marker_name>
"""
import sys, os, time, uuid

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from reaper_osc import send_action, MARKER_DIR
REAPER_ACTION_ID = "_RS029a8bb47393fd930d3565e3798911ec978b0105"


def main():
    if len(sys.argv) < 2:
        print("Usage: send_reaper_marker.py <marker_name>", file=sys.stderr)
        sys.exit(1)

    os.makedirs(MARKER_DIR, exist_ok=True)
    marker_file = os.path.join(MARKER_DIR, f"{time.time_ns()}_{uuid.uuid4().hex[:8]}.marker")

    with open(marker_file, "w") as f:
        f.write(sys.argv[1])

    send_action(REAPER_ACTION_ID)


if __name__ == "__main__":
    main()
