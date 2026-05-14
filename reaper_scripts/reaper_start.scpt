-- |-----------------------------------------------------------------------|
-- |  SHOW RECORD — QLab cue to start/re-start recording                   |
-- |  Assumes REAPER project is already open (from reaper_setup)            |
-- |-----------------------------------------------------------------------|
set pythonScript to "~/git/qlab_logging/reaper_scripts/reaper_osc.py"

delay 0.5
do shell script "python3 " & pythonScript & " 41804"
delay 0.5
do shell script "python3 " & pythonScript & " 1013"