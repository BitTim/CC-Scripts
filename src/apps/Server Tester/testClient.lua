-- ================================
--  testClient.lua
-- --------------------------------
--  Client to test 
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

local comlib = require("/lib/comlib")

-- --------------------------------
--  Configurable Properties
-- --------------------------------

local modemSide = "back"

-- --------------------------------
--  Constants
-- --------------------------------

local title = "Test Client"
local version = "v1.0"

-- --------------------------------
--  Internal Properties
-- --------------------------------

local sModem = nil





term.clear()
term.setCursorPos(1, 1)

sModem = comlib.open(modemSide)

while true do
    local input = read()

end