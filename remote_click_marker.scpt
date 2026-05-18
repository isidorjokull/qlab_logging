-- |-----------------------------------------------------------------------|
-- |  REMOTE CLICK MARKER for REAPER                                      |
-- |  Logs a named marker in a REAPER recording at the press time         |
-- |-----------------------------------------------------------------------|

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
set timeStr to text -2 thru -1 of ("0" & (hours of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (minutes of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (seconds of t as string))

set markerName to "[" & timeStr & "] " & remoteName & "| " & activeCueList & " | cue: " & selectedGroup

do shell script "python3 /Users/isidor/git/qlab_logging/reaper_scripts/send_reaper_marker.py " & quoted form of markerName
