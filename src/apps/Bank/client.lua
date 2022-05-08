-- ================================
--  client.lua
-- --------------------------------
--  Boilerplate code for
--  client scripts
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

local comlib = require("/lib/comlib")
local dnslib = require("/lib/dnslib")

-- --------------------------------
--  Configurable Properties
-- --------------------------------

local modemSide = "top"
local serverDomain = "example.com"

-- --------------------------------
--  Constants
-- --------------------------------

local title = "Client"
local version = "v2.0"

-- --------------------------------
--  Internal Properties
-- --------------------------------

local sModem = nil
local serverAddress = nil







-- --------------------------------
--  Main Program
-- --------------------------------

sModem = comlib.open(modemSide)                                 -- Create Secure Modem
if dnslib.init() == -1 then                                     -- Initialize DNSLib
    print("Could not connect to DNS Server")
    return -1
end

serverAddress = dnslib.lookup(serverDomain)                     -- Lookup Address of Server

--Main Loop
while true do

end