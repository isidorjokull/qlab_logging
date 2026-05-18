# Agents

## Project Overview

QLab + REAPER integration system for logging remote clicker presses with timestamps to text files and REAPER project markers. Includes automated show setup/teardown.

## Architecture

```
QLab workspace
  └─ reaper_recording_start.scpt → open .rpp → delay 2s → activate QLab
  └─ reaper_recording_stop.scpt  → 1016 stop → 40026 save
  └─ reaper_quit.scpt            → 40026 save → delay 1s → 40004 quit
  └─ remote_click_log.scpt       → [time] cue list / group → text file
  └─ remote_click_marker.scpt    → [time] cue list / group → Python bridge → Lua script → REAPER marker

Python bridge (reaper_scripts/)
  └─ reaper_osc.py         → MARKER_DIR constant, OSC sender
  └─ send_reaper_marker.py → writes .marker file, triggers REAPER Lua action

REAPER (once)
  └─ qlab_remote_marker.lua → reads /tmp/qlab_markers/, inserts named markers
```

## File Map

```
qlab_logging/
├── reaper_scripts/
│   ├── reaper_osc.py              shared OSC engine; imported by all Python callers
│   ├── send_reaper_marker.py      writes marker queue, triggers Lua action
│   ├── reaper_setup.scpt          copies template, opens new .rpp, activates QLab
│   ├── reaper_recording_start.scpt goes to end of project, starts recording
│   ├── reaper_recording_stop.scpt stops recording, saves
│   └── reaper_quit.scpt           saves, quits REAPER
├── remote_click_log.scpt          logs timestamp + cue list + group to ~/Desktop/qlab_remote_log_*.txt
├── remote_click_marker.scpt      builds [HH:MM:SS] cue list / group, triggers REAPER marker
├── qlab_remote_marker.lua        REAPER ReaScript (installed once into REAPER Scripts folder)
└── reaper_temp/
    └── reaper_temp.RPP           REAPER template (tracks must be pre-armed)
```

## Path Convention

All AppleScripts use absolute paths (`/Users/isidor/git/qlab_logging`). When installing on a new system, search for this string and replace.

`reaper_osc.py` exports `MARKER_DIR = "/tmp/qlab_markers"` as a constant. `send_reaper_marker.py` imports it from there.

`reaper_setup.scpt` uses the absolute path for `RECORD_DIR`. After opening REAPER, it waits 2 seconds and re-activates QLab so focus returns to the controller.

## Key Design Decisions

- **Queue bridge**: marker names go into unique files in `/tmp/qlab_markers/` (timestamp + UUID) to avoid race conditions on rapid clicks. REAPER Lua processes all pending files on each trigger.
- **Go to end before recording**: `reaper_recording_start.scpt` sends 41804 (go to end) before 1013 (record) so the playhead stays at the end of the last recording, preventing overwrites on restart.
- **Setup and recording are separate**: `reaper_setup.scpt` does NOT auto-start recording. `reaper_recording_start.scpt` is a separate QLab cue for starting/restarting.
- **REAPER action IDs**: 41804 (go to end), 1013 (record), 1016 (stop), 40026 (save), 40004 (quit). All sent via `reaper_osc.py` over UDP port 8000.
- **Lua `AddProjectMarker2` arg 7**: use `0` (not `false`) for the color parameter.
- **`GetPlayPosition()` not `GetCursorPosition()`**: Lua markers land at the live recording position.

## Installing on a New Machine

1. Copy the repo
2. Copy `qlab_remote_marker.lua` to REAPER Scripts folder
3. In REAPER Actions, load the Lua script and copy its command ID into `send_reaper_marker.py` line 8 (`REAPER_ACTION_ID`)
4. Search all `.scpt` files for `/Users/isidor/git/qlab_logging` and replace with the new path
5. Update `MARKER_DIR` in `reaper_osc.py` and `qlab_remote_marker.lua` if using a different temp path
6. Configure REAPER OSC on port 8000 with "allow binding messages to actions" checked
7. Verify tracks are armed for recording in the REAPER template

## Paths That Must Be Updated Per System

- `reaper_scripts/reaper_setup.scpt` line 6: `RECORD_DIR`
- `remote_click_marker.scpt` line 32: Python script path
- `remote_click_log.scpt` line 47: log output directory
- `reaper_scripts/reaper_recording_start.scpt` line 5: Python script path
- `reaper_scripts/reaper_recording_stop.scpt` line 5: Python script path
- `reaper_scripts/reaper_quit.scpt` line 5: Python script path
- `reaper_scripts/send_reaper_marker.py` line 8: fallback path (auto-resolves when both .py files are in same directory)
- `reaper_scripts/reaper_osc.py` line 13: `MARKER_DIR`
- `qlab_remote_marker.lua` line 5: `MARKER_DIR`

## AppleScript Coding Rules

- Always use `delay 0.01` before reading the active cue list to ensure the most recent group cue has fired
- Use `tell application id "com.figure53.QLab.5"` for all QLab AppleScript calls
- Use `delay 0.5` before sending OSC actions to give REAPER time to load the project
- Use `tell application id "com.figure53.QLab.5" to activate` to bring QLab to front (not `activate id "..."` which causes a compile error)
- When calling external shell scripts that open apps (e.g. `open .rpp`), add a delay and re-activate QLab after

## Python Coding Rules

- Keep standard library only — no `pip install` dependencies
- Keep scripts separate from AppleScript; Python lives in its own `.py` file
- `reaper_osc.py` is the single OSC engine — import `send_action` from it everywhere
- Export shared constants (`MARKER_DIR`) from `reaper_osc.py` and import them in other scripts
- Never use `sys.real_argv` — it doesn't exist in Python; use `__file__` instead

## QLab Cue Mapping

| QLab cue type | Script | Trigger |
|---|---|---|
| Setup | `reaper_setup.scpt` | Once before show |
| Start recording | `reaper_recording_start.scpt` | Start/restart recording |
| Stop recording | `reaper_recording_stop.scpt` | End of show |
| Close REAPER | `reaper_quit.scpt` | End of day |
| Log only | `remote_click_log.scpt` | Each remote press |
| Log + REAPER marker | `remote_click_marker.scpt` | Each remote press |

Both `remote_click_log.scpt` and `remote_click_marker.scpt` share identical QLab query logic (delay → cue list → last group). Copy and use per group/cuelist.