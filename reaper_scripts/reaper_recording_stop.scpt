-- |-----------------------------------------------------------------------|
-- |  SHOW STOP — QLab cue to stop recording and save the project         |
-- |-----------------------------------------------------------------------|

set pythonScript to "/Users/rkhus/Documents/qlab_logging/reaper_scripts/reaper_osc.py"

delay 0.1
do shell script "python3 " & pythonScript & " 40667" --Transport: Stop (save all recorded media)
delay 0.1
do shell script "python3 " & pythonScript & " 40043" --Transport: Go to end of project
delay 0.1
do shell script "python3 " & pythonScript & " 40026" --Save project


set t to (current date)
set dateStr to ((year of t) as string) & "-" & ¬
	text -2 thru -1 of ("0" & (month of t as integer as string)) & "-" & ¬
	text -2 thru -1 of ("0" & (day of t as string))
set timeStr to text -2 thru -1 of ("0" & (hours of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (minutes of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (seconds of t as string))

set logLine to "[" & timeStr & "] -- Show stop --"

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
