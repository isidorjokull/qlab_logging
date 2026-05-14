-- |-----------------------------------------------------------------------|
-- |  SHOW SETUP — QLab cue to set up a new recording session             |
-- |  Duplicates the REAPER template, opens it, and starts recording       |
-- |-----------------------------------------------------------------------|

set RECORD_DIR to "~/Documents/show_log/reaper_recordings"
set TEMPLATE_FILE to "reaper_temp.rpp"

set t to (current date)
set dateStamp to ((year of t) as string) & "-" & ¬
    text -2 thru -1 of ("0" & (month of t as integer as string)) & "-" & ¬
    text -2 thru -1 of ("0" & (day of t as string)) & "_" & ¬
    text -2 thru -1 of ("0" & (hours of t as string)) & "-" & ¬
    text -2 thru -1 of ("0" & (minutes of t as string))

set newFile to "show_" & dateStamp & ".rpp"
set pythonScript to "~/git/qlab_logging/reaper_osc.py"

do shell script "cp " & RECORD_DIR & "/" & TEMPLATE_FILE & " " & RECORD_DIR & "/" & newFile
do shell script "open " & RECORD_DIR & "/" & newFile

delay 1
do shell script "python3 " & pythonScript & " 40042"
delay 0.5
do shell script "python3 " & pythonScript & " 1013"