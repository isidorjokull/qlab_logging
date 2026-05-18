-- |-----------------------------------------------------------------------|
-- |  REMOTE CLICK LOGGER                                                |
-- |  Logs timestamp + active cue list + last group to a text file        |
-- |-----------------------------------------------------------------------|

on padRight(str, width)
	set str to str as string
	repeat while (length of str) < width
		set str to str & " "
	end repeat
	return str
end padRight


set remoteName to "Rasmus"

tell application id "com.figure53.QLab.5"
	tell front workspace
		set activeCueList to q name of current cue list
		set sel to selected
		if (count sel) > 0 then
			set selectedGroup to q name of first item of sel
		else
			set selectedGroup to ""
		end if
	end tell
end tell

set t to (current date)
set dateStr to ((year of t) as string) & "-" & ¬
	text -2 thru -1 of ("0" & (month of t as integer as string)) & "-" & ¬
	text -2 thru -1 of ("0" & (day of t as string))
set timeStr to text -2 thru -1 of ("0" & (hours of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (minutes of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (seconds of t as string))

set logLine to "[" & timeStr & "] " & my padRight(remoteName, 7) & "| " & my padRight(activeCueList, 20) & " | cue: " & my padRight(selectedGroup, 10)

log logLine

set LOG_FILE to POSIX file ("/Users/isidor/git/qlab_logging/logs/qlab_remote_log_" & dateStr & ".txt")

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