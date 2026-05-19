# Agents

## Project Overview

QLab + REAPER integration system for logging remote clicker presses with timestamps to text files and REAPER project markers. Includes automated show setup/teardown.

## Architecture

```
QLab workspace
  └─ reaper_setup.scpt           → copy template → open .rpp → delay 5.5s → System Events frontmost QLab
  └─ reaper_recording_start.scpt → 41804 go to end → 1013 record → log "Loading show"
  └─ reaper_recording_stop.scpt  → 40667 stop+save → 40043 go to end → 40026 save → log "Show stop"
  └─ reaper_quit.scpt            → 40026 save → delay 1s → 40004 quit
  └─ remote_click_log.scpt       → [time] remote / cue list / SELECTED_CUE name → text file
  └─ remote_click_marker.scpt    → [time] remote / cue list / SELECTED_CUE name → Python bridge → Lua script → REAPER marker

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
│   ├── send_reaper_marker.py     writes marker queue, triggers Lua action
│   ├── reaper_setup.scpt          copies template, opens new .rpp, activates QLab
│   ├── reaper_recording_start.scpt goes to end of project, starts recording
│   ├── reaper_recording_stop.scpt stops recording, saves
│   └── reaper_quit.scpt          saves, quits REAPER
├── qlab_query.py                  OSC bridge — queries QLab for selected cue name
├── remote_click_log.scpt          logs [time] remote | cue list | SELECTED_CUE name to logs/qlab_remote_log_*.txt
├── remote_click_marker.scpt      builds [HH:MM:SS] remote | cue list | SELECTED_CUE name, triggers REAPER marker
├── qlab_remote_marker.lua        REAPER ReaScript (installed once into REAPER Scripts folder)
└── reaper_temp/
    └── reaper_temp.RPP           REAPER template (tracks must be pre-armed)
```

## Path Convention

All AppleScripts use absolute paths targeting `/Users/rkhus/Documents/qlab_logging` (the show machine). When installing on a new system, search for this string and replace with the new path.

`reaper_osc.py` exports `MARKER_DIR = "/tmp/qlab_markers"` as a constant. `send_reaper_marker.py` imports it from there.

`reaper_setup.scpt` uses the absolute path for `RECORD_DIR`. After opening REAPER, it waits 5.5 seconds then uses `tell application "System Events" to set frontmost of process "QLab" to true` to return focus to QLab.

## Key Design Decisions

- **Queue bridge**: marker names go into unique files in `/tmp/qlab_markers/` (timestamp + UUID) to avoid race conditions on rapid clicks. REAPER Lua processes all pending files on each trigger.
- **Go to end before recording**: `reaper_recording_start.scpt` sends 41804 (go to end) before 1013 (record) so the playhead stays at the end of the last recording, preventing overwrites on restart.
- **Setup and recording are separate**: `reaper_setup.scpt` does NOT auto-start recording. `reaper_recording_start.scpt` is a separate QLab cue for starting/restarting.
- **REAPER action IDs**: 41804 (go to end), 1013 (record), 40667 (stop + save all recorded media), 40043 (go to end of project), 40026 (save), 40004 (quit). All sent via `reaper_osc.py` over UDP port 8000.
- **Lua `AddProjectMarker2` arg 7**: use `0` (not `false`) for the color parameter.
- **`GetPlayPosition()` not `GetCursorPosition()`**: Lua markers land at the live recording position.

## Installing on a New Machine

1. Copy the repo
2. Copy `qlab_remote_marker.lua` to REAPER Scripts folder
3. In REAPER Actions, load the Lua script and copy its command ID into `send_reaper_marker.py` line 8 (`REAPER_ACTION_ID`)
4. Search all `.scpt` files for `/Users/rkhus/Documents/qlab_logging` and replace with the new path
5. Update `MARKER_DIR` in `reaper_osc.py` and `qlab_remote_marker.lua` if using a different temp path
6. Configure REAPER OSC on port 8000 with "allow binding messages to actions" checked
7. Verify tracks are armed for recording in the REAPER template

## Paths That Must Be Updated Per System

- `reaper_scripts/reaper_setup.scpt` line 6: `RECORD_DIR`
- `reaper_scripts/reaper_recording_start.scpt` line 5: Python script path + log file path
- `reaper_scripts/reaper_recording_stop.scpt` line 5: Python script path + log file path
- `reaper_scripts/reaper_quit.scpt` line 5: Python script path
- `remote_click_marker.scpt`: path to `send_reaper_marker.py`
- `remote_click_log.scpt`: log file path
- `armed_marker.scpt`: log file path
- `reaper_scripts/send_reaper_marker.py`: fallback path (auto-resolves when both .py files are in same directory)
- `reaper_scripts/reaper_osc.py` line 13: `MARKER_DIR`
- `qlab_remote_marker.lua` line 5: `MARKER_DIR`

## Reading QLab Workspace Files

To inspect or extract data from `qlab_logging_test.qlab5` (cue names, numbers, types, AppleScript source, colors, UIDs), use the skill at `~/.claude/skills/reading-qlab-files/SKILL.md`. It contains a complete Python decoder for the doubly-nested NSKeyedArchive format QLab 5 uses.

## AppleScript Coding Rules

- Use `tell application id "com.figure53.QLab.5"` for all QLab AppleScript calls
- To get the current cue selection, use a dedicated `SELECTED_CUE` cue in the workspace whose name is set to track selection: `set selectedGroup to q name of cue "SELECTED_CUE"` — more reliable than reading `selected` from the workspace, which reflects UI focus
- Use `delay 0.5` between OSC actions to give REAPER time to process
- To bring QLab to front after opening an external app, use `tell application "System Events" to set frontmost of process "QLab" to true`
- When calling external shell scripts that open apps (e.g. `open .rpp`), add a delay before restoring QLab focus

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

Both `remote_click_log.scpt` and `remote_click_marker.scpt` read `q name of current cue list` and `q name of cue "SELECTED_CUE"` to identify what's active. Duplicate and adjust `remoteName` per operator.