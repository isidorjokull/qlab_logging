-- |-----------------------------------------------------------------------|
-- |  REMOTE CLICK LOGGER                                                |
-- |  Logs timestamp + active cue list + last group to a text file        |
-- |-----------------------------------------------------------------------|

on padRight(str, width)
	set str to str as string
	if (length of str) > width then
		return text 1 thru width of str
	end if
	repeat while (length of str) < width
		set str to str & " "
	end repeat
	return str
end padRight

set remoteName to "Rasmus" --Remote name

tell application id "com.figure53.QLab.5" to tell front workspace
	set activeCueList to q name of current cue list
	set selectedGroup to q name of cue "SELECTED_CUE"
end tell

set t to (current date)
set dateStr to ((year of t) as string) & "-" & ¬
	text -2 thru -1 of ("0" & (month of t as integer as string)) & "-" & ¬
	text -2 thru -1 of ("0" & (day of t as string))
set timeStr to text -2 thru -1 of ("0" & (hours of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (minutes of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (seconds of t as string))

set logLine to "[" & timeStr & "] " & my padRight(remoteName, 7) & "| " & activeCueList & " | LT cue: " & my padRight(selectedGroup, 32) --LT cue = Last triggered cue

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
