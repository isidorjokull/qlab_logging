-- |-----------------------------------------------------------------------|
-- |  SHOW STOP — QLab cue to stop recording and save the project         |
-- |-----------------------------------------------------------------------|

set pythonScript to "~/git/qlab_logging/reaper_scripts/reaper_osc.py"

delay 0.1
do shell script "python3 " & pythonScript & " 1016"
delay 0.1
do shell script "python3 " & pythonScript & " 40026"