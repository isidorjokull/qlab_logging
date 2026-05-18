#!/usr/bin/env python3
"""
QLab OSC query bridge — gets the name of the currently selected cue.
Sends a plain-text OSC query to QLab and returns the selected cue name.
Usage: qlab_query.py
Output: the selected cue name (or "none" on error)
"""
import socket, json, time, sys

QLAB_HOST = "169.254.170.122"
RECV_PORT = 53001
SEND_PORT = 53000
TIMEOUT = 0.5


def query_selected_name() -> str:
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        sock.bind(("0.0.0.0", RECV_PORT))
        sock.settimeout(TIMEOUT)
        sock.sendto(b'/cue/selected/listName\x00\x00,\x00\x00\x00', (QLAB_HOST, SEND_PORT))
        while True:
            data, _ = sock.recvfrom(4096)
            msg = data.decode("utf-8", errors="replace")
            if '/cue/selected/listName' in msg or '/cue/selected' in msg:
                try:
                    json_start = msg.index("{")
                    reply = json.loads(msg[json_start:].rstrip("\x00 \r\n"))
                    if reply.get("status") == "ok":
                        data = reply.get("data")
                        if isinstance(data, list) and data:
                            return data[0]
                        elif isinstance(data, str) and data:
                            return data
                except (ValueError, KeyError, IndexError):
                    pass
    except socket.timeout:
        return "none"
    except Exception:
        return "none"
    finally:
        sock.close()
    return "none"


if __name__ == "__main__":
    result = query_selected_name()
    print(result)
