-- ================================
--  controller.lua
-- --------------------------------
--  Script for controlling Essentia
--  Valves and reading stored amount
--  of essentia in jars
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

local servedAspects = {}
local nbtPeripheralTags = {}
local outputSide = "back"
local modemSide = "top"

-- --------------------------------
--  Constants
-- --------------------------------

local title = "Essentia Controller"
local version = "v1.0"

-- --------------------------------
--  Internal Properties
-- --------------------------------

local nbtPeripherals = {}
local sModem = nil








-- --------------------------------
--  Local Functions
-- --------------------------------

-- Wrap all NBT Peripherals
local function wrapNBTPeripherals()
    for i = 1, #nbtPeripheralTags do
        nbtPeripherals[i] = peripheral.wrap(nbtPeripheralTags[i])
    end
end

-- Convert aspect name to local ID
local function getLocalID(aspect)
    local localID = 0

    for i = 1, #servedAspects do
        if servedAspects[i] == aspect then localID = i end
    end

    return localID
end

-- Sends a redstone pulse to a bundled cable on the output side on the specified channel
local function sendPulse(id)
    local rid = 2 ^ (id - 1)
    redstone.setBundledOutput(outputSide, rid)
    sleep(0.1)
    restone.setBundledOutput(outputSide, 0)

    log("SendPulse", "Setting redstone output to: " .. id)
end








-- --------------------------------
--  Request Handlers
-- --------------------------------

-- Handler for FLOW request
local function flow(s, p)
    local lid = getLocalID(p.contents.aspect)
    log("Flow", "Converted ID to local ID: " .. p.contents.aspect .. " -> " .. lid)

    if lid ~= 0 then
        sendPulse(lid)
        sleep(3)
        comlib.sendResponse(s, p.head, "OK", nil)
    else
        comlib.sendResponse(s, p.head, "FAIL", nil)
    end

    loglib.log("Flow", "Released 5 essentia of aspect: " .. p.contents.aspect .. " (Local ID: " .. lid .. ")")
end

-- Handler for PROBE request
local function probe(s, p)
    local lid = getLocalID(p.contents.aspect)
    loglib.log("Probe", "Converted ID to local ID: " .. p.contents.aspect .. " -> " .. lid)

    if lid ~= 0 then
        if nbtPeripherals[lid].has_nbt() then
            local nbt = nbtPeripherals.read_nbt()
            local nbtAspect, nbtAmount = nbt.Aspect, nbt.Amount
		
			comlib.sendResponse(s, p.head, "OK", {aspect = nbtAspect, amount = nbtAmount})
        else
			comlib.sendResponse(s, p.head, "FAIL", nil)
		end
    else
		comlib.sendResponse(s, p.head, "FAIL", nil)
	end
end








-- --------------------------------
--  Main Program
-- --------------------------------

sModem = comlib.open(modemSide) -- Create Secure Modem
loglib.init(title, version) -- Initialize LogLib
loglib.log("Address", comlib.getAddress()) -- Print Address

-- Main Loop
while true do
    -- Receive and decoserialize packet
    loglib.log("Main", "Receiving packet...")
    local s, msg = sModem.receive()
    local p = textutils.unserialize(msg)

    loglib.log("Main", "Received packet with header: " .. p.head)

    -- Check if packet header corresponds to a request
    if p.head == "FLOW" then
        flow(s, p)

    elseif p.head == "PROBE" then
        probe(s, p)
    end
end