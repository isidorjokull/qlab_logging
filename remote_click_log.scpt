-- |-----------------------------------------------------------------------|
-- |  REMOTE CLICK LOGGER                                	  	 |
-- |  Change IDENTIFIER below to label this cue trigger  	 |
-- |-----------------------------------------------------------------------|

set IDENTIFIER to "REMOTE-A"

-- Pad a string to a fixed width
on padRight(str, width)
	set str to str as string
	repeat while (length of str) < width
		set str to str & " "
	end repeat
	return str
end padRight


tell application id "com.figure53.QLab.5"
	tell front workspace
		
		set activeCueList to q name of current cue list
		
		set lastGroup to "none"
		set theCues to active cues
		repeat with i from 1 to count of theCues
			set c to item i of theCues
			if q type of c is "Group" then
				set lastGroup to q name of c
			end if
		end repeat
		
		set t to (current date)
		set dateStr to ((year of t) as string) & "-" & ¬
			text -2 thru -1 of ("0" & (month of t as integer as string)) & "-" & ¬
			text -2 thru -1 of ("0" & (day of t as string))
		set timeStr to text -2 thru -1 of ("0" & (hours of t as string)) & ":" & ¬
			text -2 thru -1 of ("0" & (minutes of t as string)) & ":" & ¬
			text -2 thru -1 of ("0" & (seconds of t as string))
		
		set logLine to "[" & timeStr & "] " & my padRight(IDENTIFIER, 10) & " | show: " & my padRight(activeCueList, 16) & " | cue: " & lastGroup
		
		log logLine
		
	end tell
end tell

set LOG_FILE to POSIX file ("/Users/isidor/Desktop/qlab_remote_log_" & dateStr & ".txt")

try
	set fileRef to open for access LOG_FILE with write permission
	write (logLine & linefeed) as «class utf8» to fileRef starting at eof
	close access fileRef
on error errMsg
	try
		close access LOG_FILE
	end try
	log "? Log write failed: " & errMsg
end try
