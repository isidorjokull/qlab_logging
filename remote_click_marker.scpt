-- |-----------------------------------------------------------------------|
-- |  REMOTE CLICK MARKER for REAPER                                      |
-- |  Change IDENTIFIER below to label this remote                        |
-- |  Installs a named marker in a REAPER recording at the press time     |
-- |-----------------------------------------------------------------------|

set IDENTIFIER to "REMOTE-A"

set t to (current date)
set timeStr to text -2 thru -1 of ("0" & (hours of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (minutes of t as string)) & ":" & ¬
	text -2 thru -1 of ("0" & (seconds of t as string))

set markerName to "[" & timeStr & "] " & IDENTIFIER

do shell script "python3 /Users/isidor/git/qlab_logging/send_reaper_marker.py " & quoted form of markerName
