-- |-----------------------------------------------------------------------|
-- |  SHOW RECORD — QLab cue to start/re-start recording                   |
-- |  Assumes REAPER project is already open (from reaper_setup)            |
-- |-----------------------------------------------------------------------|
set pythonScript to "/Users/rkhus/Documents/qlab_logging/reaper_scripts/reaper_osc.py"

tell application id "com.figure53.QLab.5" to tell front workspace
	set activeCueList to q name of current cue list
end tell

do shell script "python3 " & pythonScript & " 41804" --Tempo envelope: Set display range to current project min/max bpm
delay 0.5
do shell script "python3 " & pythonScript & " 1013" --Transport: Record

set t to (current date)
set dateStr to ((year of t) as string) & "-" & ¬
	text -2 thru -1 of ("0" & (month of t as integer as string)) & "-" & ¬
	text -2 thru -1 of ("0" & (day of t as string))
set timeStr to text -2 thru -1 of ("0" & (hours of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (minutes of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (seconds of t as string))

set logLine to "[" & timeStr & "] -- Loading show: " & activeCueList & " --"

set LOG_FILE to POSIX file ("/Users/rkhus/Documents/qlab_logging/logs/qlab_remote_log_" & dateStr & ".txt")

try
	open for access LOG_FILE with write permission
	set fileRef to result
	write (logLine & linefeed) as «class utf8» to fileRef starting at eof
	close access fileRef
on error errMsg
	try
		close access result
	end try
	log "? Log write failed: " & errMsg
end try
