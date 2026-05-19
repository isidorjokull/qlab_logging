# QLab + REAPER Remote Click Logging

Logs remote clicker presses with timestamps to both a text file and REAPER project markers. Automated show setup and teardown included.

## Files

| File | Purpose |
|---|---|
| **`reaper_scripts/`** | REAPER-related scripts (AppleScript + Python) |
| `reaper_scripts/reaper_osc.py` | Shared OSC sender — all REAPER communication goes through here |
| `reaper_scripts/send_reaper_marker.py` | Writes marker name to queue, triggers REAPER via `reaper_osc.py` |
| `reaper_scripts/reaper_setup.scpt` | QLab AppleScript — creates new recording session from template |
| `reaper_scripts/reaper_recording_start.scpt` | QLab AppleScript — starts/restarts recording at end of project, logs show start |
| `reaper_scripts/reaper_recording_stop.scpt` | QLab AppleScript — stops recording, saves, logs show stop |
| `reaper_scripts/reaper_quit.scpt` | QLab AppleScript — saves and quits REAPER |
| **`qlab_remote_marker.lua`** | REAPER ReaScript (installed once into REAPER's Scripts folder) |
| `remote_click_log.scpt` | QLab AppleScript — logs timestamp + cue list + `SELECTED_CUE` name to text file |
| `remote_click_marker.scpt` | QLab AppleScript — logs + adds named marker in REAPER |
| `armed_marker.scpt` | QLab AppleScript — appends `- ARMED` to the last line of today's log file |

`remote_click_log.scpt` and `remote_click_marker.scpt` share identical QLab query logic. They differ only in output: one writes to a text file, the other also inserts a REAPER marker. Both read the name of a dedicated `SELECTED_CUE` cue to identify what's active.

## Architecture

```
QLab cue system:

Show start (one-time per show):
  reaper_scripts/reaper_setup.scpt
    → cp template → open .rpp → delay 5.5s → System Events: frontmost QLab

Start/restart recording:
  reaper_scripts/reaper_recording_start.scpt
    → reaper_scripts/reaper_osc.py 41804 (go to end of project)
    → reaper_scripts/reaper_osc.py 1013 (start recording)
    → logs "[time] -- Loading show: <cue list> --" to logs/qlab_remote_log_*.txt

Remote press:
  remote_click_log.scpt    → SELECTED_CUE name → logs/qlab_remote_log_*.txt
  remote_click_marker.scpt → SELECTED_CUE name → send_reaper_marker.py → reaper_osc.py ACTION_ID
                                 → REAPER: qlab_remote_marker.lua → named marker
                                (each press gets a unique file in /tmp/qlab_markers/)
  armed_marker.scpt        → appends " - ARMED" to last line of today's log file

Show end:
  reaper_scripts/reaper_recording_stop.scpt
    → reaper_scripts/reaper_osc.py 40667 (stop + save all recorded media)
    → reaper_scripts/reaper_osc.py 40043 (go to end of project)
    → reaper_scripts/reaper_osc.py 40026 (save project)
    → logs "[time] -- Show stop --" to logs/qlab_remote_log_*.txt
  reaper_scripts/reaper_quit.scpt
    → reaper_scripts/reaper_osc.py 40026 (save) → reaper_scripts/reaper_osc.py 40004 (quit)
```

---

## One-time Installation

### 1. REAPER OSC Setup

1. Open REAPER → **Preferences** → **Control Surfaces**
2. Click **Add** → select **OSC**
3. Configure:
   - **Mode**: Local port (receive only / both)
   - **Local port**: `8000`
   - Check **Allow binding messages to REAPER actions and FX learn**
4. Click **OK**

### 2. Install REAPER Lua Script

1. Copy `qlab_remote_marker.lua` to your REAPER scripts folder:

   ```bash
   cp qlab_remote_marker.lua ~/Library/Application\ Support/REAPER/Scripts/
   ```

2. In REAPER, press `?` to open the **Actions** window
3. Click **New action** → **Load ReaScript** → select `qlab_remote_marker.lua`
4. Find the action in the list, right-click → **Copy selected action command ID**
5. Paste the command ID into `reaper_scripts/send_reaper_marker.py` line 7 (replace `_RSxxxxxxxxxx`)

   Example: if you copied `00340_qlab_remote_marker`:
   ```python
   REAPER_ACTION_ID = "_RS00340_qlab_remote_marker"
   ```

### 3. Create the logs directory

```bash
mkdir -p /Users/rkhus/Documents/qlab_logging/logs
```

---

## QLab Setup (per-show)

### Recording session

1. Open your QLab workspace
2. Add cues at the start of your show:

   | QLab cue | Script | When |
   |---|---|---|
   | Setup recording | `reaper_scripts/reaper_setup.scpt` | Once before the show starts |
   | Start recording | `reaper_scripts/reaper_recording_start.scpt` | Start/restart recording |
   | Stop recording | `reaper_scripts/reaper_recording_stop.scpt` | After the show ends |
   | Close REAPER | `reaper_scripts/reaper_quit.scpt` | End of day |

3. In the group that your MIDI clickers trigger, add cues as needed:

   | QLab cue | Script | What it does |
   |---|---|---|
   | Log only | `remote_click_log.scpt` | Writes timestamp to text file |
   | Log + marker | `remote_click_marker.scpt` | Logs + adds REAPER marker |
   | Armed marker | `armed_marker.scpt` | Appends `- ARMED` to last log line |

4. Add a `SELECTED_CUE` Script cue to your workspace. Its **name** (not number) should be updated to reflect the currently active cue/scene — other scripts read `q name of cue "SELECTED_CUE"` to identify what was active at press time.

---

## REAPER Action IDs

Used across all scripts via `reaper_osc.py`:

| ID | Action | Used by |
|---|---|---|
| `41804` | Transport: Go to end of project | `reaper_recording_start.scpt` |
| `1013` | Transport: Record | `reaper_recording_start.scpt` |
| `40667` | Transport: Stop (save all recorded media) | `reaper_recording_stop.scpt` |
| `40043` | Transport: Go to end of project | `reaper_recording_stop.scpt` |
| `40026` | File: Save project | `reaper_recording_stop.scpt`, `reaper_quit.scpt` |
| `40004` | File: Quit REAPER | `reaper_quit.scpt` |

---

## Configuration

### Template and recording path

In `reaper_scripts/reaper_setup.scpt`:

```applescript
set RECORD_DIR to "/Users/rkhus/Documents/qlab_logging/reaper_temp"
set TEMPLATE_FILE to "reaper_temp.RPP"
```

Your REAPER template (`.RPP` file) should have tracks pre-armed for recording.

### Log file location

All log scripts write to `/Users/rkhus/Documents/qlab_logging/logs/qlab_remote_log_YYYY-MM-DD.txt`.

### OSC port

In `reaper_scripts/reaper_osc.py`:

```python
PORT = 8000
```

Make sure this matches the port set in REAPER → Preferences → Control Surfaces → OSC.

### Paths that change on a new system

When installing on a different machine, search for `/Users/rkhus/Documents/qlab_logging` and replace it with the correct path. Affected files:

- **`reaper_scripts/reaper_setup.scpt`** — `RECORD_DIR`
- **`reaper_scripts/reaper_recording_start.scpt`** — Python script path + log file path
- **`reaper_scripts/reaper_recording_stop.scpt`** — Python script path + log file path
- **`reaper_scripts/reaper_quit.scpt`** — Python script path
- **`remote_click_marker.scpt`** — path to `send_reaper_marker.py`
- **`remote_click_log.scpt`** — log file path
- **`armed_marker.scpt`** — log file path
- **`reaper_scripts/reaper_osc.py`** — `MARKER_DIR` (if changing the marker queue location)
- **`qlab_remote_marker.lua`** — `MARKER_DIR` (must match `reaper_osc.py`)

Also copy `qlab_remote_marker.lua` to the new machine's REAPER Scripts folder and update the command ID in `send_reaper_marker.py`.

---

## How it works

### `reaper_scripts/reaper_osc.py`
The shared OSC engine for the entire system. Can be used from the command line:

```bash
python3 reaper_scripts/reaper_osc.py 1013    # Start recording
python3 reaper_scripts/reaper_osc.py 40667   # Stop recording (save all media)
python3 reaper_scripts/reaper_osc.py 40026   # Save project
python3 reaper_scripts/reaper_osc.py 40004   # Quit REAPER
```

Or imported as a Python module:

```python
from reaper_osc import send_action
send_action("1013")
```

### Show setup (`reaper_scripts/reaper_setup.scpt`)
1. Duplicates the REAPER template and timestamps the copy as `show_YYYY-MM-DD_HH-MM.rpp`
2. Opens the new project in REAPER
3. Waits 5.5 seconds, then uses System Events to bring QLab back to the foreground

### Start recording (`reaper_scripts/reaper_recording_start.scpt`)
1. Sends the playhead to the end of the project (so recording continues from the last stop point)
2. Starts recording
3. Logs `[HH:MM:SS] -- Loading show: <cue list> --` to today's log file

### Stop recording (`reaper_scripts/reaper_recording_stop.scpt`)
1. Stops recording and saves all recorded media (`40667`)
2. Moves the playhead to end of project (`40043`)
3. Saves the project (`40026`)
4. Logs `[HH:MM:SS] -- Show stop --` to today's log file

### Log file (`remote_click_log.scpt`)
- Reads the active cue list name and the name of the `SELECTED_CUE` cue
- Writes to `logs/qlab_remote_log_YYYY-MM-DD.txt`:

```
[14:32:15] Rasmus | Main list        | LT cue: Intro scene
```

### Armed marker (`armed_marker.scpt`)
- Appends ` - ARMED` to the last line of today's log file:

```
[14:32:15] Rasmus | Main list        | LT cue: Intro scene - ARMED
```

### REAPER markers (`remote_click_marker.scpt`)
- Reads cue list name and `SELECTED_CUE` name, builds a marker string: `[14:32:15] R| Main list | cue: Intro scene`
- Calls `reaper_scripts/send_reaper_marker.py` which writes to `/tmp/qlab_markers/` (one unique file per press) then sends OSC to trigger the REAPER Lua action
- The Lua script reads all pending files from the queue, inserts each named marker at the current playhead position, then deletes the processed files

---

## Troubleshooting

### Marker not appearing in REAPER
1. Verify the Lua script action is loaded: REAPER → Actions → search `qlab_remote_marker`
2. Confirm the command ID in `reaper_scripts/send_reaper_marker.py` matches what you copied
3. Check REAPER OSC port is `8000` and "allow binding messages to actions" is checked
4. Check for stale marker files: `ls /tmp/qlab_markers/` — if files accumulate, the Lua script isn't running
5. Test: `python3 reaper_scripts/send_reaper_marker.py "test"` — a `.marker` file should appear briefly then disappear

### Show setup not opening the file
- Make sure REAPER is running before firing `reaper_scripts/reaper_setup.scpt`
- Verify `RECORD_DIR` and `TEMPLATE_FILE` in `reaper_scripts/reaper_setup.scpt` are correct
- The `open` command uses your system's default app for `.rpp` files — ensure REAPER is set as the default

### Check what REAPER is receiving
- The OSC messages are fire-and-forget UDP. If something isn't working, add a delay in the AppleScript:
  ```applescript
  delay 1
  do shell script "python3 /Users/rkhus/Documents/qlab_logging/reaper_scripts/reaper_osc.py 1013"
  ```

### Reset the marker queue
```bash
rm -rf /tmp/qlab_markers/
```
