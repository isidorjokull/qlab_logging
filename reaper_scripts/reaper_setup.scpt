-- |-----------------------------------------------------------------------|
-- |  SHOW SETUP — QLab cue to set up a new recording session             |
-- |  Duplicates the REAPER template, opens it. Use show_record to start.   |
-- |-----------------------------------------------------------------------|

set RECORD_DIR to "/Users/isidor/git/qlab_logging/reaper_temp"
set TEMPLATE_FILE to "reaper_temp.RPP"

set t to (current date)
set dateStamp to ((year of t) as string) & "-" & ¬
    text -2 thru -1 of ("0" & (month of t as integer as string)) & "-" & ¬
    text -2 thru -1 of ("0" & (day of t as string)) & "_" & ¬
    text -2 thru -1 of ("0" & (hours of t as string)) & "-" & ¬
    text -2 thru -1 of ("0" & (minutes of t as string))

set newFile to "show_" & dateStamp & ".rpp"

do shell script "cp " & RECORD_DIR & "/" & TEMPLATE_FILE & " " & RECORD_DIR & "/" & newFile
do shell script "open " & RECORD_DIR & "/" & newFile