-- |-----------------------------------------------------------------------|
-- |  ARM MARKER — QLab script cue to mark last log line as armed          |
-- |  Appends " - ARMED" to the last line of today's log file             |
-- |-----------------------------------------------------------------------|
delay 0.1
set t to (current date)
set dateStr to ((year of t) as string) & "-" & ¬
	text -2 thru -1 of ("0" & (month of t as integer as string)) & "-" & ¬
	text -2 thru -1 of ("0" & (day of t as string))
set logPath to "/Users/rkhus/Documents/qlab_logging/logs/qlab_remote_log_" & dateStr & ".txt"
try
	do shell script "python3 -c \"
import sys
log = sys.argv[1]
try:
    with open(log, 'r') as f:
        lines = f.read().splitlines()
    if lines:
        lines[-1] += ' - ARMED'
    with open(log, 'w') as f:
        f.write('\\n'.join(lines) + '\\n')
except FileNotFoundError:
    pass
except Exception as e:
    print(e, file=sys.stderr)
    sys.exit(1)
\" " & quoted form of logPath
on error errMsg
	log "! ARMED marker failed: " & errMsg
end try
