-- qlab_remote_marker.lua
-- Reads all marker files from /tmp/qlab_markers/ and inserts named markers
-- Triggered via OSC from QLab's send_reaper_marker.py

local MARKER_DIR = "/tmp/qlab_markers"

local handle = io.popen('ls -1 "' .. MARKER_DIR .. '"/*.marker 2>/dev/null')
if handle then
    local files = handle:read("*a")
    handle:close()
    if files and #files > 0 then
        for path in files:gmatch("[^\r\n]+") do
            local f = io.open(path, "r")
            if f then
                local name = f:read("*a")
                f:close()
                os.remove(path)
                if #name > 0 then
                    name = name:gsub("%s+$", "")
                    local pos = reaper.GetPlayPosition()
                    reaper.AddProjectMarker2(0, false, pos, 0, name, -1, 0)
                end
            end
        end
    end
end