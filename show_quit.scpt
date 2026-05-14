-- |-----------------------------------------------------------------------|
-- |  SHOW QUIT — QLab cue to save and quit REAPER at end of day          |
-- |-----------------------------------------------------------------------|

set pythonScript to "~/git/qlab_logging/reaper_osc.py"

do shell script "python3 " & pythonScript & " 40026"
delay 1
do shell script "python3 " & pythonScript & " 40004"