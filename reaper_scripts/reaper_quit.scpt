-- |-----------------------------------------------------------------------|
-- |  SHOW QUIT — QLab cue to save and quit REAPER at end of day          |
-- |-----------------------------------------------------------------------|

set pythonScript to "/Users/rkhus/Documents/qlab_logging/reaper_scripts/reaper_osc.py"

do shell script "python3 " & pythonScript & " 40026" --File: Save project
delay 1
do shell script "python3 " & pythonScript & " 40004" --File: Quit REAPER
