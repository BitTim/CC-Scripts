-- ================================
--  loglib.lua
-- --------------------------------
--  Library for logging to a
--  monitor / to the screen
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Local Functions
-- --------------------------------

-- Set title of shell
local function setTitle(title, version)
    term.setTextColor(colors.yellow)
    term.clear()
    term.setCursorPos(1, 1)
    print(title.." "..version)
    term.setTextColor(colors.lightGray)
end








-- --------------------------------
--  Functions
-- --------------------------------

local M = {}

-- Initialize library
function M.init(title, version, scale, noMon)
    noMon = noMon or false
    
    setTitle(title, version)

    local mon = peripheral.find("monitor")
    if mon and not noMon then
        mon.setTextScale(scale)
        term.redirect(mon)
        setTitle(title, version)
    end
end

-- Logging message with tag and time
function M.log(tag, msg)
    local logStr = "<" .. os.time() .. "> [" .. tag .. "]: " .. msg
    print(logStr)
end

return M