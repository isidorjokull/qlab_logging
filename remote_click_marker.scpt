-- |-----------------------------------------------------------------------|
-- |  REMOTE CLICK MARKER for REAPER                                      |
-- |  Logs a named marker in a REAPER recording at the press time         |
-- |-----------------------------------------------------------------------|

tell application id "com.figure53.QLab.5"
	tell front workspace

		delay 0.01

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
		set timeStr to text -2 thru -1 of ("0" & (hours of t as string)) & ":" & ¬
			text -2 thru -1 of ("0" & (minutes of t as string)) & ":" & ¬
			text -2 thru -1 of ("0" & (seconds of t as string))

		set markerName to "[" & timeStr & "] " & activeCueList & " / " & lastGroup

	end tell
end tell

do shell script "python3 /Users/isidor/git/qlab_logging/reaper_scripts/send_reaper_marker.py " & quoted form of markerName
