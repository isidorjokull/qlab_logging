#!/usr/bin/env python3
"""
Shared OSC action sender for REAPER.
Usage as CLI:  python3 reaper_osc.py <ACTION_ID>
Usage as module:  from reaper_osc import send_action
"""

import socket
import sys

HOST = "127.0.0.1"
PORT = 8000


def _pad(data: bytes) -> bytes:
    while len(data) % 4 != 0:
        data += b"\x00"
    return data


def build_osc_string(address: str, value: str) -> bytes:
    addr = _pad(address.encode("utf-8") + b"\x00")
    types = b",s\x00\x00"
    val = _pad(value.encode("utf-8") + b"\x00")
    return addr + types + val


def send_osc_string(address: str, value: str) -> None:
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(build_osc_string(address, value), (HOST, PORT))
    sock.close()


def send_action(action_id: str) -> None:
    send_osc_string("/action", action_id)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <ACTION_ID>", file=sys.stderr)
        print("Examples:", file=sys.stderr)
        print("  1013  - Transport: Record", file=sys.stderr)
        print("  1016  - Transport: Stop", file=sys.stderr)
        print("  40042 - Transport: Go to start of project", file=sys.stderr)
        print("  40026 - File: Save project", file=sys.stderr)
        print("  40004 - File: Quit REAPER", file=sys.stderr)
        sys.exit(1)
    send_action(sys.argv[1])