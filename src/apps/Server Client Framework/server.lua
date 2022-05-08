-- ================================
--  server.lua
-- --------------------------------
--  Boilerplate code for
--  server scripts
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

local comlib = require("/lib/comlib")
local loglib = require("/lib/loglib")

-- --------------------------------
--  Configurable Properties
-- --------------------------------

local modemSide = "top"

-- --------------------------------
--  Constants
-- --------------------------------

local title = "Server"
local version = "v2.0"

-- --------------------------------
--  Internal Properties
-- --------------------------------

local sModem = nil








-- --------------------------------
--  Request Handlers
-- --------------------------------

local function req(s, p)

end








-- --------------------------------
--  Main Program
-- --------------------------------

sModem = comlib.open(modemSide)                                 -- Create Secure Modem
loglib.init(title, version, 0.5)                                -- Initialize LogLib
loglib.log("Address", comlib.getAddress())                      -- Print Address

--Main Loop
while true do
    --Receive Packet
    loglib.log("Main", "Receiving packet...")
    local s, msg = sModem.receive()
    local p = textutils.unserialize(msg)

    loglib.log("Main", "Received packet with header: " .. p.head)

    --Check Packet header
    if p.head == "" then
        req(s, p)
    end
end
