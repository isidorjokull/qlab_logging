-- |-----------------------------------------------------------------------|
-- |  SHOW STOP — QLab cue to stop recording and save the project         |
-- |-----------------------------------------------------------------------|

set pythonScript to "~/git/qlab_logging/reaper_osc.py"

do shell script "python3 " & pythonScript & " 1016"
do shell script "python3 " & pythonScript & " 40026"