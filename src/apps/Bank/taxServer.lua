-- ================================
--  taxServer.lua
-- --------------------------------
--  A server to send a TAX request
--  periodically to the bank
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

local comlib = require("/lib/comlib")
local loglib = require("/lib/loglib")
local dnslib = require("/lib/dnslib")

-- --------------------------------
--  Configurable Properties
-- --------------------------------

local modemSide = "top"
local serverDomain = "bank.test"

local taxInterval = "30"
-- local taxInterval = "604800"        -- Interval for applying taxes (604800 Seconds = 1 Week)

-- --------------------------------
--  Constants
-- --------------------------------

local title = "Tax Server"
local version = "v2.0"

-- --------------------------------
--  Internal Properties
-- --------------------------------

local sModem = nil
local serverAddress = nil
local taxTimer = nil








-- --------------------------------
--  Main Program
-- --------------------------------

sModem = comlib.open(modemSide)                                 -- Create Secure Modem
loglib.init(title, version, 0.5)                                -- Initialize LogLib
loglib.log("Address", comlib.getAddress())                      -- Print Address
dnslib.init(sModem)												-- Initialize DNSLib
serverAddress = dnslib.lookup(serverDomain)						-- Get server address
taxTimer = os.startTimer(taxInterval)							-- Start tax timer
loglib.log("Init", "Started tax timer")

--Main Loop
while true do
	local e, c = os.pullEvent()

	if e == "timer" and c == taxTimer then
		loglib.log("Main", "Tax timer completed, sending request")
		comlib.sendRequest(sModem, serverAddress, "TAX", {})
		taxTimer = os.startTimer(taxInterval)
		loglib.log("Main", "Restarted tax timer")
	end
end
