-- |-----------------------------------------------------------------------|
-- |  REMOTE CLICK MARKER for REAPER                                      |
-- |  Logs a named marker in a REAPER recording at the press time         |
-- |-----------------------------------------------------------------------|

set remoteName to "R" --Remote name

on padRight(str, width) --Keeps log string variable at a fixed length
	set str to str as string
	if (length of str) > width then
		return text 1 thru width of str
	end if
	repeat while (length of str) < width
		set str to str & " "
	end repeat
	return str
end padRight

tell application id "com.figure53.QLab.5" to tell front workspace
	set activeCueList to q name of current cue list
	set selectedGroup to q name of cue "SELECTED_CUE"
end tell

set t to (current date)
set timeStr to text -2 thru -1 of ("0" & (hours of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (minutes of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (seconds of t as string))

set markerName to "[" & timeStr & "] " & remoteName & "| " & activeCueList & " | cue: " & my padRight(selectedGroup, 20)

do shell script "python3 /Users/rkhus/Documents/qlab_logging/reaper_scripts/send_reaper_marker.py " & quoted form of markerName
