-- qlab_remote_marker.lua
-- Reads marker name from temp file and inserts it at current position
-- Triggered via OSC from QLab's send_reaper_marker.py

local TEMP_FILE = "/tmp/qlab_reaper_marker.txt"

local f = io.open(TEMP_FILE, "r")
if f then
    local name = f:read("*a")
    f:close()
    name = name:gsub("%s+$", "")
    if #name > 0 then
        os.remove(TEMP_FILE)
        local pos = reaper.GetPlayPosition()
        reaper.AddProjectMarker2(0, false, pos, 0, name, -1, 0)
    end
end
