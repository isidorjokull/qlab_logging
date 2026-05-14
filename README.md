# QLab + REAPER Remote Click Logging

Logs remote clicker presses with timestamps to both a text file and REAPER project markers. Automated show setup and teardown included.

## Files

| File | Purpose |
|---|---|
| `reaper_osc.py` | Shared OSC sender — all REAPER communication goes through here |
| `send_reaper_marker.py` | Writes marker name to temp file, triggers REAPER via `reaper_osc.py` |
| `qlab_remote_marker.lua` | REAPER ReaScript — reads temp file, inserts named marker |
| `remote_click_log.scpt` | QLab AppleScript — logs timestamp + cue info to text file |
| `remote_click_marker.scpt` | QLab AppleScript — adds named marker in REAPER |
| `reaper_setup.scpt` | QLab AppleScript — creates new recording session from template |
| `reaper_start.scpt` | QLab AppleScript — starts/restarts recording at end of project |
| `show_stop.scpt` | QLab AppleScript — stops recording and saves |
| `show_quit.scpt` | QLab AppleScript — saves and quits REAPER |

## Architecture

```
QLab cue system (all via ~/git/qlab_logging/ scripts):

Show start (one-time per show):
  reaper_setup.scpt
    → cp template → open .rpp

Start/restart recording:
  reaper_start.scpt
    → reaper_osc.py 41804 (go to end of project)
    → reaper_osc.py 1013 (start recording)

Remote press:
  remote_click_log.scpt      → Desktop/qlab_remote_log_YYYY-MM-DD.txt
  remote_click_marker.scpt   → send_reaper_marker.py → reaper_osc.py ACTION_ID
                                 → REAPER: qlab_remote_marker.lua → named marker

Show end:
  show_stop.scpt → reaper_osc.py 1016 (stop) → reaper_osc.py 40026 (save)
  show_quit.scpt → reaper_osc.py 40026 (save) → reaper_osc.py 40004 (quit)
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
   cp ~/git/qlab_logging/qlab_remote_marker.lua ~/Library/Application\ Support/REAPER/Scripts/
   ```

2. In REAPER, press `?` to open the **Actions** window
3. Click **New action** → **Load ReaScript** → select `qlab_remote_marker.lua`
4. Find the action in the list, right-click → **Copy selected action command ID**
5. Paste the command ID into `send_reaper_marker.py` line 5 (replace `_RSxxxxxxxxxx`)

   Example: if you copied `00340_qlab_remote_marker`:
   ```python
   REAPER_ACTION_ID = "_RS00340_qlab_remote_marker"
   ```

---

## QLab Setup (per-show)

### Recording session

1. Open your QLab workspace
2. Add cues at the start of your show:

   | QLab cue | Script | When |
   |---|---|---|
   | Setup recording | `reaper_setup.scpt` | Once before the show starts |
   | Start recording | `reaper_start.scpt` | Start/restart recording |
   | Stop recording | `show_stop.scpt` | After the show ends |
   | Close REAPER | `show_quit.scpt` | End of day |

3. In the group that your MIDI clickers trigger, add two cues:

   | QLab cue | Script | What it does |
   |---|---|---|
   | Log only | `remote_click_log.scpt` | Writes timestamp to text file |
   | Log + marker | `remote_click_marker.scpt` | Logs + adds REAPER marker |

### Configure the identifier

Each `.scpt` file has an `IDENTIFIER` at the top. Change it per cue:

```applescript
set IDENTIFIER to "REMOTE-A"
set IDENTIFIER to "REMOTE-B"
```

---

## REAPER Action IDs

Used across all scripts via `reaper_osc.py`:

| ID | Action | Used by |
|---|---|---|
| `41804` | Transport: Go to end of project | `reaper_start.scpt` |
| `1013` | Transport: Record | `reaper_start.scpt` |
| `1016` | Transport: Stop | `show_stop.scpt`, `show_quit.scpt` |
| `40026` | File: Save project | `show_stop.scpt`, `show_quit.scpt` |
| `40004` | File: Quit REAPER | `show_quit.scpt` |

---

## Configuration

### Template and recording path

In `reaper_setup.scpt`, adjust these to match your setup:

```applescript
set RECORD_DIR to "~/git/qlab_logging/reaper_temp"
set TEMPLATE_FILE to "reaper_temp.RPP"
```

Your REAPER template (`.RPP` file) should have tracks pre-armed for recording so it can open and immediately start capturing.

### Log file location

In `remote_click_log.scpt` line 47:

```applescript
set LOG_FILE to POSIX file ("/Users/isidor/Desktop/qlab_remote_log_" & dateStr & ".txt")
```

### OSC port

In `reaper_osc.py` line 8:

```python
PORT = 8000
```

Make sure this matches the port set in REAPER → Preferences → Control Surfaces → OSC.

---

## How it works

### `reaper_osc.py`
The shared OSC engine for the entire system. Can be used from the command line:

```bash
python3 ~/git/qlab_logging/reaper_osc.py 1013    # Start recording
python3 ~/git/qlab_logging/reaper_osc.py 1016    # Stop recording
python3 ~/git/qlab_logging/reaper_osc.py 40026   # Save project
python3 ~/git/qlab_logging/reaper_osc.py 40004   # Quit REAPER
```

Or imported as a Python module:

```python
from reaper_osc import send_action
send_action("1013")
```

### Show setup (`reaper_setup.scpt`)
1. Duplicates the REAPER template file and timestamps the copy as `show_YYYY-MM-DD_HH-MM.rpp`
2. Opens the new project in the running REAPER instance

### Start recording (`reaper_start.scpt`)
1. Sends the playhead to the end of the project (so recording continues from the last stop point, not from the beginning)
2. Starts recording

### Log file (`remote_click_log.scpt`)
- Runs inside QLab via AppleScript
- Gets current time and active cue list name
- Finds the parent group cue that triggered
- Writes to `~/Desktop/qlab_remote_log_YYYY-MM-DD.txt`:

```
[14:32:15] REMOTE-A  | show: Show Cue List   | cue: Click Group A
```

### REAPER markers (`remote_click_marker.scpt`)
- AppleScript builds a marker name: `[14:32:15] REMOTE-A`
- Calls `send_reaper_marker.py` which writes the name to `/tmp/qlab_reaper_marker.txt` then sends OSC to trigger the REAPER Lua action
- The Lua script reads the temp file, inserts the named marker at the current playhead position, then deletes the temp file

---

## Troubleshooting

### Marker not appearing in REAPER
1. Verify the Lua script action is loaded: REAPER → Actions → search `qlab_remote_marker`
2. Confirm the command ID in `send_reaper_marker.py` matches what you copied
3. Check REAPER OSC port is `8000` and "allow binding messages to actions" is checked
4. Test the temp file: run `python3 ~/git/qlab_logging/send_reaper_marker.py "test"` — it should appear briefly at `/tmp/qlab_reaper_marker.txt`, then disappear when REAPER processes it

### Show setup not opening the file
- Make sure REAPER is running before firing `reaper_setup.scpt`
- Verify `RECORD_DIR` and `TEMPLATE_FILE` paths in `reaper_setup.scpt` are correct
- The `open` command uses your system's default app for `.rpp` files — ensure REAPER is set as the default

### Check what REAPER is receiving
- The OSC messages are fire-and-forget UDP. If something isn't working, add a delay in the AppleScript:
  ```applescript
  delay 1
  do shell script "python3 ~/git/qlab_logging/reaper_osc.py 1013"
  ```

### Reset the marker temp file
```bash
rm -f /tmp/qlab_reaper_marker.txt
```